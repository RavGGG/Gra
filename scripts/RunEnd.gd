extends Control

@onready var label = $Center/VBox/Result

func set_result(victory: bool, wave: int, credits: int) -> void:
	label.text = ("Victory!" if victory else "Defeat") + "\nWave: %d\nLoot: %d" % [wave, credits]

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
