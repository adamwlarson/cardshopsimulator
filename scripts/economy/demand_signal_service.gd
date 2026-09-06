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
const SET_DISPLAY_NAMES := {
	"AA-BASE": "Aether Arc: Foundations",
	"AA-SKIE": "Skiefall Ascension",
	"AA-DUST": "Dustway Chronicles",
}
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
var _true_cert_by_key: Dictionary = {}
var _inspect_cue_by_key: Dictionary = {}
var _research_by_set: Dictionary = {}
var _fog_flag: bool = false
var _fog_sigma_mult: float = 1.0
var _counterfeit_scare: bool = false
var _scare_trust_mult: float = 1.0
var _scare_shady_fake_mult: float = 1.0
var _scare_shady_width_mult: float = 1.0
var _recession_week: bool = false
var _recession_demand_mult: float = 1.0
var _supply_glut: bool = false
var _glut_race_mult: float = 1.0
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


func set_fog_event(active: bool, sigma_mult: float = 1.5) -> void:
	_fog_flag = active
	_fog_sigma_mult = sigma_mult if active else 1.0
	_demand_cache.clear()


func has_fog_flag() -> bool:
	return _fog_flag


func set_counterfeit_scare(
	active: bool,
	trust_mult: float = 0.55,
	shady_fake_mult: float = 2.5,
	shady_width_mult: float = 1.35
) -> void:
	_counterfeit_scare = active
	_scare_trust_mult = trust_mult if active else 1.0
	_scare_shady_fake_mult = shady_fake_mult if active else 1.0
	_scare_shady_width_mult = shady_width_mult if active else 1.0
	_demand_cache.clear()


func has_counterfeit_scare() -> bool:
	return _counterfeit_scare


func set_recession_week(active: bool, demand_mult: float = 0.65) -> void:
	_recession_week = active
	_recession_demand_mult = demand_mult if active else 1.0
	_demand_cache.clear()


func has_recession_week() -> bool:
	return _recession_week


func set_supply_glut(active: bool, race_mult: float = 0.90) -> void:
	_supply_glut = active
	_glut_race_mult = race_mult if active else 1.0
	_demand_cache.clear()


func has_supply_glut() -> bool:
	return _supply_glut


func sealed_race_mult() -> float:
	return _glut_race_mult if _supply_glut else 1.0


func demand_mult() -> float:
	return _recession_demand_mult if _recession_week else 1.0


func effective_demand_score_for(sku_id: StringName) -> float:
	return _effective_demand(_market_state.demand_score_for(sku_id))


func effective_demand_band_for(sku_id: StringName) -> StringName:
	return _true_demand_band(effective_demand_score_for(sku_id))


func graded_trust_mult() -> float:
	return _scare_trust_mult if _counterfeit_scare else 1.0


func requires_owned_slab_inspect() -> bool:
	return _counterfeit_scare


func is_inspect_mandatory(dto: BuyConfirmSignal) -> bool:
	return _counterfeit_scare and _is_graded_signal(dto)


func recommends_inspect_for(dto: BuyConfirmSignal) -> bool:
	if dto == null:
		return false
	if recommends_inspect(dto.channel):
		return true
	return is_inspect_mandatory(dto)


func active_fake_slab_rate(channel: Variant = Channel.SHADY) -> float:
	return _fake_slab_rate(channel)


func shady_width_mult() -> float:
	return _scare_shady_width_mult if _counterfeit_scare else 1.0


func refresh_confirm_gate(dto: BuyConfirmSignal) -> void:
	if dto == null:
		return
	var qty_ok := dto.quantity > 0 or dto.lot_total_cents > 0
	var affordable := (
		qty_ok
		and dto.remaining_cash_cents >= 0
		and dto.space_required <= dto.space_free
	)
	dto.can_confirm = (
		affordable
		and not (is_inspect_mandatory(dto) and not dto.inspected)
	)


func active_demand_band_sigma(informed: bool = false) -> float:
	var sigma := _informed_sigma() if informed else _base_sigma()
	return sigma * _fog_sigma_mult


func clear_forced_demand_band(sku_id: StringName) -> void:
	_forced_band_by_sku.erase(sku_id)
	for key: Variant in _demand_cache.keys():
		if String(key).contains(":%s:" % sku_id):
			_demand_cache.erase(key)


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
	var true_demand := _effective_demand(_market_state.demand_score_for(sku_id))
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
	dto.grader = &""
	dto.grade = 0.0
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
			_true_demand_band(true_demand),
			-1,
			_skill_instrumentation(informed)
		)
	apply_inspect_state(dto)
	refresh_confirm_gate(dto)
	return dto


static func recommends_inspect(channel: Variant) -> bool:
	var resolved := channel_from(channel)
	return resolved in [
		Channel.MARKETPLACE,
		Channel.SHADY,
		Channel.BUYLIST,
		Channel.AUCTION,
	]


static func is_risky_slab_channel(channel: Variant) -> bool:
	var resolved := channel_from(channel)
	return resolved in [Channel.SHADY, Channel.AUCTION]


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
		and recommends_inspect_for(dto)
	)


func apply_inspect_state(dto: BuyConfirmSignal) -> void:
	if dto == null:
		return
	var key := _inspect_key(dto)
	if not _inspect_cue_by_key.has(key):
		return
	dto.condition_cue = String(_inspect_cue_by_key[key])
	dto.inspected = true
	refresh_confirm_gate(dto)


func display_name_for_set(set_id: StringName) -> String:
	var key := String(set_id)
	if SET_DISPLAY_NAMES.has(key):
		return String(SET_DISPLAY_NAMES[key])
	if key.is_empty():
		return "Unknown set"
	return key.replace("-", " ")


func is_set_informed(set_id: StringName, day: int) -> bool:
	if set_id.is_empty():
		return false
	var entry: Dictionary = _research_by_set.get(String(set_id), {})
	return day <= int(entry.get("through_day", -1))


func active_rotation_watches(day: int) -> PackedStringArray:
	var watches: PackedStringArray = []
	for set_key: Variant in _research_by_set.keys():
		var entry: Dictionary = _research_by_set[set_key]
		if day <= int(entry.get("telegraph_through_day", -1)):
			watches.append(
				"Rotation watch: %s" % display_name_for_set(StringName(String(set_key)))
			)
	return watches


func research_snapshot(set_id: StringName, day: int) -> Dictionary:
	var entry: Dictionary = _research_by_set.get(String(set_id), {})
	return {
		"set_id": String(set_id),
		"display_name": display_name_for_set(set_id),
		"informed": is_set_informed(set_id, day),
		"through_day": int(entry.get("through_day", -1)),
		"telegraph_through_day": int(entry.get("telegraph_through_day", -1)),
		"demand_band_sigma": _informed_sigma(),
		"comp_narrow_factor": _narrow_factor(),
	}


func apply_research(set_id: StringName, day: int, duration_days: int = -1) -> Dictionary:
	if set_id.is_empty():
		return {}
	var span := _research_duration_days(duration_days)
	var through_day := day + span - 1
	_research_by_set[String(set_id)] = {
		"through_day": through_day,
		"telegraph_through_day": through_day,
	}
	return research_snapshot(set_id, day)


func _research_duration_days(requested: int) -> int:
	var min_days := 1
	var max_days := 3
	if _config != null:
		min_days = maxi(1, _config.research_duration_days_min)
		max_days = maxi(min_days, _config.research_duration_days_max)
	if requested >= 1:
		return clampi(requested, min_days, max_days)
	var span := maxi(0, max_days - min_days)
	return min_days + (_rng.randi() % (span + 1))


func _skill_instrumentation(informed: bool) -> Dictionary:
	return {
		"informed": informed,
		"demand_band_sigma": active_demand_band_sigma(informed),
		"comp_narrow_factor": _narrow_factor() if informed else 1.0,
	}


func _narrow_factor() -> float:
	if _config != null:
		return _config.research_comp_narrow_factor
	return RESEARCH_NARROW_FACTOR


func _informed_sigma() -> float:
	if _config != null:
		return _config.research_demand_band_sigma
	return 0.07


func _base_sigma() -> float:
	if _config != null:
		return _config.demand_band_sigma
	return 0.12


func inspect_condition(dto: BuyConfirmSignal) -> bool:
	if not can_inspect(dto):
		return false
	var key := _inspect_key(dto)
	if _inspect_cue_by_key.has(key):
		apply_inspect_state(dto)
		return true
	var cue := ""
	if _is_graded_signal(dto):
		cue = _inspect_cert_cue(dto)
	else:
		var true_index := _true_grade_index(dto)
		var shown_index := true_index
		if not _inspect_hits():
			shown_index = _misleading_grade_index(true_index)
		cue = CONDITION_GRADE_CUES[shown_index]
	dto.condition_cue = cue
	dto.inspected = true
	_inspect_cue_by_key[key] = cue
	refresh_confirm_gate(dto)
	return true


func inspect_slab_instance(slab: SlabInstance) -> bool:
	if slab == null or slab.inspected:
		return false
	var revealed_valid := slab.cert_valid
	if not _inspect_hits():
		revealed_valid = not slab.cert_valid
	slab.apply_inspect_cue(revealed_valid)
	return true


func bind_graded_signal(
	dto: BuyConfirmSignal,
	grader: StringName,
	grade: float,
	seeded_cert_state: int = -1
) -> void:
	if dto == null or grader.is_empty() or grade <= 0.0:
		return
	dto.grader = grader
	dto.grade = grade
	if not dto.inspected:
		dto.condition_cue = _graded_fog_cue(channel_from(dto.channel))
	if seeded_cert_state >= 0:
		_true_cert_by_key[_inspect_key(dto)] = seeded_cert_state == 1
	true_cert_valid(dto)
	if _counterfeit_scare:
		dto.confidence = _downgrade_confidence(dto.confidence)
	refresh_confirm_gate(dto)


func true_cert_valid(dto: BuyConfirmSignal) -> bool:
	var key := _inspect_key(dto)
	if _true_cert_by_key.has(key):
		return bool(_true_cert_by_key[key])
	var valid := true
	if is_risky_slab_channel(dto.channel):
		valid = _rng.randf() >= _fake_slab_rate(dto.channel)
	_true_cert_by_key[key] = valid
	return valid


func apply_inspect_to_slab(dto: BuyConfirmSignal, slab: SlabInstance) -> void:
	if dto == null or slab == null:
		return
	slab.cert_valid = true_cert_valid(dto)
	slab.source_channel = dto.channel
	if dto.inspected:
		slab.inspected = true
		slab.shown_cert_cue = dto.condition_cue
	else:
		slab.shown_cert_cue = SlabInstance.CERT_FOG_CUE


func price_confirm(
	day: int,
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation,
	channel: Channel = Channel.BUYLIST,
	informed: bool = false
) -> PriceConfirmSignal:
	var dto := PriceConfirmSignal.new()
	_populate_price_fields(
		dto,
		day,
		sku_id,
		listed_price_cents,
		location,
		channel,
		informed,
		&"price_confirm"
	)
	return dto


func list_confirm(
	day: int,
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation,
	informed: bool = false
) -> OnlineListConfirmSignal:
	var dto := OnlineListConfirmSignal.new()
	_populate_price_fields(
		dto,
		day,
		sku_id,
		listed_price_cents,
		location,
		Channel.MARKETPLACE,
		informed,
		&"list_confirm"
	)
	dto.fee_percent = _config.online_fee
	dto.fee_cents = OnlineListingService.fee_cents_for(
		listed_price_cents,
		_config.online_fee
	)
	dto.ship_days_min = _config.online_ship_days_min
	dto.ship_days_max = _config.online_ship_days_max
	dto.unlocked = GameState.current_reputation >= _config.online_unlock_rep
	dto.lock_reason = &"" if dto.unlocked else &"rep_locked"
	return dto


func refresh_list_confirm(
	dto: OnlineListConfirmSignal,
	listed_price_cents: int,
	location: InventoryLocation
) -> OnlineListConfirmSignal:
	if dto == null:
		return null
	refresh_price_confirm(dto, listed_price_cents, location)
	dto.fee_cents = OnlineListingService.fee_cents_for(
		listed_price_cents,
		dto.fee_percent
	)
	return dto


func _populate_price_fields(
	dto: PriceConfirmSignal,
	day: int,
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation,
	channel: Channel,
	informed: bool,
	screen: StringName
) -> void:
	var true_market_cents := _retail_market_cents(sku_id)
	var true_demand := _effective_demand(_market_state.demand_score_for(sku_id))
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
			screen,
			dto,
			true_market_cents,
			_true_demand_band(true_demand),
			listed_price_cents,
			_skill_instrumentation(informed)
		)


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
		width *= _narrow_factor()
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
	var key := "%d:%s:%s:%s" % [day, sku_id, informed, _fog_flag]
	if _demand_cache.has(key):
		return _demand_cache[key] as StringName
	var sigma := active_demand_band_sigma(informed)
	var shown_score := clampf(true_demand + _rng.randfn(0.0, sigma), 0.0, 1.0)
	var shown_band := _true_demand_band(shown_score)
	var true_band := _true_demand_band(true_demand)
	if _should_forbid_hot_cold_invert():
		if true_band == &"hot" and shown_band == &"cold":
			shown_band = &"steady"
		elif true_band == &"cold" and shown_band == &"hot":
			shown_band = &"warm"
	_demand_cache[key] = shown_band
	return shown_band


func _should_forbid_hot_cold_invert() -> bool:
	if _config == null:
		return not _fog_flag
	return _config.fair_forbid_hot_cold_invert and not _fog_flag


func _retail_market_cents(sku_id: StringName) -> int:
	var true_market_cents := _market_state.market_cents_for(sku_id)
	if true_market_cents <= 0 or not _supply_glut:
		return true_market_cents
	if not _is_sealed_sku(sku_id):
		return true_market_cents
	return maxi(1, roundi(float(true_market_cents) * sealed_race_mult()))


func _is_sealed_sku(sku_id: StringName) -> bool:
	if sku_id.is_empty():
		return false
	var sku := InventoryService.model.get_sku(sku_id)
	return sku != null and sku.product_class == ProductSKU.ProductClass.SEALED


func _effective_demand(score: float) -> float:
	return clampf(score * demand_mult(), 0.0, 1.0)


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
			return 0.22 * _active_shady_width_mult()
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
		if _counterfeit_scare:
			return "Photo only — counterfeit scare · inspect strongly recommended"
		return "Photo only — inspect strongly recommended"
	if channel == Channel.MARKETPLACE:
		return "Photo only — inspect recommended"
	if channel == Channel.AUCTION:
		return "Mixed lot"
	return "Mixed lot"


func _graded_fog_cue(channel: Channel) -> String:
	if channel == Channel.SHADY:
		if _counterfeit_scare:
			return "Photo only — counterfeit scare · inspect strongly recommended"
		return "Photo only — inspect strongly recommended"
	if _counterfeit_scare:
		return "Slab — inspect mandatory"
	if channel == Channel.AUCTION:
		return "Slab — inspect recommended"
	return SlabInstance.CERT_FOG_CUE


func _is_graded_signal(dto: BuyConfirmSignal) -> bool:
	return dto != null and not dto.grader.is_empty() and dto.grade > 0.0


func _inspect_hits() -> bool:
	var accuracy := 0.85
	if _config != null:
		accuracy = _config.inspect_accuracy
	return _rng.randf() < accuracy


func _inspect_cert_cue(dto: BuyConfirmSignal) -> String:
	var authentic := true_cert_valid(dto)
	var revealed := authentic
	if not _inspect_hits():
		revealed = not authentic
	return SlabInstance.cue_for_revealed(revealed)


func _fake_slab_rate(channel: Variant = Channel.SHADY) -> float:
	var rate := 0.08
	if _config != null:
		rate = _config.shady_fake_slab_rate
	if _counterfeit_scare and channel_from(channel) == Channel.SHADY:
		rate = minf(1.0, rate * _scare_shady_fake_mult)
	return rate


func roll_risky_slab_cert(channel: Variant = Channel.SHADY) -> bool:
	return _rng.randf() >= _fake_slab_rate(channel)


func _downgrade_confidence(confidence: StringName) -> StringName:
	match confidence:
		&"high":
			return &"medium"
		&"medium":
			return &"low"
	return &"low"


func _active_shady_width_mult() -> float:
	return _scare_shady_width_mult if _counterfeit_scare else 1.0


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
