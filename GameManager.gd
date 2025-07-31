extends Node

# Global variables
var coins = 0
var bullets = 20
var max_bullets = 20
var has_triple_shot = false
var player_alive = true

# Utility functions
func add_coin(amount = 1):
	coins += amount

func spend_coin(amount):
	if coins >= amount:
		coins -= amount
		return true
	return false

func reset_game():
	coins = 0
	bullets = 20
	max_bullets = 20
	has_triple_shot = false
	player_alive = true
