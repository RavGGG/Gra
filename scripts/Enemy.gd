extends CharacterBody2D

@export var speed := 90.0
@export var max_hp := 20.0
@export var contact_damage := 8.0
@export var enemy_type := "grunt"

var hp := 20.0
var player: Node2D
var attack_cooldown := 0.0

func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")
	_setup_type_visuals_and_stats()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	attack_cooldown = max(0.0, attack_cooldown - delta)

	var desired = (player.global_position - global_position).normalized()
	# Lekkie rozpychanie stada, aby wróg nie blokował całkiem ruchu gracza.
	for other in get_tree().get_nodes_in_group("enemies"):
		if other == self:
			continue
		var offset = global_position - other.global_position
		var dist = offset.length()
		if dist > 0.0 and dist < 26.0:
			desired += offset.normalized() * (26.0 - dist) * 0.05

	velocity = desired.normalized() * speed
	move_and_slide()

	if global_position.distance_to(player.global_position) < 24.0 and attack_cooldown <= 0.0:
		player.take_damage(contact_damage)
		attack_cooldown = 0.45

func _setup_type_visuals_and_stats() -> void:
	match enemy_type:
		"runner":
			speed *= 1.45
			max_hp *= 0.65
			contact_damage *= 0.85
			$Body.color = Color(0.95, 0.7, 0.2)
			$Body.polygon = PackedVector2Array([Vector2(-10, -7), Vector2(12, 0), Vector2(-10, 7)])
		"tank":
			speed *= 0.75
			max_hp *= 1.8
			contact_damage *= 1.3
			$Body.color = Color(0.55, 0.2, 0.75)
			$Body.polygon = PackedVector2Array([Vector2(-13,-13), Vector2(13,-13), Vector2(13,13), Vector2(-13,13)])
		_:
			$Body.color = Color(0.85, 0.24, 0.24)
			$Body.polygon = PackedVector2Array([Vector2(-11,-11), Vector2(11,-11), Vector2(11,11), Vector2(-11,11)])
	hp = max_hp

func take_hit(dmg: float, attacker: Node = null) -> void:
	hp -= dmg
	if attacker and attacker.has_method("on_dealt_damage"):
		attacker.on_dealt_damage(dmg)
	if hp <= 0:
		if randf() < 0.6:
			var pickup = preload("res://scenes/Pickup.tscn").instantiate()
			pickup.global_position = global_position
			get_tree().current_scene.call_deferred("add_child", pickup)
		call_deferred("queue_free")
