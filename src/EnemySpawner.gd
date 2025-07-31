extends Node2D

export(PackedScene) var enemy_scene
export var max_enemies := 5

onready var timer := $Timer
onready var spawn_point := $Position2D

var spawned_enemies := 0

func _ready():
	randomize()
	timer.start()

func _on_Timer_timeout():
	if spawned_enemies >= max_enemies:
		timer.stop()
		return

	if enemy_scene == null:
		print("Enemy scene not assigned!")
		return

	var enemy = enemy_scene.instance()
	enemy.position = spawn_point.position
	add_child(enemy)

	spawned_enemies += 1
