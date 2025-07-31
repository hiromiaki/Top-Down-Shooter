extends StaticBody2D

export var max_hits := 3
var current_hits := 0

onready var sprite = $Sprite
onready var hitbox = $Area2D

func _ready():
	pass

func _on_body_entered(body):
	if body.name.begins_with("Bullet") or body.is_in_group("bullet"):
		take_damage(1)
		body.queue_free()

func take_damage(amount):
	current_hits += amount
	print("Wall hit! Current hits:", current_hits)
	if current_hits >= max_hits:
		queue_free()
