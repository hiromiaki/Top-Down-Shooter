extends Control

func _ready():
	var cursor_texture = preload("res://assets/stone-cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW)

func _on_playAgainbutton_pressed():
	GameManager.reset_game()
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()
