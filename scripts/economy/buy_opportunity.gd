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
@export var grader: StringName
@export_range(0.0, 10.0, 0.5) var grade: float = 0.0
## Test/QA seed only. -1 = roll from channel rate; 0 = fake; 1 = valid.
var seeded_cert_state: int = -1


func is_graded() -> bool:
	return not grader.is_empty() and grade > 0.0


func is_valid() -> bool:
	return (
		not id.is_empty()
		and not sku_id.is_empty()
		and not display_name.is_empty()
		and unit_cost_cents > 0
		and quantity > 0
		and space_required > 0
	)
