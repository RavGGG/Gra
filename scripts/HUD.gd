extends Control

@onready var hp_bar = $Margin/VBox/HP
@onready var wave_label = $Margin/VBox/Wave
@onready var credits_label = $Margin/VBox/Credits

func update_hp(value: float, max_value: float) -> void:
	hp_bar.max_value = max_value
	hp_bar.value = value

func update_wave(wave: int, time_left: float) -> void:
	wave_label.text = "Wave %d  |  %.0fs" % [wave, time_left]

func update_credits(value: int) -> void:
	credits_label.text = "Materials: %d" % value
