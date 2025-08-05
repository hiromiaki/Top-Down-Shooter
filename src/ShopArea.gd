extends Area2D

signal shop_opened
onready var anim_player = $AnimationPlayer
onready var label = $Label
var player_in_area = false
var current_player = null

func _ready():
	label.hide()
	anim_player.play("idle")

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("ui_accept"):  # Default: X key
		if current_player:
			emit_signal("shop_opened")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		current_player = body
		label.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		current_player = null
		label.hide()
