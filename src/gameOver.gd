extends Control

# UI Labels
onready var total_score = $"total-score"
onready var total_wave = $"total-wave"
onready var enemy_kill = $"enemy-kill"


func _ready():
	# Optional: set custom cursor
	var cursor_texture = preload("res://assets/stone-cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW)

# Called from Player.gd when player dies
func show_stats():
	total_score.text = str(GameManager.score)
	total_wave.text = str(GameManager.current_wave)
	enemy_kill.text = str(GameManager.total_enemies_killed)

	# You can add more fields here if needed (like powerups used, time survived, etc.)

func _on_playAgainbutton_pressed():
	GameManager.reset()
	get_tree().reload_current_scene()
