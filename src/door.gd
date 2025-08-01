extends Area2D

onready var anim_player = $AnimationPlayer
onready var hint_label = $CanvasLayer/hintLabel


var player_nearby = false
var door_open = false

func _ready():
	hint_label.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_nearby = true
		_update_hint()
 
func _on_body_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
		hint_label.visible = false
 
func _process(delta):
	if player_nearby and Input.is_action_just_pressed("open_close_door"): # you'll define this in Input Map
		if door_open:
			anim_player.play("closing")
			door_open = false
		else:
			anim_player.play("opening")
			door_open = true
		_update_hint()

func _update_hint():
	if door_open:
		hint_label.text = "Press Q to close the door"
	else:
		hint_label.text = "Press Q to open the door"
	hint_label.visible = true
