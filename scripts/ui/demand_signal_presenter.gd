class_name DemandSignalPresenter
extends RefCounted


static func format_cents(value: int) -> String:
	var sign_text := "-" if value < 0 else ""
	var absolute := absi(value)
	return "%s$%d.%02d" % [sign_text, absolute / 100, absolute % 100]


static func buy_summary(signal: BuyConfirmSignal) -> String:
	return "\n".join([
		"Ask (exact): %s each · %s total" % [
			format_cents(signal.unit_cost_cents),
			format_cents(signal.lot_total_cents),
		],
		"Comp range: %s – %s" % [
			format_cents(signal.shown_comp_low_cents),
			format_cents(signal.shown_comp_high_cents),
		],
		"Demand: %s · Confidence: %s" % [
			String(signal.shown_demand_band).to_upper(),
			String(signal.confidence).capitalize(),
		],
		"Condition: %s" % signal.condition_cue,
		"After buy: %s · Space: %d needed / %d free" % [
			format_cents(signal.remaining_cash_cents),
			signal.space_required,
			signal.space_free,
		],
	])


static func price_summary(signal: PriceConfirmSignal) -> String:
	var percent := roundi(signal.price_delta_percent * 100.0)
	return "\n".join([
		"Suggested (noisy): %s" % format_cents(signal.suggested_price_cents),
		"Vs suggestion: %s (%+d%%)" % [
			format_cents(signal.price_delta_cents),
			percent,
		],
		"Position: %s · Demand: %s" % [
			String(signal.position).capitalize(),
			String(signal.shown_demand_band).to_upper(),
		],
		"Move feel: %s · %s" % [
			String(signal.move_feel).replace("_", " ").capitalize(),
			signal.display_context,
		],
	])
