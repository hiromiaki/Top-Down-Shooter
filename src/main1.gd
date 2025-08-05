extends Node2D

onready var hud = $HUD
onready var start_menu = $"start-menu"
onready var start_button = $"start-menu/start_button"
onready var player = $Player  # Reference to the player (make sure this is correct)

var is_game_started = false  # To track if the game has started

var cursor_texture = preload("res://assets/stone-cursor.png")

func _ready():
	randomize()
	show_start_menu()  # Show the start menu initially

func show_start_menu():
	hud.visible = false
	start_menu.show()  # Show the start menu
	player.set_process_input(false)  # Disable player input (no movement)
	player.set_process(false)  # Disable player movement

func hide_start_menu():
	hud.visible = true
	start_menu.hide()  # Hide the start menu
	player.set_process_input(true)  # Enable player input (allow movement)
	player.set_process(true)  # Enable player movement

func _on_start_button_pressed():
	hide_start_menu()  # Hide the start menu when the start button is pressed
	is_game_started = true  # Mark that the game has started
	start_game()  # Call to start the game logic (wave, countdown, etc.)

func start_game():
	# Start the actual game functionality, such as spawning waves
	print("Game has started!")
	# You can trigger the start of the countdown or any game mechanics here
