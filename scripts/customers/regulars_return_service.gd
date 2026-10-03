class_name RegularsReturnService
extends RefCounted

var _queued: int = 0
var _unlock_rep: int = RegularsReturnPolicy.UNLOCK_REP
var _queue_cap: int = RegularsReturnPolicy.QUEUE_CAP
var _catalog := CustomerArchetypeCatalog.new()


func reset() -> void:
	_queued = 0
	_unlock_rep = RegularsReturnPolicy.UNLOCK_REP
	_queue_cap = RegularsReturnPolicy.QUEUE_CAP


func configure(unlock_rep: int, queue_cap: int) -> void:
	_unlock_rep = unlock_rep
	_queue_cap = queue_cap


func queued_count() -> int:
	return _queued


func unlock_rep() -> int:
	return RegularsReturnPolicy.unlock_rep(_unlock_rep)


func queue_cap() -> int:
	return RegularsReturnPolicy.queue_cap(_queue_cap)


func note_listed_sale(reputation: int) -> bool:
	if not RegularsReturnPolicy.can_queue(
		reputation,
		_queued,
		_unlock_rep,
		_queue_cap
	):
		return false
	_queued += 1
	return true


func note_outcome(
	customer: CustomerProfile,
	outcome: StringName,
	reputation: int
) -> bool:
	if not _paid_listed_price(customer, outcome):
		return false
	return note_listed_sale(reputation)


func take_floor_return() -> CustomerProfile:
	if _queued <= 0:
		return null
	_queued -= 1
	return build_return_customer()


func build_return_customer() -> CustomerProfile:
	var archetype := _regular_archetype()
	var customer := CustomerProfile.new()
	customer.archetype_id = RegularsReturnPolicy.ARCHETYPE_ID
	customer.display_name = String(archetype.get("display_name", "Regular"))
	customer.is_regular_return = true
	var budget_range: Array = archetype.get("budget_range_cents", [700, 9000])
	customer.budget_cents = _range_mid_int(budget_range, 700, 9000)
	var patience_range: Array = archetype.get(
		"patience_range_seconds",
		[70, 130]
	)
	customer.patience_seconds = _range_mid_float(patience_range, 70.0, 130.0)
	for tag: Variant in archetype.get("interest_tags", []):
		customer.interest_tags.append(StringName(tag))
	return customer


func _paid_listed_price(customer: CustomerProfile, outcome: StringName) -> bool:
	if outcome != &"sold" or customer == null:
		return false
	if customer.has_negotiated:
		return false
	return customer.listed_price_cents > 0


func _regular_archetype() -> Dictionary:
	for archetype: Dictionary in _catalog.archetypes:
		if StringName(archetype.get("id", "")) == RegularsReturnPolicy.ARCHETYPE_ID:
			return archetype
	return {}


func _range_mid_int(values: Array, fallback_low: int, fallback_high: int) -> int:
	if values.size() < 2:
		return int((fallback_low + fallback_high) / 2)
	return int((int(values[0]) + int(values[1])) / 2)


func _range_mid_float(values: Array, fallback_low: float, fallback_high: float) -> float:
	if values.size() < 2:
		return (fallback_low + fallback_high) * 0.5
	return (float(values[0]) + float(values[1])) * 0.5
