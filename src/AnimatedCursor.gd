extends Node2D  # Or Control, depending on your setup

func _ready():
	$AnimationPlayer.play("rotating")

func _process(delta):
	position = get_viewport().get_mouse_position()
