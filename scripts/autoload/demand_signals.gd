extends Node

var _market_state := MarketState.new()
var _service: DemandSignalService


func reset() -> void:
	_market_state = MarketState.new()
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
