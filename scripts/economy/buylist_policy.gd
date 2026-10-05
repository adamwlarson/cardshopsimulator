class_name BuylistPolicy
extends RefCounted

## systems §3 / §4.3 / §5.2 buylist buy-from-them. CustomerServe when the
## customer is selling to the shop. One lot: You offer, Buy, Walk, and
## one Change offer. Out: AV1 shop-buy Negotiate, AU1 buy Counter,
## auction, trades, trunk.
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
