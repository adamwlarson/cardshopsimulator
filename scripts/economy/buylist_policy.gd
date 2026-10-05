class_name BuylistPolicy
extends RefCounted

## systems §3 / §4.3 / §5.2 buylist buy-from-them. CustomerServe when the
## customer is selling to the shop. One lot: You offer, Buy, Walk,
## one Change offer, and one optional Inspect. Out: AV1 shop-buy
## Negotiate, AU1 buy Counter, auction, trades, trunk, marketplace
## Inspect★.
const PCT_SEALED := 0.55
const PCT_SINGLES_NM := 0.50
const PCT_GRADED := 0.45
const PCT_FALLBACK := 0.50
const COMP_WIDTH := 0.10
const ANGER_FLOOR := 0.40
const MISS_REP_DELTA := -1
const MIN_OFFER_CENTS := 1
const CONFIDENCE := &"medium"
const CATEGORY_SEALED := &"sealed"
const CATEGORY_SINGLES_NM := &"singles_nm"
const CATEGORY_GRADED := &"graded"
const UNSET_INT := 0x7fffffff
const ATTENTION_COST := 5
const ACCURACY := 0.85
const FOG_CUE := "Inspect optional"
const ACTOR_OWNER := &"owner"
const ACTOR_CASHIER := &"cashier"
const BAND_LABELS: PackedStringArray = ["NM", "LP", "MP", "HP", "DMG"]


static func category_for(
	sku: ProductSKU,
	dto: BuyConfirmSignal = null
) -> StringName:
	if is_graded_lot(dto):
		return CATEGORY_GRADED
	if sku == null:
		return &""
	match sku.product_class:
		ProductSKU.ProductClass.SEALED:
			return CATEGORY_SEALED
		ProductSKU.ProductClass.SINGLE:
			return CATEGORY_SINGLES_NM
		ProductSKU.ProductClass.GRADED:
			return CATEGORY_GRADED
		_:
			return &""


static func is_graded_lot(dto: BuyConfirmSignal) -> bool:
	return (
		dto != null
		and not String(dto.grader).is_empty()
		and dto.grade > 0.0
	)


static func buylist_pct(category: Variant, configured: float = -1.0) -> float:
	if configured >= 0.0:
		return configured
	match _named_category(category):
		CATEGORY_SEALED:
			return PCT_SEALED
		CATEGORY_SINGLES_NM:
			return PCT_SINGLES_NM
		CATEGORY_GRADED:
			return PCT_GRADED
		_:
			return PCT_FALLBACK


static func comp_width(configured: float = 0.0) -> float:
	if configured <= 0.0:
		return COMP_WIDTH
	return configured


static func anger_floor(configured: float = -1.0) -> float:
	if configured < 0.0:
		return ANGER_FLOOR
	return configured


static func miss_rep_delta(configured: int = UNSET_INT) -> int:
	if configured == UNSET_INT:
		return MISS_REP_DELTA
	return configured


static func listed_comp_cents(dto: BuyConfirmSignal) -> int:
	if dto == null:
		return 0
	var low := dto.shown_comp_low_cents
	var high := dto.shown_comp_high_cents
	if high <= 0 and low <= 0:
		return 0
	return (low + high) / 2


static func offer_cents(
	listed_comp_cents: int,
	category: Variant,
	configured_pct: float = -1.0
) -> int:
	if listed_comp_cents <= 0:
		return 0
	return maxi(
		MIN_OFFER_CENTS,
		roundi(float(listed_comp_cents) * buylist_pct(category, configured_pct))
	)


static func is_stingy(
	offer_cents: int,
	listed_comp_cents: int,
	configured_floor: float = -1.0
) -> bool:
	if listed_comp_cents <= 0 or offer_cents <= 0:
		return false
	return (
		float(offer_cents) / float(listed_comp_cents)
		< anger_floor(configured_floor)
	)


static func is_valid_change(offer_cents: int) -> bool:
	return offer_cents >= MIN_OFFER_CENTS


static func can_change_offer(customer: CustomerProfile) -> bool:
	return (
		customer != null
		and customer.trade_intent == CustomerProfile.TradeIntent.SELLING_TO_SHOP
		and customer.buylist_signal != null
		and not customer.has_changed_offer
	)


static func apply_offer_cents(dto: BuyConfirmSignal, offer_cents: int) -> void:
	if dto == null:
		return
	dto.unit_cost_cents = offer_cents
	dto.lot_total_cents = offer_cents * maxi(1, dto.quantity)


static func attention_cost(configured: int = UNSET_INT) -> int:
	if configured == UNSET_INT or configured < 0:
		return ATTENTION_COST
	return configured


static func accuracy(configured: float = -1.0) -> float:
	if configured < 0.0:
		return ACCURACY
	return clampf(configured, 0.0, 1.0)


static func can_actor_inspect(role: StringName) -> bool:
	return role == ACTOR_OWNER


static func can_inspect(
	customer: CustomerProfile,
	acting_role: StringName = ACTOR_OWNER
) -> bool:
	if customer == null or customer.buylist_signal == null:
		return false
	if customer.trade_intent != CustomerProfile.TradeIntent.SELLING_TO_SHOP:
		return false
	if customer.has_inspected or customer.buylist_signal.inspected:
		return false
	return can_actor_inspect(acting_role)


static func band_label(band: CardInstance.Condition) -> String:
	var index := clampi(int(band), 0, BAND_LABELS.size() - 1)
	return BAND_LABELS[index]


static func band_from_cue(cue: String) -> CardInstance.Condition:
	var index := BAND_LABELS.find(cue.strip_edges())
	if index < 0:
		return CardInstance.Condition.NM
	return index as CardInstance.Condition


static func is_adjacent_band(
	left: CardInstance.Condition,
	right: CardInstance.Condition
) -> bool:
	return absi(int(left) - int(right)) == 1


static func lot_condition_of(dto: BuyConfirmSignal) -> CardInstance.Condition:
	if dto == null:
		return CardInstance.Condition.NM
	return dto.lot_condition


static func ensure_lot_condition(dto: BuyConfirmSignal, day: int = 1) -> void:
	if dto == null or dto.lot_condition_ready:
		return
	dto.lot_condition = roll_true_band(condition_seed(dto, day))
	dto.lot_condition_ready = true


static func apply_fog_cue(dto: BuyConfirmSignal) -> void:
	if dto == null or dto.inspected:
		return
	dto.condition_cue = FOG_CUE


static func apply_inspect(
	dto: BuyConfirmSignal,
	day: int = 1,
	configured_accuracy: float = -1.0
) -> bool:
	if dto == null or dto.inspected:
		return false
	ensure_lot_condition(dto, day)
	var shown := revealed_band(
		dto.lot_condition,
		reveal_seed(dto, day),
		configured_accuracy
	)
	dto.condition_cue = band_label(shown)
	dto.inspected = true
	return true


static func condition_seed(dto: BuyConfirmSignal, day: int) -> int:
	return _mix(_dto_key(dto).hash(), day, 0)


static func reveal_seed(dto: BuyConfirmSignal, day: int) -> int:
	return _mix(_dto_key(dto).hash(), day, 1)


static func roll_true_band(seed: int) -> CardInstance.Condition:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed & 0x7fffffff
	var roll := rng.randf()
	if roll < 0.20:
		return CardInstance.Condition.NM
	if roll < 0.50:
		return CardInstance.Condition.LP
	if roll < 0.80:
		return CardInstance.Condition.MP
	if roll < 0.93:
		return CardInstance.Condition.HP
	return CardInstance.Condition.DMG


static func revealed_band(
	true_band: CardInstance.Condition,
	seed: int,
	configured_accuracy: float = -1.0
) -> CardInstance.Condition:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed & 0x7fffffff
	if rng.randf() < accuracy(configured_accuracy):
		return true_band
	return _adjacent_band(true_band, rng)


static func _adjacent_band(
	true_band: CardInstance.Condition,
	rng: RandomNumberGenerator
) -> CardInstance.Condition:
	var last_index := BAND_LABELS.size() - 1
	var true_index := clampi(int(true_band), 0, last_index)
	var delta := 1 if rng.randf() < 0.5 else -1
	var shown := clampi(true_index + delta, 0, last_index)
	if shown == true_index:
		shown = clampi(true_index + (1 if true_index == 0 else -1), 0, last_index)
	return shown as CardInstance.Condition


static func _dto_key(dto: BuyConfirmSignal) -> String:
	if dto == null:
		return ""
	var identity := String(dto.opportunity_id)
	if identity.is_empty():
		identity = "%s|%s" % [String(dto.sku_id), String(dto.channel)]
	return identity


static func _mix(seed: int, day: int, lane: int) -> int:
	var mixed := (
		(int(seed) * 1664525)
		^ (int(day) * 22695477)
		^ (int(lane) * 1013904223)
	)
	return mixed & 0x7fffffff


static func _named_category(category: Variant) -> StringName:
	if typeof(category) == TYPE_INT:
		match category as ProductSKU.ProductClass:
			ProductSKU.ProductClass.SEALED:
				return CATEGORY_SEALED
			ProductSKU.ProductClass.SINGLE:
				return CATEGORY_SINGLES_NM
			ProductSKU.ProductClass.GRADED:
				return CATEGORY_GRADED
			_:
				return &""
	var raw := String(category).to_lower().replace(" ", "_")
	raw = raw.replace("-", "_").replace("/", "_")
	match raw:
		"sealed":
			return CATEGORY_SEALED
		"singles_nm", "single", "singles", "nm":
			return CATEGORY_SINGLES_NM
		"graded", "slab":
			return CATEGORY_GRADED
		_:
			return StringName(raw)
