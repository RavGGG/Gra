extends Node2D

var wave := 1
var time_left := 30.0
var credits := 25
var selected_character := "scout"
var paused_for_shop := false
var arenas := [Color(0.08,0.1,0.13), Color(0.12,0.08,0.12), Color(0.08,0.13,0.09)]

@onready var player = $Player
@onready var spawn_timer = $SpawnTimer
@onready var wave_timer = $WaveTimer
@onready var hud = $CanvasLayer/HUD
@onready var shop = $CanvasLayer/ShopPanel
@onready var pause_menu = $CanvasLayer/PauseMenu

func _ready() -> void:
	selected_character = get_meta("character", "scout")
	var character = GameData.apply_meta_bonus(GameData.character_defs[selected_character])
	player.configure(character)
	player.died.connect(_on_player_died)
	player.hp_changed.connect(hud.update_hp)
	hud.update_wave(wave, time_left)
	hud.update_credits(credits)
	spawn_timer.start()
	wave_timer.start()
	shop.visible = false
	pause_menu.visible = false
	_apply_arena()

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

func _on_spawn_timer_timeout() -> void:
	if paused_for_shop:
		return
	var enemy = preload("res://scenes/Enemy.tscn").instantiate()
	enemy.player = player
	enemy.max_hp = 15 + wave * 4
	enemy.speed = 70 + wave * 5
	enemy.contact_damage = 4 + wave
	enemy.global_position = Vector2(randi_range(40, 1240), randi_range(40, 680))
	add_child(enemy)

func _on_wave_timer_timeout() -> void:
	wave += 1
	time_left = 30 + wave
	credits += 20 + wave * 3
	GameData.progression["best_wave"] = max(GameData.progression["best_wave"], wave)
	GameData.add_meta_currency(5 + wave)
	hud.update_credits(credits)
	if wave % 2 == 0:
		_open_shop()
	_apply_arena()
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

func _apply_arena() -> void:
	$CanvasLayer/ArenaColor.color = arenas[(wave - 1) % arenas.size()]
