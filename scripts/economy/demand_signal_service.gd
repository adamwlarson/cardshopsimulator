class_name DemandSignalService
extends RefCounted

enum Channel {
	DISTRIBUTOR,
	BUYLIST,
	AUCTION,
	MARKETPLACE,
	SHADY,
}

const RESEARCH_NARROW_FACTOR := 0.55

var _config: BalanceConfig
var _rng := RandomNumberGenerator.new()
var _demand_cache: Dictionary = {}


func _init(config: BalanceConfig, rng_seed: int = 1) -> void:
	_config = config
	_rng.seed = rng_seed


func buy_confirm(
	day: int,
	sku_id: StringName,
	true_market_cents: int,
	true_demand: float,
	channel: Channel,
	unit_cost_cents: int,
	quantity: int,
	current_cash_cents: int,
	space_required: int,
	space_free: int,
	informed: bool = false
) -> BuyConfirmSignal:
	var signal := BuyConfirmSignal.new()
	var comp := _comp_range(true_market_cents, channel, informed)
	signal.sku_id = sku_id
	signal.unit_cost_cents = unit_cost_cents
	signal.lot_total_cents = unit_cost_cents * quantity
	signal.shown_comp_low_cents = comp.x
	signal.shown_comp_high_cents = comp.y
	signal.shown_demand_band = _shown_demand_band(day, sku_id, true_demand, informed)
	signal.confidence = _confidence(channel)
	signal.condition_cue = _condition_cue(channel)
	signal.remaining_cash_cents = current_cash_cents - signal.lot_total_cents
	signal.space_required = space_required
	signal.space_free = space_free
	signal.can_confirm = (
		quantity > 0
		and signal.remaining_cash_cents >= 0
		and space_required <= space_free
	)
	QaInstrumentation.record_demand_signal_shown(
		&"buy_confirm",
		signal,
		true_market_cents,
		_true_demand_band(true_demand)
	)
	return signal


func price_confirm(
	day: int,
	sku_id: StringName,
	true_market_cents: int,
	true_demand: float,
	listed_price_cents: int,
	location: InventoryLocation,
	channel: Channel = Channel.BUYLIST,
	informed: bool = false
) -> PriceConfirmSignal:
	var signal := PriceConfirmSignal.new()
	var comp := _comp_range(true_market_cents, channel, informed)
	var midpoint: int = (comp.x + comp.y) / 2
	signal.sku_id = sku_id
	signal.suggested_price_cents = midpoint
	signal.price_delta_cents = listed_price_cents - midpoint
	signal.price_delta_percent = (
		float(signal.price_delta_cents) / float(midpoint)
		if midpoint > 0
		else 0.0
	)
	signal.position = _position(signal.price_delta_percent)
	signal.shown_comp_low_cents = comp.x
	signal.shown_comp_high_cents = comp.y
	signal.shown_demand_band = _shown_demand_band(day, sku_id, true_demand, informed)
	signal.confidence = _confidence(channel)
	signal.move_feel = _move_feel(signal.price_delta_percent)
	signal.display_context = _display_context(location)
	QaInstrumentation.record_demand_signal_shown(
		&"price_confirm",
		signal,
		true_market_cents,
		_true_demand_band(true_demand),
		listed_price_cents
	)
	return signal


func _comp_range(
	true_market_cents: int,
	channel: Channel,
	informed: bool
) -> Vector2i:
	if true_market_cents <= 0:
		return Vector2i.ZERO
	var width := _channel_width(channel) * _config.comp_noise_width_mult
	if informed:
		width *= RESEARCH_NARROW_FACTOR
	var center_noise := _rng.randf_range(-width * 0.5, width * 0.5)
	var center := maxi(1, roundi(true_market_cents * (1.0 + center_noise)))
	var half_width := roundi(true_market_cents * width * 0.5)
	return Vector2i(maxi(1, center - half_width), maxi(1, center + half_width))


func _shown_demand_band(
	day: int,
	sku_id: StringName,
	true_demand: float,
	informed: bool
) -> StringName:
	var key := "%d:%s:%s" % [day, sku_id, informed]
	if _demand_cache.has(key):
		return _demand_cache[key] as StringName
	var sigma := 0.07 if informed else _config.demand_band_sigma
	var shown_score := clampf(true_demand + _rng.randfn(0.0, sigma), 0.0, 1.0)
	var shown_band := _true_demand_band(shown_score)
	var true_band := _true_demand_band(true_demand)
	if _config.fair_forbid_hot_cold_invert:
		if true_band == &"hot" and shown_band == &"cold":
			shown_band = &"steady"
		elif true_band == &"cold" and shown_band == &"hot":
			shown_band = &"warm"
	_demand_cache[key] = shown_band
	return shown_band


func _true_demand_band(score: float) -> StringName:
	if score < 0.25:
		return &"cold"
	if score < 0.55:
		return &"steady"
	if score <= 0.80:
		return &"warm"
	return &"hot"


func _channel_width(channel: Channel) -> float:
	match channel:
		Channel.DISTRIBUTOR:
			return 0.06
		Channel.BUYLIST:
			return 0.10
		Channel.AUCTION:
			return 0.12
		Channel.MARKETPLACE:
			return 0.15
		Channel.SHADY:
			return 0.22
	return 0.15


func _confidence(channel: Channel) -> StringName:
	if channel == Channel.DISTRIBUTOR:
		return &"high"
	if channel in [Channel.BUYLIST, Channel.AUCTION]:
		return &"medium"
	return &"low"


func _condition_cue(channel: Channel) -> String:
	if channel == Channel.DISTRIBUTOR:
		return "NM assumed"
	if channel in [Channel.MARKETPLACE, Channel.SHADY]:
		return "Photo only — inspect recommended"
	return "Mixed lot"


func _position(delta_percent: float) -> StringName:
	if delta_percent < -0.08:
		return &"undercut"
	if delta_percent > 0.08:
		return &"premium"
	return &"competitive"


func _move_feel(delta_percent: float) -> StringName:
	if delta_percent > 0.18:
		return &"walk_risk"
	if delta_percent > 0.08:
		return &"likely_sits"
	return &"should_move"


func _display_context(location: InventoryLocation) -> String:
	if location == null:
		return "Unassigned"
	match location.type:
		InventoryLocation.Type.CASE:
			return "Case boost"
		InventoryLocation.Type.BINDER:
			return "Binder"
		InventoryLocation.Type.BACKSTOCK:
			return "Backstock (pull only)"
		InventoryLocation.Type.ONLINE_HOLD:
			return "Online hold"
		InventoryLocation.Type.SHELF:
			return "Shelf"
	return "Unassigned"
