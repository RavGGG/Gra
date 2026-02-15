extends CharacterBody2D

signal died
signal hp_changed(value: float, max_value: float)

@export var base_speed := 220.0
@export var max_health := 100.0
@export var damage_mult := 1.0
@export var fire_cooldown := 0.4

var health := 100.0
var aim_manual := true
var current_weapon: Dictionary = {}
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

func configure(character_data: Dictionary) -> void:
	base_speed = character_data["speed"]
	max_health = character_data["health"]
	damage_mult = character_data["damage"]
	health = max_health
	current_weapon = ContentDB.random_weapon()
	hp_changed.emit(health, max_health)

func _physics_process(_delta: float) -> void:
	var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * (base_speed + item_mods["speed"])
	move_and_slide()
	look_at(get_global_mouse_position())

func _process(_delta: float) -> void:
	if fire_timer.is_stopped() and (not aim_manual or Input.is_action_pressed("shoot")):
		fire()

func fire() -> void:
	fire_timer.start(max(0.05, current_weapon["rate"] + item_mods["fire_rate"]))
	if current_weapon["type"] == "melee":
		for body in get_tree().get_nodes_in_group("enemies"):
			if global_position.distance_to(body.global_position) < current_weapon.get("range", 60.0):
				body.take_hit(_weapon_damage())
	else:
		var projectile = preload("res://scenes/Projectile.tscn").instantiate()
		projectile.global_position = global_position
		projectile.direction = (get_global_mouse_position() - global_position).normalized()
		projectile.speed = current_weapon.get("proj_speed", 520.0)
		projectile.damage = _weapon_damage()
		get_tree().current_scene.add_child(projectile)

func _weapon_damage() -> float:
	return current_weapon["base_damage"] * damage_mult * (1.0 + item_mods["damage"])

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
