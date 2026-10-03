class_name PlayerTradeOffer
extends Resource

var id: StringName
var give_sku_id: StringName
var give_display_name: String
var give_condition: String
var give_qty: int = 1
var receive_sku_id: StringName
var receive_display_name: String
var receive_condition: String
var receive_qty: int = 1
var counterparty_label: String = "Another shop"


func is_valid() -> bool:
	return (
		not id.is_empty()
		and not give_sku_id.is_empty()
		and not receive_sku_id.is_empty()
		and give_qty > 0
		and receive_qty > 0
		and not give_condition.is_empty()
		and not receive_condition.is_empty()
	)
