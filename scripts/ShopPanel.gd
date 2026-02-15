extends PanelContainer

signal closed(spent: int, selected_items: Array, selected_weapon: Dictionary)

var offers: Array[Dictionary] = []
var selected_items: Array[Dictionary] = []
var selected_weapon: Dictionary = {}
var budget := 0
var spent := 0

@onready var offers_list = $VBox/Offers
@onready var wallet_label = $VBox/Wallet
@onready var description_label = $VBox/Description

func build_offers(current_credits: int) -> void:
	budget = current_credits
	spent = 0
	offers.clear()
	selected_items.clear()
	selected_weapon = {}
	description_label.text = "Hover item/weapon to see effects."
	for c in offers_list.get_children():
		c.queue_free()
	offers.append(ContentDB.random_weapon())
	for i in 3:
		offers.append(ContentDB.random_item())
	for slot in $VBox/Inventory.get_children():
		slot.set_item({})
	for offer in offers:
		var btn = Button.new()
		btn.text = "%s ($%d)" % [offer["name"], offer["price"]]
		btn.mouse_entered.connect(_on_offer_hover.bind(offer))
		btn.focus_entered.connect(_on_offer_hover.bind(offer))
		btn.pressed.connect(_on_offer_pressed.bind(offer))
		offers_list.add_child(btn)
	_update_wallet()

func _describe_offer(offer: Dictionary) -> String:
	if offer.has("type"):
		return "Weapon: %s\nType: %s\nDamage: %.1f\nRate: %.2fs\n%s" % [offer["name"], offer["type"], offer.get("base_damage", 0.0), offer.get("rate", 0.0), ("Projectile speed: %.0f" % offer.get("proj_speed", 0.0)) if offer["type"] != "melee" else ("Melee range: %.0f" % offer.get("range", 60.0))]
	return "Item: %s\nEffect: %+0.2f to %s" % [offer["name"], float(offer.get("value", 0.0)), offer.get("stat", "unknown")]

func _on_offer_hover(offer: Dictionary) -> void:
	description_label.text = _describe_offer(offer)

func _on_offer_pressed(offer: Dictionary) -> void:
	if spent + offer["price"] > budget:
		return
	spent += offer["price"]
	if offer.has("type"):
		selected_weapon = offer
	else:
		selected_items.append(offer)
		for slot in $VBox/Inventory.get_children():
			if slot.item.is_empty():
				slot.set_item(offer)
				break
	_update_wallet()

func _on_continue_pressed() -> void:
	closed.emit(spent, selected_items, selected_weapon)

func _update_wallet() -> void:
	wallet_label.text = "Shop Budget: %d | Spent: %d" % [budget, spent]

func swap_back(target: Control, data: Dictionary) -> void:
	for node in $VBox/Inventory.get_children():
		if node != target and node.item.is_empty():
			node.set_item(data)
			return
