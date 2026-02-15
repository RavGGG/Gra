extends Node

const SAVE_PATH := "user://savegame.json"

var locale := "en"
var master_volume := 0.8

var progression := {
	"meta_currency": 0,
	"unlocked_characters": ["scout"],
	"best_wave": 0,
	"perks": {
		"bonus_health": 0,
		"bonus_damage": 0,
		"bonus_speed": 0
	}
}

var character_defs := {
	"scout": {"label":"Scout Spud", "health":80.0, "speed":240.0, "damage":1.0, "ability":"Dash cooldown reduced"},
	"tank": {"label":"Bulwark", "health":140.0, "speed":170.0, "damage":0.9, "ability":"+2 armor"},
	"sniper": {"label":"Longshot", "health":75.0, "speed":200.0, "damage":1.35, "ability":"High crit chance"},
	"engineer": {"label":"Wrencher", "health":95.0, "speed":210.0, "damage":1.1, "ability":"Deploys mini-turret"},
	"pyro": {"label":"Charbroil", "health":90.0, "speed":220.0, "damage":1.2, "ability":"Burn DOT"},
	"vampire": {"label":"Hemospud", "health":85.0, "speed":215.0, "damage":1.15, "ability":"Lifesteal bonus"}
}

func _ready() -> void:
	load_data()

func apply_meta_bonus(base: Dictionary) -> Dictionary:
	var result = base.duplicate(true)
	result["health"] += progression["perks"]["bonus_health"] * 5.0
	result["damage"] += progression["perks"]["bonus_damage"] * 0.05
	result["speed"] += progression["perks"]["bonus_speed"] * 4.0
	return result

func is_character_unlocked(id: String) -> bool:
	return progression["unlocked_characters"].has(id)

func unlock_character(id: String) -> void:
	if not progression["unlocked_characters"].has(id):
		progression["unlocked_characters"].append(id)
		save_data()

func add_meta_currency(value: int) -> void:
	progression["meta_currency"] += value

func buy_meta_perk(key: String) -> bool:
	if progression["meta_currency"] < 20:
		return false
	progression["meta_currency"] -= 20
	progression["perks"][key] += 1
	save_data()
	return true

func save_data() -> void:
	var payload = {
		"locale": locale,
		"master_volume": master_volume,
		"progression": progression
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload))

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		locale = parsed.get("locale", locale)
		master_volume = parsed.get("master_volume", master_volume)
		var progress = parsed.get("progression", {})
		for k in progress.keys():
			progression[k] = progress[k]
