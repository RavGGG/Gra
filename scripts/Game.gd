extends Node2D

const MAX_WAVE := 20

var wave := 0
var time_left := 0.0
var credits := 25
var selected_character := "scout"
var paused_for_shop := false

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var wave_timer = $WaveTimer
@onready var hud = $CanvasLayer/HUD
@onready var shop = $CanvasLayer/ShopPanel
@onready var pause_menu = $CanvasLayer/PauseMenu

func _ready() -> void:
	selected_character = GameData.selected_character
	var character = GameData.apply_meta_bonus(GameData.character_defs[selected_character])
	player.configure(character)
	player.died.connect(_on_player_died)
	player.hp_changed.connect(hud.update_hp)
	hud.update_credits(credits)
	hud.update_weapon_slots(player.get_weapon_slot(0).get("name", "Pusty"), player.get_weapon_slot(1).get("name", "Pusty"), player.active_weapon_slot)
	player.weapon_changed.connect(_on_weapon_changed)
	shop.visible = false
	pause_menu.visible = false
	$CanvasLayer/ArenaColor.visible = false

	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$CanvasLayer/PauseMenu/VBox.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$CanvasLayer/PauseMenu/VBox/Resume.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$CanvasLayer/PauseMenu/VBox/Menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	spawn_timer.one_shot = false
	wave_timer.one_shot = true

	_start_wave(1)

func _process(delta: float) -> void:
	if paused_for_shop:
		return
	time_left = max(0.0, time_left - delta)
	hud.update_wave(wave, time_left)
	hud.update_weapon_slots(player.get_weapon_slot(0).get("name", "Pusty"), player.get_weapon_slot(1).get("name", "Pusty"), player.active_weapon_slot)
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func _on_weapon_changed(_slot_index: int, _weapon_name: String) -> void:
	hud.update_weapon_slots(player.get_weapon_slot(0).get("name", "Pusty"), player.get_weapon_slot(1).get("name", "Pusty"), player.active_weapon_slot)

func _toggle_pause() -> void:
	if paused_for_shop:
		return
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused

func _start_wave(next_wave: int) -> void:
	paused_for_shop = false
	shop.visible = false
	get_tree().paused = false
	pause_menu.visible = false
	_clear_enemies()
	_clear_pickups()
	wave = next_wave
	time_left = 28.0 + wave * 1.5
	hud.update_wave(wave, time_left)

	var start_count = 1 + int(wave / 5)
	for i in start_count:
		_spawn_enemy_near_player(260.0 + i * 22.0)

	spawn_timer.wait_time = max(1.15, 2.4 - wave * 0.03)
	spawn_timer.start()
	wave_timer.start(time_left)

func _finish_wave() -> void:
	credits += 18 + wave * 3
	GameData.progression["best_wave"] = max(GameData.progression["best_wave"], wave)
	GameData.add_meta_currency(4 + wave)
	hud.update_credits(credits)

	if wave >= MAX_WAVE:
		_end_run(true)
		return

	_open_shop()

func _pick_enemy_type() -> String:
	var roll = randf()
	if wave >= 7 and roll < 0.12:
		return "tank"
	if wave >= 4 and roll < 0.27:
		return "shooter"
	if wave >= 3 and roll < 0.48:
		return "runner"
	return "grunt"

func _spawn_enemy_near_player(distance: float) -> void:
	var enemy = preload("res://scenes/Enemy.tscn").instantiate()
	enemy.player = player
	enemy.enemy_type = _pick_enemy_type()
	enemy.max_hp = 12 + wave * 2.6
	enemy.speed = 72 + wave * 2.8
	enemy.contact_damage = 3 + wave * 0.6
	var angle = randf() * TAU
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * distance
	enemy.global_position.x = clamp(enemy.global_position.x, 40.0, 1240.0)
	enemy.global_position.y = clamp(enemy.global_position.y, 40.0, 680.0)
	add_child(enemy)

func _on_spawn_timer_timeout() -> void:
	if paused_for_shop:
		return
	var spawn_count = 1 + int(wave / 12)
	for i in spawn_count:
		_spawn_enemy_near_player(300.0 + i * 18.0)

func _on_wave_timer_timeout() -> void:
	_finish_wave()

func _open_shop() -> void:
	paused_for_shop = true
	spawn_timer.stop()
	wave_timer.stop()
	_clear_enemies()
	_clear_pickups()
	shop.visible = true
	shop.build_offers(credits, player)

func _on_shop_closed(spent: int, selected_items: Array, _selected_weapon: Dictionary) -> void:
	credits -= spent
	for item in selected_items:
		player.apply_item(item)
	hud.update_credits(credits)
	_start_wave(wave + 1)

func _clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()

func _clear_pickups() -> void:
	for child in get_children():
		if child.name.begins_with("Pickup") or child.get_script() == preload("res://scripts/Pickup.gd"):
			child.queue_free()

func _on_pickup_collected(value: int) -> void:
	credits += value
	hud.update_credits(credits)

func _on_player_died() -> void:
	_end_run(false)

func _end_run(victory: bool) -> void:
	spawn_timer.stop()
	wave_timer.stop()
	GameData.save_data()
	var end_scene = preload("res://scenes/RunEnd.tscn").instantiate()
	end_scene.set_result(victory, wave, credits)
	get_tree().root.add_child(end_scene)
	queue_free()

func _on_resume_pressed() -> void:
	if get_tree().paused:
		_toggle_pause()

func _on_menu_pressed() -> void:
	GameData.save_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
