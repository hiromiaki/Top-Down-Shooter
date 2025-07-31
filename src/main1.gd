extends Node2D

onready var tile_map = $TileMap
onready var camera = get_node("Player/Camera2D")  # Adjust path if needed

func _ready():
	 Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

