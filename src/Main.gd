extends Control

export(NodePath) var host_nodepath
export(NodePath) var port_nodepath
onready var host_node = get_node(host_nodepath)
onready var port_node = get_node(port_nodepath)

var ws = WebSocketClient.new()


var code = 0
var isHost = false

func _init():
	ws.connect("connection_established", self, "_client_connected")
	ws.connect("connection_error", self, "_client_disconnected")
	ws.connect("connection_closed", self, "_client_disconnected")
	ws.connect("server_close_request", self, "_client_close_request")
	ws.connect("data_received", self, "_client_received")

	ws.connect("peer_packet", self, "_client_received")
	ws.connect("peer_connected", self, "_peer_connected")
	ws.connect("connection_succeeded", self, "_client_connected", ["multiplayer_protocol"])
	ws.connect("connection_failed", self, "_client_disconnected")


func _client_close_request(code, reason):
	print("Close code: %d, reason: %s" % [code, reason])


func _peer_connected(id):
	print( "%s: Client just connected" % id)


func _exit_tree():
	ws.disconnect_from_host(1001, "Bye bye!")

func _process(_delta):
	if ws.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		match (code):
			0:
				if (Input.is_key_pressed(KEY_PAGEDOWN)):
					code+=1
			1:
				if (Input.is_key_pressed(KEY_PAGEUP)):
					code+=1
			2:
				if (Input.is_key_pressed(KEY_PAGEDOWN)):
					code+=1
			3:
				$Connect/PanelContainer/MarginContainer/VBoxContainer/isHost.show()
				isHost = true
	
		return
		
	ws.poll()
	
	
func _client_connected(protocol= ""):
	print( "Client just connected with protocol: %s" % protocol)
	ws.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)


func _client_disconnected(clean=true):
	print("Client just disconnected. Was clean: %s" % clean)

func _client_received(_p_id = 1):
	if not(isHost):
		var peer_id = ws.get_packet_peer()
		var packet = ws.get_packet()
		var data = bytes2var(packet)
		if typeof( data) == TYPE_DICTIONARY:
			$Laser.set_dot_data(data)
		else:
			print("MPAPI: From %s Data: %s" % [str(peer_id), bytes2var(packet)])


func connect_ws() -> void:
	var wshost = host_node.text
	var wsport = port_node.text
	var err = connect_to_url(wshost+":"+wsport)
	if err == OK:
		print("connected to: ",wshost+":"+wsport)
		$Laser.init(ws,isHost)
		$Connect.hide()
	else:
		print("cannot connect")
	
func connect_to_url(host):
	if ws.get_connection_status() != WebSocketClient.CONNECTION_DISCONNECTED:
		ws.disconnect_from_host(1000, "Bye bye!")
	return ws.connect_to_url(host,PoolStringArray(),true)
	
func disconnect_from_host():
	ws.disconnect_from_host(1000, "Bye bye!")
	

func send_data(data):
	ws.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)
	ws.set_target_peer(WebSocketClient.TARGET_PEER_BROADCAST)
	ws.put_packet(var2bytes(data))


func _on_isHost_pressed() -> void:
	isHost = not(isHost)
	$Connect/PanelContainer/MarginContainer/VBoxContainer/isHost.text = "isHost: "+str(isHost)


