class_name DemandSignalPresenter
extends RefCounted


static func format_cents(value: int) -> String:
	var sign_text := "-" if value < 0 else ""
	var absolute := absi(value)
	return "%s$%d.%02d" % [sign_text, absolute / 100, absolute % 100]


static func parse_cents(text: String) -> int:
	var cleaned := text.strip_edges().trim_prefix("$")
	if cleaned.is_empty():
		return 0
	var parts := cleaned.split(".", false, 1)
	if not parts[0].is_valid_int():
		return 0
	var dollars := int(parts[0])
	var cents := 0
	if parts.size() > 1:
		var cents_text := parts[1].left(2).rpad(2, "0")
		if not cents_text.is_valid_int():
			return 0
		cents = int(cents_text)
	return dollars * 100 + cents


static func buy_summary(dto: BuyConfirmSignal) -> String:
	return "\n".join([
		"Ask (exact): %s each · %s total" % [
			format_cents(dto.unit_cost_cents),
			format_cents(dto.lot_total_cents),
		],
		"Comp range: %s – %s" % [
			format_cents(dto.shown_comp_low_cents),
			format_cents(dto.shown_comp_high_cents),
		],
		"Demand: %s · Confidence: %s" % [
			String(dto.shown_demand_band).to_upper(),
			String(dto.confidence).capitalize(),
		],
		"Condition: %s" % dto.condition_cue,
		"After buy: %s · Space: %d needed / %d free" % [
			format_cents(dto.remaining_cash_cents),
			dto.space_required,
			dto.space_free,
		],
	])


static func price_summary(dto: PriceConfirmSignal) -> String:
	var percent := roundi(dto.price_delta_percent * 100.0)
	return "\n".join([
		"Suggested (noisy): %s" % format_cents(dto.suggested_price_cents),
		"Vs suggestion: %s (%+d%%)" % [
			format_cents(dto.price_delta_cents),
			percent,
		],
		"Position: %s · Demand: %s" % [
			String(dto.position).capitalize(),
			String(dto.shown_demand_band).to_upper(),
		],
		"Move feel: %s · %s" % [
			String(dto.move_feel).replace("_", " ").capitalize(),
			dto.display_context,
		],
	])
