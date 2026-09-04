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
var _market_state: MarketState
var _rng := RandomNumberGenerator.new()
var _demand_cache: Dictionary = {}
var _instrumentation: QaInstrumentationService


func _init(
	config: BalanceConfig,
	market_state: MarketState,
	rng_seed: int = 1,
	instrumentation: QaInstrumentationService = null
) -> void:
	_config = config
	_market_state = market_state
	_rng.seed = rng_seed
	_instrumentation = instrumentation
	if _instrumentation == null:
		var main_loop := Engine.get_main_loop()
		if main_loop is SceneTree:
			_instrumentation = (main_loop as SceneTree).root.get_node_or_null(
				"QaInstrumentation"
			) as QaInstrumentationService


func buy_confirm(
	day: int,
	sku_id: StringName,
	channel: Channel,
	unit_cost_cents: int,
	quantity: int,
	current_cash_cents: int,
	space_required: int,
	space_free: int,
	informed: bool = false
) -> BuyConfirmSignal:
	var dto := BuyConfirmSignal.new()
	var true_market_cents := _market_state.market_cents_for(sku_id)
	var true_demand := _market_state.demand_score_for(sku_id)
	var comp := _comp_range(true_market_cents, channel, informed)
	dto.sku_id = sku_id
	dto.unit_cost_cents = unit_cost_cents
	dto.lot_total_cents = unit_cost_cents * quantity
	dto.shown_comp_low_cents = comp.x
	dto.shown_comp_high_cents = comp.y
	dto.shown_demand_band = _shown_demand_band(day, sku_id, true_demand, informed)
	dto.confidence = _confidence(channel)
	dto.condition_cue = _condition_cue(channel)
	dto.remaining_cash_cents = current_cash_cents - dto.lot_total_cents
	dto.space_required = space_required
	dto.space_free = space_free
	dto.can_confirm = (
		quantity > 0
		and dto.remaining_cash_cents >= 0
		and space_required <= space_free
	)
	if _instrumentation != null:
		_instrumentation.record_demand_signal_shown(
			&"buy_confirm",
			dto,
			true_market_cents,
			_true_demand_band(true_demand)
		)
	return dto


func price_confirm(
	day: int,
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation,
	channel: Channel = Channel.BUYLIST,
	informed: bool = false
) -> PriceConfirmSignal:
	var dto := PriceConfirmSignal.new()
	var true_market_cents := _market_state.market_cents_for(sku_id)
	var true_demand := _market_state.demand_score_for(sku_id)
	var comp := _comp_range(true_market_cents, channel, informed)
	var midpoint: int = (comp.x + comp.y) / 2
	dto.sku_id = sku_id
	dto.suggested_price_cents = midpoint
	dto.price_delta_cents = listed_price_cents - midpoint
	dto.price_delta_percent = (
		float(dto.price_delta_cents) / float(midpoint)
		if midpoint > 0
		else 0.0
	)
	dto.position = _position(dto.price_delta_percent)
	dto.shown_comp_low_cents = comp.x
	dto.shown_comp_high_cents = comp.y
	dto.shown_demand_band = _shown_demand_band(day, sku_id, true_demand, informed)
	dto.confidence = _confidence(channel)
	dto.move_feel = _move_feel(dto.price_delta_percent)
	dto.display_context = _display_context(location)
	if _instrumentation != null:
		_instrumentation.record_demand_signal_shown(
			&"price_confirm",
			dto,
			true_market_cents,
			_true_demand_band(true_demand),
			listed_price_cents
		)
	return dto


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
