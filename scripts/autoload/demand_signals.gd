extends Node

var _market_state := MarketState.new()
var _service: DemandSignalService
var _opportunity_catalog := BuyOpportunityCatalog.new()
var _closed_opportunity_ids: Dictionary = {}


func reset() -> void:
	_market_state = MarketState.new()
	_closed_opportunity_ids.clear()
	for value: Variant in InventoryService.model.catalog.values():
		var sku := value as ProductSKU
		if sku == null:
			continue
		var demand_score := 0.45
		if &"staple" in sku.tags:
			demand_score = 0.68
		elif &"chase" in sku.tags or &"legendary" in sku.tags:
			demand_score = 0.78
		elif sku.product_class == ProductSKU.ProductClass.ACCESSORY:
			demand_score = 0.58
		_market_state.update_sku(sku.id, sku.base_market_cents, demand_score)
	_service = DemandSignalService.new(
		GameState.balance_config,
		_market_state,
		GameState.current_day * 7919,
		QaInstrumentation
	)


func apply_hype_event(
	sku_id: StringName,
	through_day: int,
	market_multiplier: float = 1.35
) -> bool:
	var sku := InventoryService.model.get_sku(sku_id)
	if sku == null or _service == null:
		return false
	var current_market := _market_state.market_cents_for(sku_id)
	_market_state.update_sku(
		sku_id,
		maxi(sku.base_market_cents, roundi(current_market * market_multiplier)),
		0.95
	)
	_service.force_demand_band(sku_id, &"hot", through_day)
	return true


func apply_soft_shelf_signal(sku_id: StringName, through_day: int) -> bool:
	if InventoryService.model.get_sku(sku_id) == null or _service == null:
		return false
	_service.force_demand_band(sku_id, &"steady", through_day)
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
		GameState.balance_config.backstock_bins - InventoryService.model.backstock_bins_used()
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
	var refreshed := price_signal(
		dto.sku_id,
		listed_price_cents,
		InventoryService.location_for(dto.sku_id)
	)
	refreshed.display_name = dto.display_name
	refreshed.quantity = dto.quantity
	return refreshed


func _open_opportunities() -> Array[BuyOpportunity]:
	var result: Array[BuyOpportunity] = []
	var opportunities := _opportunity_catalog.open_for_day(
		GameState.current_day,
		InventoryService.model.catalog
	)
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
	return dto


func price_signal(
	sku_id: StringName,
	listed_price_cents: int,
	location: InventoryLocation
) -> PriceConfirmSignal:
	return _service.price_confirm(
		GameState.current_day,
		sku_id,
		listed_price_cents,
		location
	)
