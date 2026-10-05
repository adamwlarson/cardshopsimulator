class_name AuctionInspectPolicy
extends RefCounted

## BC1 auction snipe Inspect fog. AS1 Bid / Decline prep offer only.
## Owner Inspect is 5 Att; Specialist on duty (hired + present;
## missing duty → 5) cuts that to 2. Paid when taken. Cashier cannot
## Inspect. Reveal reuses the AZ1/BA1 85/15 adjacent band. Out:
## buylist Inspect (AY1/AZ1), marketplace/shady Inspect (BA1),
## distributor, trades, trunk, non-snipe auction lots.
const FOG_CUE := AuctionSnipePolicy.CONDITION_CUE
const ACTOR_OWNER := BuylistPolicy.ACTOR_OWNER
const ACTOR_CASHIER := BuylistPolicy.ACTOR_CASHIER


static func is_snipe(dto: BuyConfirmSignal) -> bool:
	return dto != null and AuctionSnipePolicy.is_snipe_id(dto.opportunity_id)


static func applies_to(dto: BuyConfirmSignal) -> bool:
	return is_snipe(dto)


static func attention_cost(
	specialist_on_duty: Variant = null,
	owner_configured: int = BuylistPolicy.UNSET_INT,
	specialist_configured: int = BuylistPolicy.UNSET_INT
) -> int:
	return BuylistPolicy.attention_cost(
		specialist_on_duty,
		owner_configured,
		specialist_configured
	)


static func attention_cost_for(
	shop: ShopState = null,
	config: BalanceConfig = null
) -> int:
	return BuylistPolicy.attention_cost_for(shop, config)


static func can_actor_inspect(role: StringName) -> bool:
	return BuylistPolicy.can_actor_inspect(role)


static func can_inspect(
	dto: BuyConfirmSignal,
	acting_role: StringName = ACTOR_OWNER
) -> bool:
	if not applies_to(dto):
		return false
	if dto.inspected:
		return false
	return can_actor_inspect(acting_role)


static func ensure_lot_condition(dto: BuyConfirmSignal, day: int = 1) -> void:
	if not applies_to(dto):
		return
	BuylistPolicy.ensure_lot_condition(dto, day)


static func apply_fog_cue(dto: BuyConfirmSignal) -> void:
	if not applies_to(dto) or dto.inspected:
		return
	dto.condition_cue = FOG_CUE


static func apply_inspect(
	dto: BuyConfirmSignal,
	day: int = 1,
	configured_accuracy: float = -1.0
) -> bool:
	if not can_inspect(dto):
		return false
	return BuylistPolicy.apply_inspect(dto, day, configured_accuracy)


static func lot_condition_of(dto: BuyConfirmSignal) -> CardInstance.Condition:
	return BuylistPolicy.lot_condition_of(dto)


static func apply_true_condition(
	dto: BuyConfirmSignal,
	card: CardInstance,
	day: int = 1
) -> void:
	if card == null or not applies_to(dto):
		return
	ensure_lot_condition(dto, day)
	card.condition = lot_condition_of(dto)


static func apply_true_condition_to_stock(
	dto: BuyConfirmSignal,
	lot: StockLot,
	day: int = 1
) -> void:
	if lot == null or not applies_to(dto):
		return
	ensure_lot_condition(dto, day)
	lot.condition = lot_condition_of(dto)
