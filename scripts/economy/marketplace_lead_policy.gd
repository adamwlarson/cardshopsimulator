class_name MarketplaceLeadPolicy
extends RefCounted

## systems §5.3 band 75–100. Integer gate: Rep ≥ 75 adds one extra
## marketplace lead on top of today's list. Rep ≤ 74 keeps today's
## leads. Ask is the low end of today's marketplace band (40% of the
## same market basis today's leads already use). Not a fee cut and
## not a door-spawn change.
const HIGH_REP_MIN_REP := 75
const EXTRA_LEAD_COUNT := 1
const ASK_RATE := 0.40
const EXTRA_LEAD_ID := &"high-rep-marketplace-lead"
const DEFAULT_SKU_ID := &"AA-DUST-ETB"
const OFFER_LABEL := "Marketplace lot"


static func is_high_rep(reputation: int) -> bool:
	return reputation >= HIGH_REP_MIN_REP


static func extra_lead_count(configured: int = EXTRA_LEAD_COUNT) -> int:
	if configured <= 0:
		return EXTRA_LEAD_COUNT
	return configured


static func ask_rate(configured: float = ASK_RATE) -> float:
	if configured <= 0.0:
		return ASK_RATE
	return configured


static func extra_leads_for(
	reputation: int,
	configured_count: int = EXTRA_LEAD_COUNT
) -> int:
	if not is_high_rep(reputation):
		return 0
	return extra_lead_count(configured_count)


static func ask_cents(basis_cents: int, configured_rate: float = ASK_RATE) -> int:
	if basis_cents <= 0:
		return 0
	return maxi(1, roundi(float(basis_cents) * ask_rate(configured_rate)))


static func extra_lead_id(index: int = 0) -> StringName:
	if index <= 0:
		return EXTRA_LEAD_ID
	return StringName("%s-%d" % [String(EXTRA_LEAD_ID), index + 1])


static func is_extra_lead_id(opportunity_id: StringName) -> bool:
	var raw := String(opportunity_id)
	return raw == String(EXTRA_LEAD_ID) or raw.begins_with("%s-" % String(EXTRA_LEAD_ID))
