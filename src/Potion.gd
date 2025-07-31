extends Area2D

onready var anim_player = $AnimationPlayer

func _ready():
	if anim_player.has_animation("idle"):
		anim_player.play("idle")

func _on_Potion_body_entered(body):
	if body.is_in_group("player"):
		body.heal(10)
		queue_free() # Remove potion after pickup
