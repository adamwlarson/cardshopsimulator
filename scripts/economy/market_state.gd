class_name MarketState
extends RefCounted

var _state_by_sku: Dictionary = {}


func update_sku(sku_id: StringName, market_cents: int, demand_score: float) -> void:
	if sku_id.is_empty() or market_cents <= 0:
		return
	_state_by_sku[sku_id] = {
		"market_cents": market_cents,
		"demand_score": clampf(demand_score, 0.0, 1.0),
	}


func has_sku(sku_id: StringName) -> bool:
	return _state_by_sku.has(sku_id)


func market_cents_for(sku_id: StringName) -> int:
	var state: Dictionary = _state_by_sku.get(sku_id, {})
	return int(state.get("market_cents", 0))


func demand_score_for(sku_id: StringName) -> float:
	var state: Dictionary = _state_by_sku.get(sku_id, {})
	return float(state.get("demand_score", 0.0))
