class_name OnlineListConfirmSignal
extends PriceConfirmSignal

@export var fee_percent: float = 0.08
@export var fee_cents: int = 0
@export var ship_days_min: int = 1
@export var ship_days_max: int = 3
@export var unlocked: bool = false
@export var lock_reason: StringName = &""
