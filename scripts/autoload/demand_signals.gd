extends Node

const EVENT_PRICE_BRIDGE := &"event_price_bridge"
const MARKET_DRIFT_SEED := 20261003
const BUYLIST_OFFER_PLACEHOLDER_CENTS := 1

var _market_state := MarketState.new()
var _service: DemandSignalService
var _opportunity_catalog := BuyOpportunityCatalog.new()
var _closed_opportunity_ids: Dictionary = {}
var _haggle_spent_ids: Dictionary = {}
var _scripted_opportunities: Array[BuyOpportunity] = []
var _event_service := MarketEventService.new()
var _active_event: MarketEvent
var _pending_rotation_crash_set_id: StringName = &""
var _player_trades := PlayerTradeService.new()
var _regulars := RegularsReturnService.new()
var _drift_rng := RandomNumberGenerator.new()
var _noisy_suggested := NoisySuggestedCache.new()


func _ready() -> void:
	_ensure_regulars_bus()


func reset() -> void:
	_market_state = MarketState.new()
	_closed_opportunity_ids.clear()
	_haggle_spent_ids.clear()
	_scripted_opportunities.clear()
	_player_trades.reset()
	_regulars.reset()
	clear_cached_noisy_suggested()
	_ensure_regulars_bus()
	_event_service.reset(MarketEventService.EVENT_RNG_SEED)
	_drift_rng.seed = MARKET_DRIFT_SEED
	_active_event = null
	_pending_rotation_crash_set_id = &""
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku == null:
			continue
		_market_state.update_sku(sku.id, sku.base_market_cents, _default_demand_score(sku))
	_service = DemandSignalService.new(
		GameState.balance_config,
		_market_state,
		GameState.current_day * 7919,
		QaInstrumentation
	)
	_publish_event_changed()


func apply_hype_event(
	sku_id: StringName,
	through_day: int,
	market_multiplier: float = MarketEventService.HYPE_MARKET_MULT
) -> bool:
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null or _service == null:
		return false
	_market_state.update_sku(
		sku_id,
		maxi(
			sku.base_market_cents,
			roundi(float(sku.base_market_cents) * market_multiplier)
		),
		MarketEventService.HYPE_DEMAND_SCORE
	)
	_service.force_demand_band(sku_id, &"hot", through_day)
	return true


func apply_soft_shelf_signal(sku_id: StringName, through_day: int) -> bool:
	if InventoryService.model.get_sku(sku_id) == null or _service == null:
		return false
	_service.force_demand_band(sku_id, &"steady", through_day)
	return true


func seed_market_drift_rng(rng_seed: int) -> void:
	_drift_rng.seed = rng_seed


func apply_daily_market_drift() -> Dictionary:
	var config := GameState.balance_config
	var drifted := 0
	for sku_id: StringName in _market_state.live_sku_ids():
		var sku: ProductSKU = null
		if InventoryService.model != null:
			sku = InventoryService.model.get_sku(sku_id)
		var product_class := (
			sku.product_class if sku != null else ProductSKU.ProductClass.SEALED
		)
		var band := (
			config.market_drift_range(product_class)
			if config != null
			else Vector2(0.98, 1.02)
		)
		var multiplier := _drift_rng.randf_range(band.x, band.y)
		if _market_state.apply_multiplier(sku_id, multiplier) > 0:
			drifted += 1
	# BL1: AR1 overnight drift invalidates yesterday's noisy stickers so
	# the next HUD / PriceConfirm / BK1 read re-derives today's §4.5.
	clear_cached_noisy_suggested()
	return {"drifted": drifted}


func roll_settle_events() -> Dictionary:
	var scheduled_crash_set := &""
	if _active_event != null and _active_event.is_active():
		_active_event.remaining_days -= 1
		if not _active_event.is_active():
			if _active_event.kind == MarketEvent.KIND_ROTATION:
				scheduled_crash_set = _active_event.set_id
				if scheduled_crash_set.is_empty():
					scheduled_crash_set = _pending_rotation_crash_set_id
			_clear_active_event()
		elif _active_event.kind == MarketEvent.KIND_PRO_TOUR:
			_sync_pro_tour_service(_active_event)
	if _active_event != null and _active_event.is_active():
		return _record_roll(_active_event, false)
	if scheduled_crash_set.is_empty():
		scheduled_crash_set = _pending_rotation_crash_set_id
	if not scheduled_crash_set.is_empty():
		_pending_rotation_crash_set_id = &""
		var follow_on := start_pack_event(
			MarketEvent.KIND_ROTATION_CRASH,
			{
				"set_id": scheduled_crash_set,
				"duration_days": RotationCrashPolicy.duration_days_for(
					GameState.balance_config
				),
			}
		)
		if follow_on != null and follow_on.is_active():
			return _record_roll(follow_on, true)
	var config := GameState.balance_config
	if not _event_service.should_roll(config):
		return _record_roll(null, true)
	var def := _event_service.roll_definition(config, GameState.current_day)
	if def.is_empty():
		return _record_roll(null, true)
	var kind := StringName(def.get("type", ""))
	var opts := {
		"duration_days": _event_service.roll_duration(def, config),
	}
	if kind == MarketEvent.KIND_SET_RELEASE:
		var remaining := SetReleaseHypePolicy.remaining_days_on(
			GameState.current_day,
			config
		)
		if remaining <= 0:
			return _record_roll(null, true)
		opts["remaining_days"] = remaining
	elif kind == MarketEvent.KIND_PRO_TOUR:
		opts["remaining_days"] = (
			ProTourSpikePolicy.telegraph_days_for(config) + int(opts["duration_days"])
		)
	var started := start_pack_event(kind, opts)
	if started == null or not started.is_active():
		return _record_roll(null, true)
	return _record_roll(started, true)


func start_pack_event(kind: StringName, opts: Dictionary = {}) -> MarketEvent:
	var def := _event_service.definition_for(kind)
	if def.is_empty():
		return null
	_clear_active_event()
	_pending_rotation_crash_set_id = &""
	var event := MarketEvent.new()
	event.id = StringName(def.get("id", kind))
	event.kind = kind
	event.title = String(def.get("title", String(kind)))
	event.duration_days = int(opts.get("duration_days", _event_service.roll_duration(def, GameState.balance_config)))
	event.duration_days = maxi(1, event.duration_days)
	event.remaining_days = int(opts.get("remaining_days", event.duration_days))
	event.remaining_days = maxi(1, event.remaining_days)
	event.sku_id = StringName(opts.get("sku_id", &""))
	event.set_id = StringName(opts.get("set_id", &""))
	event.old_set_id = StringName(opts.get("old_set_id", &""))
	event.archetype_tag = StringName(opts.get("archetype_tag", &""))
	event.pro_tour_mult = float(opts.get("pro_tour_mult", 0.0))
	event.rotation_crash_mult = float(opts.get("rotation_crash_mult", 0.0))
	event.fog_flag = bool(def.get("fog_flag", kind == MarketEvent.KIND_FOG))
	if not _bind_event_targets(event):
		return null
	if not _apply_event_effects(event):
		return null
	if event.kind == MarketEvent.KIND_ROTATION:
		_pending_rotation_crash_set_id = event.set_id
	else:
		_pending_rotation_crash_set_id = &""
	_active_event = event
	_publish_event_changed()
	return event


func active_event() -> MarketEvent:
	if _active_event != null and _active_event.is_active():
		return _active_event
	return null


func market_cents_for(sku_id: StringName) -> int:
	# Hidden market used by Economy net-worth math (systems §9.2). Not a UI value.
	# BR1 Pro tour and BS1 Rotation crash read through non-compounding event
	# mults; AR1 drift still writes the unmultiplied MarketState base.
	var cents := _market_state.market_cents_for(sku_id)
	if cents <= 0:
		if InventoryService.model == null:
			return 0
		var sku := InventoryService.model.get_sku(sku_id)
		if sku == null:
			return 0
		cents = sku.base_market_cents
	if cents <= 0:
		return 0
	var mult := (
		pro_tour_market_mult_for(sku_id) * rotation_crash_market_mult_for(sku_id)
	)
	if is_equal_approx(mult, 1.0):
		return cents
	return maxi(1, roundi(float(cents) * mult))


func has_fog_flag() -> bool:
	return _service != null and _service.has_fog_flag()


func has_counterfeit_scare() -> bool:
	return _service != null and _service.has_counterfeit_scare()


func has_convention_weekend() -> bool:
	var event := active_event()
	return event != null and event.kind == MarketEvent.KIND_CONVENTION


func has_theft_ring() -> bool:
	var event := active_event()
	return event != null and event.kind == MarketEvent.KIND_THEFT_RING


func has_recession_week() -> bool:
	var event := active_event()
	return event != null and event.kind == MarketEvent.KIND_RECESSION


func has_supply_glut() -> bool:
	var event := active_event()
	return event != null and event.kind == MarketEvent.KIND_SUPPLY_GLUT


func has_set_release_hype() -> bool:
	var event := active_event()
	return event != null and event.kind == MarketEvent.KIND_SET_RELEASE


func has_pro_tour() -> bool:
	var event := active_event()
	return event != null and event.kind == MarketEvent.KIND_PRO_TOUR


func has_pro_tour_spike() -> bool:
	var event := active_event()
	if event == null or event.kind != MarketEvent.KIND_PRO_TOUR:
		return false
	return ProTourSpikePolicy.is_spike_window(event.remaining_days, event.duration_days)


func has_rotation_crash() -> bool:
	var event := active_event()
	return event != null and event.kind == MarketEvent.KIND_ROTATION_CRASH


func set_release_demand_mult_for(sku_id: StringName) -> float:
	if _service == null or not has_set_release_hype():
		return 1.0
	return _service.set_release_demand_mult_for(sku_id)


func pro_tour_market_mult_for(sku_id: StringName) -> float:
	if _service == null or not has_pro_tour_spike():
		return 1.0
	return _service.pro_tour_market_mult_for(sku_id)


func rotation_crash_market_mult_for(sku_id: StringName) -> float:
	if _service == null or not has_rotation_crash():
		return 1.0
	return _service.rotation_crash_market_mult_for(sku_id)


func pending_rotation_crash_set_id() -> StringName:
	return _pending_rotation_crash_set_id


func active_event_demand_mult() -> float:
	if not has_recession_week():
		return 1.0
	return MarketEventService.RECESSION_DEMAND_MULT


func active_event_sell_through_mult() -> float:
	return active_event_demand_mult()


func display_bonus() -> float:
	# Live layout read — rearrange or the next tick sees the new origin.
	if GameState.shop.has_sightline_display_bonus():
		return GameState.shop.sightline_display_bonus_mult()
	return 1.0


func display_bonus_for_graded_case(location: InventoryLocation) -> float:
	if location == null or location.type != InventoryLocation.Type.CASE:
		return 1.0
	return display_bonus()


func sell_through_mult_for(sku_id: StringName) -> float:
	var mult := active_event_sell_through_mult()
	var slab: SlabInstance = InventoryService.get_slab(sku_id)
	if slab != null:
		mult *= display_bonus_for_graded_case(slab.location)
	return mult


func location_display_bonus(location: InventoryLocation) -> float:
	return GameState.shop.location_display_bonus(location)


func walk_in_interest(location: InventoryLocation) -> float:
	return location_display_bonus(location)


func walk_in_interest_for(sku_id: StringName) -> float:
	if _is_accessory_sku(sku_id):
		return impulse_shelf_interest_for(sku_id)
	return walk_in_interest(InventoryService.location_for(sku_id))


func impulse_shelf_interest(location: InventoryLocation) -> float:
	return GameState.shop.impulse_shelf_interest(location)


func impulse_shelf_interest_for(sku_id: StringName) -> float:
	if not _is_accessory_sku(sku_id):
		return 0.0
	var best := -1.0
	for lot: StockLot in InventoryService.get_lots(sku_id):
		if lot == null or lot.qty <= 0:
			continue
		best = maxf(best, impulse_shelf_interest(lot.location))
	if best >= 0.0:
		return best
	return impulse_shelf_interest(InventoryService.location_for(sku_id))


func _is_accessory_sku(sku_id: StringName) -> bool:
	if InventoryService.model == null:
		return false
	var sku := InventoryService.model.get_sku(sku_id)
	return sku != null and sku.product_class == ProductSKU.ProductClass.ACCESSORY


func active_event_buylist_mult() -> float:
	if not has_recession_week():
		return 1.0
	return MarketEventService.RECESSION_BUYLIST_MULT


func active_sealed_wholesale_mult() -> float:
	if not has_supply_glut():
		return 1.0
	return MarketEventService.SUPPLY_GLUT_WHOLESALE_MULT


func active_sealed_race_mult() -> float:
	if not has_supply_glut():
		return 1.0
	return MarketEventService.SUPPLY_GLUT_SEALED_RACE_MULT


func sealed_wholesale_cents(
	sku_id: StringName,
	baseline_cents: int,
	channel: Variant = DemandSignalService.Channel.DISTRIBUTOR
) -> int:
	if baseline_cents <= 0:
		return baseline_cents
	if DemandSignalService.channel_from(channel) != DemandSignalService.Channel.DISTRIBUTOR:
		return baseline_cents
	if not has_supply_glut() or not _is_sealed_sku(sku_id):
		return baseline_cents
	return maxi(1, roundi(float(baseline_cents) * active_sealed_wholesale_mult()))


func sealed_retail_comp_cents(sku_id: StringName, baseline_cents: int) -> int:
	if baseline_cents <= 0 or not has_supply_glut() or not _is_sealed_sku(sku_id):
		return baseline_cents
	return maxi(1, roundi(float(baseline_cents) * active_sealed_race_mult()))


func effective_demand_score(sku_id: StringName) -> float:
	if _service == null:
		return 0.0
	return _service.effective_demand_score_for(sku_id)


func effective_demand_band(sku_id: StringName) -> StringName:
	if _service == null:
		return &""
	return _service.effective_demand_band_for(sku_id)


func active_shrink_multiplier() -> float:
	if not has_theft_ring():
		return 1.0
	if GameState.shop.has_active_cameras():
		return GameState.shop.camera_theft_shrink_mult()
	return MarketEventService.THEFT_RING_SHRINK_MULT


func has_play_table_event_night() -> bool:
	return (
		MarketEventService.is_event_night_day(GameState.current_day)
		and GameState.shop.has_play_table_placed()
	)


func play_table_event_traffic_mult() -> float:
	if not has_play_table_event_night():
		return 1.0
	return MarketEventService.EVENT_NIGHT_TRAFFIC_MULT


func play_table_event_whale_weight_mult() -> float:
	if not has_play_table_event_night():
		return 1.0
	return MarketEventService.EVENT_NIGHT_WHALE_WEIGHT_MULT


func circulation_traffic_mult() -> float:
	if GameState.shop.layout.has_circulation():
		return 1.0
	return MarketEventService.BLOCKED_PATH_TRAFFIC_MULT


func active_event_traffic_mult() -> float:
	var mult := 1.0
	if has_convention_weekend():
		mult *= MarketEventService.CONVENTION_TRAFFIC_MULT
	mult *= play_table_event_traffic_mult()
	mult *= circulation_traffic_mult()
	return mult


func active_event_whale_weight_mult() -> float:
	var mult := 1.0
	if has_convention_weekend():
		mult *= MarketEventService.CONVENTION_WHALE_WEIGHT_MULT
	mult *= play_table_event_whale_weight_mult()
	return mult


func customer_spawn_wait_seconds(base_interval: float, shop_tier: int) -> float:
	var wait := GameState.balance_config.customer_spawn_wait_seconds(
		base_interval,
		shop_tier
	)
	return wait / maxf(0.01, active_event_traffic_mult())


func graded_trust_mult() -> float:
	if _service == null:
		return 1.0
	return _service.graded_trust_mult()


func requires_owned_slab_inspect() -> bool:
	return _service != null and _service.requires_owned_slab_inspect()


func is_inspect_mandatory(dto: BuyConfirmSignal) -> bool:
	return _service != null and _service.is_inspect_mandatory(dto)


func recommends_inspect(dto: BuyConfirmSignal) -> bool:
	if _service == null:
		if dto == null:
			return false
		return DemandSignalService.recommends_inspect(dto.channel)
	return _service.recommends_inspect_for(dto)


func active_fake_slab_rate(channel: Variant = DemandSignalService.Channel.SHADY) -> float:
	if _service == null:
		return GameState.balance_config.shady_fake_slab_rate
	return _service.active_fake_slab_rate(channel)


func shady_width_mult() -> float:
	if _service == null:
		return 1.0
	return _service.shady_width_mult()


func active_demand_band_sigma(informed: bool = false) -> float:
	if _service == null:
		return GameState.balance_config.demand_band_sigma
	return _service.active_demand_band_sigma(informed)


func wants_event_price_editor() -> bool:
	return not peek_event_price_editor_request().is_empty()


func peek_event_price_editor_request() -> Dictionary:
	if not _should_offer_event_price_editor():
		return {}
	var sku_id := resolve_event_price_sku()
	if sku_id.is_empty():
		return {}
	return {
		"sku_id": sku_id,
		"beat_id": EVENT_PRICE_BRIDGE,
		"message": event_banner_text(),
		"suggestion_mode": &"suggested",
	}


func resolve_event_price_sku() -> StringName:
	var event := active_event()
	if event == null:
		return &""
	match event.kind:
		MarketEvent.KIND_HYPE:
			return _ensure_priceable_sku(event.sku_id)
		MarketEvent.KIND_FOG:
			if _is_sku_priceable(MarketEventService.TITAN_SKU):
				return MarketEventService.TITAN_SKU
			var owned := _first_priceable_sku()
			if not owned.is_empty():
				return owned
			return _ensure_priceable_sku(MarketEventService.TITAN_SKU)
	return &""


func acknowledge_event_price_editor(sku_id: StringName = &"") -> void:
	var event := active_event()
	if event == null or event.price_editor_prompted:
		return
	if event.kind != MarketEvent.KIND_HYPE and event.kind != MarketEvent.KIND_FOG:
		return
	if not sku_id.is_empty() and resolve_event_price_sku() != sku_id:
		return
	event.price_editor_prompted = true


func event_banner_text() -> String:
	var event := active_event()
	if event == null:
		return ""
	match event.kind:
		MarketEvent.KIND_HYPE:
			var sku := InventoryService.model.get_sku(event.sku_id)
			var name_text := sku.display_name if sku != null else String(event.sku_id)
			return "Hype: %s · HOT" % name_text
		MarketEvent.KIND_FOG:
			return "Fog day — demand signals noisier"
		MarketEvent.KIND_COUNTERFEIT:
			return "Counterfeit scare — Inspect mandatory · shady risk up"
		MarketEvent.KIND_CONVENTION:
			return "Calendar: Convention weekend — busier floor · whales inbound"
		MarketEvent.KIND_THEFT_RING:
			return "Rumor: extra loss on the floor — staff up or wait it out"
		MarketEvent.KIND_RECESSION:
			return "Macro: Recession week — demand soft · sellers inbound"
		MarketEvent.KIND_SUPPLY_GLUT:
			return "Distributor: Supply glut — sealed cheap · retail race"
		MarketEvent.KIND_SET_RELEASE:
			return "Calendar: Set release — new sealed hot · old sealed cool"
		MarketEvent.KIND_PRO_TOUR:
			return ProTourSpikePolicy.banner_text(event.archetype_tag)
		MarketEvent.KIND_ROTATION_CRASH:
			var set_name := String(event.set_id)
			if _service != null:
				set_name = _service.display_name_for_set(event.set_id)
			return RotationCrashPolicy.banner_text(set_name)
		MarketEvent.KIND_ROTATION:
			if not _can_see_rotation_leak(event):
				return ""
			return "Rotation watch: %s" % _service.display_name_for_set(event.set_id)
	return event.title


func calendar_telegraph_text() -> String:
	var active := event_banner_text()
	if not active.is_empty():
		return active
	if has_play_table_event_night():
		return "Calendar: Event night — play table drawing a crowd"
	if MarketEventService.is_convention_telegraph_day(GameState.current_day):
		return "Calendar: Convention weekend incoming"
	if MarketEventService.is_set_release_telegraph_day(
		GameState.current_day,
		GameState.balance_config
	):
		return "Calendar: Set release incoming"
	return ""


func event_to_save() -> Dictionary:
	var event := active_event()
	var data := event.to_save() if event != null else {}
	if not _pending_rotation_crash_set_id.is_empty():
		data["pending_rotation_crash_set_id"] = String(_pending_rotation_crash_set_id)
	return data


func seed_event_rng(rng_seed: int) -> void:
	_event_service.reset(rng_seed)


func apply_event_save(data: Dictionary) -> bool:
	_clear_active_event()
	if data.is_empty():
		_pending_rotation_crash_set_id = &""
		_publish_event_changed()
		return true
	_pending_rotation_crash_set_id = StringName(
		data.get("pending_rotation_crash_set_id", "")
	)
	var event := MarketEvent.from_save(data)
	if not event.is_active():
		_publish_event_changed()
		return true
	if not _bind_event_targets(event):
		return false
	if not _apply_event_effects(event):
		return false
	_active_event = event
	if (
		event.kind == MarketEvent.KIND_ROTATION
		and _pending_rotation_crash_set_id.is_empty()
	):
		_pending_rotation_crash_set_id = event.set_id
	if event.kind == MarketEvent.KIND_ROTATION_CRASH:
		_pending_rotation_crash_set_id = &""
	_publish_event_changed()
	return true


func open_buy_signals() -> Array[BuyConfirmSignal]:
	var result: Array[BuyConfirmSignal] = []
	for opportunity: BuyOpportunity in _open_opportunities():
		result.append(_signal_for_opportunity(opportunity))
	return result


func player_trade_seed(day: int = -1) -> int:
	var resolved_day := day if day >= 0 else GameState.current_day
	return resolved_day * 7919


func open_player_trade() -> PlayerTradeOffer:
	return roll_player_trade(player_trade_seed(), GameState.current_reputation)


func roll_player_trade(seed: int, reputation: int, day: int = -1) -> PlayerTradeOffer:
	var resolved_day := day if day >= 0 else GameState.current_day
	return _player_trades.roll_open(seed, reputation, resolved_day)


func player_trade_can_accept(offer: PlayerTradeOffer) -> bool:
	return _player_trades.can_accept(offer)


func accept_player_trade(offer: PlayerTradeOffer) -> bool:
	return _player_trades.accept(offer, GameState.current_day)


func decline_player_trade(offer: PlayerTradeOffer) -> bool:
	return _player_trades.decline(offer, GameState.current_day)


func configure_regulars_return(unlock_rep: int, queue_cap: int) -> void:
	_regulars.configure(unlock_rep, queue_cap)


func regulars_queued_count() -> int:
	return _regulars.queued_count()


func regulars_unlock_rep(configured: int = RegularsReturnPolicy.UNLOCK_REP) -> int:
	return RegularsReturnPolicy.unlock_rep(configured)


func regulars_queue_cap(configured: int = RegularsReturnPolicy.QUEUE_CAP) -> int:
	return RegularsReturnPolicy.queue_cap(configured)


func note_regulars_listed_sale(reputation: int = -1) -> bool:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return _regulars.note_listed_sale(resolved)


func note_regulars_outcome(
	customer: CustomerProfile,
	outcome: StringName,
	reputation: int = -1
) -> bool:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return _regulars.note_outcome(customer, outcome, resolved)


func take_regular_return() -> CustomerProfile:
	return _regulars.take_floor_return()


func distributor_moq_mult(configured: float = 0.0) -> float:
	return DistributorMoqPolicy.moq_mult(configured)


func is_distributor_moq_worse(reputation: int = -1) -> bool:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return DistributorMoqPolicy.is_worse_moq(resolved)


func distributor_minimum_units(
	today_moq: int,
	reputation: int = -1,
	configured_mult: float = 0.0
) -> int:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return DistributorMoqPolicy.minimum_units(today_moq, resolved, configured_mult)


func distributor_menu_first_day(configured: int = 0) -> int:
	return DistributorMenuPolicy.first_day(configured)


func distributor_menu_interval_days(configured: int = 0) -> int:
	return DistributorMenuPolicy.interval_days(configured)


func distributor_menu_moq_sealed(configured: int = 0) -> int:
	return DistributorMenuPolicy.moq_sealed(configured)


func distributor_menu_moq_accessory(configured: int = 0) -> int:
	return DistributorMenuPolicy.moq_accessory(configured)


func is_distributor_menu_day(day: int = -1, config: BalanceConfig = null) -> bool:
	var resolved_day := day if day >= 0 else GameState.current_day
	var resolved_config := config if config != null else GameState.balance_config
	return DistributorMenuPolicy.is_menu_day(resolved_day, resolved_config)


func closed_opportunity_ids_to_save() -> Array:
	return DistributorMenuPolicy.closed_ids_to_save(_closed_opportunity_ids)


func apply_closed_opportunity_ids_save(value: Variant) -> void:
	_closed_opportunity_ids = DistributorMenuPolicy.closed_ids_from_save(value)


func marketplace_extra_lead_count(configured: int = 0) -> int:
	return MarketplaceLeadPolicy.extra_lead_count(configured)


func marketplace_ask_rate(configured: float = 0.0) -> float:
	return MarketplaceLeadPolicy.ask_rate(configured)


func is_better_marketplace_lead(reputation: int = -1) -> bool:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return MarketplaceLeadPolicy.is_high_rep(resolved)


func marketplace_ask_cents(basis_cents: int, configured_rate: float = 0.0) -> int:
	return MarketplaceLeadPolicy.ask_cents(basis_cents, configured_rate)


func online_fee_cut_percent(configured: int = 0) -> int:
	return OnlineFeePolicy.cut_percent(configured)


func online_fee_cut_rep(configured: int = 0) -> int:
	return OnlineFeePolicy.cut_rep(configured)


func is_online_fee_cut(reputation: int = -1) -> bool:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return OnlineFeePolicy.is_high_rep_for(resolved, GameState.balance_config)


func online_listing_fee_rate(reputation: int = -1) -> float:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return OnlineFeePolicy.fee_rate_for(resolved, GameState.balance_config)


func online_listing_fee_cents(sale_cents: int, reputation: int = -1) -> int:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return OnlineFeePolicy.fee_cents_for(sale_cents, resolved, GameState.balance_config)


func online_hold_cap(reputation: int = -1) -> int:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return OnlineHoldCapPolicy.cap_for_config(resolved, GameState.balance_config)


func online_hold_count() -> int:
	return Economy.online_listings.concurrent_hold_count()


func auction_snipe_attention(configured: int = 0) -> int:
	return AuctionSnipePolicy.attention_cost(configured)


func auction_snipe_comp_width(configured: float = 0.0) -> float:
	return AuctionSnipePolicy.comp_width(configured)


func auction_snipe_flag(seed: int, day: int) -> bool:
	return AuctionSnipePolicy.flag_on(seed, day)


func auction_snipe_should_offer(
	seed: int,
	day: int,
	named_event_live: bool = false
) -> bool:
	return AuctionSnipePolicy.should_offer(seed, day, named_event_live)


func auction_snipe_ask_cents(
	basis_cents: int,
	seed: int,
	day: int,
	configured_width: float = 0.0
) -> int:
	return AuctionSnipePolicy.ask_cents(basis_cents, seed, day, configured_width)


func shady_trunk_ask_rate(configured: float = 0.0) -> float:
	return ShadyTrunkPolicy.ask_rate(configured)


func shady_trunk_report_rep_gain(configured: int = 0) -> int:
	return ShadyTrunkPolicy.report_rep_gain(configured)


func shady_trunk_fake_slab_rate(configured: float = -1.0) -> float:
	return ShadyTrunkPolicy.fake_slab_rate(configured)


func shady_trunk_comp_width(configured: float = 0.0) -> float:
	return ShadyTrunkPolicy.comp_width(configured)


func shady_trunk_flag(seed: int, day: int) -> bool:
	return ShadyTrunkPolicy.flag_on(seed, day)


func shady_trunk_should_offer(seed: int, day: int) -> bool:
	return ShadyTrunkPolicy.should_offer(seed, day)


func shady_trunk_ask_cents(basis_cents: int, configured_rate: float = 0.0) -> int:
	return ShadyTrunkPolicy.ask_cents(basis_cents, configured_rate)


func open_shady_trunk() -> BuyConfirmSignal:
	return buy_signal_for_id(ShadyTrunkPolicy.offer_id(GameState.current_day))


func roll_shady_trunk(seed: int, day: int) -> BuyConfirmSignal:
	if not ShadyTrunkPolicy.should_offer(seed, day):
		return null
	var opportunity := _make_shady_trunk(seed, day)
	if opportunity == null or not opportunity.is_valid():
		return null
	return _signal_for_opportunity(opportunity)


func shady_trunk_can_buy(dto: BuyConfirmSignal) -> bool:
	if dto == null or not ShadyTrunkPolicy.is_trunk_id(dto.opportunity_id):
		return false
	if _closed_opportunity_ids.has(dto.opportunity_id):
		return false
	var ask := maxi(dto.lot_total_cents, dto.unit_cost_cents * maxi(1, dto.quantity))
	if not Economy.can_afford(ask):
		return false
	return dto.space_required <= dto.space_free


func buy_shady_trunk(dto: BuyConfirmSignal) -> bool:
	if dto == null or not ShadyTrunkPolicy.is_trunk_id(dto.opportunity_id):
		return false
	if _closed_opportunity_ids.has(dto.opportunity_id):
		return false
	var opportunity := _existing_opportunity(dto.opportunity_id)
	if opportunity == null or not opportunity.is_valid():
		return false
	var buy_qty := maxi(1, opportunity.quantity)
	var ask := opportunity.unit_cost_cents * buy_qty
	if not Economy.can_afford(ask):
		return false
	if is_inspect_mandatory(dto) and not dto.inspected:
		return false
	var shown_midpoint := (dto.shown_comp_low_cents + dto.shown_comp_high_cents) / 2
	var purchased := false
	if opportunity.is_graded():
		purchased = _confirm_graded_purchase(dto, opportunity, shown_midpoint)
	else:
		purchased = _confirm_ungraded_purchase(
			dto,
			opportunity,
			buy_qty,
			opportunity.unit_cost_cents,
			shown_midpoint
		)
	if purchased:
		_closed_opportunity_ids[opportunity.id] = true
	return purchased


func report_shady_trunk(dto: BuyConfirmSignal) -> bool:
	if dto == null or not ShadyTrunkPolicy.is_trunk_id(dto.opportunity_id):
		return false
	if _closed_opportunity_ids.has(dto.opportunity_id):
		return false
	if _existing_opportunity(dto.opportunity_id) == null:
		return false
	GameState.adjust_reputation(shady_trunk_report_rep_gain())
	return dismiss_buy_opportunity(dto.opportunity_id)


func walk_shady_trunk(dto: BuyConfirmSignal) -> bool:
	if dto == null or not ShadyTrunkPolicy.is_trunk_id(dto.opportunity_id):
		return false
	return dismiss_buy_opportunity(dto.opportunity_id)


func open_auction_snipe() -> BuyConfirmSignal:
	return buy_signal_for_id(AuctionSnipePolicy.offer_id(GameState.current_day))


func roll_auction_snipe(
	seed: int,
	day: int,
	named_event_live: bool = false
) -> BuyConfirmSignal:
	if not AuctionSnipePolicy.should_offer(seed, day, named_event_live):
		return null
	var opportunity := _make_auction_snipe(seed, day)
	if opportunity == null or not opportunity.is_valid():
		return null
	return _signal_for_opportunity(opportunity)


func auction_snipe_can_bid(dto: BuyConfirmSignal) -> bool:
	if dto == null or not AuctionSnipePolicy.is_snipe_id(dto.opportunity_id):
		return false
	if _closed_opportunity_ids.has(dto.opportunity_id):
		return false
	var ask := maxi(dto.lot_total_cents, dto.unit_cost_cents * maxi(1, dto.quantity))
	if GameState.attention_remaining < auction_snipe_attention():
		return false
	if not Economy.can_afford(ask):
		return false
	return dto.space_required <= dto.space_free


func bid_auction_snipe(dto: BuyConfirmSignal) -> bool:
	if dto == null or not AuctionSnipePolicy.is_snipe_id(dto.opportunity_id):
		return false
	if _closed_opportunity_ids.has(dto.opportunity_id):
		return false
	var opportunity := _existing_opportunity(dto.opportunity_id)
	if opportunity == null or not opportunity.is_valid():
		return false
	var attention_cost := auction_snipe_attention()
	var buy_qty := maxi(1, opportunity.quantity)
	var ask := opportunity.unit_cost_cents * buy_qty
	if GameState.attention_remaining < attention_cost:
		return false
	if not Economy.can_afford(ask):
		return false
	if not GameState.consume_attention(attention_cost):
		return false
	AuctionInspectPolicy.ensure_lot_condition(dto, GameState.current_day)
	var shown_midpoint := (dto.shown_comp_low_cents + dto.shown_comp_high_cents) / 2
	var purchased := _confirm_ungraded_purchase(
		dto,
		opportunity,
		buy_qty,
		opportunity.unit_cost_cents,
		shown_midpoint
	)
	if not purchased:
		_refund_attention(attention_cost)
		return false
	_closed_opportunity_ids[opportunity.id] = true
	return true


func decline_auction_snipe(dto: BuyConfirmSignal) -> bool:
	if dto == null or not AuctionSnipePolicy.is_snipe_id(dto.opportunity_id):
		return false
	return dismiss_buy_opportunity(dto.opportunity_id)


func can_haggle_offer(dto: BuyConfirmSignal) -> bool:
	if dto == null or dto.opportunity_id.is_empty():
		return false
	if AuctionSnipePolicy.is_snipe_id(dto.opportunity_id):
		return false
	if _closed_opportunity_ids.has(dto.opportunity_id):
		return false
	if _haggle_spent_ids.has(dto.opportunity_id):
		return false
	return HagglePolicy.can_haggle(dto.channel)


func haggle_channel_weight(channel: Variant, configured: float = -1.0) -> float:
	return HagglePolicy.channel_weight(channel, configured)


func haggle_rep_term(reputation: int = -1, configured: float = -1.0) -> float:
	var resolved := reputation if reputation >= 0 else GameState.current_reputation
	return HagglePolicy.rep_term(resolved, configured)


func haggle_accept_chance(
	offer_cents: int,
	ask_cents: int,
	reputation: int,
	channel: Variant,
	configured_weight: float = -1.0,
	configured_rep_term: float = -1.0
) -> float:
	return HagglePolicy.accept_chance(
		offer_cents,
		ask_cents,
		reputation,
		channel,
		configured_weight,
		configured_rep_term
	)


func haggle_roll_seed(opportunity_id: StringName, day: int = -1) -> int:
	var resolved_day := day if day >= 0 else GameState.current_day
	return HagglePolicy.roll_seed(opportunity_id, resolved_day)


func decline_haggle_offer(dto: BuyConfirmSignal) -> bool:
	if not can_haggle_offer(dto):
		return false
	return dismiss_buy_opportunity(dto.opportunity_id)


func counter_buy(dto: BuyConfirmSignal, offer_cents: int) -> StringName:
	if not can_haggle_offer(dto):
		return HagglePolicy.RESULT_REFUSED
	var opportunity := _existing_opportunity(dto.opportunity_id)
	if opportunity == null or not opportunity.is_valid():
		return HagglePolicy.RESULT_REFUSED
	var ask := _haggle_ask_cents(dto, opportunity)
	if not HagglePolicy.is_valid_counter(offer_cents, ask):
		return HagglePolicy.RESULT_REFUSED
	if is_inspect_mandatory(dto) and not dto.inspected:
		return HagglePolicy.RESULT_REFUSED
	if not Economy.can_afford(offer_cents):
		return HagglePolicy.RESULT_REFUSED
	if dto.space_required > dto.space_free:
		return HagglePolicy.RESULT_REFUSED
	var reputation := GameState.current_reputation
	var seed := haggle_roll_seed(dto.opportunity_id)
	var hit := HagglePolicy.roll_accept(
		seed,
		offer_cents,
		ask,
		reputation,
		dto.channel
	)
	_haggle_spent_ids[dto.opportunity_id] = true
	if not hit:
		dismiss_buy_opportunity(dto.opportunity_id)
		return HagglePolicy.RESULT_MISSED
	if not _complete_cash_buy_at(dto, opportunity, offer_cents):
		_haggle_spent_ids.erase(dto.opportunity_id)
		return HagglePolicy.RESULT_REFUSED
	_closed_opportunity_ids[opportunity.id] = true
	return HagglePolicy.RESULT_ACCEPTED


func _haggle_ask_cents(dto: BuyConfirmSignal, opportunity: BuyOpportunity) -> int:
	if opportunity != null and opportunity.unit_cost_cents > 0:
		var qty := _offer_quantity(opportunity)
		var unit := _effective_unit_cost_cents(opportunity)
		if opportunity.is_graded():
			unit = opportunity.unit_cost_cents
			qty = maxi(1, opportunity.quantity)
		return maxi(1, unit * maxi(1, qty))
	return maxi(dto.lot_total_cents, dto.unit_cost_cents * maxi(1, dto.quantity))


func _complete_cash_buy_at(
	dto: BuyConfirmSignal,
	opportunity: BuyOpportunity,
	paid_total_cents: int
) -> bool:
	var shown_midpoint := (dto.shown_comp_low_cents + dto.shown_comp_high_cents) / 2
	if opportunity.is_graded():
		return _confirm_graded_purchase(dto, opportunity, shown_midpoint, paid_total_cents)
	var buy_qty := _purchase_quantity(dto, opportunity, -1)
	if buy_qty <= 0:
		return false
	var unit_cost := maxi(1, paid_total_cents / buy_qty)
	return _confirm_ungraded_purchase(
		dto,
		opportunity,
		buy_qty,
		unit_cost,
		shown_midpoint,
		paid_total_cents
	)


func _ensure_regulars_bus() -> void:
	if EventBus.customer_resolved.is_connected(_on_customer_resolved_regulars):
		return
	EventBus.customer_resolved.connect(_on_customer_resolved_regulars)


func _on_customer_resolved_regulars(
	customer: CustomerProfile,
	outcome: StringName
) -> void:
	_regulars.note_outcome(customer, outcome, GameState.current_reputation)


func confirm_buy(dto: BuyConfirmSignal, requested_count: int = -1) -> bool:
	if dto != null and AuctionSnipePolicy.is_snipe_id(dto.opportunity_id):
		return bid_auction_snipe(dto)
	if dto != null and ShadyTrunkPolicy.is_trunk_id(dto.opportunity_id):
		return buy_shady_trunk(dto)
	if dto == null or not dto.can_confirm:
		return false
	if is_inspect_mandatory(dto) and not dto.inspected:
		return false
	for opportunity: BuyOpportunity in _open_opportunities():
		if opportunity.id != dto.opportunity_id:
			continue
		var shown_midpoint := (
			dto.shown_comp_low_cents + dto.shown_comp_high_cents
		) / 2
		var purchased := false
		if opportunity.is_graded():
			purchased = _confirm_graded_purchase(dto, opportunity, shown_midpoint)
		else:
			var buy_qty := _purchase_quantity(dto, opportunity, requested_count)
			if buy_qty <= 0:
				return false
			var unit_cost := _effective_unit_cost_cents(opportunity)
			purchased = _confirm_ungraded_purchase(
				dto,
				opportunity,
				buy_qty,
				unit_cost,
				shown_midpoint
			)
		if purchased:
			_closed_opportunity_ids[opportunity.id] = true
		return purchased
	return false


func inject_graded_opportunity(
	opportunity_id: StringName,
	sku_id: StringName,
	channel: DemandSignalService.Channel,
	unit_cost_cents: int,
	grader: StringName,
	grade: float,
	offer_label: String = "Graded slab",
	seeded_cert_state: int = -1,
	beat_id: StringName = &""
) -> BuyOpportunity:
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null or grader.is_empty() or grade <= 0.0:
		return null
	var opportunity := BuyOpportunity.new()
	opportunity.id = opportunity_id
	opportunity.sku_id = sku_id
	opportunity.display_name = sku.display_name
	opportunity.offer_label = offer_label
	opportunity.channel = channel
	opportunity.unit_cost_cents = unit_cost_cents
	opportunity.quantity = 1
	opportunity.space_required = 2
	opportunity.beat_id = beat_id
	opportunity.grader = grader
	opportunity.grade = grade
	opportunity.seeded_cert_state = seeded_cert_state
	if not inject_buy_opportunity(opportunity):
		return _existing_opportunity(opportunity_id)
	return opportunity


func apply_owned_slab_cue(dto: PriceConfirmSignal) -> void:
	if dto == null:
		return
	var slab := InventoryService.get_slab(dto.sku_id)
	if slab == null:
		return
	dto.condition_cue = slab.shown_cert_cue
	dto.inspected = slab.inspected
	if has_counterfeit_scare() and not slab.inspected:
		dto.condition_cue = "Slab — inspect mandatory"
	dto.grader = slab.grader
	dto.grade = slab.grade


func inspect_owned_slab(slab: SlabInstance) -> bool:
	if _service == null or slab == null or slab.inspected:
		return false
	return _service.inspect_slab_instance(slab)


func can_inspect_slab(slab: SlabInstance) -> bool:
	return (
		_service != null
		and slab != null
		and not slab.inspected
		and GameState.can_inspect()
	)


func roll_channel_slab_cert(channel: Variant) -> bool:
	if _service == null:
		return true
	if not DemandSignalService.is_risky_slab_channel(channel):
		return true
	return _service.roll_risky_slab_cert(channel)


func inject_buy_opportunity(opportunity: BuyOpportunity) -> bool:
	if opportunity == null or not opportunity.is_valid():
		return false
	for existing: BuyOpportunity in _scripted_opportunities:
		if existing.id == opportunity.id:
			return false
	_scripted_opportunities.append(opportunity)
	return true


func dismiss_buy_opportunity(opportunity_id: StringName) -> bool:
	if opportunity_id.is_empty():
		return false
	_closed_opportunity_ids[opportunity_id] = true
	return true


func buy_signal_for_id(opportunity_id: StringName) -> BuyConfirmSignal:
	for opportunity: BuyOpportunity in _open_opportunities():
		if opportunity.id == opportunity_id:
			return _signal_for_opportunity(opportunity)
	return null


func buy_signal(
	sku_id: StringName,
	channel: DemandSignalService.Channel,
	unit_cost_cents: int,
	quantity: int,
	space_required: int = 1
) -> BuyConfirmSignal:
	return _service.buy_confirm(
		GameState.current_day,
		sku_id,
		channel,
		sealed_wholesale_cents(sku_id, unit_cost_cents, channel),
		quantity,
		Economy.balance_cents,
		space_required,
		InventoryService.backstock_free_bins(),
		is_skill_informed(sku_id)
	)


func buylist_pct(category: Variant, configured: float = -1.0) -> float:
	if configured >= 0.0:
		return BuylistPolicy.buylist_pct(category, configured)
	return GameState.player_buylist_pct(category)


func buylist_offer_cents(
	listed_comp_cents: int,
	category: Variant,
	configured_pct: float = -1.0
) -> int:
	return BuylistPolicy.offer_cents(listed_comp_cents, category, configured_pct)


func buylist_comp_width(configured: float = 0.0) -> float:
	return BuylistPolicy.comp_width(configured)


func buylist_anger_floor(configured: float = -1.0) -> float:
	return BuylistPolicy.anger_floor(configured)


func buylist_miss_rep_delta(configured: int = BuylistPolicy.UNSET_INT) -> int:
	return BuylistPolicy.miss_rep_delta(configured)


func is_valid_buylist_change(offer_cents: int) -> bool:
	return BuylistPolicy.is_valid_change(offer_cents)


func refresh_buylist_affordability(dto: BuyConfirmSignal) -> void:
	if dto == null:
		return
	dto.remaining_cash_cents = Economy.balance_cents - dto.lot_total_cents
	if _service != null:
		_service.refresh_confirm_gate(dto)
	else:
		dto.can_confirm = (
			dto.quantity > 0
			and dto.remaining_cash_cents >= 0
			and dto.space_required <= dto.space_free
		)


func buylist_signal(
	sku_id: StringName,
	quantity: int = 1,
	grader: StringName = &"",
	grade: float = 0.0
) -> BuyConfirmSignal:
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null:
		return null
	var dto := buy_signal(
		sku_id,
		DemandSignalService.Channel.BUYLIST,
		BUYLIST_OFFER_PLACEHOLDER_CENTS,
		quantity
	)
	if dto == null:
		return null
	dto.display_name = sku.display_name
	dto.offer_label = "Walk-in seller"
	dto.channel = &"buylist"
	dto.quantity = quantity
	if not grader.is_empty() and grade > 0.0 and _service != null:
		_service.bind_graded_signal(dto, grader, grade)
	_apply_buylist_offer(dto, sku)
	return dto


func _apply_buylist_offer(dto: BuyConfirmSignal, sku: ProductSKU) -> void:
	if dto == null:
		return
	var listed := BuylistPolicy.listed_comp_cents(dto)
	var category := BuylistPolicy.category_for(sku, dto)
	var offer := BuylistPolicy.offer_cents(listed, category, buylist_pct(category))
	dto.unit_cost_cents = offer
	dto.lot_total_cents = offer * maxi(1, dto.quantity)
	dto.remaining_cash_cents = Economy.balance_cents - dto.lot_total_cents
	dto.confidence = BuylistPolicy.CONFIDENCE
	BuylistPolicy.apply_fog_cue(dto)
	BuylistPolicy.ensure_lot_condition(dto, GameState.current_day)
	if _service != null:
		_service.refresh_confirm_gate(dto)
	else:
		dto.can_confirm = (
			dto.quantity > 0
			and dto.remaining_cash_cents >= 0
			and dto.space_required <= dto.space_free
		)


func priceable_stock_signals() -> Array[PriceConfirmSignal]:
	var result: Array[PriceConfirmSignal] = []
	for item: Dictionary in InventoryService.get_priceable_stock():
		var dto := price_signal(
			StringName(item["sku_id"]),
			int(item["listed_price_cents"]),
			item["location"] as InventoryLocation
		)
		dto.display_name = String(item["display_name"])
		dto.quantity = int(item["quantity"])
		dto.condition_cue = String(item.get("condition_cue", ""))
		dto.inspected = bool(item.get("inspected", false))
		dto.grader = StringName(item.get("grader", &""))
		dto.grade = float(item.get("grade", 0.0))
		result.append(dto)
	return result


func refresh_price_signal(
	dto: PriceConfirmSignal,
	listed_price_cents: int
) -> PriceConfirmSignal:
	if dto == null:
		return null
	var location := InventoryService.location_for(dto.sku_id)
	var cached := shown_shop_suggested_cents(dto.sku_id)
	if cached <= 0:
		return _rebuild_price_signal(dto, listed_price_cents, location)
	if dto.suggested_price_cents != cached:
		dto.suggested_price_cents = cached
	return _service.refresh_price_confirm(dto, listed_price_cents, location)


func _confirm_ungraded_purchase(
	dto: BuyConfirmSignal,
	opportunity: BuyOpportunity,
	buy_qty: int,
	unit_cost: int,
	shown_midpoint: int,
	paid_total_cents: int = -1
) -> bool:
	var location := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	var margin := shown_midpoint - unit_cost
	var fog_inspect := (
		MarketplaceInspectPolicy.applies_to(dto)
		or AuctionInspectPolicy.applies_to(dto)
	)
	if fog_inspect:
		if MarketplaceInspectPolicy.applies_to(dto):
			MarketplaceInspectPolicy.ensure_lot_condition(dto, GameState.current_day)
		if AuctionInspectPolicy.applies_to(dto):
			AuctionInspectPolicy.ensure_lot_condition(dto, GameState.current_day)
		var sku := InventoryService.model.get_sku(opportunity.sku_id)
		if sku != null and sku.product_class == ProductSKU.ProductClass.SINGLE:
			return InventoryService.confirm_channel_singles_purchase(
				dto,
				buy_qty,
				unit_cost,
				margin,
				location,
				paid_total_cents
			)
		var purchased := InventoryService.confirm_stock_purchase(
			opportunity.sku_id,
			buy_qty,
			unit_cost,
			margin,
			location,
			paid_total_cents
		)
		if purchased and AuctionInspectPolicy.applies_to(dto):
			AuctionInspectPolicy.apply_true_condition_to_stock(
				dto,
				_backstock_stock_lot(opportunity.sku_id),
				GameState.current_day
			)
		return purchased
	return InventoryService.confirm_stock_purchase(
		opportunity.sku_id,
		buy_qty,
		unit_cost,
		margin,
		location,
		paid_total_cents
	)


func _confirm_graded_purchase(
	dto: BuyConfirmSignal,
	opportunity: BuyOpportunity,
	shown_midpoint: int,
	paid_total_cents: int = -1
) -> bool:
	var total_cost := opportunity.unit_cost_cents * opportunity.quantity
	if paid_total_cents > 0:
		total_cost = paid_total_cents
	var unit_cost := opportunity.unit_cost_cents
	if paid_total_cents > 0:
		unit_cost = maxi(1, paid_total_cents / maxi(1, opportunity.quantity))
	if total_cost <= 0 or not Economy.can_afford(total_cost):
		return false
	var location := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	var cert_state := 1 if _service.true_cert_valid(dto) else 0
	var slab := InventoryService.receive_slab(
		opportunity.sku_id,
		opportunity.grader,
		opportunity.grade,
		unit_cost,
		location,
		dto.channel,
		cert_state
	)
	if slab == null:
		return false
	_service.apply_inspect_to_slab(dto, slab)
	if MarketplaceInspectPolicy.applies_to(dto):
		MarketplaceInspectPolicy.apply_true_condition(
			dto,
			slab.card_ref,
			GameState.current_day
		)
	if AuctionInspectPolicy.applies_to(dto):
		AuctionInspectPolicy.apply_true_condition(
			dto,
			slab.card_ref,
			GameState.current_day
		)
	if not Economy.record_expense(total_cost, &"inventory", "Graded slab purchase"):
		InventoryService.model.remove_slab(slab)
		return false
	QaInstrumentation.record_buy_confirm(
		opportunity.sku_id,
		opportunity.quantity,
		unit_cost,
		shown_midpoint - unit_cost
	)
	EventBus.publish_inventory_changed(
		opportunity.sku_id,
		InventoryService.total_owned(opportunity.sku_id)
	)
	return true


func _existing_opportunity(opportunity_id: StringName) -> BuyOpportunity:
	for opportunity: BuyOpportunity in _open_opportunities():
		if opportunity.id == opportunity_id:
			return opportunity
	return null


func _backstock_stock_lot(sku_id: StringName) -> StockLot:
	if InventoryService.model == null:
		return null
	var found: StockLot = null
	for lot: StockLot in InventoryService.model.stock_lots:
		if lot == null or lot.sku == null:
			continue
		if lot.sku.id != sku_id:
			continue
		if lot.location == null or lot.location.type != InventoryLocation.Type.BACKSTOCK:
			continue
		found = lot
	return found


func _open_opportunities() -> Array[BuyOpportunity]:
	var result: Array[BuyOpportunity] = []
	var opportunities := _opportunity_catalog.open_for_day(
		GameState.current_day,
		InventoryService.model.catalog
	)
	opportunities.append_array(_scripted_opportunities)
	opportunities.append_array(_supply_glut_restock_lots())
	# BT1: weekly restock menu from day 8 every 7 days. One line per
	# live SEALED / ACCESSORY SKU. Unbought lines expire at close.
	opportunities.append_array(_prep_distributor_menu())
	# AQ1: read live Rep when today's marketplace list is prepared.
	# Rep ≥ 75 appends one extra lead. Rep ≤ 74 keeps today's list.
	opportunities.append_array(_high_rep_marketplace_leads(opportunities))
	# AS1: prep roll lives here. Seeded auction flag offers one snipe.
	# A live named settle event forces the flag on for this prep.
	var snipe := _prep_auction_snipe()
	if snipe != null:
		opportunities.append(snipe)
	# AT1: same night roll. Seeded night flag offers one trunk lot.
	# No flag → no trunk that night. Not a sell weight.
	var trunk := _prep_shady_trunk()
	if trunk != null:
		opportunities.append(trunk)
	for opportunity: BuyOpportunity in opportunities:
		if not _closed_opportunity_ids.has(opportunity.id):
			result.append(opportunity)
	return result


func _prep_distributor_menu() -> Array[BuyOpportunity]:
	var lots: Array[BuyOpportunity] = []
	var config := GameState.balance_config
	var day := GameState.current_day
	if not DistributorMenuPolicy.is_menu_day(day, config):
		return lots
	if InventoryService.model == null:
		return lots
	for sku_id: StringName in DistributorMenuPolicy.menu_sku_ids(
		InventoryService.model.catalog
	):
		var lot := _make_distributor_menu_lot(day, sku_id, config)
		if lot != null:
			lots.append(lot)
	return lots


func _make_distributor_menu_lot(
	day: int,
	sku_id: StringName,
	config: BalanceConfig
) -> BuyOpportunity:
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null or not DistributorMenuPolicy.is_menu_sku(sku):
		return null
	var moq := DistributorMenuPolicy.base_moq_for(sku.product_class, config)
	if moq <= 0:
		return null
	var wholesale := PricingService.distributor_wholesale_cents(
		sku.base_market_cents,
		config
	)
	if wholesale <= 0:
		return null
	var opportunity := BuyOpportunity.new()
	opportunity.id = DistributorMenuPolicy.offer_id(day, sku_id)
	opportunity.sku_id = sku_id
	opportunity.display_name = sku.display_name
	opportunity.offer_label = DistributorMenuPolicy.OFFER_LABEL
	opportunity.channel = DemandSignalService.Channel.DISTRIBUTOR
	opportunity.unit_cost_cents = wholesale
	opportunity.quantity = moq
	opportunity.space_required = DistributorMenuPolicy.SPACE_REQUIRED
	if not opportunity.is_valid():
		return null
	return opportunity


func _prep_auction_snipe() -> BuyOpportunity:
	var day := GameState.current_day
	var event_live := active_event() != null
	if not AuctionSnipePolicy.should_offer(AuctionSnipePolicy.RUN_SEED, day, event_live):
		return null
	return _make_auction_snipe(AuctionSnipePolicy.RUN_SEED, day)


func _prep_shady_trunk() -> BuyOpportunity:
	var day := GameState.current_day
	if not ShadyTrunkPolicy.should_offer(ShadyTrunkPolicy.RUN_SEED, day):
		return null
	return _make_shady_trunk(ShadyTrunkPolicy.RUN_SEED, day)


func _make_shady_trunk(_seed: int, day: int) -> BuyOpportunity:
	var sku_id := ShadyTrunkPolicy.DEFAULT_SKU_ID
	if InventoryService.model == null:
		return null
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null:
		return null
	var ask_cents := ShadyTrunkPolicy.ask_cents(_marketplace_basis_cents(sku_id))
	if ask_cents <= 0:
		return null
	var opportunity := BuyOpportunity.new()
	opportunity.id = ShadyTrunkPolicy.offer_id(day)
	opportunity.sku_id = sku_id
	opportunity.display_name = sku.display_name
	opportunity.offer_label = ShadyTrunkPolicy.OFFER_LABEL
	opportunity.channel = DemandSignalService.Channel.SHADY
	opportunity.unit_cost_cents = ask_cents
	opportunity.quantity = 1
	opportunity.space_required = ShadyTrunkPolicy.SPACE_REQUIRED
	opportunity.grader = ShadyTrunkPolicy.DEFAULT_GRADER
	opportunity.grade = ShadyTrunkPolicy.DEFAULT_GRADE
	return opportunity


func _make_auction_snipe(seed: int, day: int) -> BuyOpportunity:
	var sku_id := AuctionSnipePolicy.DEFAULT_SKU_ID
	if InventoryService.model == null:
		return null
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null:
		return null
	var ask_cents := AuctionSnipePolicy.ask_cents(
		market_cents_for(sku_id),
		seed,
		day
	)
	if ask_cents <= 0:
		return null
	var opportunity := BuyOpportunity.new()
	opportunity.id = AuctionSnipePolicy.offer_id(day)
	opportunity.sku_id = sku_id
	opportunity.display_name = sku.display_name
	opportunity.offer_label = AuctionSnipePolicy.OFFER_LABEL
	opportunity.channel = DemandSignalService.Channel.AUCTION
	opportunity.unit_cost_cents = ask_cents
	opportunity.quantity = 1
	opportunity.space_required = 1
	return opportunity


func _refund_attention(amount: int) -> void:
	if amount <= 0:
		return
	GameState.attention_remaining += amount
	EventBus.attention_changed.emit(GameState.attention_remaining)


func _high_rep_marketplace_leads(today: Array[BuyOpportunity]) -> Array[BuyOpportunity]:
	var extras: Array[BuyOpportunity] = []
	var extra_count := MarketplaceLeadPolicy.extra_leads_for(GameState.current_reputation)
	if extra_count <= 0:
		return extras
	var used_ids: Dictionary = {}
	for opportunity: BuyOpportunity in today:
		if opportunity != null:
			used_ids[opportunity.id] = true
	for index: int in extra_count:
		var lead_id := MarketplaceLeadPolicy.extra_lead_id(index)
		if used_ids.has(lead_id):
			continue
		var lead := _make_high_rep_marketplace_lead(today, lead_id)
		if lead != null and lead.is_valid():
			extras.append(lead)
			used_ids[lead.id] = true
	return extras


func _make_high_rep_marketplace_lead(
	today: Array[BuyOpportunity],
	lead_id: StringName
) -> BuyOpportunity:
	var template := _today_marketplace_template(today)
	var sku_id := StringName(template.get("sku_id", MarketplaceLeadPolicy.DEFAULT_SKU_ID))
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null:
		return null
	var ask_cents := marketplace_ask_cents(_marketplace_basis_cents(sku_id))
	if ask_cents <= 0:
		return null
	var opportunity := BuyOpportunity.new()
	opportunity.id = lead_id
	opportunity.sku_id = sku_id
	opportunity.display_name = sku.display_name
	opportunity.offer_label = String(
		template.get("offer_label", MarketplaceLeadPolicy.OFFER_LABEL)
	)
	opportunity.channel = DemandSignalService.Channel.MARKETPLACE
	opportunity.unit_cost_cents = ask_cents
	opportunity.quantity = maxi(1, int(template.get("quantity", 1)))
	opportunity.space_required = maxi(1, int(template.get("space_required", 1)))
	return opportunity


func _today_marketplace_template(today: Array[BuyOpportunity]) -> Dictionary:
	for opportunity: BuyOpportunity in today:
		if opportunity == null:
			continue
		if opportunity.channel != DemandSignalService.Channel.MARKETPLACE:
			continue
		if MarketplaceLeadPolicy.is_extra_lead_id(opportunity.id):
			continue
		return {
			"sku_id": opportunity.sku_id,
			"quantity": opportunity.quantity,
			"space_required": opportunity.space_required,
			"offer_label": opportunity.offer_label,
		}
	return {
		"sku_id": MarketplaceLeadPolicy.DEFAULT_SKU_ID,
		"quantity": 1,
		"space_required": 1,
		"offer_label": MarketplaceLeadPolicy.OFFER_LABEL,
	}


func _marketplace_basis_cents(sku_id: StringName) -> int:
	# Same live market today's marketplace comps already read.
	var live := market_cents_for(sku_id)
	if live > 0:
		return live
	if InventoryService.model == null:
		return 0
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null:
		return 0
	return sku.base_market_cents


func _signal_for_opportunity(opportunity: BuyOpportunity) -> BuyConfirmSignal:
	var offer_qty := _offer_quantity(opportunity)
	var dto := buy_signal(
		opportunity.sku_id,
		opportunity.channel,
		opportunity.unit_cost_cents,
		offer_qty,
		opportunity.space_required
	)
	dto.opportunity_id = opportunity.id
	dto.display_name = opportunity.display_name
	dto.offer_label = opportunity.offer_label
	dto.channel = StringName(
		DemandSignalService.Channel.keys()[opportunity.channel].to_lower()
	)
	dto.quantity = offer_qty
	dto.beat_id = opportunity.beat_id
	if opportunity.is_graded():
		_service.bind_graded_signal(
			dto,
			opportunity.grader,
			opportunity.grade,
			opportunity.seeded_cert_state
		)
	_service.apply_inspect_state(dto)
	_service.refresh_confirm_gate(dto)
	if AuctionSnipePolicy.is_snipe_id(opportunity.id):
		if not dto.inspected:
			dto.condition_cue = AuctionSnipePolicy.CONDITION_CUE
		dto.confidence = AuctionSnipePolicy.CONFIDENCE
		AuctionInspectPolicy.ensure_lot_condition(dto, GameState.current_day)
		if GameState.attention_remaining < auction_snipe_attention():
			dto.can_confirm = false
	if ShadyTrunkPolicy.is_trunk_id(opportunity.id):
		if not dto.inspected:
			dto.condition_cue = ShadyTrunkPolicy.CONDITION_CUE
		dto.confidence = ShadyTrunkPolicy.CONFIDENCE
	if MarketplaceInspectPolicy.applies_to(dto):
		MarketplaceInspectPolicy.ensure_lot_condition(dto, GameState.current_day)
	return dto


func inspect_attention_cost_for(dto: BuyConfirmSignal) -> int:
	if AuctionInspectPolicy.applies_to(dto):
		return AuctionInspectPolicy.attention_cost_for(
			GameState.shop,
			GameState.balance_config
		)
	if MarketplaceInspectPolicy.applies_to(dto):
		return MarketplaceInspectPolicy.attention_cost_for(
			GameState.shop,
			GameState.balance_config
		)
	return GameState.shop.inspect_attention_cost()


func can_inspect(
	dto: BuyConfirmSignal,
	acting_role: StringName = MarketplaceInspectPolicy.ACTOR_OWNER
) -> bool:
	if dto == null or _service == null:
		return false
	if AuctionInspectPolicy.applies_to(dto):
		if not AuctionInspectPolicy.can_inspect(dto, acting_role):
			return false
		if not GameState.is_game_active:
			return false
		return GameState.attention_remaining >= inspect_attention_cost_for(dto)
	if MarketplaceInspectPolicy.applies_to(dto):
		if not MarketplaceInspectPolicy.can_inspect(dto, acting_role):
			return false
		if not GameState.is_game_active:
			return false
		return GameState.attention_remaining >= inspect_attention_cost_for(dto)
	return (
		_service.can_inspect(dto)
		and GameState.can_inspect()
	)


func inspect_buy(
	dto: BuyConfirmSignal,
	acting_role: StringName = MarketplaceInspectPolicy.ACTOR_OWNER
) -> bool:
	if not can_inspect(dto, acting_role):
		return false
	var cost := inspect_attention_cost_for(dto)
	if not GameState.consume_attention(cost):
		return false
	if not _service.inspect_condition(dto, GameState.current_day):
		_refund_attention(cost)
		return false
	return true


func price_signal(
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation
) -> PriceConfirmSignal:
	var dto := _service.price_confirm(
		GameState.current_day,
		sku_id,
		listed_price_cents,
		location,
		DemandSignalService.Channel.BUYLIST,
		is_skill_informed(sku_id)
	)
	if dto != null:
		_remember_shop_suggested(dto.sku_id, dto.suggested_price_cents)
	return dto


func listable_stock_signals() -> Array[OnlineListConfirmSignal]:
	var result: Array[OnlineListConfirmSignal] = []
	if _service == null:
		return result
	for item: Dictionary in Economy.online_listings.listable_targets():
		var dto := list_confirm_signal(
			StringName(item["sku_id"]),
			int(item["listed_price_cents"]),
			item["location"] as InventoryLocation
		)
		dto.display_name = String(item["display_name"])
		dto.quantity = int(item["quantity"])
		result.append(dto)
	return result


func list_confirm_signal(
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation
) -> OnlineListConfirmSignal:
	var dto := _service.list_confirm(
		GameState.current_day,
		sku_id,
		listed_price_cents,
		location,
		is_skill_informed(sku_id)
	)
	if dto != null:
		_remember_online_suggested(dto.sku_id, dto.suggested_price_cents)
	return dto


func shown_shop_suggested_cents(sku_id: StringName) -> int:
	return _noisy_suggested.shop_cents(sku_id)


func shown_online_suggested_cents(sku_id: StringName) -> int:
	return _noisy_suggested.online_cents(sku_id)


func clear_cached_noisy_suggested() -> void:
	# BL1: drop live-SKU noisy suggested plus sibling shop/online stickers.
	# Position / move-feel re-derive on the next §4.5 read. List-time
	# `suggested_at_list_cents` on an ONLINE_HOLD stays on the listing.
	_noisy_suggested.clear()


func suggested_for_listed_sale(
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation = null
) -> int:
	var cached := shown_shop_suggested_cents(sku_id)
	if cached > 0:
		return cached
	var loc := location if location != null else InventoryService.location_for(sku_id)
	var dto := price_signal(sku_id, listed_price_cents, loc)
	if dto == null:
		return 0
	return dto.suggested_price_cents


func suggested_for_online_list(
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation = null
) -> int:
	var cached := shown_online_suggested_cents(sku_id)
	if cached > 0:
		return cached
	var loc := location if location != null else InventoryService.location_for(sku_id)
	var dto := list_confirm_signal(sku_id, listed_price_cents, loc)
	if dto == null:
		return 0
	return dto.suggested_price_cents


func _remember_shop_suggested(sku_id: StringName, suggested_cents: int) -> void:
	_noisy_suggested.remember_shop(sku_id, suggested_cents)


func _remember_online_suggested(sku_id: StringName, suggested_cents: int) -> void:
	_noisy_suggested.remember_online(sku_id, suggested_cents)


func refresh_list_signal(
	dto: OnlineListConfirmSignal,
	listed_price_cents: int,
	location: InventoryLocation
) -> OnlineListConfirmSignal:
	if dto == null or _service == null:
		return null
	var cached := shown_online_suggested_cents(dto.sku_id)
	if cached <= 0:
		return _rebuild_list_signal(dto, listed_price_cents, location)
	if dto.suggested_price_cents != cached:
		dto.suggested_price_cents = cached
	return _service.refresh_list_confirm(dto, listed_price_cents, location)


func _rebuild_price_signal(
	dto: PriceConfirmSignal,
	listed_price_cents: int,
	location: InventoryLocation
) -> PriceConfirmSignal:
	var rebuilt := price_signal(dto.sku_id, listed_price_cents, location)
	if rebuilt == null:
		return null
	rebuilt.display_name = dto.display_name
	rebuilt.quantity = dto.quantity
	rebuilt.condition_cue = dto.condition_cue
	rebuilt.inspected = dto.inspected
	rebuilt.grader = dto.grader
	rebuilt.grade = dto.grade
	return rebuilt


func _rebuild_list_signal(
	dto: OnlineListConfirmSignal,
	listed_price_cents: int,
	location: InventoryLocation
) -> OnlineListConfirmSignal:
	var rebuilt := list_confirm_signal(dto.sku_id, listed_price_cents, location)
	if rebuilt == null:
		return null
	rebuilt.display_name = dto.display_name
	rebuilt.quantity = dto.quantity
	rebuilt.condition_cue = dto.condition_cue
	rebuilt.inspected = dto.inspected
	rebuilt.grader = dto.grader
	rebuilt.grade = dto.grade
	return rebuilt


func researchable_sets() -> Array[Dictionary]:
	var seen := {}
	var result: Array[Dictionary] = []
	if _service == null:
		return result
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku == null or sku.set_id.is_empty() or seen.has(String(sku.set_id)):
			continue
		seen[String(sku.set_id)] = true
		var snapshot := _service.research_snapshot(sku.set_id, GameState.current_day)
		result.append(snapshot)
	return result


func rotation_watch_text() -> String:
	if _service == null:
		return ""
	var watches := _service.active_rotation_watches(GameState.current_day)
	var event := active_event()
	if (
		event != null
		and event.kind == MarketEvent.KIND_ROTATION
		and _can_see_rotation_leak(event)
	):
		var leak := "Rotation watch: %s" % _service.display_name_for_set(event.set_id)
		if leak not in watches:
			watches.append(leak)
	return "\n".join(watches)


func can_research_set(set_id: StringName) -> bool:
	return research_block_reason(set_id).is_empty()


func research_block_reason(set_id: StringName) -> StringName:
	if _service == null or set_id.is_empty():
		return &"invalid"
	if (
		not GameState.is_game_active
		or GameState.current_phase not in [
			GameState.DayPhase.PREP,
			GameState.DayPhase.FLOOR,
		]
	):
		return &"wrong_phase"
	if _service.is_set_informed(set_id, GameState.current_day):
		return &"already_researched"
	var attention_cost := GameState.shop.research_attention_cost()
	if GameState.attention_remaining < attention_cost:
		return &"insufficient_attention"
	if not Economy.can_afford(GameState.shop.research_cash_cost_cents()):
		return &"insufficient_cash"
	return &""


func research_set(set_id: StringName) -> Dictionary:
	var reason := research_block_reason(set_id)
	if not reason.is_empty():
		return {"ok": false, "reason": reason}
	var sample := _sample_sku_for_set(set_id)
	var width_before := -1
	var width_after := -1
	var condition_cue := ""
	if not sample.is_empty():
		var before := buy_signal(
			sample,
			DemandSignalService.Channel.MARKETPLACE,
			1_200,
			1
		)
		width_before = before.shown_comp_high_cents - before.shown_comp_low_cents
		condition_cue = before.condition_cue
	var cash_cost := GameState.shop.research_cash_cost_cents()
	var attention_cost := GameState.shop.research_attention_cost()
	if not Economy.record_expense(cash_cost, &"research", "Research %s" % String(set_id)):
		return {"ok": false, "reason": &"insufficient_cash"}
	if not GameState.consume_attention(attention_cost):
		return {"ok": false, "reason": &"insufficient_attention"}
	var snapshot := _service.apply_research(set_id, GameState.current_day)
	if not sample.is_empty():
		var after := buy_signal(
			sample,
			DemandSignalService.Channel.MARKETPLACE,
			1_200,
			1
		)
		width_after = after.shown_comp_high_cents - after.shown_comp_low_cents
	var payload := {
		"ok": true,
		"reason": &"ok",
		"set_id": String(set_id),
		"display_name": String(snapshot.get("display_name", "")),
		"attention_spent": attention_cost,
		"cash_spent_cents": cash_cost,
		"through_day": int(snapshot.get("through_day", -1)),
		"telegraph_through_day": int(snapshot.get("telegraph_through_day", -1)),
		"demand_band_sigma": GameState.balance_config.demand_band_sigma,
		"research_demand_band_sigma": float(snapshot.get("demand_band_sigma", 0.07)),
		"comp_narrow_factor": float(snapshot.get("comp_narrow_factor", 0.55)),
		"sample_sku_id": String(sample),
		"sample_comp_width_before": width_before,
		"sample_comp_width_after": width_after,
		"rotation_watch": rotation_watch_text(),
		"condition_cue": condition_cue,
		"skill_channel": String(skill_channel_for(sample) if not sample.is_empty() else &"research"),
	}
	QaInstrumentation.record_research_applied(payload)
	return payload


func is_skill_informed(sku_id: StringName) -> bool:
	if GameState.shop != null and GameState.shop.has_specialist_on_duty():
		return true
	return _is_set_researched_for_sku(sku_id)


func skill_channel_for(sku_id: StringName) -> StringName:
	if GameState.shop != null and GameState.shop.has_specialist_on_duty():
		return &"specialist"
	if _is_set_researched_for_sku(sku_id):
		return &"research"
	return &""


func _is_set_researched_for_sku(sku_id: StringName) -> bool:
	if _service == null:
		return false
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null:
		return false
	return _service.is_set_informed(sku.set_id, GameState.current_day)


func _sample_sku_for_set(set_id: StringName) -> StringName:
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku != null and sku.set_id == set_id:
			return sku.id
	return &""


func _is_sealed_sku(sku_id: StringName) -> bool:
	if sku_id.is_empty():
		return false
	var sku := InventoryService.model.get_sku(sku_id)
	return sku != null and sku.product_class == ProductSKU.ProductClass.SEALED


func _effective_unit_cost_cents(opportunity: BuyOpportunity) -> int:
	if opportunity == null:
		return 0
	return sealed_wholesale_cents(
		opportunity.sku_id,
		opportunity.unit_cost_cents,
		opportunity.channel
	)


func _offer_quantity(opportunity: BuyOpportunity) -> int:
	# AP1: read Rep when the distributor offer is built. Quiet band
	# (≤24) doubles today's MOQ. Rep ≥ 25 keeps today's minimum.
	if opportunity == null:
		return 0
	if opportunity.channel != DemandSignalService.Channel.DISTRIBUTOR:
		return opportunity.quantity
	return distributor_minimum_units(
		opportunity.quantity,
		GameState.current_reputation
	)


func _purchase_quantity(
	dto: BuyConfirmSignal,
	opportunity: BuyOpportunity,
	requested_count: int
) -> int:
	if opportunity == null:
		return 0
	if opportunity.channel != DemandSignalService.Channel.DISTRIBUTOR:
		return opportunity.quantity
	var min_qty := distributor_minimum_units(
		opportunity.quantity,
		GameState.current_reputation
	)
	var buy_qty := requested_count if requested_count >= 0 else dto.quantity
	if buy_qty < min_qty:
		return 0
	return buy_qty


func _supply_glut_restock_lots() -> Array[BuyOpportunity]:
	var lots: Array[BuyOpportunity] = []
	if not has_supply_glut():
		return lots
	var deep := _make_glut_lot(
		&"supply-glut-deep-skie-blst",
		&"AA-SKIE-BLST",
		"Glut restock — deep",
		8
	)
	var skim := _make_glut_lot(
		&"supply-glut-skim-dust-etb",
		&"AA-DUST-ETB",
		"Glut restock — skim",
		2
	)
	if deep != null:
		lots.append(deep)
	if skim != null:
		lots.append(skim)
	return lots


func _make_glut_lot(
	opportunity_id: StringName,
	sku_id: StringName,
	offer_label: String,
	quantity: int
) -> BuyOpportunity:
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null or sku.product_class != ProductSKU.ProductClass.SEALED:
		return null
	var opportunity := BuyOpportunity.new()
	opportunity.id = opportunity_id
	opportunity.sku_id = sku_id
	opportunity.display_name = sku.display_name
	opportunity.offer_label = offer_label
	opportunity.channel = DemandSignalService.Channel.DISTRIBUTOR
	opportunity.unit_cost_cents = PricingService.distributor_wholesale_cents(
		sku.base_market_cents,
		GameState.balance_config
	)
	opportunity.quantity = quantity
	opportunity.space_required = 1
	if not opportunity.is_valid():
		return null
	return opportunity


func _default_demand_score(sku: ProductSKU) -> float:
	if &"staple" in sku.tags:
		return 0.68
	if &"chase" in sku.tags or &"legendary" in sku.tags:
		return 0.78
	if sku.product_class == ProductSKU.ProductClass.ACCESSORY:
		return 0.58
	return 0.45


func _bind_event_targets(event: MarketEvent) -> bool:
	match event.kind:
		MarketEvent.KIND_HYPE:
			if event.sku_id.is_empty():
				event.sku_id = _pick_hype_sku()
			return InventoryService.model.get_sku(event.sku_id) != null
		MarketEvent.KIND_ROTATION:
			if event.set_id.is_empty():
				event.set_id = MarketEventService.ROTATION_SET_ID
			return not event.set_id.is_empty()
		MarketEvent.KIND_FOG:
			event.fog_flag = true
			return true
		MarketEvent.KIND_COUNTERFEIT:
			return true
		MarketEvent.KIND_CONVENTION:
			return true
		MarketEvent.KIND_THEFT_RING:
			return true
		MarketEvent.KIND_RECESSION:
			return true
		MarketEvent.KIND_SUPPLY_GLUT:
			return true
		MarketEvent.KIND_SET_RELEASE:
			var picked := _event_service.pick_set_release_targets(
				event.set_id,
				event.old_set_id
			)
			if picked.is_empty():
				return false
			event.set_id = StringName(picked.get("set_id", &""))
			event.old_set_id = StringName(picked.get("old_set_id", &""))
			return not event.set_id.is_empty() and not event.old_set_id.is_empty()
		MarketEvent.KIND_PRO_TOUR:
			var picked := _event_service.pick_pro_tour_target(event.archetype_tag)
			if picked.is_empty():
				return false
			event.archetype_tag = StringName(picked.get("archetype_tag", &""))
			if event.pro_tour_mult <= 0.0:
				event.pro_tour_mult = _event_service.roll_pro_tour_mult(
					GameState.balance_config
				)
			return (
				ProTourSpikePolicy.is_archetype_tag(event.archetype_tag)
				and event.pro_tour_mult > 0.0
			)
		MarketEvent.KIND_ROTATION_CRASH:
			if RotationCrashPolicy.is_base_set(event.set_id):
				return false
			var crash_target := _event_service.pick_rotation_crash_target(event.set_id)
			if crash_target.is_empty():
				return false
			event.set_id = StringName(crash_target.get("set_id", &""))
			if event.set_id.is_empty() or RotationCrashPolicy.is_base_set(event.set_id):
				return false
			if event.rotation_crash_mult <= 0.0:
				event.rotation_crash_mult = _event_service.roll_rotation_crash_mult(
					GameState.balance_config
				)
			return event.rotation_crash_mult > 0.0
	return false


func _apply_event_effects(event: MarketEvent) -> bool:
	if _service == null:
		return false
	var through_day := GameState.current_day + event.remaining_days - 1
	match event.kind:
		MarketEvent.KIND_HYPE:
			return apply_hype_event(event.sku_id, through_day)
		MarketEvent.KIND_ROTATION:
			return true
		MarketEvent.KIND_FOG:
			_service.set_fog_event(true, MarketEventService.FOG_SIGMA_MULT)
			return true
		MarketEvent.KIND_COUNTERFEIT:
			_service.set_counterfeit_scare(
				true,
				MarketEventService.COUNTERFEIT_TRUST_MULT,
				MarketEventService.COUNTERFEIT_SHADY_FAKE_MULT,
				MarketEventService.COUNTERFEIT_SHADY_WIDTH_MULT
			)
			return true
		MarketEvent.KIND_CONVENTION:
			return true
		MarketEvent.KIND_THEFT_RING:
			return true
		MarketEvent.KIND_RECESSION:
			_service.set_recession_week(
				true,
				MarketEventService.RECESSION_DEMAND_MULT
			)
			return true
		MarketEvent.KIND_SUPPLY_GLUT:
			_service.set_supply_glut(
				true,
				MarketEventService.SUPPLY_GLUT_SEALED_RACE_MULT
			)
			return true
		MarketEvent.KIND_SET_RELEASE:
			_service.set_set_release_hype(
				true,
				event.set_id,
				event.old_set_id,
				SetReleaseHypePolicy.hype_new_mult_for(GameState.balance_config),
				SetReleaseHypePolicy.hype_old_mult_for(GameState.balance_config)
			)
			return true
		MarketEvent.KIND_PRO_TOUR:
			_sync_pro_tour_service(event)
			return true
		MarketEvent.KIND_ROTATION_CRASH:
			_sync_rotation_crash_service(event)
			return true
	return false


func _clear_active_event() -> void:
	if _active_event != null:
		_revert_event_effects(_active_event)
	_active_event = null
	_publish_event_changed()


func _revert_event_effects(event: MarketEvent) -> void:
	if event == null or _service == null:
		return
	match event.kind:
		MarketEvent.KIND_HYPE:
			var sku := InventoryService.model.get_sku(event.sku_id)
			if sku == null:
				return
			_service.clear_forced_demand_band(event.sku_id)
			_market_state.update_sku(
				event.sku_id,
				sku.base_market_cents,
				_default_demand_score(sku)
			)
		MarketEvent.KIND_FOG:
			_service.set_fog_event(false)
		MarketEvent.KIND_COUNTERFEIT:
			_service.set_counterfeit_scare(false)
		MarketEvent.KIND_CONVENTION:
			pass
		MarketEvent.KIND_THEFT_RING:
			pass
		MarketEvent.KIND_RECESSION:
			_service.set_recession_week(false)
		MarketEvent.KIND_SUPPLY_GLUT:
			_service.set_supply_glut(false)
		MarketEvent.KIND_SET_RELEASE:
			_service.set_set_release_hype(false)
		MarketEvent.KIND_PRO_TOUR:
			_service.set_pro_tour_spike(false)
		MarketEvent.KIND_ROTATION_CRASH:
			_service.set_rotation_crash(false)
		MarketEvent.KIND_ROTATION:
			pass


func _sync_pro_tour_service(event: MarketEvent) -> void:
	if _service == null:
		return
	if event == null or event.kind != MarketEvent.KIND_PRO_TOUR:
		_service.set_pro_tour_spike(false)
		return
	var spike := ProTourSpikePolicy.is_spike_window(
		event.remaining_days,
		event.duration_days
	)
	_service.set_pro_tour_spike(spike, event.archetype_tag, event.pro_tour_mult)


func _sync_rotation_crash_service(event: MarketEvent) -> void:
	if _service == null:
		return
	if event == null or event.kind != MarketEvent.KIND_ROTATION_CRASH:
		_service.set_rotation_crash(false)
		return
	_service.set_rotation_crash(
		true,
		event.set_id,
		event.rotation_crash_mult,
		RotationCrashPolicy.mild_mult_for(GameState.balance_config)
	)


func _can_see_rotation_leak(event: MarketEvent) -> bool:
	if event == null or event.kind != MarketEvent.KIND_ROTATION:
		return false
	if GameState.shop.has_specialist_on_duty():
		return true
	return _service != null and _service.is_set_informed(event.set_id, GameState.current_day)


func _pick_hype_sku() -> StringName:
	if (
		GameState.current_day >= 8
		and GameState.current_day <= 10
		and InventoryService.model.get_sku(MarketEventService.TITAN_SKU) != null
	):
		return MarketEventService.TITAN_SKU
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku == null:
			continue
		if &"chase" in sku.tags or &"staple" in sku.tags:
			return sku.id
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku != null and sku.product_class != ProductSKU.ProductClass.ACCESSORY:
			return sku.id
	return MarketEventService.TITAN_SKU


func _record_roll(event: MarketEvent, rolled: bool) -> Dictionary:
	var payload := {
		"day": GameState.current_day,
		"rolled": rolled,
		"event_id": String(event.id) if event != null else "",
		"kind": String(event.kind) if event != null else "",
		"remaining_days": event.remaining_days if event != null else 0,
		"sku_id": String(event.sku_id) if event != null else "",
		"set_id": String(event.set_id) if event != null else "",
		"old_set_id": String(event.old_set_id) if event != null else "",
		"fog_flag": event.fog_flag if event != null else false,
		"demand_band_sigma": active_demand_band_sigma(),
		"inspect_mandatory": (
			event != null and event.kind == MarketEvent.KIND_COUNTERFEIT
		),
		"graded_trust_mult": graded_trust_mult(),
		"shady_width_mult": shady_width_mult(),
		"traffic_mult": active_event_traffic_mult(),
		"whale_weight_mult": active_event_whale_weight_mult(),
		"play_table_placed": GameState.shop.has_play_table_placed(),
		"event_night": MarketEventService.is_event_night_day(GameState.current_day),
		"calendar_day": MarketEventService.is_convention_calendar_day(
			GameState.current_day
		),
		"shrink_mult": active_shrink_multiplier(),
		"theft_ring": has_theft_ring(),
		"cameras_active": GameState.shop.has_active_cameras(),
		"demand_mult": active_event_demand_mult(),
		"sell_through_mult": active_event_sell_through_mult(),
		"buylist_mult": active_event_buylist_mult(),
		"recession_week": has_recession_week(),
		"sealed_wholesale_mult": active_sealed_wholesale_mult(),
		"sealed_race_mult": active_sealed_race_mult(),
		"supply_glut": has_supply_glut(),
		"set_release_hype": has_set_release_hype(),
		"hype_new_mult": (
			SetReleaseHypePolicy.hype_new_mult_for(GameState.balance_config)
			if has_set_release_hype()
			else 1.0
		),
		"hype_old_mult": (
			SetReleaseHypePolicy.hype_old_mult_for(GameState.balance_config)
			if has_set_release_hype()
			else 1.0
		),
		"pro_tour": has_pro_tour(),
		"pro_tour_spike": has_pro_tour_spike(),
		"archetype_tag": String(event.archetype_tag) if event != null else "",
		"pro_tour_mult": (
			event.pro_tour_mult
			if event != null and event.kind == MarketEvent.KIND_PRO_TOUR
			else 1.0
		),
		"rotation_crash": has_rotation_crash(),
		"rotation_crash_mult": (
			event.rotation_crash_mult
			if event != null and event.kind == MarketEvent.KIND_ROTATION_CRASH
			else 1.0
		),
		"pending_rotation_crash_set_id": String(_pending_rotation_crash_set_id),
	}
	QaInstrumentation.record_market_event_rolled(payload)
	return payload


func _should_offer_event_price_editor() -> bool:
	var event := active_event()
	if event == null or event.price_editor_prompted:
		return false
	if event.kind != MarketEvent.KIND_HYPE and event.kind != MarketEvent.KIND_FOG:
		return false
	if not GameState.is_game_active:
		return false
	return GameState.current_phase in [
		GameState.DayPhase.PREP,
		GameState.DayPhase.FLOOR,
	]


func _is_sku_priceable(sku_id: StringName) -> bool:
	if sku_id.is_empty():
		return false
	for item: Dictionary in InventoryService.get_priceable_stock():
		if StringName(item["sku_id"]) == sku_id:
			return true
	return false


func _first_priceable_sku() -> StringName:
	for item: Dictionary in InventoryService.get_priceable_stock():
		return StringName(item["sku_id"])
	return &""


func _ensure_priceable_sku(sku_id: StringName) -> StringName:
	if _is_sku_priceable(sku_id):
		return sku_id
	var sku := InventoryService.model.get_sku(sku_id)
	if sku != null and sku.product_class == ProductSKU.ProductClass.SINGLE:
		if InventoryService.receive_card(
			sku_id,
			sku.base_market_cents,
			InventoryLocation.new(InventoryLocation.Type.BINDER),
			sku.base_market_cents
		) != null:
			return sku_id
	if sku_id != MarketEventService.TITAN_SKU:
		return _ensure_priceable_sku(MarketEventService.TITAN_SKU)
	return &""


func _publish_event_changed() -> void:
	if Engine.get_main_loop() == null:
		return
	EventBus.market_event_changed.emit(event_to_save())
