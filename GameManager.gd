extends Node

# Global variables
var coins = 0
var bullets = 20
var max_bullets = 20
var has_triple_shot = false
var player_alive = true

var score = 0
var current_wave = 0  # Variable to track the current wave
var total_enemies_killed = 0  

var score_label = null
var enemy_label = null

func _ready():
	score_label = get_node("/root/main2/CanvasLayer/score_label")
	update_score_ui()  # Update the score label on startup

# Utility functions
func add_coin(amount = 0):
	coins += amount
	update_score_ui()

func add_score(amount):
	score += amount
	update_score_ui()

# Function to update the wave count
func increment_wave():
	current_wave += 1
	update_score_ui()  # Update the wave label in the UI

# Function to add an enemy kill
func add_enemy_kill():
	total_enemies_killed += 1
	update_score_ui()  # Update the UI to show the updated enemy kill count

# Function to update the score UI
func update_score_ui():
	score_label.text = str(score)

# Function to reset the game stats
func reset():
	coins = 0
	bullets = 20
	max_bullets = 20
	score = 0
	current_wave = 0
	total_enemies_killed = 0
	has_triple_shot = false
	player_alive = true
	
	# Reset all UI elements
	update_score_ui()
	
	# Optionally, you can reset other UI elements or restart music, etc.
	# For example, resetting music or fading out can also be added.
