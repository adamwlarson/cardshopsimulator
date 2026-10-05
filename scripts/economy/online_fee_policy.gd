class_name OnlineFeePolicy
extends RefCounted

## BE1: online listing settle cut at high Rep. ONLINE_HOLD sales only.
## Rep ≥ 75 uses 5% of sale cents; Rep ≤ 74 keeps today's `online_fee` (8%
## on Normal). Same roundi cents as today's fee path. Not a refund of
## past fees. Out: in-shop sales, buylist, distributor, auction Bid, trades.
const CUT_PERCENT := 5
const CUT_REP := 75
const BASE_PERCENT := 8


static func cut_percent(configured: int = 0) -> int:
	if configured <= 0:
		return CUT_PERCENT
	return configured


static func cut_rep(configured: int = 0) -> int:
	if configured <= 0:
		return CUT_REP
	return configured


static func base_rate(configured: float = -1.0) -> float:
	if configured <= 0.0:
		return float(BASE_PERCENT) / 100.0
	return configured


static func is_high_rep(reputation: int, configured_gate: int = 0) -> bool:
	return reputation >= cut_rep(configured_gate)


static func is_high_rep_for(reputation: int, config: BalanceConfig = null) -> bool:
	if config == null:
		return is_high_rep(reputation)
	return is_high_rep(reputation, config.online_high_rep_fee_gate)


static func fee_rate(
	reputation: int,
	configured_cut_percent: int = 0,
	configured_gate: int = 0,
	configured_base_rate: float = -1.0
) -> float:
	if is_high_rep(reputation, configured_gate):
		return float(cut_percent(configured_cut_percent)) / 100.0
	return base_rate(configured_base_rate)


static func fee_rate_for(
	reputation: int,
	config: BalanceConfig = null,
	configured_cut_percent: int = 0,
	configured_gate: int = 0
) -> float:
	if config == null:
		return fee_rate(reputation, configured_cut_percent, configured_gate)
	var cut := configured_cut_percent if configured_cut_percent > 0 else config.online_high_rep_fee_percent
	var gate := configured_gate if configured_gate > 0 else config.online_high_rep_fee_gate
	return fee_rate(reputation, cut, gate, config.online_fee)


static func fee_percent_for(
	reputation: int,
	config: BalanceConfig = null,
	configured_cut_percent: int = 0,
	configured_gate: int = 0
) -> int:
	return roundi(fee_rate_for(
		reputation,
		config,
		configured_cut_percent,
		configured_gate
	) * 100.0)


static func fee_cents_for(
	sale_price_cents: int,
	reputation: int,
	config: BalanceConfig = null,
	configured_cut_percent: int = 0,
	configured_gate: int = 0
) -> int:
	if sale_price_cents <= 0:
		return 0
	var rate := fee_rate_for(
		reputation,
		config,
		configured_cut_percent,
		configured_gate
	)
	if rate <= 0.0:
		return 0
	return maxi(1, roundi(float(sale_price_cents) * rate))
