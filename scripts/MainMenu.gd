extends Control

var char_list: VBoxContainer
var details: Label

func _ready() -> void:
	# Fallback dla różnych wersji layoutu menu (stary/nowy), żeby nie wywalać null instance.
	char_list = get_node_or_null("Center/Card/VBox/CharacterList")
	if char_list == null:
		char_list = get_node_or_null("Center/VBox/CharacterList")
	details = get_node_or_null("Center/Card/VBox/Details")
	if details == null:
		details = get_node_or_null("Center/VBox/Details")

	if char_list == null or details == null:
		push_error("MainMenu: missing CharacterList/Details node. Check scene hierarchy.")
		return

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
	if details == null:
		return
	var data = GameData.character_defs[id]
	details.text = "%s\nHP %.0f  SZYB %.0f  OBR %.2f\n%s" % [data["label"], data["health"], data["speed"], data["damage"], data["ability"]]
	GameData.selected_character = id

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_unlocks_pressed() -> void:
	var s = preload("res://scenes/Progression.tscn").instantiate()
	get_tree().root.add_child(s)

func _on_settings_pressed() -> void:
	var s = preload("res://scenes/Settings.tscn").instantiate()
	get_tree().root.add_child(s)

func _on_quit_pressed() -> void:
	get_tree().quit()
