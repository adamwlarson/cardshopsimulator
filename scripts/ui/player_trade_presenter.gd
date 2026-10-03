class_name PlayerTradePresenter
extends RefCounted


static func opportunity_row(offer: PlayerTradeOffer) -> String:
	if offer == null:
		return ""
	return "Player trade · %s\nGive %s · Receive %s" % [
		offer.counterparty_label,
		_lot_line(offer.give_display_name, offer.give_sku_id, offer.give_condition, offer.give_qty),
		_lot_line(
			offer.receive_display_name,
			offer.receive_sku_id,
			offer.receive_condition,
			offer.receive_qty
		),
	]


static func detail_title(offer: PlayerTradeOffer) -> String:
	if offer == null:
		return "PLAYER TRADE"
	return "TRADE · %s" % offer.counterparty_label


static func detail_summary(offer: PlayerTradeOffer) -> String:
	if offer == null:
		return ""
	return "\n".join([
		"%s wants a straight swap." % offer.counterparty_label,
		"Give: %s" % _lot_line(
			offer.give_display_name,
			offer.give_sku_id,
			offer.give_condition,
			offer.give_qty
		),
		"Receive: %s" % _lot_line(
			offer.receive_display_name,
			offer.receive_sku_id,
			offer.receive_condition,
			offer.receive_qty
		),
		"Received lot goes to BACKSTOCK. Cash does not change.",
	])


static func confirm_snapshot(offer: PlayerTradeOffer) -> String:
	if offer == null:
		return ""
	return "\n".join([
		"Swap %s for %s." % [
			_lot_line(
				offer.give_display_name,
				offer.give_sku_id,
				offer.give_condition,
				offer.give_qty
			),
			_lot_line(
				offer.receive_display_name,
				offer.receive_sku_id,
				offer.receive_condition,
				offer.receive_qty
			),
		],
		"Cash does not change.",
	])


static func _lot_line(
	display_name: String,
	sku_id: StringName,
	condition: String,
	quantity: int
) -> String:
	var name_text := display_name.strip_edges()
	if name_text.is_empty():
		name_text = String(sku_id)
	var line := "%s · %s" % [name_text, condition.strip_edges()]
	if quantity > 1:
		line += " ×%d" % quantity
	return line
