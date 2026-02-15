extends Control

@onready var char_list = $Center/VBox/CharacterList
@onready var details = $Center/VBox/Details

func _ready() -> void:
	for c in char_list.get_children():
		c.queue_free()
	for key in GameData.character_defs.keys():
		var b = Button.new()
		b.text = GameData.character_defs[key]["label"]
		b.disabled = not GameData.is_character_unlocked(key)
		b.pressed.connect(_on_character_selected.bind(key))
		char_list.add_child(b)
	_on_character_selected("scout")

func _on_character_selected(id: String) -> void:
	var data = GameData.character_defs[id]
	details.text = "%s\nHP %.0f  SPD %.0f  DMG %.2f\n%s" % [data["label"], data["health"], data["speed"], data["damage"], data["ability"]]
	set_meta("selected_character", id)

func _on_start_pressed() -> void:
	var game = preload("res://scenes/Game.tscn").instantiate()
	game.set_meta("character", get_meta("selected_character", "scout"))
	get_tree().root.add_child(game)
	queue_free()

func _on_unlocks_pressed() -> void:
	var s = preload("res://scenes/Progression.tscn").instantiate()
	get_tree().root.add_child(s)

func _on_settings_pressed() -> void:
	var s = preload("res://scenes/Settings.tscn").instantiate()
	get_tree().root.add_child(s)

func _on_quit_pressed() -> void:
	get_tree().quit()
