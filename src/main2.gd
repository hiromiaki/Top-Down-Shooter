extends Node2D

onready var game_over = $CanvasLayer/gameOver
onready var color_rect = $CanvasLayer/ColorRect

var cursor_texture = preload("res://assets/stone-cursor.png")

func _process(delta):
	color_rect.material.set_shader_param("time", OS.get_ticks_msec() / 1000.0)

	if game_over.visible:
		# Show the default system mouse cursor
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW)
	else:
		# Hide the cursor during gameplay
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
