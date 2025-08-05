extends KinematicBody2D

signal enemy_died  # Signal emitted when enemy dies

export var speed := 100
export var max_health := 3

var current_health := 0
var velocity = Vector2.ZERO
var random_direction = Vector2.ZERO
var is_hurt := false

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var anim_player = $AnimationPlayer
onready var coin_scene = preload("res://src/coin.tscn")
onready var point_label_scene = preload("res://src/PointLabel.tscn")
onready var game_manager = get_node("/root/GameManager")

func _ready():
	current_health = max_health

	if player == null or not is_instance_valid(player):
		random_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()

func _physics_process(delta):
	if current_health <= 0:
		return  # Stop movement if dead

	if is_hurt:
		return

	if is_instance_valid(player) and player.is_inside_tree():
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		velocity = random_direction * speed

	move_and_slide(velocity)
	rotation = 0

func _on_Area2D_body_entered(body):
	if body.name.begins_with("Bullet") or body.is_in_group("bullet"):
		take_damage(1)
		body.queue_free()

func take_damage(amount):
	if is_hurt or current_health <= 0:
		return

	current_health -= amount
	is_hurt = true

	if anim_player.has_animation("hurt"):
		anim_player.play("hurt")

	yield(get_tree().create_timer(0.3), "timeout")
	is_hurt = false

	if current_health <= 0:
		drop_coin()
		award_points()
		emit_signal("enemy_died")
		die()

func die():
	GameManager.add_enemy_kill() 
	queue_free()

func drop_coin():
	var coin = coin_scene.instance()
	get_parent().add_child(coin)
	coin.global_position = global_position

func award_points():
	var score = randi() % 50 + 1  # Random points: 1–100
	GameManager.add_score(score)

	
