class_name NmMismatchPolicy
extends RefCounted

## BB1/BD1 sell-side uninspected NM mismatch. Shop sale of a marketplace /
## shady / auction single that skipped Inspect and listed NM while true is LP+.
## Soft Rep −2 once and claw back half the sale. Stock stays sold.
## Out: distributor NM-assumed, buylist, graded/`cert_valid` (AT1),
## inspected lots, listed true-or-worse. Not a sell weight.
const REP_HIT := 2
const REFUND_FRACTION := 0.50
const UNSET_INT := BuylistPolicy.UNSET_INT
const LEDGER_CATEGORY := &"condition_mismatch"
const LEDGER_MEMO := "Uninspected NM mismatch refund"


static func is_fog_channel(channel: Variant) -> bool:
	if MarketplaceInspectPolicy.is_channel(channel):
		return true
	if typeof(channel) == TYPE_INT:
		return channel == DemandSignalService.Channel.AUCTION
	return String(channel).to_lower() == "auction"


static func listed_presents_as_nm(card: CardInstance) -> bool:
	return card != null and card.listed_condition == CardInstance.Condition.NM


static func true_worse_than_nm(card: CardInstance) -> bool:
	return card != null and int(card.condition) > int(CardInstance.Condition.NM)


static func listed_true_or_worse(card: CardInstance) -> bool:
	if card == null:
		return false
	return int(card.listed_condition) >= int(card.condition)


static func applies_to(card: CardInstance) -> bool:
	if card == null:
		return false
	if card.mismatch_fired:
		return false
	if card.inspected:
		return false
	return is_fog_channel(card.source_channel)


static func should_fire(card: CardInstance) -> bool:
	if not applies_to(card):
		return false
	if not listed_presents_as_nm(card):
		return false
	return true_worse_than_nm(card)


static func rep_hit(configured: int = UNSET_INT) -> int:
	if configured == UNSET_INT or configured <= 0:
		return REP_HIT
	return configured


static func rep_hit_for(config: BalanceConfig = null) -> int:
	if config == null:
		return REP_HIT
	return rep_hit(config.uninspected_nm_mismatch_rep_hit)


static func refund_fraction(configured: float = -1.0) -> float:
	if configured <= 0.0:
		return REFUND_FRACTION
	return configured


static func refund_fraction_for(config: BalanceConfig = null) -> float:
	if config == null:
		return REFUND_FRACTION
	return refund_fraction(config.uninspected_nm_mismatch_refund_fraction)


static func refund_cents(
	sale_price_cents: int,
	configured_fraction: float = -1.0
) -> int:
	if sale_price_cents <= 0:
		return 0
	return maxi(0, roundi(float(sale_price_cents) * refund_fraction(configured_fraction)))


static func refund_cents_for(
	sale_price_cents: int,
	config: BalanceConfig = null
) -> int:
	return refund_cents(sale_price_cents, refund_fraction_for(config))


static func stamp_acquired_card(dto: BuyConfirmSignal, card: CardInstance) -> void:
	if card == null or dto == null:
		return
	card.source_channel = dto.channel
	card.inspected = dto.inspected
	card.mismatch_fired = false
