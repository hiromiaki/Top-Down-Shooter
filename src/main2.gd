extends Node2D

onready var game_over = $CanvasLayer/gameOver
onready var color_rect = $CanvasLayer/ColorRect
onready var shop_area = $ShopArea
onready var shop_ui = $Shop
onready var player = $Player
onready var countdown_timer = $CountdownTimer
onready var countdown_label = $CanvasLayer/CountdownLabel
onready var potion_timer = $PotionTimer

export(PackedScene) var EnemyScene
export(PackedScene) var PotionScene

var cursor_texture = preload("res://assets/stone-cursor.png")
var active_potion = null

var current_wave = 1
var enemies_per_wave = 3
var alive_enemies = 0
var countdown_time = 3
var is_game_over = false

func _ready():
	randomize()
	shop_area.connect("shop_opened", self, "_on_shop_opened")
	countdown_timer.connect("timeout", self, "_on_countdown_tick")
	potion_timer.connect("timeout", self, "_on_potion_timer_timeout")


	# Connect the player death signal
	if player.has_signal("player_died"):
		player.connect("player_died", self, "_on_player_died")

	start_countdown()

func is_area_occupied(position: Vector2, enemy_node: Node2D) -> bool:
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_point(position, 1, [enemy_node], 0xFFFFFFFF, true, true)
	return result.size() > 0


func _process(delta):
	color_rect.material.set_shader_param("time", OS.get_ticks_msec() / 1000.0)

	if is_game_over:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_shop_opened():
	shop_ui.open_shop(player)

func _on_potion_timer_timeout():
	if is_game_over:
		return
	
	# If a potion still exists, skip this spawn
	if is_instance_valid(active_potion):
		return

	var spawn_points = get_tree().get_nodes_in_group("potion_spawns")
	if spawn_points.empty():
		print("No potion spawn points!")
		return

	var spawn_point = spawn_points[randi() % spawn_points.size()]
	var potion = PotionScene.instance()
	potion.position = spawn_point.global_position
	add_child(potion)

	active_potion = potion

	# When potion is picked up or freed, clear reference
	if potion.has_signal("tree_exited"):
		potion.connect("tree_exited", self, "_on_potion_disappeared")

func _on_potion_disappeared():
	active_potion = null

func spawn_wave():
	if is_game_over:
		return

	var spawn_points = get_tree().get_nodes_in_group("enemy_spawns")
	if spawn_points.empty():
		print("No spawn points in 'enemy_spawns' group!")
		return

	spawn_enemies_staggered(spawn_points)

func spawn_enemies_staggered(spawn_points):
	for i in range(enemies_per_wave):
		if is_game_over:
			return

		var enemy = EnemyScene.instance()
		add_child(enemy)

		# Try up to 10 times to find a non-colliding spawn point
		var spawn_point = null
		for attempt in range(10):
			var candidate = spawn_points[randi() % spawn_points.size()]
			if not is_area_occupied(candidate.global_position, enemy):
				spawn_point = candidate
				break

		if spawn_point == null:
			print("Could not find non-colliding spawn location for enemy ", i)
			continue

		enemy.position = spawn_point.global_position


		if enemy.has_method("set_stats_for_wave"):
			enemy.set_stats_for_wave(current_wave)

		alive_enemies += 1
		enemy.connect("enemy_died", self, "_on_enemy_died")

		# Delay before spawning next enemy
		yield(get_tree().create_timer(0.1), "timeout")


func _on_enemy_died():
	if is_game_over:
		return

	alive_enemies -= 1
	if alive_enemies <= 0:
		current_wave += 1
		enemies_per_wave += 2
		start_countdown()

func start_countdown():
	if is_game_over:
		return

	countdown_time = 3
	countdown_label.text = "Wave starts in %d..." % countdown_time
	countdown_label.show()
	countdown_timer.start(1.0)

func _on_countdown_tick():
	if is_game_over:
		countdown_timer.stop()
		countdown_label.hide()
		return

	countdown_time -= 1
	if countdown_time > 0:
		countdown_label.text = "Wave starts in %d..." % countdown_time
	else:
		countdown_timer.stop()
		countdown_label.hide()
		spawn_wave()

func _on_player_died():
	is_game_over = true
	countdown_timer.stop()
	countdown_label.hide()
	game_over.show()
