extends Area2D

var value := 5

func _ready() -> void:
	$Label.text = "+%d" % value

func _process(delta: float) -> void:
	rotation += delta

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var game = get_tree().current_scene
		if game and game.has_method("_on_pickup_collected"):
			game._on_pickup_collected(value)
		queue_free()
