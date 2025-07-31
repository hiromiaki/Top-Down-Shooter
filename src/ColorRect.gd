extends ColorRect

var time_passed := 0.0

func _process(delta):
	time_passed += delta
	material.set_shader_param("time", time_passed)
