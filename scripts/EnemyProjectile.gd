extends Area2D

var direction := Vector2.RIGHT
var speed := 340.0
var damage := 5.0

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	if global_position.x < -120 or global_position.x > 3000 or global_position.y < -120 or global_position.y > 2000:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()
