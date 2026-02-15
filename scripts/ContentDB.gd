extends Node

const WEAPON_COUNT := 40
const ITEM_COUNT := 50

var weapon_defs: Array[Dictionary] = []
var item_defs: Array[Dictionary] = []

func _ready() -> void:
	_generate_weapons()
	_generate_items()

func _generate_weapons() -> void:
	var templates = [
		{"name":"Pistolet", "type":"ranged", "style":"pistol", "base_damage":16.0, "rate":0.45, "proj_speed":620.0, "price":22},
		{"name":"Karabin", "type":"ranged", "style":"rifle", "base_damage":6.0, "rate":0.12, "proj_speed":820.0, "price":24},
		{"name":"Bazooka", "type":"special", "style":"bazooka", "base_damage":20.0, "rate":0.95, "proj_speed":460.0, "explosion_radius":90.0, "price":34},
		{"name":"Miecz", "type":"melee", "style":"sword", "base_damage":14.0, "rate":0.28, "range":78.0, "price":26},
		{"name":"Włócznia", "type":"melee", "style":"spear", "base_damage":18.0, "rate":0.5, "range":100.0, "price":30}
	]
	for i in WEAPON_COUNT:
		var t = templates[i % templates.size()].duplicate(true)
		t["id"] = "weapon_%d" % i
		t["name"] = "%s %d" % [t["name"], i + 1]
		t["tier"] = 1 + int(i / 10)
		t["price"] += t["tier"] * 4
		weapon_defs.append(t)

func _generate_items() -> void:
	var pool = [
		{"name":"Ostry sos", "stat":"damage", "value":0.08},
		{"name":"Buty biegacza", "stat":"speed", "value":8.0},
		{"name":"Mechanizm zamka", "stat":"fire_rate", "value":-0.03},
		{"name":"Pancerz skrobi", "stat":"armor", "value":1.0},
		{"name":"Nanoplasty", "stat":"max_health", "value":5.0},
		{"name":"Magnes", "stat":"pickup_radius", "value":24.0},
		{"name":"Wampiryzm", "stat":"lifesteal", "value":0.02}
	]
	for i in ITEM_COUNT:
		var entry = pool[i % pool.size()].duplicate(true)
		entry["id"] = "item_%d" % i
		entry["name"] = "%s %d" % [entry["name"], i + 1]
		entry["price"] = 10 + int(i / 5) * 3
		item_defs.append(entry)

func random_weapon() -> Dictionary:
	return weapon_defs.pick_random().duplicate(true)

func random_item() -> Dictionary:
	return item_defs.pick_random().duplicate(true)

func starter_weapon(style: String) -> Dictionary:
	for w in weapon_defs:
		if w.get("style", "") == style:
			return w.duplicate(true)
	return random_weapon()
