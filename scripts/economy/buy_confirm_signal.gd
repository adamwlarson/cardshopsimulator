class_name BuyConfirmSignal
extends Resource

@export var sku_id: StringName
@export var unit_cost_cents: int
@export var lot_total_cents: int
@export var shown_comp_low_cents: int
@export var shown_comp_high_cents: int
@export var shown_demand_band: StringName
@export var confidence: StringName
@export var condition_cue: String
@export var remaining_cash_cents: int
@export var space_required: int
@export var space_free: int
@export var can_confirm: bool
