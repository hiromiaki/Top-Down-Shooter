extends Area2D

const FILE_BEGIN = "res://src/main"

onready var anim_player = $AnimationPlayer  # This is for the door animation
onready var fade_anim = $"../CanvasLayer/ScreenFade/AnimationPlayer"

var next_level_path = ""

func _on_next_level_body_entered(body):
	if body.is_in_group("player"):
		var current_scene = get_tree().current_scene
		var current_scene_path = current_scene.filename

		var current_number = current_scene_path.get_file().get_basename().to_int()
		next_level_path = FILE_BEGIN + str(current_number + 1) + ".tscn"

		if ResourceLoader.exists(next_level_path):
			anim_player.play("door-open")
		else:
			print("Next level not found: ", next_level_path)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "door-open" and next_level_path != "":
		if fade_anim and fade_anim.has_animation("fade_to_black"):
			fade_anim.play("fade_to_black")
			yield(fade_anim, "animation_finished")  # Wait until the fade finishes
		get_tree().change_scene(next_level_path)
