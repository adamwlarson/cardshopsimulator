class_name PlayerTradePresenter
extends RefCounted


static func opportunity_row(offer: PlayerTradeOffer) -> String:
	if offer == null:
		return ""
	return "%s · %s\nGive %s · Receive %s" % [
		_offer_label(offer),
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
		return "SHOP TRADE"
	return "%s · %s" % [_offer_label(offer).to_upper(), offer.counterparty_label]


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
		"%s · %s" % [_offer_label(offer), offer.counterparty_label],
		"Give: %s ×%d · %s" % [
			_name_of(offer.give_display_name, offer.give_sku_id),
			offer.give_qty,
			offer.give_condition.strip_edges(),
		],
		"Receive: %s ×%d · %s" % [
			_name_of(offer.receive_display_name, offer.receive_sku_id),
			offer.receive_qty,
			offer.receive_condition.strip_edges(),
		],
		"Cash does not change.",
	])


static func _offer_label(offer: PlayerTradeOffer) -> String:
	var label := offer.offer_label.strip_edges()
	if label.is_empty():
		return PlayerTradePolicy.OFFER_LABEL
	return label


static func _name_of(display_name: String, sku_id: StringName) -> String:
	var name_text := display_name.strip_edges()
	if name_text.is_empty():
		return String(sku_id)
	return name_text


static func _lot_line(
	display_name: String,
	sku_id: StringName,
	condition: String,
	quantity: int
) -> String:
	var line := "%s · %s" % [_name_of(display_name, sku_id), condition.strip_edges()]
	if quantity > 1:
		line += " ×%d" % quantity
	return line
