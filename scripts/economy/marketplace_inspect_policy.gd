class_name MarketplaceInspectPolicy
extends RefCounted

## BA1 marketplace / shady Buy Inspect. BuyOpportunityDetail and shady
## trunk Buy only. Owner Inspect is 5 Att; Specialist on duty (hired +
## present; missing duty → 5) cuts that to 2. Out: buylist Inspect
## (AY1/AZ1), distributor, auction, trades, trunk Report/Walk.
const FOG_CUE := "Photo only — inspect recommended"
const ACTOR_OWNER := BuylistPolicy.ACTOR_OWNER
const ACTOR_CASHIER := BuylistPolicy.ACTOR_CASHIER


static func is_channel(channel: Variant) -> bool:
	if typeof(channel) == TYPE_INT:
		return (
			channel == DemandSignalService.Channel.MARKETPLACE
			or channel == DemandSignalService.Channel.SHADY
		)
	match String(channel).to_lower():
		"marketplace", "shady":
			return true
		_:
			return false


static func applies_to(dto: BuyConfirmSignal) -> bool:
	return dto != null and is_channel(dto.channel)


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
	if String(dto.channel).to_lower() == "shady":
		if dto.condition_cue.strip_edges().is_empty():
			dto.condition_cue = ShadyTrunkPolicy.CONDITION_CUE
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
