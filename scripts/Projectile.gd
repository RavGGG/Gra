extends Area2D

var direction := Vector2.RIGHT
var speed := 500.0
var damage := 10.0

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	if global_position.x < -100 or global_position.x > 3000 or global_position.y < -100 or global_position.y > 2000:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.take_hit(damage)
		queue_free()
