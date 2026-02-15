extends PanelContainer

signal closed(spent: int, selected_items: Array, selected_weapon: Dictionary)

var offers: Array[Dictionary] = []
var selected_items: Array[Dictionary] = []
var selected_weapon: Dictionary = {}
var budget := 0
var spent := 0
var player_ref: Node = null
var selected_weapon_offer: Dictionary = {}
var weapon_purchase_slot := 0

@onready var offers_list = $VBox/Offers
@onready var wallet_label = $VBox/Wallet
@onready var popup_panel = $Tooltip
@onready var popup_label = $Tooltip/Label
@onready var slot1_name = $VBox/WeaponRow/Slot1Name
@onready var slot2_name = $VBox/WeaponRow/Slot2Name
@onready var buy_slot1 = $VBox/WeaponRow/BuyTo1
@onready var buy_slot2 = $VBox/WeaponRow/BuyTo2

func build_offers(current_credits: int, player_node: Node) -> void:
	budget = current_credits
	spent = 0
	player_ref = player_node
	offers.clear()
	selected_items.clear()
	selected_weapon = {}
	selected_weapon_offer = {}
	popup_panel.visible = false

	for c in offers_list.get_children():
		c.queue_free()
	offers.append(ContentDB.random_weapon())
	for i in 3:
		offers.append(ContentDB.random_item())
	for slot in $VBox/Inventory.get_children():
		slot.set_item({})
	for offer in offers:
		var btn = Button.new()
		btn.text = "%s (%d)" % [offer["name"], offer["price"]]
		btn.mouse_entered.connect(_on_offer_hover.bind(offer, btn))
		btn.mouse_exited.connect(_on_offer_unhover)
		btn.focus_entered.connect(_on_offer_hover.bind(offer, btn))
		btn.pressed.connect(_on_offer_pressed.bind(offer))
		offers_list.add_child(btn)
	_refresh_weapon_row()
	_update_wallet()

func _describe_offer(offer: Dictionary) -> String:
	if offer.has("type"):
		return "Broń: %s\nTyp: %s\nObrażenia: %.1f\nSzybkostrzelność: %.2fs\n%s" % [offer["name"], offer["type"], offer.get("base_damage", 0.0), offer.get("rate", 0.0), ("Eksplozja: %.0f" % offer.get("explosion_radius", 0.0)) if offer.get("explosion_radius", 0.0) > 0.0 else ("Zasięg: %.0f" % offer.get("range", 60.0))]
	return "Przedmiot: %s\nEfekt: %+0.2f do %s\nCena rośnie po zakupie." % [offer["name"], float(offer.get("value", 0.0)), offer.get("stat", "unknown")]

func _on_offer_hover(offer: Dictionary, btn: Control) -> void:
	popup_label.text = _describe_offer(offer)
	popup_panel.visible = true
	popup_panel.global_position = btn.get_screen_position() + Vector2(btn.size.x + 16.0, -10.0)

func _on_offer_unhover() -> void:
	popup_panel.visible = false

func _on_offer_pressed(offer: Dictionary) -> void:
	if offer.has("type"):
		selected_weapon_offer = offer
		popup_label.text = _describe_offer(offer) + "\n\nWybierz slot 1/2 przyciskami obok."
		popup_panel.visible = true
		return

	if spent + offer["price"] > budget:
		return
	spent += offer["price"]
	selected_items.append(offer.duplicate(true))
	for slot in $VBox/Inventory.get_children():
		if slot.item.is_empty():
			slot.set_item(offer)
			break
	offer["price"] = int(ceil(float(offer["price"]) * 1.2))
	_refresh_offer_buttons()
	_update_wallet()

func _refresh_offer_buttons() -> void:
	var i := 0
	for btn in offers_list.get_children():
		if btn is Button and i < offers.size():
			btn.text = "%s (%d)" % [offers[i]["name"], offers[i]["price"]]
		i += 1

func _on_buy_to_1_pressed() -> void:
	weapon_purchase_slot = 0
	_buy_selected_weapon()

func _on_buy_to_2_pressed() -> void:
	weapon_purchase_slot = 1
	_buy_selected_weapon()

func _buy_selected_weapon() -> void:
	if selected_weapon_offer.is_empty() or player_ref == null:
		return
	var price = int(selected_weapon_offer.get("price", 0))
	if spent + price > budget:
		return
	spent += price
	player_ref.set_weapon_slot(weapon_purchase_slot, selected_weapon_offer)
	selected_weapon_offer["price"] = int(ceil(float(selected_weapon_offer["price"]) * 1.25))
	_refresh_offer_buttons()
	_refresh_weapon_row()
	_update_wallet()

func _on_sell_1_pressed() -> void:
	if player_ref == null:
		return
	var gain = player_ref.sell_weapon_slot(0)
	budget += gain
	_refresh_weapon_row()
	_update_wallet()

func _on_sell_2_pressed() -> void:
	if player_ref == null:
		return
	var gain = player_ref.sell_weapon_slot(1)
	budget += gain
	_refresh_weapon_row()
	_update_wallet()

func _refresh_weapon_row() -> void:
	if player_ref == null:
		slot1_name.text = "Slot 1: ---"
		slot2_name.text = "Slot 2: ---"
		return
	slot1_name.text = "Slot 1: %s" % player_ref.get_weapon_slot(0).get("name", "Pusty")
	slot2_name.text = "Slot 2: %s" % player_ref.get_weapon_slot(1).get("name", "Pusty")

func _on_continue_pressed() -> void:
	popup_panel.visible = false
	closed.emit(spent, selected_items, selected_weapon)

func _update_wallet() -> void:
	wallet_label.text = "Budżet sklepu: %d | Wydano: %d | Zostaje: %d" % [budget, spent, budget - spent]

func swap_back(target: Control, data: Dictionary) -> void:
	for node in $VBox/Inventory.get_children():
		if node != target and node.item.is_empty():
			node.set_item(data)
			return
