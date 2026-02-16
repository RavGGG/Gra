extends Area2D

var direction := Vector2.RIGHT
var speed := 500.0
var damage := 10.0
var shooter: Node = null
var explosion_radius := 0.0
var style := "pistol"

func _ready() -> void:
	match style:
		"bazooka":
			$Body.color = Color(1.0, 0.45, 0.2)
			$Body.scale = Vector2(1.8, 1.2)
		"rifle":
			$Body.color = Color(0.7, 1.0, 0.5)
		"pistol":
			$Body.color = Color(1.0, 0.95, 0.45)
		_:
			$Body.color = Color(1,1,1)

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	if global_position.x < -100 or global_position.x > 3000 or global_position.y < -100 or global_position.y > 2000:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if explosion_radius > 0.0:
		_explode()
	else:
		body.take_hit(damage, shooter)
	queue_free()

func _explode() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var d = global_position.distance_to(enemy.global_position)
		if d <= explosion_radius:
			var scale = clamp(1.0 - (d / explosion_radius), 0.2, 1.0)
			enemy.take_hit(damage * scale, shooter)
	var pulse = ColorRect.new()
	pulse.color = Color(1.0, 0.5, 0.2, 0.35)
	pulse.size = Vector2(explosion_radius * 2.0, explosion_radius * 2.0)
	pulse.position = global_position - pulse.size * 0.5
	get_tree().current_scene.add_child(pulse)
	pulse.call_deferred("queue_free")
