extends CharacterBody2D

@export var speed := 90.0
@export var max_hp := 20.0
@export var contact_damage := 8.0

var hp := 20.0
var player: Node2D

func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	velocity = (player.global_position - global_position).normalized() * speed
	move_and_slide()
	if global_position.distance_to(player.global_position) < 22.0:
		player.take_damage(contact_damage)

func take_hit(dmg: float, attacker: Node = null) -> void:
	hp -= dmg
	if attacker and attacker.has_method("on_dealt_damage"):
		attacker.on_dealt_damage(dmg)
	if hp <= 0:
		if randf() < 0.5:
			var pickup = preload("res://scenes/Pickup.tscn").instantiate()
			pickup.global_position = global_position
			get_tree().current_scene.add_child(pickup)
		queue_free()
