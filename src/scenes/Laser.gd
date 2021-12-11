extends Control

var client

export(Vector2) var global_mouse_pos
var last_global_pos = Vector2()
var position_offset = Vector2(0,0)
var debug = true
var watchdog = 0
var is_active = false
var max_type = 5
var type = 0
onready var viewport_size = get_viewport_rect().size
onready var screen_size = OS.get_screen_size()
var is_host = false
var currentId =0


func _ready() -> void:
	hide()
	set_process(false)
	
func init(multiplayer_client,isHost):
	client = multiplayer_client
	is_host = isHost
	get_tree().get_root().set_transparent_background(true)
	show()
	set_process(true)
	if not(is_host):
		OS.window_size = Vector2(16,16)
		OS.window_resizable = false
		OS.window_borderless = true
		OS.set_window_always_on_top(true)
		position_offset = Vector2(8,8)

func _process(delta: float) -> void:
	if (is_host):
		viewport_size = get_viewport_rect().size
		if Input.is_action_just_pressed("click"):
			is_active = not(is_active)
			if is_active:
				type = 0
				show_type(0)
			else:
				type = max_type
				
		if is_active:
			global_mouse_pos = get_global_mouse_position()
		else:
			global_mouse_pos = Vector2.ZERO
		$Cursor.position = global_mouse_pos - position_offset
		
		if last_global_pos != global_mouse_pos:
			var data = {
				"pos":global_mouse_pos,
				"screen":viewport_size,
				"type":type
			}
			if type >125:
				type = 0
			client.put_var(data)
			last_global_pos = global_mouse_pos
		
func show_type(id = 0):
#	print(id)
	if currentId != id :
		currentId = id
		for i in $Cursor.get_children():
			i.hide()
		if id < $Cursor.get_child_count():
			$Cursor.get_child(id).show()
		else:
			print("error wrong id")
			$Cursor.get_child(0).show()
		
					
			
func set_dot_data(data):
#	print(position_offset)
	OS.window_position = (((data.pos)/data.screen) * screen_size) - position_offset
	if data.type == 255:
		get_tree().quit()
	else:
		show_type(data.type)

func _on_ChangeType_pressed() -> void:
	type +=1
	if type >= max_type and type < 128:
		type = 0
	show_type(type)
	last_global_pos += Vector2.ONE
	
func _on_Quit_pressed() -> void:
	type = 255
	last_global_pos += Vector2.ONE
