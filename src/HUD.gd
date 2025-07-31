extends CanvasLayer

onready var timer = $Timer
onready var health_bar = $healthBar
onready var damage_bar = $damageBar

var health = 0
var max_value = 100  # Default max health

func set_health(new_health):
	var prev_health = health
	health = clamp(new_health, 0, max_value)

	if health_bar:
		health_bar.value = health
	
	if health <= 0:
		queue_free()
	
	if health < prev_health:
		timer.start()
	elif damage_bar:
		damage_bar.value = health

func init_health(_health):
	health = _health
	max_value = _health

	if health_bar:
		health_bar.max_value = _health
		health_bar.value = _health
	

	if damage_bar:
		damage_bar.max_value = _health
		damage_bar.value = _health
	

func _on_Timer_timeout():
	if damage_bar:
		damage_bar.value = health
