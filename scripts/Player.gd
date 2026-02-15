extends CharacterBody2D

signal died
signal hp_changed(value: float, max_value: float)
signal weapon_changed(slot_index: int, weapon_name: String)

@export var base_speed := 220.0
@export var max_health := 100.0
@export var damage_mult := 1.0

var health := 100.0
var aim_manual := true
var weapon_slots: Array[Dictionary] = [{}, {}]
var active_weapon_slot := 0
var inventory: Array[Dictionary] = []
var item_mods := {
	"speed": 0.0,
	"damage": 0.0,
	"fire_rate": 0.0,
	"armor": 0.0,
	"max_health": 0.0,
	"lifesteal": 0.0,
	"pickup_radius": 0.0
}

@onready var fire_timer: Timer = $FireTimer
@onready var weapon_visual: Polygon2D = $WeaponVisual

func _ready() -> void:
	add_to_group("player")

func configure(character_data: Dictionary) -> void:
	base_speed = character_data["speed"]
	max_health = character_data["health"]
	damage_mult = character_data["damage"]
	health = max_health
	weapon_slots[0] = ContentDB.starter_weapon("pistol")
	weapon_slots[1] = ContentDB.starter_weapon("sword")
	active_weapon_slot = 0
	_update_weapon_visual()
	hp_changed.emit(health, max_health)
	weapon_changed.emit(0, weapon_slots[0]["name"])
	weapon_changed.emit(1, weapon_slots[1]["name"])

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_slot_1"):
		active_weapon_slot = 0
		_update_weapon_visual()
	elif event.is_action_pressed("weapon_slot_2"):
		active_weapon_slot = 1
		_update_weapon_visual()

func _physics_process(_delta: float) -> void:
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * (base_speed + item_mods["speed"])
	move_and_slide()
	look_at(get_global_mouse_position())

func _process(_delta: float) -> void:
	if fire_timer.is_stopped() and (not aim_manual or Input.is_action_pressed("shoot")):
		fire()

func get_current_weapon() -> Dictionary:
	return weapon_slots[active_weapon_slot]

func fire() -> void:
	var current_weapon = get_current_weapon()
	if current_weapon.is_empty():
		return
	fire_timer.start(max(0.05, current_weapon["rate"] + item_mods["fire_rate"]))

	if current_weapon["type"] == "melee":
		_slash_effect(current_weapon)
		for body in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(body.global_position) < current_weapon.get("range", 60.0):
				body.take_hit(_weapon_damage(current_weapon), self)
		return

	var projectile = preload("res://scenes/Projectile.tscn").instantiate()
	projectile.global_position = global_position
	projectile.direction = (get_global_mouse_position() - global_position).normalized()
	projectile.speed = current_weapon.get("proj_speed", 520.0)
	projectile.damage = _weapon_damage(current_weapon)
	projectile.shooter = self
	projectile.explosion_radius = current_weapon.get("explosion_radius", 0.0)
	projectile.style = current_weapon.get("style", "pistol")
	get_tree().current_scene.add_child(projectile)

func _weapon_damage(weapon: Dictionary) -> float:
	return weapon["base_damage"] * damage_mult * (1.0 + item_mods["damage"])

func _slash_effect(weapon: Dictionary) -> void:
	var slash = Line2D.new()
	slash.width = 4.0
	slash.default_color = Color(1.0, 1.0, 0.6, 0.95)
	var r = weapon.get("range", 60.0)
	slash.points = PackedVector2Array([Vector2.ZERO, Vector2(r, -12), Vector2(r + 10, 0), Vector2(r, 12)])
	add_child(slash)
	await get_tree().create_timer(0.08).timeout
	slash.queue_free()

func _update_weapon_visual() -> void:
	var w = get_current_weapon()
	if w.is_empty():
		weapon_visual.visible = false
		return
	weapon_visual.visible = true
	var style = w.get("style", "pistol")
	match style:
		"pistol":
			weapon_visual.polygon = PackedVector2Array([Vector2(5, -3), Vector2(18, -3), Vector2(18, 3), Vector2(5, 3)])
			weapon_visual.color = Color(0.25, 0.25, 0.3)
		"rifle":
			weapon_visual.polygon = PackedVector2Array([Vector2(2, -2), Vector2(24, -2), Vector2(24, 2), Vector2(2, 2)])
			weapon_visual.color = Color(0.1, 0.4, 0.2)
		"bazooka":
			weapon_visual.polygon = PackedVector2Array([Vector2(2, -4), Vector2(20, -6), Vector2(20, 6), Vector2(2, 4)])
			weapon_visual.color = Color(0.5, 0.2, 0.1)
		"sword":
			weapon_visual.polygon = PackedVector2Array([Vector2(4, -2), Vector2(24, -1), Vector2(24, 1), Vector2(4, 2)])
			weapon_visual.color = Color(0.8, 0.8, 0.95)
		_:
			weapon_visual.polygon = PackedVector2Array([Vector2(5, -3), Vector2(18, -3), Vector2(18, 3), Vector2(5, 3)])
			weapon_visual.color = Color(0.3, 0.3, 0.3)

func set_weapon_slot(slot_index: int, weapon: Dictionary) -> void:
	if slot_index < 0 or slot_index >= weapon_slots.size():
		return
	weapon_slots[slot_index] = weapon.duplicate(true)
	weapon_changed.emit(slot_index, weapon_slots[slot_index].get("name", "Brak"))
	if slot_index == active_weapon_slot:
		_update_weapon_visual()

func get_weapon_slot(slot_index: int) -> Dictionary:
	if slot_index < 0 or slot_index >= weapon_slots.size():
		return {}
	return weapon_slots[slot_index]

func sell_weapon_slot(slot_index: int) -> int:
	if slot_index < 0 or slot_index >= weapon_slots.size():
		return 0
	if weapon_slots[slot_index].is_empty():
		return 0
	var value = int(round(float(weapon_slots[slot_index].get("price", 0)) * 0.5))
	weapon_slots[slot_index] = {}
	weapon_changed.emit(slot_index, "Pusty")
	if slot_index == active_weapon_slot:
		_update_weapon_visual()
	return value

func apply_item(item: Dictionary) -> void:
	if item_mods.has(item["stat"]):
		item_mods[item["stat"]] += item["value"]
	if item["stat"] == "max_health":
		max_health += item["value"]
		health += item["value"]
	hp_changed.emit(health, max_health)
	inventory.append(item)

func take_damage(value: float) -> void:
	var final = max(1.0, value - item_mods["armor"])
	health -= final
	hp_changed.emit(health, max_health)
	if health <= 0:
		died.emit()

func heal(value: float) -> void:
	health = min(max_health, health + value)
	hp_changed.emit(health, max_health)

func on_dealt_damage(damage_done: float) -> void:
	if item_mods["lifesteal"] > 0.0:
		heal(max(0.0, damage_done * item_mods["lifesteal"]))
