extends PanelContainer

var item: Dictionary = {}
@onready var label = $Label

func set_item(data: Dictionary) -> void:
	item = data
	label.text = data.get("name", "Empty")

func _get_drag_data(_at_position: Vector2) -> Variant:
	if item.is_empty():
		return null
	var preview = Label.new()
	preview.text = item["name"]
	set_drag_preview(preview)
	return item

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var swap = item
	set_item(data)
	if get_parent().has_method("swap_back"):
		get_parent().swap_back(self, swap)
