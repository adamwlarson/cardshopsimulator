class_name NegotiatePolicy
extends RefCounted

## systems §5.2 sell-side Negotiate ±10%. CustomerServe when the
## customer is buying from the shop. One step: they take the nudge,
## or they walk. Out: buylist walk-ins, AU1 buy Counter, auction, trades.
const ATTENTION_COST := 8
const MISS_REP_DELTA := -1
const REP_BASE := 0.45
const REP_PER_POINT := 0.005
const DIRECTION_WEIGHT_MINUS := 1.15
const DIRECTION_WEIGHT_PLUS := 0.70
const ARCHETYPE_WEIGHT_KID := 1.10
const ARCHETYPE_WEIGHT_REGULAR := 1.05
const ARCHETYPE_WEIGHT_COLLECTOR := 1.00
const ARCHETYPE_WEIGHT_WHALE := 0.90
const ARCHETYPE_WEIGHT_FLIPPER := 0.85
const ARCHETYPE_WEIGHT_SPIKE := 0.70
const ARCHETYPE_WEIGHT_FALLBACK := 1.00
const DIRECTION_MINUS := -0.10
const DIRECTION_PLUS := 0.10
const UNSET_INT := 0x7fffffff
const RESULT_REFUSED := &"refused"
const RESULT_SOLD := &"sold"
const RESULT_WALKED := &"walked"
const ACTOR_OWNER := &"owner"
const ACTOR_CASHIER := &"cashier"


static func can_actor_negotiate(role: StringName) -> bool:
	return role == ACTOR_OWNER


static func can_negotiate_customer(customer: CustomerProfile) -> bool:
	if customer == null:
		return false
	return customer.trade_intent == CustomerProfile.TradeIntent.BUYING_FROM_SHOP


static func attention_cost(configured: int = UNSET_INT) -> int:
	if configured == UNSET_INT or configured < 0:
		return ATTENTION_COST
	return configured


static func miss_rep_delta(configured: int = UNSET_INT) -> int:
	if configured == UNSET_INT:
		return MISS_REP_DELTA
	return configured


static func direction_percent(percent_from_list: float) -> float:
	return DIRECTION_PLUS if percent_from_list > 0.0 else DIRECTION_MINUS


static func direction_weight(
	percent_from_list: float,
	configured: float = -1.0
) -> float:
	if configured > 0.0:
		return configured
	if percent_from_list > 0.0:
		return DIRECTION_WEIGHT_PLUS
	return DIRECTION_WEIGHT_MINUS


static func archetype_weight(
	archetype_id: StringName,
	configured: float = -1.0
) -> float:
	if configured > 0.0:
		return configured
	match _named_archetype(archetype_id):
		&"kid":
			return ARCHETYPE_WEIGHT_KID
		&"regular":
			return ARCHETYPE_WEIGHT_REGULAR
		&"collector":
			return ARCHETYPE_WEIGHT_COLLECTOR
		&"whale":
			return ARCHETYPE_WEIGHT_WHALE
		&"flipper":
			return ARCHETYPE_WEIGHT_FLIPPER
		&"spike":
			return ARCHETYPE_WEIGHT_SPIKE
		_:
			return ARCHETYPE_WEIGHT_FALLBACK


static func rep_term(reputation: int, configured: float = -1.0) -> float:
	if configured < 0.0:
		return REP_BASE + float(reputation) * REP_PER_POINT
	return configured


static func accept_chance(
	percent_from_list: float,
	reputation: int,
	archetype_id: StringName,
	configured_direction_weight: float = -1.0,
	configured_archetype_weight: float = -1.0,
	configured_rep_term: float = -1.0
) -> float:
	var dir_w := direction_weight(percent_from_list, configured_direction_weight)
	var arch_w := archetype_weight(archetype_id, configured_archetype_weight)
	var term := rep_term(reputation, configured_rep_term)
	return clampf(dir_w * term * arch_w, 0.0, 1.0)


static func customer_seed_key(customer: CustomerProfile) -> String:
	if customer == null:
		return ""
	return "%s|%s|%s|%d" % [
		customer.display_name,
		String(customer.archetype_id),
		String(customer.target_sku),
		customer.listed_price_cents,
	]


static func roll_seed(
	customer_key: String,
	day: int,
	percent_from_list: float
) -> int:
	var lane := 1 if percent_from_list > 0.0 else 0
	return _mix(customer_key.hash(), day, lane)


static func roll_accept(
	seed: int,
	percent_from_list: float,
	reputation: int,
	archetype_id: StringName,
	configured_direction_weight: float = -1.0,
	configured_archetype_weight: float = -1.0,
	configured_rep_term: float = -1.0
) -> bool:
	var chance := accept_chance(
		percent_from_list,
		reputation,
		archetype_id,
		configured_direction_weight,
		configured_archetype_weight,
		configured_rep_term
	)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed & 0x7fffffff
	return rng.randf() < chance


static func _named_archetype(archetype_id: StringName) -> StringName:
	var raw := String(archetype_id).to_lower().replace(" ", "_")
	raw = raw.replace("-", "_").replace("/", "_")
	match raw:
		"kid", "kid_parent", "kid__parent":
			return &"kid"
		"regular":
			return &"regular"
		"collector":
			return &"collector"
		"whale":
			return &"whale"
		"flipper":
			return &"flipper"
		"spike":
			return &"spike"
		_:
			return StringName(raw)


static func _mix(seed: int, day: int, lane: int) -> int:
	var mixed := (
		(int(seed) * 1664525)
		^ (int(day) * 22695477)
		^ (int(lane) * 1013904223)
	)
	return mixed & 0x7fffffff
