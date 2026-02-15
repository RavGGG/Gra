extends Control

@onready var hp_bar = $Margin/VBox/HP
@onready var wave_label = $Margin/VBox/Wave
@onready var credits_label = $Margin/VBox/Credits
@onready var weapons_label = $Margin/VBox/Weapons

func update_hp(value: float, max_value: float) -> void:
	hp_bar.max_value = max_value
	hp_bar.value = value

func update_wave(wave: int, time_left: float) -> void:
	wave_label.text = "Fala %d  |  %.0fs" % [wave, time_left]

func update_credits(value: int) -> void:
	credits_label.text = "Materiały: %d" % value

func update_weapon_slots(slot1: String, slot2: String, active_slot: int) -> void:
	weapons_label.text = "[1] %s  |  [2] %s   (Aktywna: %d)" % [slot1, slot2, active_slot + 1]
