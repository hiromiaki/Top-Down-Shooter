extends CanvasLayer

onready var coin_label = $CoinLabel
onready var triple_shot_button = $tripleShotButton
onready var add_ammo_button = $addAmmoButton
onready var error_purchase_label = $ErrorPurchase

export var triple_shot_cost := 10
export var add_ammo_cost := 10
export var full_heal_cost := 10

var cursor_texture = preload("res://assets/stone-cursor.png")
var player = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW)

func open_shop(player_ref):
	player = player_ref
	update_coin_display()
	error_purchase_label.hide()
	
	get_tree().paused = true  # Pause the game
	pause_mode = Node.PAUSE_MODE_PROCESS  # Ensure this UI continues working
	
	show()

func update_coin_display():
	coin_label.text = "Coins: %d" % GameManager.coins

func _on_buy_triple_shot():
	if player.has_triple_shot:
		show_message("Triple shot is already equipped.")
		return

	if GameManager.coins >= triple_shot_cost:
		GameManager.coins -= triple_shot_cost
		player.unlock_triple_shot()
		update_coin_display()
		error_purchase_label.hide()
	else:
		show_message("Failed to purchase: Not enough coins.")

func _on_buy_ammo():
	if player.max_ammo < 100:
		if GameManager.coins >= add_ammo_cost:
			GameManager.coins -= add_ammo_cost
			player.max_ammo += 10
			player.current_ammo = player.max_ammo  # optionally refill
			update_coin_display()
			error_purchase_label.hide()
		else:
			show_message("Failed to purchase: Not enough coins.")
	else:
		show_message("Max ammo upgrade reached!")

func _on_buy_full_heal():
	if GameManager.coins >= full_heal_cost:
		GameManager.coins -= full_heal_cost
		player.restore_full_health()
		update_coin_display()
		error_purchase_label.hide()
	else:
		show_message("Failed to purchase: Not enough coins.")

func show_message(text):
	error_purchase_label.text = text
	error_purchase_label.show()
	yield(get_tree().create_timer(2.0), "timeout")
	error_purchase_label.hide()

func _on_quit_button_pressed():
	get_tree().paused = false  # Resume the game
	hide()
