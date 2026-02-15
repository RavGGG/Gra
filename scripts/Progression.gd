extends Control

@onready var currency = $Center/VBox/Currency
@onready var best_wave = $Center/VBox/BestWave

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	currency.text = "Meta Currency: %d" % GameData.progression["meta_currency"]
	best_wave.text = "Best Wave: %d" % GameData.progression["best_wave"]

func _on_health_pressed() -> void:
	if GameData.buy_meta_perk("bonus_health"):
		_refresh()

func _on_damage_pressed() -> void:
	if GameData.buy_meta_perk("bonus_damage"):
		_refresh()

func _on_speed_pressed() -> void:
	if GameData.buy_meta_perk("bonus_speed"):
		_refresh()

func _on_unlock_pressed() -> void:
	for id in GameData.character_defs.keys():
		if not GameData.is_character_unlocked(id) and GameData.progression["meta_currency"] >= 40:
			GameData.progression["meta_currency"] -= 40
			GameData.unlock_character(id)
			break
	_refresh()

func _on_back_pressed() -> void:
	GameData.save_data()
	queue_free()
