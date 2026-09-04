class_name BuyOpportunityCatalog
extends RefCounted

const DATA_PATH := "res://data/buy_opportunities.json"


func open_for_day(day: int, products: Dictionary) -> Array[BuyOpportunity]:
	var result: Array[BuyOpportunity] = []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not parsed is Dictionary:
		push_error("Could not load buy opportunities.")
		return result
	for value: Variant in (parsed as Dictionary).get("opportunities", []):
		var entry := value as Dictionary
		if day < int(entry.get("first_day", 1)):
			continue
		var last_day := int(entry.get("last_day", day))
		if day > last_day:
			continue
		var sku_id := StringName(entry.get("sku", ""))
		var product := products.get(sku_id) as ProductSKU
		if product == null:
			continue
		var opportunity := BuyOpportunity.new()
		opportunity.id = StringName(entry.get("id", ""))
		opportunity.sku_id = sku_id
		opportunity.display_name = product.display_name
		opportunity.offer_label = String(entry.get("offer_label", "Lot"))
		opportunity.channel = _channel_from_name(String(entry.get("channel", "")))
		opportunity.unit_cost_cents = int(entry.get("unit_cost_cents", 0))
		opportunity.quantity = int(entry.get("quantity", 0))
		opportunity.space_required = int(entry.get("space_required", 1))
		opportunity.beat_id = StringName(entry.get("beat_id", ""))
		if opportunity.is_valid():
			result.append(opportunity)
	return result


func _channel_from_name(value: String) -> DemandSignalService.Channel:
	match value.to_lower():
		"distributor":
			return DemandSignalService.Channel.DISTRIBUTOR
		"buylist":
			return DemandSignalService.Channel.BUYLIST
		"auction":
			return DemandSignalService.Channel.AUCTION
		"shady":
			return DemandSignalService.Channel.SHADY
	return DemandSignalService.Channel.MARKETPLACE
