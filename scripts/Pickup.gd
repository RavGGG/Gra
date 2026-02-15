extends Area2D

var value := 5
var armed := false
var arm_time := 0.4

func _ready() -> void:
	$Label.text = "+%d" % value
	monitoring = false
	set_process(true)

func _process(delta: float) -> void:
	rotation += delta
	if not armed:
		arm_time -= delta
		if arm_time <= 0.0:
			armed = true
			monitoring = true
		return

	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player = players[0]
	var pull_radius = 40.0 + player.item_mods["pickup_radius"]
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	if dist < pull_radius and dist > 0.1:
		global_position += to_player.normalized() * min(250.0 * delta, dist)

func _on_body_entered(body: Node2D) -> void:
	if not armed:
		return
	if body.is_in_group("player"):
		var game = get_tree().current_scene
		if game and game.has_method("_on_pickup_collected"):
			game._on_pickup_collected(value)
		queue_free()
