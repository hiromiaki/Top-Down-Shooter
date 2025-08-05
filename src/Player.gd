extends KinematicBody2D

signal healthChanged(new_health)
signal player_died

# === Player Stats ===
export var maxHealth := 100
export var speed := 200
export var damageCooldown := 1.0

# === Dash Config ===
export var dash_speed := 600
export var dash_duration := 0.2
export var dash_cooldown := 1.0

# === State ===
var velocity := Vector2.ZERO
var currentHealth := maxHealth
var last_direction_index := 2
var can_take_damage := true
var is_dead := false
var is_dashing := false
var can_dash := true

#=== Coin ===
onready var coin_label = $"../CanvasLayer/coin_label"

# === Gun Ammo ===
export var max_ammo := 20
var current_ammo := 20
var is_reloading := false
onready var bullet_label = $"../CanvasLayer/bulletLabel"
onready var anim_player = $AnimationPlayer

# === Power-Ups ===
var has_triple_shot := false

# === Camera Shake ===
var shake_strength := 0.0
var is_paused = false

# === Sound Effects ===
onready var gun_fire = $"gun-fire"
onready var reload_gun = $"reload-gun"
onready var hurt_sound = $"hurt-sound"


# === Nodes ===
onready var gun = $GunSprite
onready var animated_sprite = $AnimatedSprite
onready var hurtbox = $HurtBox
onready var camera = $Camera2D
onready var bullet_scene = preload("res://src/Bullet.tscn")
onready var health_ui = $"../HUD"
onready var screen_fade = $"../CanvasLayer/ScreenFade"
onready var fade_anim = $"../CanvasLayer/ScreenFade/AnimationPlayer"

func _ready():
	emit_signal("healthChanged", currentHealth)
	if health_ui.has_method("init_health"):
		health_ui.call("init_health", maxHealth)
	
	update_coin_display()
	update_bullet_label()

func _physics_process(delta):
	if is_dead:
		return

	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		start_dash()

	handle_movement()
	update_animation()
	aim_gun_at_mouse()

	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("reload") and not is_reloading and current_ammo < max_ammo:
		start_reload()

func start_reload():
	is_reloading = true
	
	# Play reload animation
	if anim_player.has_animation("reloading"):
		anim_player.play("reloading")
		yield(anim_player, "animation_finished")
	else:
		yield(get_tree().create_timer(1.5), "timeout")  # fallback if animation not found
	
	reload_gun.play()
	current_ammo = max_ammo
	is_reloading = false
	update_bullet_label()

func pause_player(pause: bool):
	is_paused = pause
	if is_paused:
		velocity = Vector2.ZERO  # Stop movement when paused

func _process(delta):
	# Camera shake logic
	if shake_strength > 0:
		camera.offset = Vector2(
			rand_range(-shake_strength, shake_strength),
			rand_range(-shake_strength, shake_strength)
		)
		shake_strength = lerp(shake_strength, 0, delta * 5)
	else:
		camera.offset = Vector2.ZERO

func handle_movement():
	if is_dashing:
		move_and_slide(velocity)
		return

	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	velocity = input_dir.normalized() * speed
	move_and_slide(velocity)

func update_animation():
	if is_dead:
		return

	if is_dashing:
		if velocity.x > 0:
			animated_sprite.animation = "dash-right"
		elif velocity.x < 0:
			animated_sprite.animation = "dash-left"
		elif velocity.y > 0:
			animated_sprite.animation = "dash-front"
		elif velocity.y < 0:
			animated_sprite.animation = "dash-back"
		animated_sprite.play()
		return

	if velocity.length() > 0:
		var direction = get_global_mouse_position() - global_position
		var angle = direction.angle()
		if angle < 0:
			angle += PI * 2
		var index = int(round(angle / (PI / 4))) % 8
		last_direction_index = index
		animated_sprite.animation = "walk" + str(index)
		animated_sprite.play()
	else:
		match last_direction_index:
			0:
				animated_sprite.animation = "idle-right"
			1, 2:
				animated_sprite.animation = "idle-front"
			3, 4:
				animated_sprite.animation = "idle-left"
			5:
				animated_sprite.animation = "idle-backLeft"
			6:
				animated_sprite.animation = "idle-back"
			7:
				animated_sprite.animation = "idle-backRight"
		animated_sprite.play()
	
func update_bullet_label():
	bullet_label.text = str(GameManager.coins)
	
	if is_instance_valid(bullet_label):
		bullet_label.text = str(current_ammo) + " / " + str(max_ammo)

func unlock_triple_shot():
	has_triple_shot = true
	coin_label.text = str(GameManager.coins)

func aim_gun_at_mouse():
	if is_dead or not is_instance_valid(gun):
		return

	var dir = get_global_mouse_position() - gun.global_position
	gun.rotation = dir.angle()

	if gun.has_method("set_flip_v"):
		gun.set("flip_v", abs(gun.rotation) > PI / 2)

	gun.z_index = 10

func restore_full_health():
	currentHealth = maxHealth
	emit_signal("healthChanged", currentHealth)
	if health_ui.has_method("set_health"):
		health_ui.call("set_health", currentHealth)
	
	coin_label.text = str(GameManager.coins)

func add_coin(amount):
	GameManager.add_coin(amount)
	if coin_label:
		coin_label.text = str(GameManager.coins)

func upgrade_ammo_capacity(increment):
	max_ammo = min(max_ammo + increment, 100)
	current_ammo = max_ammo
	coin_label.text = str(GameManager.coins)
	update_bullet_label()

func update_coin_display():
	print("Updating Coin Display:", GameManager.coins)
	coin_label.text = str(GameManager.coins)

func heal(amount):
	if is_dead:
		return
	currentHealth += amount
	currentHealth = clamp(currentHealth, 0, maxHealth)
	emit_signal("healthChanged", currentHealth)
	if health_ui.has_method("set_health"):
		health_ui.call("set_health", currentHealth)

func shoot():
	if is_dead or is_reloading or current_ammo <= 0:
		return

	if has_triple_shot:
		for angle_offset in [-10, 0, 10]:
			if current_ammo <= 0:
				break

			var bullet = bullet_scene.instance()
			var spawn_position = gun.global_position
			if gun.has_node("FirePoint"):
				spawn_position = gun.get_node("FirePoint").global_position

			bullet.position = spawn_position
			var dir = (get_global_mouse_position() - spawn_position).normalized().rotated(deg2rad(angle_offset))
			bullet.direction = dir
			get_parent().add_child(bullet)
			gun_fire.play()
			current_ammo -= 1
	else:
		var bullet = bullet_scene.instance()
		var spawn_position = gun.global_position
		if gun.has_node("FirePoint"):
			spawn_position = gun.get_node("FirePoint").global_position

		bullet.position = spawn_position
		bullet.direction = (get_global_mouse_position() - spawn_position).normalized()
		get_parent().add_child(bullet)

		current_ammo -= 1

	update_bullet_label()

	# 💥 Trigger screen shake
	shake_strength = 5


func _on_HurtBox_body_entered(body):
	if body.is_in_group("enemy") and can_take_damage and not is_dead:
		take_damage(20)
		can_take_damage = false
		yield(get_tree().create_timer(damageCooldown), "timeout")
		can_take_damage = true

func take_damage(amount):
	currentHealth -= amount
	currentHealth = clamp(currentHealth, 0, maxHealth)
	emit_signal("healthChanged", currentHealth)

	if health_ui.has_method("set_health"):
		health_ui.call("set_health", currentHealth)

	if currentHealth <= 0 and not is_dead:
		die()

func die():
	is_dead = true
	velocity = Vector2.ZERO
	animated_sprite.animation = "death"
	animated_sprite.play()
	
	emit_signal("player_died")

	# Play fade animation if available
	if fade_anim and fade_anim.has_animation("fade_to_black"):
		fade_anim.play("fade_to_black")

	# Clean up the gun and hurtbox
	if is_instance_valid(gun):
		gun.queue_free()

	if is_instance_valid(hurtbox):
		hurtbox.set_deferred("disabled", true)

	# Wait for death animation to finish
	yield(animated_sprite, "animation_finished")

	# Remove the player node
	queue_free()

	# Show the Game Over screen and update stats
	var gameover_ui = $"../CanvasLayer/gameOver"
	gameover_ui.show()

	if gameover_ui.has_method("show_stats"):
		gameover_ui.call("show_stats")


func start_dash():
	is_dashing = true
	can_dash = false

	var input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	velocity = input.normalized() * dash_speed

	yield(get_tree().create_timer(dash_duration), "timeout")
	is_dashing = false
	velocity = Vector2.ZERO

	yield(get_tree().create_timer(dash_cooldown), "timeout")
	can_dash = true
