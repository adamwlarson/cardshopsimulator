extends Node

var _market_state := MarketState.new()
var _service: DemandSignalService
var _opportunity_catalog := BuyOpportunityCatalog.new()
var _closed_opportunity_ids: Dictionary = {}
var _scripted_opportunities: Array[BuyOpportunity] = []
var _event_service := MarketEventService.new()
var _active_event: MarketEvent


func reset() -> void:
	_market_state = MarketState.new()
	_closed_opportunity_ids.clear()
	_scripted_opportunities.clear()
	_event_service.reset(MarketEventService.EVENT_RNG_SEED)
	_active_event = null
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


func roll_settle_events() -> Dictionary:
	if _active_event != null and _active_event.is_active():
		_active_event.remaining_days -= 1
		if not _active_event.is_active():
			_clear_active_event()
	if _active_event != null and _active_event.is_active():
		return _record_roll(_active_event, false)
	var config := GameState.balance_config
	if not _event_service.should_roll(config):
		return _record_roll(null, true)
	var def := _event_service.roll_definition(config)
	if def.is_empty():
		return _record_roll(null, true)
	var started := start_pack_event(
		StringName(def.get("type", "")),
		{"duration_days": _event_service.roll_duration(def)}
	)
	if started == null or not started.is_active():
		return _record_roll(null, true)
	return _record_roll(started, true)


func start_pack_event(kind: StringName, opts: Dictionary = {}) -> MarketEvent:
	var def := _event_service.definition_for(kind)
	if def.is_empty():
		return null
	_clear_active_event()
	var event := MarketEvent.new()
	event.id = StringName(def.get("id", kind))
	event.kind = kind
	event.title = String(def.get("title", String(kind)))
	event.duration_days = int(opts.get("duration_days", _event_service.roll_duration(def)))
	event.duration_days = maxi(1, event.duration_days)
	event.remaining_days = int(opts.get("remaining_days", event.duration_days))
	event.remaining_days = maxi(1, event.remaining_days)
	event.sku_id = StringName(opts.get("sku_id", &""))
	event.set_id = StringName(opts.get("set_id", &""))
	event.fog_flag = bool(def.get("fog_flag", kind == MarketEvent.KIND_FOG))
	if not _bind_event_targets(event):
		return null
	if not _apply_event_effects(event):
		return null
	_active_event = event
	_publish_event_changed()
	return event


func active_event() -> MarketEvent:
	if _active_event != null and _active_event.is_active():
		return _active_event
	return null


func has_fog_flag() -> bool:
	return _service != null and _service.has_fog_flag()


func active_demand_band_sigma(informed: bool = false) -> float:
	if _service == null:
		return GameState.balance_config.demand_band_sigma
	return _service.active_demand_band_sigma(informed)


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
		MarketEvent.KIND_ROTATION:
			if not _can_see_rotation_leak(event):
				return ""
			return "Rotation watch: %s" % _service.display_name_for_set(event.set_id)
	return event.title


func event_to_save() -> Dictionary:
	var event := active_event()
	if event == null:
		return {}
	return event.to_save()


func seed_event_rng(rng_seed: int) -> void:
	_event_service.reset(rng_seed)


func apply_event_save(data: Dictionary) -> bool:
	_clear_active_event()
	if data.is_empty():
		_publish_event_changed()
		return true
	var event := MarketEvent.from_save(data)
	if not event.is_active():
		_publish_event_changed()
		return true
	if not _bind_event_targets(event):
		return false
	if not _apply_event_effects(event):
		return false
	_active_event = event
	_publish_event_changed()
	return true


func open_buy_signals() -> Array[BuyConfirmSignal]:
	var result: Array[BuyConfirmSignal] = []
	for opportunity: BuyOpportunity in _open_opportunities():
		result.append(_signal_for_opportunity(opportunity))
	return result


func confirm_buy(dto: BuyConfirmSignal) -> bool:
	if dto == null or not dto.can_confirm:
		return false
	for opportunity: BuyOpportunity in _open_opportunities():
		if opportunity.id != dto.opportunity_id:
			continue
		var shown_midpoint := (
			dto.shown_comp_low_cents + dto.shown_comp_high_cents
		) / 2
		var purchased := InventoryService.confirm_stock_purchase(
			opportunity.sku_id,
			opportunity.quantity,
			opportunity.unit_cost_cents,
			shown_midpoint - opportunity.unit_cost_cents,
			InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
		)
		if purchased:
			_closed_opportunity_ids[opportunity.id] = true
		return purchased
	return false


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
		unit_cost_cents,
		quantity,
		Economy.balance_cents,
		space_required,
		InventoryService.backstock_free_bins(),
		_informed_for_sku(sku_id)
	)


func buylist_signal(sku_id: StringName, quantity: int = 1) -> BuyConfirmSignal:
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null:
		return null
	var unit_offer_cents := PricingService.suggested_buy_price_cents(
		sku.base_market_cents
	)
	var dto := buy_signal(
		sku_id,
		DemandSignalService.Channel.BUYLIST,
		unit_offer_cents,
		quantity
	)
	dto.display_name = sku.display_name
	dto.offer_label = "Walk-in seller"
	dto.channel = &"buylist"
	dto.quantity = quantity
	return dto


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
		result.append(dto)
	return result


func refresh_price_signal(
	dto: PriceConfirmSignal,
	listed_price_cents: int
) -> PriceConfirmSignal:
	if dto == null:
		return null
	return _service.refresh_price_confirm(
		dto,
		listed_price_cents,
		InventoryService.location_for(dto.sku_id)
	)


func _open_opportunities() -> Array[BuyOpportunity]:
	var result: Array[BuyOpportunity] = []
	var opportunities := _opportunity_catalog.open_for_day(
		GameState.current_day,
		InventoryService.model.catalog
	)
	opportunities.append_array(_scripted_opportunities)
	for opportunity: BuyOpportunity in opportunities:
		if not _closed_opportunity_ids.has(opportunity.id):
			result.append(opportunity)
	return result


func _signal_for_opportunity(opportunity: BuyOpportunity) -> BuyConfirmSignal:
	var dto := buy_signal(
		opportunity.sku_id,
		opportunity.channel,
		opportunity.unit_cost_cents,
		opportunity.quantity,
		opportunity.space_required
	)
	dto.opportunity_id = opportunity.id
	dto.display_name = opportunity.display_name
	dto.offer_label = opportunity.offer_label
	dto.channel = StringName(
		DemandSignalService.Channel.keys()[opportunity.channel].to_lower()
	)
	dto.quantity = opportunity.quantity
	dto.beat_id = opportunity.beat_id
	_service.apply_inspect_state(dto)
	return dto


func can_inspect(dto: BuyConfirmSignal) -> bool:
	return (
		_service != null
		and _service.can_inspect(dto)
		and GameState.can_inspect()
	)


func inspect_buy(dto: BuyConfirmSignal) -> bool:
	if not can_inspect(dto):
		return false
	return _service.inspect_condition(dto)


func price_signal(
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation
) -> PriceConfirmSignal:
	return _service.price_confirm(
		GameState.current_day,
		sku_id,
		listed_price_cents,
		location,
		DemandSignalService.Channel.BUYLIST,
		_informed_for_sku(sku_id)
	)


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
	if not GameState.can_research():
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
	}
	QaInstrumentation.record_research_applied(payload)
	return payload


func _informed_for_sku(sku_id: StringName) -> bool:
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
		MarketEvent.KIND_ROTATION:
			pass


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
		"fog_flag": event.fog_flag if event != null else false,
		"demand_band_sigma": active_demand_band_sigma(),
	}
	QaInstrumentation.record_market_event_rolled(payload)
	return payload


func _publish_event_changed() -> void:
	if Engine.get_main_loop() == null:
		return
	EventBus.market_event_changed.emit(event_to_save())
