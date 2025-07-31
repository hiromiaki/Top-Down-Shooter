extends Area2D

export var value := 1

func _ready():
	visible = true
	z_index = 5

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("add_coin"):
			body.add_coin(value)
		queue_free()
