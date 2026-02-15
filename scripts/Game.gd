extends Node2D

var wave := 1
var time_left := 30.0
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
	hud.update_wave(wave, time_left)
	hud.update_credits(credits)
	shop.visible = false
	pause_menu.visible = false
	$CanvasLayer/ArenaColor.visible = false

	# Natychmiastowy, pewny spawn żeby gra nie wyglądała na "pustą".
	for i in 4:
		_spawn_enemy_near_player(180.0 + i * 35.0)

	spawn_timer.start()
	wave_timer.start()

func _process(delta: float) -> void:
	if paused_for_shop:
		return
	time_left -= delta
	hud.update_wave(wave, max(0.0, time_left))
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_menu.visible = get_tree().paused

func _spawn_enemy_near_player(distance: float) -> void:
	var enemy = preload("res://scenes/Enemy.tscn").instantiate()
	enemy.player = player
	enemy.max_hp = 14 + wave * 4
	enemy.speed = 80 + wave * 6
	enemy.contact_damage = 4 + wave
	var angle = randf() * TAU
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * distance
	# Clamp do obszaru ekranu, aby zawsze był widoczny.
	enemy.global_position.x = clamp(enemy.global_position.x, 40.0, 1240.0)
	enemy.global_position.y = clamp(enemy.global_position.y, 40.0, 680.0)
	add_child(enemy)

func _on_spawn_timer_timeout() -> void:
	if paused_for_shop:
		return
	for i in (1 + int(wave / 4)):
		_spawn_enemy_near_player(220.0 + i * 24.0)

func _on_wave_timer_timeout() -> void:
	wave += 1
	time_left = 30 + wave
	credits += 20 + wave * 3
	GameData.progression["best_wave"] = max(GameData.progression["best_wave"], wave)
	GameData.add_meta_currency(5 + wave)
	hud.update_credits(credits)
	if wave % 2 == 0:
		_open_shop()
	if wave >= 20:
		_end_run(true)

func _open_shop() -> void:
	paused_for_shop = true
	shop.visible = true
	shop.build_offers(credits)

func _on_shop_closed(spent: int, selected_items: Array, selected_weapon: Dictionary) -> void:
	credits -= spent
	if not selected_weapon.is_empty():
		player.current_weapon = selected_weapon
	for item in selected_items:
		player.apply_item(item)
	hud.update_credits(credits)
	shop.visible = false
	paused_for_shop = false

func _on_pickup_collected(value: int) -> void:
	credits += value
	hud.update_credits(credits)

func _on_player_died() -> void:
	_end_run(false)

func _end_run(victory: bool) -> void:
	GameData.save_data()
	var end_scene = preload("res://scenes/RunEnd.tscn").instantiate()
	end_scene.set_result(victory, wave, credits)
	get_tree().root.add_child(end_scene)
	queue_free()

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_menu_pressed() -> void:
	GameData.save_data()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
