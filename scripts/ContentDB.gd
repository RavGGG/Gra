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
		{"name":"Blaster", "type":"ranged", "base_damage":8.0, "rate":0.55, "proj_speed":520.0},
		{"name":"Needler", "type":"ranged", "base_damage":4.0, "rate":0.15, "proj_speed":760.0},
		{"name":"Arc Wand", "type":"special", "base_damage":11.0, "rate":0.7, "proj_speed":420.0},
		{"name":"Boomstick", "type":"ranged", "base_damage":15.0, "rate":0.9, "proj_speed":460.0},
		{"name":"Pan", "type":"melee", "base_damage":13.0, "rate":0.5, "range":55.0}
	]
	for i in WEAPON_COUNT:
		var template = templates[i % templates.size()].duplicate()
		template["id"] = "weapon_%d" % i
		template["name"] = "%s %d" % [template["name"], i + 1]
		template["tier"] = 1 + int(i / 10)
		template["price"] = 15 + template["tier"] * 6
		weapon_defs.append(template)

func _generate_items() -> void:
	var pool = [
		{"name":"Spice Rack", "stat":"damage", "value":0.08},
		{"name":"Gym Socks", "stat":"speed", "value":8.0},
		{"name":"Battery Pack", "stat":"fire_rate", "value":-0.04},
		{"name":"Starch Shield", "stat":"armor", "value":1.0},
		{"name":"Nano Patch", "stat":"max_health", "value":5.0},
		{"name":"Magnet", "stat":"pickup_radius", "value":24.0},
		{"name":"Blood Siphon", "stat":"lifesteal", "value":0.02}
	]
	for i in ITEM_COUNT:
		var entry = pool[i % pool.size()].duplicate()
		entry["id"] = "item_%d" % i
		entry["name"] = "%s %d" % [entry["name"], i + 1]
		entry["price"] = 10 + int(i / 5) * 3
		item_defs.append(entry)

func random_weapon() -> Dictionary:
	return weapon_defs.pick_random().duplicate(true)

func random_item() -> Dictionary:
	return item_defs.pick_random().duplicate(true)
