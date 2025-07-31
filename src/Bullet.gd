extends Area2D

export var speed := 500
var direction := Vector2.ZERO

func _ready():
	$gun.play("shoot")
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group("enemy") or body.is_in_group("breakable"):
		if body.has_method("take_damage"):
			body.take_damage(1)
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
