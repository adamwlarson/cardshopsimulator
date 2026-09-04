extends SceneTree

const EASY_CONFIG: BalanceConfig = preload("res://data/balance/easy.tres")
const NORMAL_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")
const HARD_CONFIG: BalanceConfig = preload("res://data/balance/hard.tres")

var _failures: int = 0
var _qa := QaInstrumentationService.new()


func _initialize() -> void:
	_test_pricing_spread()
	_test_stock_lot_unit_cost()
	_test_inventory_mutations_and_capacity()
	_test_balance_seed_inventory()
	_test_demand_signal_dto_does_not_leak_truth()
	_test_demand_fairness_contract()
	_test_qa_instrumentation_payloads()
	_test_difficulty_balance_ordering()
	_test_normal_shop_capacity()
	_test_weekly_rent_schedule()
	_test_customer_archetype_weights()
	_test_customer_spawn_phase_gating()
	_test_day_phase_transitions()
	_test_negotiate_clamp()
	_test_ui_helpers_do_not_read_hidden_values()

	if _failures == 0:
		print("All foundation tests passed.")
		_qa.free()
		quit(0)
	else:
		push_error("%d foundation test(s) failed." % _failures)
		_qa.free()
		quit(1)


func _test_pricing_spread() -> void:
	_expect_equal(PricingService.suggested_buy_price_cents(1000), 550, "default buy offer")
	_expect_equal(PricingService.suggested_sell_price_cents(600, 700), 720, "margin floor")
	_expect_equal(PricingService.spread_cents(550, 720), 170, "buy/sell spread")


func _test_stock_lot_unit_cost() -> void:
	var lot := StockLot.new()
	lot.qty = 4
	lot.acquired_cost_avg_cents = 250
	_expect_equal(lot.unit_cost_cents(), 250, "weighted unit cost")
	_expect_equal(lot.total_cost_cents(), 1000, "lot total cost")


func _test_inventory_mutations_and_capacity() -> void:
	var config := BalanceConfig.new()
	config.case_slots = 2
	config.backstock_bins = 1
	var inventory := InventoryModel.new(config)
	var backstock := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	var shelf := InventoryLocation.new(InventoryLocation.Type.SHELF)
	_expect_equal(inventory.add_stock(&"ACC-SLV-60", 2, 100, shelf), true, "add accessory lot")
	_expect_equal(inventory.add_stock(&"ACC-SLV-60", 2, 200, shelf), true, "merge accessory lot")
	_expect_equal(inventory.get_stock_quantity(&"ACC-SLV-60"), 4, "merged accessory quantity")
	_expect_equal(inventory.stock_lots[0].unit_cost_cents(), 150, "weighted lot average")
	_expect_equal(inventory.remove_stock(&"ACC-SLV-60", 3), true, "remove accessory stock")
	_expect_equal(inventory.remove_stock(&"ACC-SLV-60", 2), false, "reject stock underflow")
	_expect_equal(inventory.add_stock(&"AA-BASE-088", 1, 100, shelf), false, "single cannot use stock lot")
	_expect_equal(inventory.add_stock(&"AA-DUST-ETB", 1, 100, backstock), true, "first backstock bin")
	_expect_equal(inventory.add_stock(&"AA-SKIE-ETB", 1, 100, backstock), false, "backstock capacity")
	_expect_equal(inventory.move_stock(&"ACC-SLV-60", shelf, backstock, 1), false, "reject move to full backstock")
	_expect_equal(inventory.remove_stock(&"AA-DUST-ETB", 1), true, "remove complete stock lot")
	_expect_equal(inventory.move_stock(&"ACC-SLV-60", shelf, backstock, 1), true, "split lot into free backstock")
	_expect_equal(inventory.get_stock_quantity(&"ACC-SLV-60"), 1, "split move preserves quantity")

	var case_location := InventoryLocation.new(InventoryLocation.Type.CASE)
	var first_card := CardInstance.new(&"AA-BASE-088", 200, case_location)
	var second_card := CardInstance.new(&"AA-BASE-078", 200, case_location)
	_expect_equal(inventory.add_card(first_card), true, "first case card")
	_expect_equal(inventory.add_card(second_card), true, "second case card")
	var slab_card := CardInstance.new(&"AA-SKIE-052", 300)
	var slab := SlabInstance.new(slab_card, &"Prism Grade", 10.0, "CERT-1", 500, case_location)
	_expect_equal(inventory.add_slab(slab), false, "slab needs two free case slots")
	_expect_equal(inventory.case_slots_used(), 2, "case slot accounting")
	_expect_equal(inventory.remove_card(first_card), true, "remove first card")
	_expect_equal(inventory.remove_card(second_card), true, "remove second card")
	_expect_equal(inventory.add_slab(slab), true, "add slab with two free slots")
	_expect_equal(inventory.add_slab(slab), false, "reject duplicate slab object")
	var duplicate_card_slab := SlabInstance.new(
		slab_card, &"Vaultmark", 9.5, "CERT-2", 500, case_location
	)
	_expect_equal(
		inventory.add_slab(duplicate_card_slab),
		false,
		"reject duplicate slab card ownership"
	)
	_expect_equal(inventory.remove_slab(slab), true, "remove slab")

	var split_config := BalanceConfig.new()
	split_config.backstock_bins = 2
	var split_inventory := InventoryModel.new(split_config)
	var bin_zero := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK, 0)
	var bin_one := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK, 1)
	var bin_two := InventoryLocation.new(InventoryLocation.Type.BACKSTOCK, 2)
	_expect_equal(split_inventory.add_stock(&"ACC-SLV-60", 2, 100, bin_zero), true, "fill first bin")
	_expect_equal(split_inventory.add_stock(&"ACC-TOP-25", 1, 100, bin_one), true, "fill second bin")
	_expect_equal(
		split_inventory.move_stock(&"ACC-SLV-60", bin_zero, bin_two, 1),
		false,
		"partial split cannot overflow bins"
	)


func _test_balance_seed_inventory() -> void:
	for config: BalanceConfig in [EASY_CONFIG, NORMAL_CONFIG, HARD_CONFIG]:
		var inventory := InventoryModel.new(config)
		inventory.reset_and_seed()
		_expect_equal(
			inventory.get_stock_quantity(&"AA-SKIE-BLST"),
			config.seed_blasters + config.seed_skie_blasters,
			"seed current-set blasters"
		)
		_expect_equal(
			inventory.get_stock_quantity(&"AA-DUST-ETB"),
			config.seed_dust_etbs,
			"seed Dust ETBs"
		)
		_expect_equal(
			inventory.get_stock_quantity(&"ACC-SLV-60"),
			ceili(config.seed_sleeves / 60.0),
			"seed sleeve packs"
		)
		_expect_equal(
			inventory.get_stock_quantity(&"ACC-TOP-25"),
			ceili(config.seed_toploaders / 25.0),
			"seed toploader packs"
		)
		_expect_equal(
			inventory.cards.size(),
			config.seed_named_staples + config.seed_bulk_cards,
			"seed card count"
		)
	_expect_equal(
		InventoryModel.new(NORMAL_CONFIG).get_sku(&"AA-SKIE-ETB") != null,
		true,
		"canon Skiefall ETB catalog SKU"
	)


func _test_demand_signal_dto_does_not_leak_truth() -> void:
	_qa.set_force_enabled(false)
	var market_state := MarketState.new()
	market_state.update_sku(&"AA-SKIE-047", 2200, 0.75)
	var service := DemandSignalService.new(NORMAL_CONFIG, market_state, 42, _qa)
	var buy_signal := service.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		1200, 2, 800_000, 1, 3
	)
	var price_signal := service.price_confirm(
		1, &"AA-SKIE-047", 2300,
		InventoryLocation.new(InventoryLocation.Type.CASE)
	)
	_expect_dto_has_no_truth_fields(buy_signal, "buy signal")
	_expect_dto_has_no_truth_fields(price_signal, "price signal")
	_expect_equal(
		buy_signal.shown_demand_band,
		price_signal.shown_demand_band,
		"shared daily demand band"
	)
	_expect_equal(price_signal.move_feel.is_empty(), false, "qualitative move feel")


func _test_demand_fairness_contract() -> void:
	var market_state := MarketState.new()
	market_state.update_sku(&"AA-SKIE-047", 10_000, 0.70)
	var service := DemandSignalService.new(NORMAL_CONFIG, market_state, 99, _qa)
	var total_midpoint_error := 0.0
	var within_one_band := 0
	var sample_count := 0
	for day: int in range(1, 31):
		var dto := service.buy_confirm(
			day, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
			5000, 1, 800_000, 1, 10
		)
		var midpoint: int = (dto.shown_comp_low_cents + dto.shown_comp_high_cents) / 2
		total_midpoint_error += absf(float(midpoint - 10_000)) / 10_000.0
		var shown_index := _band_index(dto.shown_demand_band)
		var true_index := _band_index(&"warm")
		if absi(shown_index - true_index) <= 1:
			within_one_band += 1
		sample_count += 1
	_expect_equal(
		total_midpoint_error / sample_count <= NORMAL_CONFIG.fair_comp_mae_max,
		true,
		"30-day comp MAE fairness"
	)
	_expect_equal(
		float(within_one_band) / sample_count >= NORMAL_CONFIG.fair_band_within1_min,
		true,
		"30-day band fairness"
	)

	var narrow_default := DemandSignalService.new(NORMAL_CONFIG, market_state, 12, _qa)
	var narrow_research := DemandSignalService.new(NORMAL_CONFIG, market_state, 12, _qa)
	var default_dto := narrow_default.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		5000, 1, 800_000, 1, 10
	)
	var research_dto := narrow_research.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		5000, 1, 800_000, 1, 10, true
	)
	_expect_equal(
		research_dto.shown_comp_high_cents - research_dto.shown_comp_low_cents
		< default_dto.shown_comp_high_cents - default_dto.shown_comp_low_cents,
		true,
		"research narrows comp"
	)
	var distributor_service := DemandSignalService.new(
		NORMAL_CONFIG, market_state, 12, _qa
	)
	var distributor_dto := distributor_service.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.DISTRIBUTOR,
		5000, 1, 800_000, 1, 10
	)
	_expect_equal(
		distributor_dto.shown_comp_high_cents - distributor_dto.shown_comp_low_cents
		< default_dto.shown_comp_high_cents - default_dto.shown_comp_low_cents,
		true,
		"distributor comp tighter than marketplace"
	)

	for demand_score: float in [0.0, 1.0]:
		market_state.update_sku(&"AA-SKIE-047", 10_000, demand_score)
		var inversion_service := DemandSignalService.new(
			NORMAL_CONFIG, market_state, 123, _qa
		)
		for day: int in range(1, 101):
			var dto := inversion_service.buy_confirm(
				day, &"AA-SKIE-047", DemandSignalService.Channel.SHADY,
				5000, 1, 800_000, 1, 10
			)
			var cruel_inversion := (
				demand_score == 0.0 and dto.shown_demand_band == &"hot"
				or demand_score == 1.0 and dto.shown_demand_band == &"cold"
			)
			_expect_equal(cruel_inversion, false, "forbid hot-cold inversion")


func _test_qa_instrumentation_payloads() -> void:
	_qa.set_force_enabled(true)
	_qa.clear()
	_qa.begin_day(3, 10_000)
	_qa.end_day(3, 11_500)
	_qa.record_buy_confirm(&"AA-DUST-ETB", 2, 2500, 1500)
	var market_state := MarketState.new()
	market_state.update_sku(&"AA-DUST-ETB", 4499, 0.30)
	var service := DemandSignalService.new(NORMAL_CONFIG, market_state, 7, _qa)
	service.buy_confirm(
		3, &"AA-DUST-ETB", DemandSignalService.Channel.DISTRIBUTOR,
		2500, 2, 20_000, 1, 2
	)
	service.price_confirm(
		3, &"AA-DUST-ETB", 4799,
		InventoryLocation.new(InventoryLocation.Type.SHELF),
		DemandSignalService.Channel.DISTRIBUTOR
	)
	_qa.record_save_pre_write("save-data".to_utf8_buffer())
	_qa.record_save_post_load("save-data".to_utf8_buffer())
	var events := _qa.get_events()
	_expect_equal(events.size(), 6, "instrumentation event count")
	_expect_payload_keys(events[0], [&"day", &"cash_start", &"cash_end", &"delta"], "day cash payload")
	_expect_payload_keys(events[1], [&"sku", &"qty", &"unit_cost", &"expected_margin"], "buy payload")
	_expect_payload_keys(
		events[2],
		[
			&"screen", &"sku_id", &"shown_comp_low_cents", &"shown_comp_high_cents",
			&"true_market_cents", &"shown_demand_band", &"true_demand_band", &"confidence",
		],
		"buy demand signal payload"
	)
	_expect_payload_keys(
		events[3],
		[
			&"screen", &"sku_id", &"shown_comp_low_cents", &"shown_comp_high_cents",
			&"true_market_cents", &"shown_demand_band", &"true_demand_band", &"confidence",
			&"listed_price_cents", &"move_feel",
		],
		"price demand signal payload"
	)
	_expect_equal(
		events[4]["payload"]["hash"],
		events[5]["payload"]["hash"],
		"save round-trip hash"
	)
	_qa.set_force_enabled(false)


func _test_difficulty_balance_ordering() -> void:
	var cash_is_ordered := (
		EASY_CONFIG.start_cash_cents
		> NORMAL_CONFIG.start_cash_cents
		and NORMAL_CONFIG.start_cash_cents
		> HARD_CONFIG.start_cash_cents
	)
	_expect_equal(cash_is_ordered, true, "starting cash difficulty ordering")
	_expect_equal(HARD_CONFIG.loan_shark_enabled, false, "hard loan shark access")
	_expect_equal(NORMAL_CONFIG.start_cash_cents, 800_000, "normal starting cash")
	_expect_equal(NORMAL_CONFIG.start_reputation, 40, "normal starting reputation")
	_expect_equal(NORMAL_CONFIG.rent_small_weekly_cents, 120_000, "normal weekly rent")
	_expect_equal(NORMAL_CONFIG.first_rent_due_day, 7, "normal first rent due day")
	_expect_equal(NORMAL_CONFIG.event_chance_settle, 0.18, "normal settle event chance")
	_expect_equal(NORMAL_CONFIG.comp_noise_width_mult, 1.0, "normal comp noise width")
	_expect_equal(EASY_CONFIG.start_cash_cents, 1_200_000, "easy starting cash")
	_expect_equal(HARD_CONFIG.start_cash_cents, 550_000, "hard starting cash")
	_expect_equal(EASY_CONFIG.rent_small_weekly_cents, 100_000, "easy weekly rent")
	_expect_equal(HARD_CONFIG.rent_small_weekly_cents, 135_000, "hard weekly rent")
	_expect_equal(EASY_CONFIG.first_rent_due_day, 10, "easy first rent due day")
	_expect_equal(EASY_CONFIG.whale_weight_mult, 1.4, "easy whale weight")
	_expect_equal(NORMAL_CONFIG.whale_weight_mult, 1.0, "normal whale weight")
	_expect_equal(HARD_CONFIG.whale_weight_mult, 0.7, "hard whale weight")
	_expect_equal(
		EASY_CONFIG.whale_weight_mult > HARD_CONFIG.whale_weight_mult,
		true,
		"easy whale weight exceeds hard"
	)
	_expect_equal(EASY_CONFIG.demand_band_sigma, 0.09, "easy demand sigma")
	_expect_equal(NORMAL_CONFIG.demand_band_sigma, 0.12, "normal demand sigma")
	_expect_equal(HARD_CONFIG.demand_band_sigma, 0.16, "hard demand sigma")
	_expect_equal(EASY_CONFIG.seed_bulk_cards, 80, "easy seed bulk cards")
	_expect_equal(NORMAL_CONFIG.seed_bulk_cards, 80, "normal seed bulk cards")
	_expect_equal(HARD_CONFIG.seed_bulk_cards, 80, "hard seed bulk cards")


func _test_normal_shop_capacity() -> void:
	var capacity := ShopCapacity.new()
	_expect_equal(capacity.display_slots, NORMAL_CONFIG.case_slots, "normal case slots")
	_expect_equal(capacity.storage_units, NORMAL_CONFIG.backstock_bins, "normal backstock bins")


func _test_weekly_rent_schedule() -> void:
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(6), false, "no rent before weekly settle")
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(7), true, "day seven weekly settle")
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(14), true, "recurring weekly settle")
	_expect_equal(NORMAL_CONFIG.rent_small_weekly_cents, 120_000, "weekly rent amount")


func _test_customer_archetype_weights() -> void:
	var catalog := CustomerArchetypeCatalog.new()
	_expect_equal(catalog.archetypes.size(), 6, "six customer archetypes")
	var ids: Array[StringName] = []
	for archetype: Dictionary in catalog.archetypes:
		ids.append(StringName(archetype.get("id", "")))
		_expect_equal(
			float(archetype.get("weight_normal", 0.0)) > 0.0,
			true,
			"positive normal archetype weight"
		)
	for expected_id: StringName in [
		&"kid_parent", &"spike", &"collector",
		&"flipper", &"regular", &"whale",
	]:
		_expect_equal(expected_id in ids, true, "archetype %s" % expected_id)
	var whale: Dictionary = {}
	for archetype: Dictionary in catalog.archetypes:
		if StringName(archetype.get("id", "")) == &"whale":
			whale = archetype
			break
	var low_weight := catalog.weight_for(whale, 10, NORMAL_CONFIG)
	var high_weight := catalog.weight_for(whale, 80, NORMAL_CONFIG)
	_expect_equal(low_weight, 0.0, "whales gated at low reputation")
	_expect_equal(high_weight > low_weight, true, "whale high reputation bias")


func _test_customer_spawn_phase_gating() -> void:
	_expect_equal(
		CustomerSpawner.can_spawn_for_phase(GameState.DayPhase.PREP),
		false,
		"no prep customer spawn"
	)
	_expect_equal(
		CustomerSpawner.can_spawn_for_phase(GameState.DayPhase.FLOOR),
		true,
		"floor customer spawn"
	)
	_expect_equal(
		CustomerSpawner.can_spawn_for_phase(GameState.DayPhase.SETTLE),
		false,
		"no settle customer spawn"
	)


func _test_day_phase_transitions() -> void:
	GameState.start_new_game()
	_expect_equal(GameState.current_phase, GameState.DayPhase.PREP, "new game prep phase")
	_expect_equal(GameState.advance_day(), false, "prep cannot advance day")
	_expect_equal(GameState.start_floor(), true, "prep enters floor")
	_expect_equal(GameState.start_floor(), false, "floor cannot restart floor")
	_expect_equal(GameState.start_settle(), true, "floor enters settle")
	var first_day := GameState.current_day
	_expect_equal(GameState.advance_day(), true, "settle advances day")
	_expect_equal(GameState.current_day, first_day + 1, "day increment")
	_expect_equal(GameState.current_phase, GameState.DayPhase.PREP, "next day returns prep")
	_expect_equal(
		GameState.attention_remaining,
		NORMAL_CONFIG.attention_pool,
		"attention resets each day"
	)


func _test_negotiate_clamp() -> void:
	_expect_equal(
		CustomerQueue.negotiated_price_cents(1000, -0.50),
		900,
		"negotiation lower clamp"
	)
	_expect_equal(
		CustomerQueue.negotiated_price_cents(1000, 0.50),
		1100,
		"negotiation upper clamp"
	)


func _test_ui_helpers_do_not_read_hidden_values() -> void:
	for path: String in [
		"res://scripts/ui/demand_signal_presenter.gd",
		"res://scripts/ui/hud.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_expect_equal(source.contains("true_market"), false, "%s market truth access" % path)
		_expect_equal(source.contains("p_buy"), false, "%s probability access" % path)
		_expect_equal(source.contains("cert_valid"), false, "%s certificate access" % path)


func _expect_dto_has_no_truth_fields(dto: Resource, label: String) -> void:
	for property: Dictionary in dto.get_property_list():
		var property_name := String(property["name"])
		var leaks_truth := (
			property_name.contains("true_market")
			or property_name.contains("p_buy")
			or property_name.contains("cert_valid")
		)
		_expect_equal(leaks_truth, false, "%s field %s" % [label, property_name])


func _band_index(band: StringName) -> int:
	return [&"cold", &"steady", &"warm", &"hot"].find(band)


func _expect_payload_keys(
	event: Dictionary,
	expected_keys: Array[StringName],
	label: String
) -> void:
	var payload: Dictionary = event["payload"]
	for key: StringName in expected_keys:
		_expect_equal(payload.has(String(key)), true, "%s key %s" % [label, key])


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		return
	_failures += 1
	push_error("%s: expected %s, got %s" % [label, expected, actual])
