class_name BuyOpportunity
extends Resource

@export var id: StringName
@export var sku_id: StringName
@export var display_name: String
@export var offer_label: String
@export var channel: DemandSignalService.Channel
@export var unit_cost_cents: int
@export var quantity: int
@export var space_required: int = 1
@export var beat_id: StringName


func is_valid() -> bool:
	return (
		not id.is_empty()
		and not sku_id.is_empty()
		and not display_name.is_empty()
		and unit_cost_cents > 0
		and quantity > 0
		and space_required > 0
	)
