class_name OnlineListing
extends RefCounted

enum Kind {
	LOT,
	CARD,
	SLAB,
}

enum Status {
	ACTIVE,
	FILLED,
	CANCELLED,
}

var id: StringName
var kind: Kind = Kind.LOT
var sku_id: StringName
var display_name: String = ""
var quantity: int = 1
var listed_price_cents: int = 0
var fee_cents: int = 0
var ship_days: int = 1
var remaining_days: int = 1
var listed_on_day: int = 1
var previous_location: InventoryLocation
var status: Status = Status.ACTIVE
var card: CardInstance
var slab: SlabInstance


func is_active() -> bool:
	return status == Status.ACTIVE


func net_proceeds_cents() -> int:
	return maxi(0, listed_price_cents - fee_cents)
