extends Control

@onready var volume = $Center/VBox/Volume
@onready var lang = $Center/VBox/Language

func _ready() -> void:
	volume.value = GameData.master_volume * 100
	lang.select(0 if GameData.locale == "en" else 1)

func _on_volume_value_changed(value: float) -> void:
	GameData.master_volume = value / 100.0
	AudioServer.set_bus_volume_db(0, linear_to_db(GameData.master_volume))

func _on_language_item_selected(index: int) -> void:
	GameData.locale = "en" if index == 0 else "es"

func _on_back_pressed() -> void:
	GameData.save_data()
	queue_free()
