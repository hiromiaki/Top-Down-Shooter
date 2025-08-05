extends Control

onready var point_text = $PointText
onready var tween = $Tween

func set_text(value):
	point_text = value

func _ready():
	modulate = Color(1, 1, 1, 1)

	tween.interpolate_property(self, "modulate:a", 1, 0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(self, "rect_position", rect_position, rect_position + Vector2(0, -30), 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)

	tween.start()
	yield(tween, "tween_all_completed")
	queue_free()
