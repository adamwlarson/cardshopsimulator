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
const CONDITION_GRADE_CUES: PackedStringArray = [
	"Looks NM",
	"Light wear",
	"Moderate wear",
	"Heavy wear",
	"Damaged",
]

var _config: BalanceConfig
var _market_state: MarketState
var _rng := RandomNumberGenerator.new()
var _demand_cache: Dictionary = {}
var _forced_band_by_sku: Dictionary = {}
var _true_grade_by_key: Dictionary = {}
var _inspect_cue_by_key: Dictionary = {}
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


func force_demand_band(
	sku_id: StringName,
	band: StringName,
	through_day: int
) -> void:
	_forced_band_by_sku[sku_id] = {
		"band": band,
		"through_day": through_day,
	}
	for key: Variant in _demand_cache.keys():
		if String(key).contains(":%s:" % sku_id):
			_demand_cache.erase(key)


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
	dto.channel = StringName(Channel.keys()[channel].to_lower())
	dto.condition_cue = _condition_cue(channel)
	dto.inspected = false
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
	apply_inspect_state(dto)
	return dto


static func recommends_inspect(channel: Variant) -> bool:
	var resolved := channel_from(channel)
	return resolved in [Channel.MARKETPLACE, Channel.SHADY, Channel.BUYLIST]


static func channel_from(channel: Variant) -> Channel:
	if typeof(channel) == TYPE_INT:
		return channel as Channel
	match String(channel).to_lower():
		"distributor":
			return Channel.DISTRIBUTOR
		"buylist":
			return Channel.BUYLIST
		"auction":
			return Channel.AUCTION
		"shady":
			return Channel.SHADY
	return Channel.MARKETPLACE


func can_inspect(dto: BuyConfirmSignal) -> bool:
	return (
		dto != null
		and not dto.inspected
		and recommends_inspect(dto.channel)
	)


func apply_inspect_state(dto: BuyConfirmSignal) -> void:
	if dto == null:
		return
	var key := _inspect_key(dto)
	if not _inspect_cue_by_key.has(key):
		return
	dto.condition_cue = String(_inspect_cue_by_key[key])
	dto.inspected = true


func inspect_condition(dto: BuyConfirmSignal) -> bool:
	if not can_inspect(dto):
		return false
	var key := _inspect_key(dto)
	if _inspect_cue_by_key.has(key):
		apply_inspect_state(dto)
		return true
	var true_index := _true_grade_index(dto)
	var accuracy := 0.85
	if _config != null:
		accuracy = _config.inspect_accuracy
	var success := _rng.randf() < accuracy
	var shown_index := true_index
	if not success:
		shown_index = _misleading_grade_index(true_index)
	var cue := CONDITION_GRADE_CUES[shown_index]
	dto.condition_cue = cue
	dto.inspected = true
	_inspect_cue_by_key[key] = cue
	return true


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
	dto.listed_price_cents = listed_price_cents
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


func refresh_price_confirm(
	dto: PriceConfirmSignal,
	listed_price_cents: int,
	location: InventoryLocation
) -> PriceConfirmSignal:
	if dto == null:
		return null
	dto.listed_price_cents = listed_price_cents
	dto.price_delta_cents = listed_price_cents - dto.suggested_price_cents
	dto.price_delta_percent = (
		float(dto.price_delta_cents) / float(dto.suggested_price_cents)
		if dto.suggested_price_cents > 0
		else 0.0
	)
	dto.position = _position(dto.price_delta_percent)
	dto.move_feel = _move_feel(dto.price_delta_percent)
	dto.display_context = _display_context(location)
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
	var forced: Dictionary = _forced_band_by_sku.get(sku_id, {})
	if day <= int(forced.get("through_day", -1)):
		return StringName(forced.get("band", &""))
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
	if channel == Channel.SHADY:
		return "Photo only — inspect strongly recommended"
	if channel == Channel.MARKETPLACE:
		return "Photo only — inspect recommended"
	return "Mixed lot"


func _inspect_key(dto: BuyConfirmSignal) -> String:
	if not String(dto.opportunity_id).is_empty():
		return "id:%s" % String(dto.opportunity_id)
	return "sku:%s:%s" % [String(dto.sku_id), String(dto.channel)]


func _true_grade_index(dto: BuyConfirmSignal) -> int:
	var key := _inspect_key(dto)
	if _true_grade_by_key.has(key):
		return int(_true_grade_by_key[key])
	var roll := _rng.randf()
	var index := 1
	match channel_from(dto.channel):
		Channel.SHADY:
			if roll < 0.15:
				index = 0
			elif roll < 0.40:
				index = 1
			elif roll < 0.70:
				index = 2
			elif roll < 0.90:
				index = 3
			else:
				index = 4
		_:
			if roll < 0.20:
				index = 0
			elif roll < 0.50:
				index = 1
			elif roll < 0.80:
				index = 2
			elif roll < 0.93:
				index = 3
			else:
				index = 4
	_true_grade_by_key[key] = index
	return index


func _misleading_grade_index(true_index: int) -> int:
	var last_index := CONDITION_GRADE_CUES.size() - 1
	var delta := 1 if _rng.randf() < 0.5 else -1
	var shown := clampi(true_index + delta, 0, last_index)
	if shown == true_index:
		shown = clampi(true_index + (1 if true_index == 0 else -1), 0, last_index)
	return shown


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
