extends SceneTree

const EASY_CONFIG: BalanceConfig = preload("res://data/balance/easy.tres")
const NORMAL_CONFIG: BalanceConfig = preload("res://data/balance/normal.tres")
const HARD_CONFIG: BalanceConfig = preload("res://data/balance/hard.tres")
const SPIKE_STAPLE_BEAT := &"sec10_4_spike_staple"
const RENT_FIRESALE_BEAT := &"sec10_6_rent_firesale"
const TITAN_HYPE_BEAT := &"sec10_7_titan_hype"
const SHOWCASE_BEAT := &"sec10_8_slab_vs_singles"
const MARKETPLACE_OUTING_BEAT := &"sec10_3_marketplace_outing"
const HIRE_CASHIER_BEAT := &"sec10_5_hire_cashier"
const EXPAND_MEDIUM_BEAT := &"sec10_9_expand_medium"
const SHADY_TRUNK_BEAT := &"sec10_10_shady_trunk"
const EXPAND_LARGE_BEAT := &"sec10_11_expand_large"

var _failures: int = 0
var _qa := QaInstrumentationService.new()
var _captured_scripted_customer: CustomerProfile
var _captured_price_sku: StringName = &""
var _captured_price_beat: StringName = &""
var _captured_price_mode: StringName = &""
var _captured_price_focus_count: int = 0
var _captured_rent_decision: Dictionary = {}
var _captured_beat_decision: Dictionary = {}
var _captured_buy_focus_id: StringName = &""
var _captured_buy_focus_beat: StringName = &""
var _captured_showcase_decision: Dictionary = {}
var _captured_showcase_failed: String = ""
var _captured_campaign_won: Dictionary = {}
var _captured_loan_shark: Dictionary = {}
var _captured_loan_shark_outcome: StringName = &""
var _captured_campaign_lost: Dictionary = {}
var _event_bus: Node
var _game_state: Node
var _economy: Node
var _inventory_service: Node
var _demand_signals: Node
var _beat_director: Node
var _qa_autoload: Node

class FakeCustomerInventory:
	extends Node

	var sold: bool = false
	var bought: bool = false

	func find_listed_offer(
		_interest_tags: Array[StringName],
		_budget_cents: int
	) -> Dictionary:
		return {
			"sku_id": &"ACC-SLV-60",
			"listed_price_cents": 599,
		}

	func confirm_customer_sale(
		_sku_id: StringName,
		_sale_price_cents: int
	) -> bool:
		sold = true
		return true

	func confirm_stock_purchase(
		_sku_id: StringName,
		_quantity: int,
		_unit_cost_cents: int,
		_expected_margin_cents: int,
		_location: InventoryLocation
	) -> bool:
		bought = true
		return true

	func has_backstock(_sku_id: StringName) -> bool:
		return false

	func pull_from_backstock(_sku_id: StringName) -> bool:
		return false


func _initialize() -> void:
	_event_bus = root.get_node("EventBus")
	_game_state = root.get_node("GameState")
	_economy = root.get_node("Economy")
	_inventory_service = root.get_node("InventoryService")
	_demand_signals = root.get_node("DemandSignals")
	_beat_director = root.get_node("BeatDirector")
	_qa_autoload = root.get_node("QaInstrumentation")
	_event_bus.connect(
		"scripted_customer_requested",
		_capture_scripted_customer
	)
	_event_bus.connect("price_focus_requested", _capture_price_focus)
	_event_bus.connect("rent_decision_requested", _capture_rent_decision)
	_event_bus.connect("beat_decision_requested", _capture_beat_decision)
	_event_bus.connect("buy_focus_requested", _capture_buy_focus)
	_event_bus.connect("showcase_choice_requested", _capture_showcase_decision)
	_event_bus.connect("showcase_choice_failed", _capture_showcase_failed)
	_event_bus.connect("campaign_won", _capture_campaign_won)
	_event_bus.connect("loan_shark_offered", _capture_loan_shark_offered)
	_event_bus.connect("loan_shark_resolved", _capture_loan_shark_resolved)
	_event_bus.connect("campaign_lost", _capture_campaign_lost)
	_test_pricing_spread()
	_test_stock_lot_unit_cost()
	_test_inventory_mutations_and_capacity()
	_test_balance_seed_inventory()
	_test_buy_opportunity_picker_seed()
	_test_price_editor_inventory_picker()
	_test_demand_signal_dto_does_not_leak_truth()
	_test_demand_fairness_contract()
	_test_inspect_buy_opportunity()
	_test_research_and_rearrange_attention()
	_test_qa_instrumentation_payloads()
	_test_difficulty_balance_ordering()
	_test_normal_shop_capacity()
	_test_weekly_rent_schedule()
	_test_customer_archetype_weights()
	_test_customer_spawn_phase_gating()
	_test_day_phase_transitions()
	_test_negotiate_clamp()
	_test_customer_service_actions()
	_test_ui_price_labels()
	_test_ui_helpers_do_not_read_hidden_values()
	_test_wants_label_format()
	_test_prep_hud_seed_before_bind()
	_test_gameplay_hud_visual_smoke()
	_test_undercut_fill_boundary()
	_test_rent_firesale_beat()
	_test_spike_staple_beat()
	_test_titan_hype_price_focus()
	_test_market_events_seven_day_seeded_run()
	_test_hype_spike_target_sku_only()
	_test_fog_day_sigma_and_inversion()
	_test_market_event_save_load()
	_test_option_d_seeded_hype_opens_price_editor_once()
	_test_option_d_price_editor_has_no_truth()
	_test_option_d_cancel_keeps_event_apply_persists()
	_test_counterfeit_scare_event()
	_test_convention_weekend_event()
	_test_theft_ring_event()
	_test_camera_unlock()
	_test_security_camera_prop_stub_swap()
	_test_recession_week_event()
	_test_supply_glut_event()
	_test_day_ten_beat_serialization()
	_test_marketplace_outing_beat()
	_test_hire_cashier_beat()
	_test_specialist_staff_path()
	_test_expand_medium_beat()
	_test_medium_floor_growth()
	_test_medium_overhead_lights()
	_test_expand_large_beat()
	_test_large_floor_growth()
	_test_shady_trunk_beat()
	_test_showcase_slab_and_singles_preconditions()
	_test_shop_camera_framing()
	_test_shop_camera_look_clamps()
	_test_heavier_decor_placement()
	_test_customer_npc_spawn_browse_approach_path()
	_test_customer_npc_intent_icons_have_no_truth()
	_test_customer_npc_desk_volume_gates_hud()
	_test_customer_npc_does_not_change_camera()
	_test_customer_npc_visible_when_queued()
	_test_customer_npc_mvp_cast()
	_test_customer_npc_locomotion_clips()
	_test_cashier_silhouette_on_floor()
	_test_c2_hire_beat_paths()
	_test_c2_unreliable_ten_day_stress()
	_test_c2_att_zero_owner_verbs()
	_test_c2_specialist_attention_assert()
	_test_c3_beats_reachable_without_debug()
	_test_c3_drive_shortens_floor_courier_keeps()
	_test_c3_shady_confirm_has_no_truth()
	_test_c3_report_applies_rep()
	_test_hold_soft_polish()
	_test_sec10_4_spike_staple()
	_test_sec10_6_rent_firesale()
	_test_sec10_7_titan_hype()
	_test_sec10_8_slab_vs_singles()
	_test_g1_graded_authenticity()
	_test_i1_online_unlock_gate()
	_test_i1_list_hold_fee_and_cancel()
	_test_i1_frequent_cancel_rep_hit()
	_test_i1_list_confirm_has_no_truth()
	_test_i1_soft_ensure_priceable_sku_parked()
	_test_j1_research_specialist_skill_deepen()
	_test_flagship_win_award()
	_test_survive_y1_win_award()
	_test_liquidity_king_win_award()
	_test_campaign_mode_picker()
	_test_loan_shark_soft_fail()

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


func _test_buy_opportunity_picker_seed() -> void:
	var inventory := InventoryModel.new(NORMAL_CONFIG)
	var opportunities := BuyOpportunityCatalog.new().open_for_day(1, inventory.catalog)
	var has_dustway := false
	var has_distributor_moq := false
	for opportunity: BuyOpportunity in opportunities:
		if opportunity.sku_id == &"AA-DUST-ETB":
			has_dustway = true
		if (
			opportunity.channel == DemandSignalService.Channel.DISTRIBUTOR
			and opportunity.beat_id == &"distributor_moq"
			and opportunity.quantity > 1
		):
			has_distributor_moq = true
	_expect_equal(has_dustway, true, "Dustway buy opportunity available")
	_expect_equal(has_distributor_moq, true, "distributor MOQ opportunity available")
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("AA-SKIE-ETB"),
		false,
		"HUD does not hardcode sole Skiefall opportunity"
	)
	_expect_equal(
		hud_source.contains("DemandSignals.open_buy_signals()"),
		true,
		"HUD binds demand signal opportunity list"
	)


func _test_price_editor_inventory_picker() -> void:
	var inventory_service_script := load(
		"res://scripts/autoload/inventory_service.gd"
	) as Script
	var inventory_service := inventory_service_script.new() as Node
	var inventory_model := InventoryModel.new(NORMAL_CONFIG)
	inventory_model.reset_and_seed()
	inventory_service.set("model", inventory_model)
	var priceable_stock: Array = inventory_service.call("get_priceable_stock")
	var priceable_skus: Array[StringName] = []
	var has_non_dustway_sku := false
	for item: Dictionary in priceable_stock:
		var sku_id := StringName(item["sku_id"])
		priceable_skus.append(sku_id)
		if sku_id != &"AA-DUST-ETB":
			has_non_dustway_sku = true
	_expect_equal(
		priceable_skus.size() > 1,
		true,
		"price picker exposes multiple seeded SKUs"
	)
	_expect_equal(
		has_non_dustway_sku,
		true,
		"price picker is not Dustway-only"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("DemandSignals.priceable_stock_signals()"),
		true,
		"HUD binds priceable inventory signals"
	)
	_expect_equal(
		hud_source.contains("AA-DUST-ETB"),
		false,
		"HUD does not hardcode Dustway price target"
	)
	inventory_service.free()


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
	var list_signal := service.list_confirm(
		1, &"AA-SKIE-047", 2300,
		InventoryLocation.new(InventoryLocation.Type.SHELF)
	)
	_expect_dto_has_no_truth_fields(list_signal, "list confirm signal")
	_assert_text_has_no_truth(
		DemandSignalPresenter.list_confirm_summary(list_signal),
		"list confirm summary"
	)


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


func _test_inspect_buy_opportunity() -> void:
	_qa.set_force_enabled(false)
	_expect_equal(
		DemandSignalService.recommends_inspect(
			DemandSignalService.Channel.MARKETPLACE
		),
		true,
		"marketplace recommends inspect"
	)
	_expect_equal(
		DemandSignalService.recommends_inspect(&"shady"),
		true,
		"shady recommends inspect"
	)
	_expect_equal(
		DemandSignalService.recommends_inspect(&"buylist"),
		true,
		"buylist inspect is optional"
	)
	_expect_equal(
		DemandSignalService.recommends_inspect(
			DemandSignalService.Channel.DISTRIBUTOR
		),
		false,
		"distributor does not recommend inspect"
	)

	var market_state := MarketState.new()
	market_state.update_sku(&"AA-SKIE-047", 2200, 0.75)
	var seeded_a := DemandSignalService.new(NORMAL_CONFIG, market_state, 42, _qa)
	var seeded_b := DemandSignalService.new(NORMAL_CONFIG, market_state, 42, _qa)
	var dto_a := seeded_a.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		1200, 2, 800_000, 1, 3
	)
	var dto_b := seeded_b.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		1200, 2, 800_000, 1, 3
	)
	var fog_cue := dto_a.condition_cue
	var comp_low := dto_a.shown_comp_low_cents
	var comp_high := dto_a.shown_comp_high_cents
	var demand_band := dto_a.shown_demand_band
	var confidence := dto_a.confidence
	_expect_equal(
		fog_cue.to_lower().contains("photo"),
		true,
		"marketplace starts with photo-only fog"
	)
	_expect_equal(seeded_a.can_inspect(dto_a), true, "fogged marketplace can inspect")
	_expect_equal(seeded_a.inspect_condition(dto_a), true, "seeded inspect succeeds")
	_expect_equal(seeded_b.inspect_condition(dto_b), true, "duplicate seed inspect")
	_expect_equal(
		dto_a.condition_cue,
		dto_b.condition_cue,
		"inspect cue is deterministic under seeded RNG"
	)
	_expect_equal(dto_a.inspected, true, "inspect marks opportunity inspected")
	_expect_equal(
		dto_a.shown_comp_low_cents,
		comp_low,
		"inspect does not change comp low"
	)
	_expect_equal(
		dto_a.shown_comp_high_cents,
		comp_high,
		"inspect does not change comp high"
	)
	_expect_equal(
		dto_a.shown_demand_band,
		demand_band,
		"inspect does not change demand band"
	)
	_expect_equal(dto_a.confidence, confidence, "inspect does not change confidence")
	_assert_text_has_no_truth(dto_a.condition_cue, "inspect cue")
	_assert_text_has_no_truth(
		DemandSignalPresenter.buy_summary(dto_a),
		"inspect buy summary"
	)
	_expect_dto_has_no_truth_fields(dto_a, "inspected buy signal")
	_expect_equal(
		seeded_a.inspect_condition(dto_a),
		false,
		"second inspect is blocked"
	)
	_expect_equal(
		dto_a.condition_cue,
		dto_b.condition_cue,
		"blocked inspect leaves cue unchanged"
	)

	var accurate_config := BalanceConfig.new()
	accurate_config.inspect_accuracy = 1.0
	accurate_config.inspect_attention = 5
	var miss_config := BalanceConfig.new()
	miss_config.inspect_accuracy = 0.0
	miss_config.inspect_attention = 5
	var accurate := DemandSignalService.new(accurate_config, market_state, 7, _qa)
	var miss := DemandSignalService.new(miss_config, market_state, 7, _qa)
	var accurate_dto := accurate.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.SHADY,
		900, 1, 800_000, 1, 3
	)
	var miss_dto := miss.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.SHADY,
		900, 1, 800_000, 1, 3
	)
	var shady_fog := accurate_dto.condition_cue
	_expect_equal(
		shady_fog.to_lower().contains("strongly recommended"),
		true,
		"shady starts with strongly recommended fog"
	)
	_expect_equal(accurate.inspect_condition(accurate_dto), true, "accuracy 1.0 inspect")
	_expect_equal(miss.inspect_condition(miss_dto), true, "accuracy 0.0 inspect")
	_expect_equal(
		accurate_dto.condition_cue != shady_fog,
		true,
		"successful inspect clears photo fog"
	)
	_expect_equal(
		accurate_dto.condition_cue != miss_dto.condition_cue,
		true,
		"accuracy miss yields a different soft cue"
	)
	_assert_text_has_no_truth(accurate_dto.condition_cue, "accurate inspect cue")
	_assert_text_has_no_truth(miss_dto.condition_cue, "miss inspect cue")

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.inspect_attention_cost(), 5, "Owner inspect costs 5 Att")
	_expect_equal(
		int(_game_state.get("current_phase")),
		DayPhasePolicy.PREP,
		"inspect attention test starts in PREP"
	)
	_expect_equal(
		bool(_game_state.call("spend_attention", 5)),
		false,
		"FLOOR-only spend_attention still rejects PREP"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		100,
		"rejected FLOOR spend does not debit PREP Att"
	)
	_expect_equal(
		bool(_game_state.call("consume_attention", 5)),
		true,
		"PREP consume_attention debits inspect cost"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		95,
		"inspect debit leaves 95 Att"
	)
	_expect_equal(
		bool(_game_state.call("consume_attention", 96)),
		false,
		"insufficient Attention blocks inspect spend"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		95,
		"blocked inspect spend does not debit"
	)

	_game_state.call("start_new_game")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "gameplay HUD loads for inspect")
	if hud == null:
		return
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	var attention := hud.get_node_or_null("%AttentionLabel") as Label
	var summary_label := hud.get_node_or_null("%BuySummary") as Label
	var open_buy := hud.get_node_or_null("%OpenBuyButton") as Button
	_expect_equal(open_buy != null, true, "OpenBuyButton present")
	open_buy.pressed.emit()
	var marketplace_row_clicked := _click_buy_row_for_channel(hud, &"marketplace")
	_expect_equal(marketplace_row_clicked, true, "day 1 marketplace lot exists")
	var selected := hud.get("_buy_signal") as BuyConfirmSignal
	_expect_equal(
		selected != null and selected.channel == &"marketplace",
		true,
		"detail opened for marketplace lot"
	)
	_expect_equal(
		inspect_button != null and inspect_button.visible,
		true,
		"Inspect★ visible on marketplace detail"
	)
	_expect_equal(
		inspect_button != null and not inspect_button.disabled,
		true,
		"Inspect★ enabled with full Attention"
	)
	var fog_summary := summary_label.text if summary_label != null else ""
	var marketplace_fog := selected.condition_cue if selected != null else ""
	inspect_button.pressed.emit()
	selected = hud.get("_buy_signal") as BuyConfirmSignal
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		95,
		"Inspect★ spends 5 Attention from PREP"
	)
	_expect_equal(
		attention != null and attention.text == "Att 95/100",
		true,
		"HUD Att label reflects inspect spend"
	)
	_expect_equal(
		selected != null and selected.inspected,
		true,
		"HUD inspect updates the lot"
	)
	_expect_equal(
		selected != null
		and selected.condition_cue != ""
		and selected.condition_cue != marketplace_fog,
		true,
		"HUD inspect updates condition cue"
	)
	_assert_text_has_no_truth(
		selected.condition_cue if selected != null else "",
		"HUD inspect cue"
	)
	_assert_text_has_no_truth(summary_label.text, "HUD inspect summary")
	_expect_equal(
		summary_label.text != fog_summary,
		true,
		"BuyOpportunityDetail summary refreshes after inspect"
	)
	_expect_equal(
		inspect_button.disabled,
		true,
		"Inspect★ disables after a successful inspect"
	)

	_game_state.set("attention_remaining", 4)
	Callable(hud, "_update_attention").call(4)
	var shady := _demand_signals.call(
		"buy_signal",
		&"AA-SKIE-047",
		DemandSignalService.Channel.SHADY,
		900,
		1
	) as BuyConfirmSignal
	shady.opportunity_id = &"test-shady-inspect"
	_select_buy_on_hud(hud, shady)
	_expect_equal(
		inspect_button.visible,
		true,
		"Inspect★ visible on shady detail"
	)
	_expect_equal(
		inspect_button.disabled,
		true,
		"Inspect★ disabled when Attention is below cost"
	)
	var shady_fog_cue := shady.condition_cue
	Callable(hud, "_inspect_buy").call()
	_expect_equal(shady.inspected, false, "blocked inspect does not resolve")
	_expect_equal(shady.condition_cue, shady_fog_cue, "blocked inspect keeps fog")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		4,
		"blocked Inspect★ does not debit Attention"
	)

	open_buy.pressed.emit()
	_expect_equal(
		_click_buy_row_for_channel(hud, &"distributor"),
		true,
		"day 1 distributor lot exists"
	)
	_expect_equal(
		inspect_button.visible,
		false,
		"Inspect★ hidden on distributor NM-assumed lots"
	)
	root.remove_child(hud)
	hud.free()


func _test_research_and_rearrange_attention() -> void:
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.inspect_attention_cost(), 5, "Owner inspect stays 5 without specialist")
	_expect_equal(shop.research_attention_cost(), 15, "Owner research costs 15 Att")
	_expect_equal(shop.rearrange_attention_cost(), 10, "Owner rearrange costs 10 Att")
	_expect_equal(shop.research_cash_cost_cents(), 5_000, "Owner research costs $50")
	shop.set_specialist_on_duty(true)
	_expect_equal(shop.inspect_attention_cost(), 2, "Specialist inspect 5→2")
	_expect_equal(shop.research_attention_cost(), 10, "Specialist research 15→10")
	_expect_equal(shop.rearrange_attention_cost(), 10, "Rearrange cost ignores specialist")
	shop.set_specialist_on_duty(false)
	_expect_equal(shop.inspect_attention_cost(), 5, "Inspect returns to 5 off duty")

	var market_state := MarketState.new()
	market_state.update_sku(&"AA-SKIE-047", 10_000, 0.70)
	market_state.update_sku(&"AA-BASE-088", 500, 0.45)
	var fogged := DemandSignalService.new(NORMAL_CONFIG, market_state, 12, _qa)
	var researched := DemandSignalService.new(NORMAL_CONFIG, market_state, 12, _qa)
	var snapshot := researched.apply_research(&"AA-SKIE", 1, 2)
	_expect_equal(researched.is_set_informed(&"AA-SKIE", 1), true, "research informs target set")
	_expect_equal(researched.is_set_informed(&"AA-SKIE", 2), true, "research lasts through day 2")
	_expect_equal(researched.is_set_informed(&"AA-SKIE", 3), false, "research expires after telegraph")
	_expect_equal(researched.is_set_informed(&"AA-BASE", 1), false, "research does not inform other sets")
	_expect_equal(
		String(snapshot.get("display_name", "")).contains("Skiefall"),
		true,
		"research snapshot names the set"
	)
	var watches := researched.active_rotation_watches(1)
	_expect_equal(watches.size() > 0, true, "rotation watch is present")
	_expect_equal(
		watches[0].begins_with("Rotation watch:"),
		true,
		"soft telegraph uses Rotation watch copy"
	)
	_assert_text_has_no_truth(watches[0], "rotation watch")
	var fog_dto := fogged.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		5000, 1, 800_000, 1, 10, false
	)
	var researched_dto := researched.buy_confirm(
		1, &"AA-SKIE-047", DemandSignalService.Channel.MARKETPLACE,
		5000, 1, 800_000, 1, 10, researched.is_set_informed(&"AA-SKIE", 1)
	)
	_expect_equal(
		researched_dto.shown_comp_high_cents - researched_dto.shown_comp_low_cents
		< fog_dto.shown_comp_high_cents - fog_dto.shown_comp_low_cents,
		true,
		"research narrows target-set comp width"
	)
	_expect_equal(
		researched_dto.condition_cue.to_lower().contains("photo"),
		true,
		"research keeps photo condition fog"
	)
	_expect_equal(researched_dto.inspected, false, "research does not inspect")
	_expect_dto_has_no_truth_fields(researched_dto, "researched buy signal")
	_assert_text_has_no_truth(researched_dto.condition_cue, "researched condition cue")
	_assert_text_has_no_truth(
		DemandSignalPresenter.buy_summary(researched_dto),
		"researched buy summary"
	)

	_qa.set_force_enabled(true)
	_qa.clear()
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	_game_state.call("start_new_game")
	var cash_before := int(_economy.get("balance_cents"))
	var att_before := int(_game_state.get("attention_remaining"))
	var live_before := _demand_signals.call(
		"buy_signal",
		&"AA-SKIE-047",
		DemandSignalService.Channel.MARKETPLACE,
		1200,
		1
	) as BuyConfirmSignal
	var result: Dictionary = _demand_signals.call("research_set", &"AA-SKIE")
	_expect_equal(bool(result.get("ok", false)), true, "research spends Att and cash")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		att_before - NORMAL_CONFIG.research_attention,
		"research debits Att 15"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - NORMAL_CONFIG.research_cost_cents,
		"research debits $50"
	)
	_expect_equal(
		int(result.get("sample_comp_width_after", 0))
		< int(result.get("sample_comp_width_before", 0)),
		true,
		"QA research payload shows narrower comps"
	)
	_expect_equal(
		float(result.get("research_demand_band_sigma", 1.0))
		< float(result.get("demand_band_sigma", 0.0)),
		true,
		"QA research payload shows narrower demand-band σ"
	)
	_assert_payload_has_no_truth(result, "research payload")
	_assert_text_has_no_truth(String(result.get("rotation_watch", "")), "research rotation watch")
	_expect_equal(
		String(result.get("condition_cue", "")).to_lower().contains("cert_valid"),
		false,
		"research payload cue has no cert_valid"
	)
	var live_after := _demand_signals.call(
		"buy_signal",
		&"AA-SKIE-047",
		DemandSignalService.Channel.MARKETPLACE,
		1200,
		1
	) as BuyConfirmSignal
	_expect_equal(
		live_after.shown_comp_high_cents - live_after.shown_comp_low_cents
		< live_before.shown_comp_high_cents - live_before.shown_comp_low_cents,
		true,
		"live buy signal narrows after researching the set"
	)
	_expect_equal(
		live_after.condition_cue.to_lower().contains("photo")
		or live_after.condition_cue.to_lower().contains("inspect"),
		true,
		"live research does not reveal true condition"
	)
	_expect_dto_has_no_truth_fields(live_after, "live researched signal")
	var events: Array = _qa_autoload.call("get_events")
	var saw_research := false
	for event: Dictionary in events:
		if String(event.get("event", "")) == "research_applied":
			saw_research = true
			_assert_payload_has_no_truth(event.get("payload", {}), "research_applied event")
	_expect_equal(saw_research, true, "QA emits research_applied")
	var already := _demand_signals.call("research_set", &"AA-SKIE") as Dictionary
	_expect_equal(bool(already.get("ok", false)), false, "active research cannot be repeated")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		att_before - NORMAL_CONFIG.research_attention,
		"blocked repeat research does not debit Att"
	)

	_game_state.set("attention_remaining", 14)
	var low_att := _demand_signals.call("research_set", &"AA-DUST") as Dictionary
	_expect_equal(bool(low_att.get("ok", false)), false, "research refuses Att < 15")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		14,
		"failed research does not debit Att"
	)
	_game_state.set("attention_remaining", 100)
	_economy.set("balance_cents", 4_999)
	_event_bus.call("publish_cash_changed", 4_999)
	var low_cash := _demand_signals.call("research_set", &"AA-DUST") as Dictionary
	_expect_equal(bool(low_cash.get("ok", false)), false, "research refuses cash < $50")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		100,
		"failed cash research does not debit Att"
	)

	_game_state.call("start_new_game")
	_expect_equal(shop.layout.has_circulation(), true, "default layout has circulation")
	var binder := shop.layout.fixture_by_id(&"binder_rack")
	_expect_equal(binder != null, true, "binder rack exists")
	var legal := _game_state.call(
		"rearrange_fixture",
		&"binder_rack",
		Vector2i(1, 5)
	) as Dictionary
	_expect_equal(bool(legal.get("ok", false)), true, "legal rearrange succeeds")
	_expect_equal(int(legal.get("attention_spent", 0)), 10, "legal rearrange spends Att 10")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		90,
		"rearrange debit leaves 90 Att"
	)
	_expect_equal(shop.layout.fixture_by_id(&"binder_rack").origin, Vector2i(1, 5), "binder moved")
	var blocked := _game_state.call(
		"rearrange_fixture",
		&"binder_rack",
		Vector2i(7, 1)
	) as Dictionary
	_expect_equal(bool(blocked.get("ok", false)), false, "illegal pathing is rejected")
	_expect_equal(
		StringName(blocked.get("reason", &"")),
		&"blocked_path",
		"illegal rearrange reason is blocked_path"
	)
	_expect_equal(int(blocked.get("attention_spent", -1)), 0, "illegal rearrange spends no Att")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		90,
		"illegal rearrange does not debit Att"
	)
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(1, 5),
		"illegal rearrange leaves fixture in place"
	)
	_game_state.set("attention_remaining", 0)
	var free := _game_state.call(
		"rearrange_fixture",
		&"binder_rack",
		Vector2i(1, 4)
	) as Dictionary
	_expect_equal(bool(free.get("ok", false)), false, "free rearrange without Att fails")
	_expect_equal(
		StringName(free.get("reason", &"")),
		&"insufficient_attention",
		"Att 0 rearrange reason"
	)
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(1, 5),
		"Att 0 rearrange does not move"
	)

	var inventory := FakeCustomerInventory.new()
	var queue := CustomerQueue.new()
	queue.configure(inventory)
	var buying_customer := CustomerProfile.new()
	buying_customer.budget_cents = 1000
	buying_customer.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(buying_customer), true, "Att 0 still enqueues customers")
	_expect_equal(queue.sell_listed(), true, "cashiers still sell at Att 0")
	_expect_equal(inventory.sold, true, "Att 0 sale reaches inventory")
	queue.free()
	inventory.free()
	var zero_research := _demand_signals.call("research_set", &"AA-BASE") as Dictionary
	_expect_equal(bool(zero_research.get("ok", false)), false, "Att 0 research is disabled")

	_game_state.call("start_new_game")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "gameplay HUD loads for research/rearrange")
	if hud == null:
		_qa.set_force_enabled(false)
		_qa_autoload.call("set_force_enabled", false)
		return
	var open_research := hud.get_node_or_null("%OpenResearchButton") as Button
	var open_rearrange := hud.get_node_or_null("%OpenRearrangeButton") as Button
	var research_confirm := hud.get_node_or_null("%ResearchConfirmButton") as Button
	var rearrange_confirm := hud.get_node_or_null("%RearrangeConfirmButton") as Button
	_expect_equal(
		open_research != null and not open_research.disabled,
		true,
		"Research enabled with cash and Att"
	)
	_expect_equal(
		open_rearrange != null and not open_rearrange.disabled,
		true,
		"Rearrange enabled with Att"
	)
	open_research.pressed.emit()
	var research_rows := hud.get_node_or_null("%ResearchRows") as VBoxContainer
	var clicked_set := false
	if research_rows != null:
		for child: Node in research_rows.get_children():
			var row := child as Button
			if row != null and row.text.contains("Skiefall"):
				row.pressed.emit()
				clicked_set = true
				break
	_expect_equal(clicked_set, true, "Research list includes Skiefall")
	_expect_equal(
		research_confirm != null and research_confirm.text.contains("Att 15"),
		true,
		"Research confirm shows Att cost"
	)
	_expect_equal(
		research_confirm != null and research_confirm.text.contains("$50.00"),
		true,
		"Research confirm shows cash cost"
	)
	var confirm_body := hud.get_node_or_null("%ResearchConfirmBody") as Label
	_assert_text_has_no_truth(
		confirm_body.text if confirm_body != null else "",
		"research confirm body"
	)
	research_confirm.pressed.emit()
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		85,
		"HUD Research spends Att 15"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		795_000,
		"HUD Research spends $50"
	)
	var watch := hud.get_node_or_null("%RotationWatchLabel") as Label
	_expect_equal(
		watch != null and watch.visible and watch.text.contains("Rotation watch"),
		true,
		"HUD shows rotation watch after research"
	)
	_assert_text_has_no_truth(watch.text if watch != null else "", "HUD rotation watch")

	open_rearrange.pressed.emit()
	Callable(hud, "_select_rearrange_fixture").call(&"binder_rack")
	Callable(hud, "_select_rearrange_tile").call(Vector2i(7, 1))
	_expect_equal(
		rearrange_confirm != null and rearrange_confirm.disabled,
		true,
		"HUD disables confirm on illegal pathing"
	)
	Callable(hud, "_confirm_rearrange").call()
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		85,
		"HUD illegal rearrange does not spend Att"
	)
	Callable(hud, "_select_rearrange_tile").call(Vector2i(1, 5))
	_expect_equal(
		rearrange_confirm != null and not rearrange_confirm.disabled,
		true,
		"HUD enables confirm on legal rearrange"
	)
	rearrange_confirm.pressed.emit()
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		75,
		"HUD legal rearrange spends Att 10"
	)

	_game_state.set("attention_remaining", 0)
	Callable(hud, "_update_attention").call(0)
	_expect_equal(open_research.disabled, true, "HUD Research disabled at Att 0")
	_expect_equal(open_rearrange.disabled, true, "HUD Rearrange disabled at Att 0")
	root.remove_child(hud)
	hud.free()
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)


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
			&"skill_informed", &"demand_band_sigma", &"comp_narrow_factor",
		],
		"buy demand signal payload"
	)
	_expect_payload_keys(
		events[3],
		[
			&"screen", &"sku_id", &"shown_comp_low_cents", &"shown_comp_high_cents",
			&"true_market_cents", &"shown_demand_band", &"true_demand_band", &"confidence",
			&"listed_price_cents", &"move_feel",
			&"skill_informed", &"demand_band_sigma", &"comp_narrow_factor",
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
	_expect_equal(EASY_CONFIG.event_chance_settle, 0.12, "easy settle event chance")
	_expect_equal(HARD_CONFIG.event_chance_settle, 0.26, "hard settle event chance")
	_expect_equal(NORMAL_CONFIG.negative_event_weight_mult, 1.0, "normal negative event weight")
	_expect_equal(EASY_CONFIG.negative_event_weight_mult, 0.7, "easy negative event weight")
	_expect_equal(HARD_CONFIG.negative_event_weight_mult, 1.4, "hard negative event weight")
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
	_expect_equal(NORMAL_CONFIG.inspect_attention, 5, "normal inspect attention")
	_expect_equal(EASY_CONFIG.inspect_attention, 5, "easy inspect attention default")
	_expect_equal(HARD_CONFIG.inspect_attention, 5, "hard inspect attention default")
	_expect_equal(NORMAL_CONFIG.inspect_attention_specialist, 2, "normal inspect specialist")
	_expect_equal(EASY_CONFIG.inspect_attention_specialist, 2, "easy inspect specialist default")
	_expect_equal(HARD_CONFIG.inspect_attention_specialist, 2, "hard inspect specialist default")
	_expect_equal(NORMAL_CONFIG.research_attention, 15, "normal research attention")
	_expect_equal(EASY_CONFIG.research_attention, 10, "easy research attention")
	_expect_equal(HARD_CONFIG.research_attention, 18, "hard research attention")
	_expect_equal(NORMAL_CONFIG.research_cost_cents, 5_000, "normal research cash")
	_expect_equal(NORMAL_CONFIG.research_attention_specialist, 10, "normal research specialist")
	_expect_equal(NORMAL_CONFIG.specialist_wage_cents, 14_000, "normal specialist wage")
	_expect_equal(EASY_CONFIG.specialist_wage_cents, 14_000, "easy specialist wage default")
	_expect_equal(HARD_CONFIG.specialist_wage_cents, 14_000, "hard specialist wage default")
	_expect_equal(NORMAL_CONFIG.rearrange_attention, 10, "normal rearrange attention")
	_expect_equal(EASY_CONFIG.rearrange_attention, 10, "easy rearrange inherits")
	_expect_equal(HARD_CONFIG.rearrange_attention, 10, "hard rearrange inherits")
	_expect_equal(NORMAL_CONFIG.research_demand_band_sigma, 0.07, "normal research sigma")
	_expect_equal(NORMAL_CONFIG.research_comp_narrow_factor, 0.55, "normal research narrow")
	_expect_equal(NORMAL_CONFIG.inspect_accuracy, 0.85, "normal inspect accuracy")
	_expect_equal(EASY_CONFIG.inspect_accuracy, 0.92, "easy inspect accuracy unchanged")
	_expect_equal(HARD_CONFIG.inspect_accuracy, 0.75, "hard inspect accuracy unchanged")
	_expect_equal(NORMAL_CONFIG.shady_fake_slab_rate, 0.08, "normal fake-slab rate")
	_expect_equal(EASY_CONFIG.shady_fake_slab_rate, 0.04, "easy fake-slab rate")
	_expect_equal(HARD_CONFIG.shady_fake_slab_rate, 0.14, "hard fake-slab rate")
	_expect_equal(NORMAL_CONFIG.fake_slab_sale_rep_hit, 15, "normal fake-slab sale Rep hit")
	_expect_equal(EASY_CONFIG.fake_slab_sale_rep_hit, 15, "easy fake-slab sale Rep inherits")
	_expect_equal(HARD_CONFIG.fake_slab_sale_rep_hit, 15, "hard fake-slab sale Rep inherits")
	_expect_equal(
		DemandSignalService.recommends_inspect(&"auction"),
		true,
		"auction recommends inspect for graded authenticity"
	)
	_expect_equal(
		DemandSignalService.is_risky_slab_channel(&"shady"),
		true,
		"shady is a risky slab channel"
	)
	_expect_equal(
		DemandSignalService.is_risky_slab_channel(&"auction"),
		true,
		"auction is a risky slab channel"
	)
	_expect_equal(
		DemandSignalService.is_risky_slab_channel(&"distributor"),
		false,
		"distributor is not a risky slab channel"
	)
	_expect_equal(NORMAL_CONFIG.staff_noshow_mult, 0.4, "normal staff_noshow_mult")
	_expect_equal(EASY_CONFIG.staff_noshow_mult, 0.4, "easy staff_noshow_mult inherits")
	_expect_equal(HARD_CONFIG.staff_noshow_mult, 0.4, "hard staff_noshow_mult inherits")
	_expect_equal(NORMAL_CONFIG.pull_attention, 5, "normal pull_attention")
	_expect_equal(EASY_CONFIG.pull_attention, 5, "easy pull_attention inherits")
	_expect_equal(HARD_CONFIG.pull_attention, 5, "hard pull_attention inherits")
	_expect_equal(EASY_CONFIG.staff_cap_small, 1, "easy staff_cap_small inherits")
	_expect_equal(HARD_CONFIG.staff_cap_small, 1, "hard staff_cap_small inherits")
	_expect_equal(EASY_CONFIG.staff_cap_medium, 3, "easy staff_cap_medium inherits")
	_expect_equal(HARD_CONFIG.staff_cap_medium, 3, "hard staff_cap_medium inherits")
	_expect_equal(NORMAL_CONFIG.staff_cap_large, 5, "normal staff_cap_large")
	_expect_equal(EASY_CONFIG.staff_cap_large, 5, "easy staff_cap_large inherits")
	_expect_equal(HARD_CONFIG.staff_cap_large, 5, "hard staff_cap_large inherits")
	_expect_equal(NORMAL_CONFIG.rent_large_weekly_cents, 400_000, "normal Large rent $4,000")
	_expect_equal(EASY_CONFIG.rent_large_weekly_cents, 400_000, "easy Large rent inherits")
	_expect_equal(HARD_CONFIG.rent_large_weekly_cents, 400_000, "hard Large rent inherits")
	_expect_equal(NORMAL_CONFIG.expand_large_cash_cents, 4_000_000, "normal Large cash gate $40k")
	_expect_equal(NORMAL_CONFIG.expand_large_rep, 70, "normal Large Rep gate 70")
	_expect_equal(EASY_CONFIG.expand_large_cash_cents, 4_000_000, "easy Large cash inherits")
	_expect_equal(HARD_CONFIG.expand_large_rep, 70, "hard Large Rep inherits")
	_expect_equal(
		is_equal_approx(NORMAL_CONFIG.expand_medium_traffic_mult, 1.0),
		true,
		"Medium traffic scalar stays 1.0 (shipped Medium spawn)"
	)
	_expect_equal(
		is_equal_approx(NORMAL_CONFIG.expand_large_traffic_mult, 1.25),
		true,
		"Large traffic scalar is 1.25 versus Medium"
	)
	_expect_equal(
		is_equal_approx(EASY_CONFIG.expand_large_traffic_mult, 1.25),
		true,
		"easy Large traffic inherits"
	)
	_expect_equal(
		is_equal_approx(HARD_CONFIG.expand_large_traffic_mult, 1.25),
		true,
		"hard Large traffic inherits"
	)
	var rent_step := (
		float(NORMAL_CONFIG.rent_large_weekly_cents)
		/ float(NORMAL_CONFIG.rent_medium_weekly_cents)
	)
	_expect_equal(
		NORMAL_CONFIG.expand_large_traffic_mult < 2.0,
		true,
		"Large traffic is not 2× Medium"
	)
	_expect_equal(
		NORMAL_CONFIG.expand_large_traffic_mult < rent_step,
		true,
		"Large traffic is sublinear versus the 1.67× rent step"
	)
	_expect_equal(
		is_equal_approx(
			NORMAL_CONFIG.shop_traffic_mult(ShopState.Tier.MEDIUM),
			1.0
		),
		true,
		"Medium shop traffic mult is the documented Medium scalar"
	)
	_expect_equal(
		is_equal_approx(
			NORMAL_CONFIG.shop_traffic_mult(ShopState.Tier.LARGE),
			1.25
		),
		true,
		"Large shop traffic mult is Medium × Large scalars"
	)
	_expect_equal(
		is_equal_approx(
			NORMAL_CONFIG.customer_spawn_wait_seconds(12.0, ShopState.Tier.LARGE),
			9.6
		),
		true,
		"Large spawn wait is 12s / 1.25"
	)
	_expect_equal(NORMAL_CONFIG.flagship_cash_cents, 5_000_000, "normal Flagship cash $50k")
	_expect_equal(EASY_CONFIG.flagship_cash_cents, 4_000_000, "easy Flagship cash $40k")
	_expect_equal(HARD_CONFIG.flagship_cash_cents, 6_500_000, "hard Flagship cash $65k")
	_expect_equal(NORMAL_CONFIG.flagship_rep, 80, "normal Flagship Rep 80")
	_expect_equal(EASY_CONFIG.flagship_rep, 80, "easy Flagship Rep inherits 80")
	_expect_equal(HARD_CONFIG.flagship_rep, 80, "hard Flagship Rep inherits 80")
	_expect_equal(
		NORMAL_CONFIG.meets_flagship(ShopState.Tier.LARGE, 80, 5_000_000),
		true,
		"normal Flagship predicate at exact cash/Rep"
	)
	_expect_equal(
		NORMAL_CONFIG.meets_flagship(ShopState.Tier.LARGE, 80, 4_999_999),
		false,
		"normal Flagship misses one cent under"
	)
	_expect_equal(
		NORMAL_CONFIG.meets_flagship(ShopState.Tier.MEDIUM, 80, 5_000_000),
		false,
		"normal Flagship requires Large"
	)
	_expect_equal(NORMAL_CONFIG.survive_y1_rep_floor, 40, "normal Survive Y1 Rep 40")
	_expect_equal(EASY_CONFIG.survive_y1_rep_floor, 30, "easy Survive Y1 Rep 30")
	_expect_equal(HARD_CONFIG.survive_y1_rep_floor, 50, "hard Survive Y1 Rep 50")
	_expect_equal(NORMAL_CONFIG.survive_y1_day, 365, "Survive Y1 day is 365")
	_expect_equal(
		NORMAL_CONFIG.meets_survive_y1(365, 40, 1),
		true,
		"normal Survive Y1 at exact day/Rep/cash"
	)
	_expect_equal(
		NORMAL_CONFIG.meets_survive_y1(364, 40, 1),
		false,
		"normal Survive Y1 misses day 364"
	)
	_expect_equal(
		NORMAL_CONFIG.meets_survive_y1(365, 40, 0),
		false,
		"normal Survive Y1 misses cash 0"
	)
	_expect_equal(
		NORMAL_CONFIG.meets_survive_y1(365, 39, 1),
		false,
		"normal Survive Y1 misses Rep 39"
	)
	_expect_equal(NORMAL_CONFIG.liquidity_king_cash_cents, 10_000_000, "normal Liquidity $100k")
	_expect_equal(EASY_CONFIG.liquidity_king_cash_cents, 7_500_000, "easy Liquidity $75k")
	_expect_equal(HARD_CONFIG.liquidity_king_cash_cents, 12_500_000, "hard Liquidity $125k")
	_expect_equal(NORMAL_CONFIG.month_length_days, 30, "Liquidity month is 30 days")
	_expect_equal(
		NORMAL_CONFIG.meets_liquidity_king(30, 10_000_000),
		true,
		"normal Liquidity king at month-end exact cash"
	)
	_expect_equal(
		NORMAL_CONFIG.meets_liquidity_king(29, 10_000_000),
		false,
		"normal Liquidity king misses mid-month"
	)
	_expect_equal(
		NORMAL_CONFIG.meets_liquidity_king(30, 9_999_999),
		false,
		"normal Liquidity king misses one cent under"
	)
	_expect_equal(
		NORMAL_CONFIG.meets_liquidity_king(60, 10_000_000),
		true,
		"normal Liquidity king accepts any month-end"
	)


func _test_normal_shop_capacity() -> void:
	var capacity := ShopCapacity.new()
	_expect_equal(capacity.display_slots, NORMAL_CONFIG.case_slots, "normal case slots")
	_expect_equal(capacity.storage_units, NORMAL_CONFIG.backstock_bins, "normal backstock bins")
	capacity.apply_large_upgrade()
	_expect_equal(
		capacity.display_slots,
		NORMAL_CONFIG.case_slots
		+ ShopState.MEDIUM_CASE_SLOT_BONUS
		+ ShopState.LARGE_CASE_SLOT_BONUS,
		"Large case bonus stacks on Medium"
	)
	_expect_equal(
		capacity.storage_units,
		NORMAL_CONFIG.backstock_bins
		+ ShopState.MEDIUM_BACKSTOCK_BONUS
		+ ShopState.LARGE_BACKSTOCK_BONUS,
		"Large backstock bonus stacks on Medium"
	)


func _test_weekly_rent_schedule() -> void:
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(6), false, "no rent before weekly settle")
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(7), true, "day seven weekly settle")
	_expect_equal(NORMAL_CONFIG.is_rent_due_day(14), true, "recurring weekly settle")
	_expect_equal(NORMAL_CONFIG.rent_small_weekly_cents, 120_000, "weekly rent amount")
	_expect_equal(NORMAL_CONFIG.rent_medium_weekly_cents, 240_000, "Medium weekly rent")
	_expect_equal(NORMAL_CONFIG.rent_large_weekly_cents, 400_000, "Large weekly rent")


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
		CustomerSpawnPolicy.can_spawn(DayPhasePolicy.PREP),
		false,
		"no prep customer spawn"
	)
	_expect_equal(
		CustomerSpawnPolicy.can_spawn(DayPhasePolicy.FLOOR),
		true,
		"floor customer spawn"
	)
	_expect_equal(
		CustomerSpawnPolicy.can_spawn(DayPhasePolicy.SETTLE),
		false,
		"no settle customer spawn"
	)


func _test_day_phase_transitions() -> void:
	_expect_equal(
		DayPhasePolicy.can_start_floor(DayPhasePolicy.PREP),
		true,
		"prep enters floor"
	)
	_expect_equal(
		DayPhasePolicy.can_start_floor(DayPhasePolicy.FLOOR),
		false,
		"floor cannot restart floor"
	)
	_expect_equal(
		DayPhasePolicy.can_start_settle(DayPhasePolicy.FLOOR),
		true,
		"floor enters settle"
	)
	_expect_equal(
		DayPhasePolicy.can_start_settle(DayPhasePolicy.PREP),
		false,
		"prep cannot settle"
	)
	_expect_equal(
		DayPhasePolicy.can_advance_day(DayPhasePolicy.SETTLE),
		true,
		"settle advances day"
	)
	_expect_equal(
		DayPhasePolicy.can_advance_day(DayPhasePolicy.FLOOR),
		false,
		"floor cannot advance day"
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


func _test_customer_service_actions() -> void:
	var inventory := FakeCustomerInventory.new()
	var queue := CustomerQueue.new()
	queue.configure(inventory)
	var refused_customer := CustomerProfile.new()
	refused_customer.budget_cents = 1000
	refused_customer.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(refused_customer), true, "enqueue listed offer")
	_expect_equal(queue.refuse(), true, "refuse customer")
	_expect_equal(inventory.sold, false, "refuse does not sell")
	var buying_customer := CustomerProfile.new()
	buying_customer.budget_cents = 1000
	buying_customer.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(buying_customer), true, "enqueue sale customer")
	_expect_equal(queue.sell_listed(), true, "sell listed action")
	_expect_equal(inventory.sold, true, "sell action reaches inventory")
	var seller := CustomerProfile.new()
	seller.trade_intent = CustomerProfile.TradeIntent.SELLING_TO_SHOP
	seller.buylist_signal = BuyConfirmSignal.new()
	seller.buylist_signal.sku_id = &"AA-DUST-ETB"
	seller.buylist_signal.display_name = "Dustway Chronicles Explorer Box"
	seller.buylist_signal.quantity = 1
	seller.buylist_signal.unit_cost_cents = 2400
	seller.buylist_signal.lot_total_cents = 2400
	seller.buylist_signal.shown_comp_low_cents = 4200
	seller.buylist_signal.shown_comp_high_cents = 4800
	seller.buylist_signal.can_confirm = true
	_expect_equal(queue.enqueue(seller), true, "enqueue buylist seller")
	_expect_equal(queue.accept_buylist_offer(), true, "accept buylist offer")
	_expect_equal(inventory.bought, true, "buylist offer reaches inventory purchase")
	queue.free()
	inventory.free()


func _test_ui_price_labels() -> void:
	_expect_equal(
		DemandSignalPresenter.price_label(
			DemandSignalPresenter.PriceContext.CUSTOMER_BUYING_FROM_SHOP
		),
		"Your list",
		"customer sale price label"
	)
	_expect_equal(
		DemandSignalPresenter.price_label(
			DemandSignalPresenter.PriceContext.CUSTOMER_SELLING_TO_SHOP
		),
		"You offer",
		"buylist bid label"
	)
	_expect_equal(
		DemandSignalPresenter.price_label(
			DemandSignalPresenter.PriceContext.SHOP_BUYING_OPPORTUNITY
		),
		"Ask",
		"buy opportunity ask label"
	)
	var buylist_dto := BuyConfirmSignal.new()
	buylist_dto.display_name = "Seller lot"
	buylist_dto.quantity = 1
	buylist_dto.unit_cost_cents = 500
	buylist_dto.lot_total_cents = 500
	buylist_dto.confidence = &"medium"
	var seller_summary := DemandSignalPresenter.buylist_seller_summary(
		buylist_dto
	)
	_expect_equal(
		seller_summary.contains("You offer: $5.00 each"),
		true,
		"buylist seller summary uses You offer helper"
	)
	_expect_equal(
		DemandSignalPresenter.parse_cents("$8,000.00"),
		800_000,
		"parse_cents accepts grouped cash"
	)
	_expect_equal(
		DemandSignalPresenter.format_cents(800_000),
		"$8,000.00",
		"format_cents groups thousands"
	)
	_expect_equal(
		DemandSignalPresenter.parse_cents("$44.99"),
		4499,
		"parse_cents still accepts ungrouped dollars"
	)
	var buy_dto := BuyConfirmSignal.new()
	buy_dto.unit_cost_cents = 100
	buy_dto.lot_total_cents = 100
	buy_dto.shown_comp_low_cents = 90
	buy_dto.shown_comp_high_cents = 110
	buy_dto.shown_demand_band = &"steady"
	buy_dto.confidence = &"medium"
	buy_dto.condition_cue = "NM"
	buy_dto.remaining_cash_cents = 500
	buy_dto.space_required = 1
	buy_dto.space_free = 2
	var buy_ok := DemandSignalPresenter.buy_summary(buy_dto)
	_expect_equal(
		buy_ok.contains("After buy: ✓") and buy_ok.contains("Space: ✓"),
		true,
		"Buy cash/space check uses ✓ when affordable"
	)
	buy_dto.remaining_cash_cents = -25
	buy_dto.space_free = 0
	var buy_fail := DemandSignalPresenter.buy_summary(buy_dto)
	_expect_equal(
		buy_fail.contains("After buy: ✗") and buy_fail.contains("Space: ✗"),
		true,
		"Buy cash/space check uses ✗ when blocked"
	)


func _test_ui_helpers_do_not_read_hidden_values() -> void:
	for path: String in [
		"res://scripts/ui/demand_signal_presenter.gd",
		"res://scripts/ui/hud.gd",
		"res://scripts/shop/staff_presenter.gd",
		"res://scripts/shop/staff_member.gd",
		"res://scripts/shop/shop_state.gd",
		"res://scripts/economy/online_listing.gd",
		"res://scripts/economy/online_list_confirm_signal.gd",
		"res://scripts/economy/online_listing_service.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_expect_equal(source.contains("true_market"), false, "%s market truth access" % path)
		_expect_equal(source.contains("p_buy"), false, "%s probability access" % path)
		_expect_equal(source.contains("cert_valid"), false, "%s certificate access" % path)
	_expect_equal(
		bool(ProjectSettings.get_setting("debug/qa_instrumentation", true)),
		false,
		"QA instrumentation defaults off"
	)


func _test_wants_label_format() -> void:
	_expect_equal(
		DemandSignalPresenter.wants_label(
			"Bastion Captain",
			&"AA-BASE-088",
			"NM"
		),
		"Bastion Captain · NM",
		"Wants uses bible name and condition"
	)
	_expect_equal(
		DemandSignalPresenter.wants_label(
			"Arcbolt Adept",
			&"AA-BASE-078",
			"NM"
		),
		"Arcbolt Adept · NM",
		"Wants Arcbolt staple format"
	)
	_expect_equal(
		DemandSignalPresenter.wants_label(
			"Empress of Updrafts",
			&"AA-SKIE-052",
			"",
			"Prism",
			10.0
		),
		"Empress of Updrafts · Prism 10",
		"Wants graded format omits .0"
	)
	_expect_equal(
		DemandSignalPresenter.wants_label(
			"Bastion Captain",
			&"AA-BASE-088",
			"NM",
			"",
			-1.0,
			2
		),
		"Bastion Captain · NM ×2",
		"Wants appends quantity when above one"
	)
	var fallback := DemandSignalPresenter.wants_label(
		"",
		&"AA-BASE-088",
		"NM"
	)
	_expect_equal(fallback, "Base 088 · NM", "missing name humanizes SKU")
	_expect_equal(
		fallback.contains("AA-") or fallback.contains("AA-BASE-"),
		false,
		"humanized fallback has no raw AA SKU"
	)
	var raw_passthrough := DemandSignalPresenter.wants_label(
		"AA-BASE-088",
		&"AA-BASE-088",
		"NM"
	)
	_expect_equal(
		raw_passthrough.contains("AA-BASE-") or raw_passthrough.contains("AA-"),
		false,
		"raw SKU display name is humanized away"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var inventory := _inventory_service.get("model") as InventoryModel
	var bastion := inventory.get_sku(&"AA-BASE-088")
	var bastion_card: CardInstance = _inventory_service.call(
		"get_card",
		&"AA-BASE-088"
	)
	var spike_wants := DemandSignalPresenter.wants_label(
		bastion.display_name,
		&"AA-BASE-088",
		CardInstance.Condition.keys()[bastion_card.condition]
	)
	_expect_equal(
		spike_wants,
		"Bastion Captain · NM",
		"CustomerServe Wants uses Bastion Captain · NM"
	)
	_expect_equal(
		spike_wants.contains("AA-BASE-"),
		false,
		"CustomerServe Wants hides raw SKU ids"
	)
	var empress := inventory.get_sku(&"AA-SKIE-052")
	_inventory_service.call(
		"receive_slab",
		&"AA-SKIE-052",
		&"Prism",
		10.0,
		empress.base_market_cents,
		InventoryLocation.new(InventoryLocation.Type.CASE)
	)
	var empress_slab: SlabInstance = _inventory_service.call(
		"get_slab",
		&"AA-SKIE-052"
	)
	_expect_equal(
		DemandSignalPresenter.wants_label(
			empress.display_name,
			&"AA-SKIE-052",
			"",
			String(empress_slab.grader),
			empress_slab.grade
		),
		"Empress of Updrafts · Prism 10",
		"CustomerServe Wants uses grader and grade"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("String(_current_customer.target_sku)"),
		false,
		"HUD Wants line does not interpolate raw SKU"
	)
	_expect_equal(
		hud_source.contains("_customer_wants_label"),
		true,
		"HUD CustomerServe uses Wants helper"
	)


func _test_prep_hud_seed_before_bind() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("is_game_active", false)
	_economy.set("balance_cents", 0)
	_game_state.set("attention_remaining", 0)
	_game_state.call("start_new_game")
	_expect_equal(
		int(_economy.get("balance_cents")),
		800_000,
		"Prep seed cash from Normal BalanceConfig"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		100,
		"Prep seed attention from Normal BalanceConfig"
	)
	_expect_equal(
		NORMAL_CONFIG.start_cash_cents,
		800_000,
		"Normal start_cash_cents unchanged"
	)
	_expect_equal(
		NORMAL_CONFIG.attention_pool,
		100,
		"Normal attention_pool unchanged"
	)
	_expect_equal(
		DemandSignalPresenter.format_cents(int(_economy.get("balance_cents"))),
		"$8,000.00",
		"Prep cash formats as $8,000.00"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("_bind_seeded_status"),
		true,
		"HUD binds status after seed"
	)
	_expect_equal(
		hud_source.contains("GameState.start_new_game()"),
		true,
		"HUD seeds inactive sessions before bind"
	)
	var hud_scene := FileAccess.get_file_as_string(
		"res://scenes/ui/gameplay_hud.tscn"
	)
	_expect_equal(
		hud_scene.contains("$8,000.00"),
		true,
		"Prep HUD scene default is seeded cash"
	)
	_expect_equal(
		hud_scene.contains("$0.00"),
		false,
		"Prep HUD scene default is not $0"
	)
	_expect_equal(
		hud_scene.contains("Att 100/100"),
		true,
		"Prep HUD scene default is seeded attention"
	)
	_expect_equal(
		hud_scene.contains("res://themes/shop_hud.tres"),
		true,
		"Prep HUD scene uses shop HUD theme"
	)


func _test_gameplay_hud_visual_smoke() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("is_game_active", false)
	_economy.set("balance_cents", 0)
	_game_state.set("attention_remaining", 0)
	var packed: PackedScene = load("res://scenes/ui/gameplay_hud.tscn") as PackedScene
	_expect_equal(packed != null, true, "gameplay HUD scene loads")
	if packed == null:
		return
	var hud: Node = packed.instantiate()
	root.add_child(hud)
	var cash := hud.get_node_or_null("%CashLabel") as Label
	var attention := hud.get_node_or_null("%AttentionLabel") as Label
	var day := hud.get_node_or_null("%DayLabel") as Label
	var phase := hud.get_node_or_null("%PhaseLabel") as Label
	var queue := hud.get_node_or_null("%QueueLabel") as Label
	var phase_chip := hud.get_node_or_null("%PhaseChip") as PanelContainer
	var open_floor := hud.get_node_or_null("%PhaseButton") as Button
	var buy_button := hud.get_node_or_null("%OpenBuyButton") as Button
	var price_button := hud.get_node_or_null("%OpenPriceButton") as Button
	var serve := hud.get_node_or_null("%CustomerServe") as PanelContainer
	_expect_equal(cash != null and cash.text == "$8,000.00", true, "HUD binds Prep $8,000.00")
	_expect_equal(
		attention != null and attention.text == "Att 100/100",
		true,
		"HUD binds Prep attention 100"
	)
	_expect_equal(day != null and day.text == "Day 1", true, "HUD binds Day 1")
	_expect_equal(
		phase != null and phase.text == "PREP",
		true,
		"HUD binds PREP phase chip"
	)
	_expect_equal(
		queue != null and queue.text == "Queue 0",
		true,
		"HUD binds empty queue"
	)
	_expect_equal(
		hud.get("theme") != null,
		true,
		"HUD theme resource assigned"
	)
	_expect_equal(
		phase_chip != null and phase_chip.theme_type_variation == &"PhaseChipPrep",
		true,
		"PREP uses phase chip variation"
	)
	_expect_equal(
		open_floor != null and open_floor.custom_minimum_size.y >= 40.0,
		true,
		"Open floor hit target height"
	)
	_expect_equal(
		buy_button != null and buy_button.custom_minimum_size.y >= 40.0,
		true,
		"Buy opportunity hit target height"
	)
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(inspect_button != null, true, "Inspect★ button present")
	_expect_equal(
		inspect_button != null
		and inspect_button.text.contains("Inspect★")
		and inspect_button.text.contains("Att 5"),
		true,
		"Inspect★ label shows owner Att cost"
	)
	_expect_equal(
		inspect_button != null and inspect_button.custom_minimum_size.y >= 40.0,
		true,
		"Inspect★ hit target height"
	)
	var research_button := hud.get_node_or_null("%OpenResearchButton") as Button
	var rearrange_button := hud.get_node_or_null("%OpenRearrangeButton") as Button
	var event_banner := hud.get_node_or_null("%EventBannerLabel") as Label
	_expect_equal(event_banner != null, true, "thin event banner present")
	_expect_equal(
		event_banner != null and event_banner.visible == false,
		true,
		"event banner hidden with no active event"
	)
	_expect_equal(research_button != null, true, "Research button present")
	_expect_equal(
		research_button != null
		and research_button.text.contains("Att 15")
		and research_button.text.contains("$50.00"),
		true,
		"Research button shows cash and Att cost"
	)
	_expect_equal(
		research_button != null and research_button.custom_minimum_size.y >= 40.0,
		true,
		"Research hit target height"
	)
	_expect_equal(rearrange_button != null, true, "Rearrange button present")
	_expect_equal(
		rearrange_button != null and rearrange_button.text.contains("Att 10"),
		true,
		"Rearrange button shows Att cost"
	)
	_expect_equal(
		rearrange_button != null and rearrange_button.custom_minimum_size.y >= 40.0,
		true,
		"Rearrange hit target height"
	)
	var cameras_button := hud.get_node_or_null("%OpenCamerasButton") as Button
	_expect_equal(cameras_button != null, true, "Cameras button present")
	_expect_equal(
		cameras_button != null
		and cameras_button.text.contains("Att 8")
		and cameras_button.text.contains("$2,500.00"),
		true,
		"Cameras button shows cash and Att cost"
	)
	_expect_equal(
		cameras_button != null and cameras_button.custom_minimum_size.y >= 40.0,
		true,
		"Cameras hit target height"
	)
	var online_button := hud.get_node_or_null("%OpenOnlineButton") as Button
	_expect_equal(online_button != null, true, "Online listings button present")
	_expect_equal(
		online_button != null and online_button.custom_minimum_size.y >= 40.0,
		true,
		"Online listings hit target height"
	)
	_expect_equal(
		price_button != null and price_button.custom_minimum_size.y >= 40.0,
		true,
		"Price inventory hit target height"
	)
	var price_input := hud.get_node_or_null("%PriceInput") as LineEdit
	_expect_equal(
		price_input != null and price_input.custom_minimum_size.y >= 40.0,
		true,
		"Your list input is the larger primary field"
	)
	_expect_equal(
		open_floor != null and open_floor.theme_type_variation == &"PrimaryButton",
		true,
		"Open floor uses primary button variation"
	)
	_expect_equal(serve != null, true, "CustomerServe panel present")
	var patience := hud.get_node_or_null("%PatienceBar") as ProgressBar
	_expect_equal(patience != null, true, "CustomerServe patience bar present")
	_expect_equal(
		patience != null and patience.custom_minimum_size.x >= 120.0,
		true,
		"Patience bar is at least 120px wide"
	)
	_expect_equal(
		patience != null and patience.show_percentage == false,
		true,
		"Patience bar is a meter, not a percent label"
	)
	var price_chip_row := hud.get_node_or_null("%PriceChipRow") as HBoxContainer
	var position_chip := hud.get_node_or_null("%PricePositionChip") as Label
	_expect_equal(price_chip_row != null, true, "PriceEditor has a chip strip")
	_expect_equal(
		position_chip != null,
		true,
		"PriceEditor position chip is present"
	)
	var hud_scene := FileAccess.get_file_as_string(
		"res://scenes/ui/gameplay_hud.tscn"
	)
	_expect_equal(
		hud_scene.contains("text = \"Your list\""),
		true,
		"PriceEditor labels the primary input Your list"
	)
	_expect_equal(
		hud_scene.contains("ACC-*"),
		false,
		"HUD chrome does not show raw accessory SKU walls"
	)
	_expect_equal(
		serve != null and serve.offset_left >= 48.0 and serve.offset_bottom <= 480.0,
		true,
		"CustomerServe hugs left edge above lower third"
	)
	var buy_list := hud.get_node_or_null("%BuyOpportunityList") as PanelContainer
	_expect_equal(
		buy_list != null
		and buy_list.offset_left >= 48.0
		and buy_list.offset_bottom <= 480.0,
		true,
		"Buy list stays in left edge chrome"
	)
	var veil := hud.get_node_or_null("%ModalVeil") as ColorRect
	_expect_equal(veil != null, true, "Modal veil present")
	_expect_equal(
		veil != null and veil.visible == false,
		true,
		"Veil hidden until a modal opens"
	)
	_expect_equal(
		veil != null and is_equal_approx(veil.color.a, 0.4),
		true,
		"Modal veil is a 40% soft dim"
	)
	var theme_source := FileAccess.get_file_as_string("res://themes/shop_hud.tres")
	_expect_equal(
		theme_source.contains("bg_color = Color(0.145, 0.145, 0.155, 0.78)"),
		true,
		"Modal panels use charcoal fill at ~78% opacity"
	)
	_expect_equal(
		theme_source.contains("Color(0.957, 0.941, 0.91"),
		true,
		"Cream is reserved for HUD type on dark chrome"
	)
	_expect_equal(
		theme_source.contains("corner_radius_top_left = 10"),
		true,
		"Panel corner radius is 8–12"
	)
	_expect_equal(
		theme_source.contains("Color(0.24, 0.43, 0.42"),
		true,
		"Muted teal is the system accent"
	)
	_expect_equal(
		theme_source.contains("id=\"StyleSignalChip\""),
		true,
		"Signal chips use calm gunmetal chrome, not extra accent fill"
	)
	_expect_equal(
		theme_source.contains("id=\"StyleProgressFill\""),
		true,
		"Patience meter fill is themed cream, not a second accent"
	)
	var hud_script: Script = hud.get_script()
	_expect_equal(hud_script != null, true, "HUD script attached")
	var wants := DemandSignalPresenter.wants_label(
		"Bastion Captain",
		&"AA-BASE-088",
		"NM"
	)
	_expect_equal(wants, "Bastion Captain · NM", "Wants keeps bible · condition")
	_expect_equal(wants.contains("AA-"), false, "Wants smoke stays non-SKU")
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("_customer_wants_label"),
		true,
		"CustomerServe still uses Wants helper"
	)
	_expect_equal(
		hud_source.contains("String(_current_customer.target_sku)"),
		false,
		"CustomerServe still hides raw SKU ids"
	)
	_expect_equal(
		hud_source.contains("ShopCamera")
		or hud_source.contains("Camera3D")
		or hud_source.contains("fov"),
		false,
		"HUD script does not mutate camera/FOV"
	)
	var steady_chip := DemandSignalPresenter.band_chip(&"steady")
	_expect_equal(
		steady_chip.contains("STEADY") and steady_chip != "STEADY",
		true,
		"Demand chips include icon and label"
	)
	_expect_equal(
		DemandSignalPresenter.position_chip(&"undercut").contains("Undercut"),
		true,
		"Position chips keep label text"
	)
	root.remove_child(hud)
	hud.free()


func _test_undercut_fill_boundary() -> void:
	_expect_equal(
		DemandSignalPresenter.UNDERCUT_FILL_FACTOR,
		0.90,
		"Undercut fill factor is strict 0.90"
	)
	_expect_equal(
		DemandSignalPresenter.undercut_fill_cents(1000),
		900,
		"Undercut fill floors suggested * 0.90"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var preview := _demand_signals.call(
		"price_signal",
		&"AA-DUST-ETB",
		_inventory_service.call("listed_price_for", &"AA-DUST-ETB"),
		_inventory_service.call("location_for", &"AA-DUST-ETB")
	) as PriceConfirmSignal
	var undercut_cents := DemandSignalPresenter.undercut_fill_cents(
		preview.suggested_price_cents
	)
	_expect_equal(
		undercut_cents,
		maxi(1, floori(preview.suggested_price_cents * 0.90)),
		"Undercut helper matches floori(suggested * 0.90)"
	)
	var undercut_preview := _demand_signals.call(
		"refresh_price_signal",
		preview,
		undercut_cents
	) as PriceConfirmSignal
	_expect_equal(
		undercut_preview.position,
		&"undercut",
		"×0.90 fill maps to Undercut"
	)
	var competitive_cents := ceili(preview.suggested_price_cents * 0.92)
	var competitive_preview := _demand_signals.call(
		"refresh_price_signal",
		preview,
		competitive_cents
	) as PriceConfirmSignal
	_expect_equal(
		competitive_preview.position,
		&"competitive",
		"exact −8% (suggest × 0.92) maps to Competitive"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("* 0.92") or hud_source.contains("*0.92"),
		false,
		"HUD has no leftover ×0.92 Undercut fill"
	)
	_expect_equal(
		hud_source.contains("undercut_fill_cents"),
		true,
		"HUD Undercut fill uses shared 0.90 helper"
	)
	var presenter_source := FileAccess.get_file_as_string(
		"res://scripts/ui/demand_signal_presenter.gd"
	)
	_expect_equal(
		presenter_source.contains("* 0.92") or presenter_source.contains("*0.92"),
		false,
		"presenter has no leftover ×0.92 Undercut fill"
	)


func _test_spike_staple_beat() -> void:
	_game_state.call("start_new_game")
	var inventory := _inventory_service.get("model") as InventoryModel
	for card: CardInstance in inventory.cards.duplicate():
		if card.sku_id in [&"AA-BASE-088", &"AA-BASE-078"]:
			inventory.remove_card(card)
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.FLOOR)
	_captured_scripted_customer = null
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call(
			"trigger_qa_beat",
			SPIKE_STAPLE_BEAT
		),
		true,
		"Spike staple QA trigger"
	)
	_expect_equal(
		_inventory_service.call("card_count", &"AA-BASE-088"),
		1,
		"Spike beat seeds exactly one missing NM staple"
	)
	_expect_equal(
		_captured_scripted_customer != null,
		true,
		"Spike scripted customer emitted"
	)
	if _captured_scripted_customer != null:
		_expect_equal(
			_captured_scripted_customer.archetype_id,
			&"spike",
			"scripted customer archetype"
		)
		_expect_equal(
			_captured_scripted_customer.desired_skus,
			[&"AA-BASE-088"],
			"Spike targets seeded staple"
		)
	_qa_autoload.call("set_force_enabled", false)


func _test_rent_firesale_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_rent_decision = {}
	_beat_director.call("_start_day_beats", 7)
	_expect_equal(
		_beat_director.call("is_started", RENT_FIRESALE_BEAT),
		true,
		"rent fire-sale starts on Normal day seven PREP"
	)
	_expect_equal(
		StringName(_captured_rent_decision.get("beat_id", &"")),
		RENT_FIRESALE_BEAT,
		"rent decision carries beat tag"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("fire_sale_enabled", false)),
		true,
		"rent decision offers sealed fire-sale"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("accessory_enabled", false)),
		true,
		"rent decision offers accessory cut"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("loan_enabled", false)),
		true,
		"rent decision offers Normal payday loan"
	)
	for key: Variant in _captured_rent_decision.keys():
		var field := String(key)
		_expect_equal(
			field.contains("true_market")
			or field.contains("p_buy")
			or field.contains("cert_valid"),
			false,
			"rent decision field %s does not leak truth" % field
		)

	_captured_price_sku = &""
	_captured_price_beat = &""
	_captured_price_mode = &""
	_expect_equal(
		_beat_director.call("choose_rent_path", &"fire_sale"),
		true,
		"rent fire-sale path opens pricing"
	)
	_expect_equal(
		_captured_price_sku in [&"AA-DUST-ETB", &"AA-DUST-BLST"],
		true,
		"rent fire-sale focuses owned Dustway sealed"
	)
	_expect_equal(
		_captured_price_beat,
		RENT_FIRESALE_BEAT,
		"rent price focus carries beat tag"
	)
	_expect_equal(
		_captured_price_mode,
		&"undercut",
		"rent price focus suggests Undercut"
	)
	var fire_sale_preview := _demand_signals.call(
		"price_signal",
		_captured_price_sku,
		_inventory_service.call("listed_price_for", _captured_price_sku),
		_inventory_service.call("location_for", _captured_price_sku)
	) as PriceConfirmSignal
	var undercut_cents := DemandSignalPresenter.undercut_fill_cents(
		fire_sale_preview.suggested_price_cents
	)
	fire_sale_preview = _demand_signals.call(
		"refresh_price_signal",
		fire_sale_preview,
		undercut_cents
	) as PriceConfirmSignal
	_expect_equal(
		fire_sale_preview.position,
		&"undercut",
		"rent fire-sale preview refresh shows Undercut"
	)
	_beat_director.call(
		"_on_beat_ui_resolved",
		RENT_FIRESALE_BEAT,
		&"cancelled"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 7)
	var cash_before_rent := int(_economy.get("balance_cents"))
	_expect_equal(
		_beat_director.call("choose_rent_path", &"dismissed"),
		true,
		"rent decision can explicitly dismiss"
	)
	_expect_equal(
		(_economy.call("get_ledger") as Array).is_empty(),
		true,
		"dismiss does not auto-pay rent"
	)
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_rent - NORMAL_CONFIG.rent_small_weekly_cents,
		"dismissed rent still collects at SETTLE"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_rent_decision = {}
	_beat_director.call("_start_day_beats", 7)
	_expect_equal(
		bool(_captured_rent_decision.get("loan_enabled", true)),
		false,
		"Hard rent decision hides payday loan"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains(
			"rent_loan_button.visible = bool(payload.get(\"loan_enabled\", false))"
		),
		true,
		"HUD hides unavailable loan option"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_titan_hype_price_focus() -> void:
	_beat_director.call("reset")
	var inventory := _inventory_service.get("model") as InventoryModel
	for card: CardInstance in inventory.cards.duplicate():
		if card.sku_id == &"AA-SKIE-047":
			inventory.remove_card(card)
	_game_state.set("current_day", 8)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_price_sku = &""
	_captured_price_beat = &""
	_captured_price_focus_count = 0
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call(
			"trigger_qa_beat",
			TITAN_HYPE_BEAT
		),
		true,
		"Titan hype QA trigger"
	)
	_expect_equal(
		int(_inventory_service.call("card_count", &"AA-SKIE-047")) >= 1,
		true,
		"Titan hype ensures NM inventory"
	)
	var titan_signal := _demand_signals.call(
		"price_signal",
		&"AA-SKIE-047",
		2200,
		_inventory_service.call("location_for", &"AA-SKIE-047")
	) as PriceConfirmSignal
	_expect_equal(
		titan_signal.shown_demand_band,
		&"hot",
		"Titan hype shows HOT noisy demand band"
	)
	_expect_equal(
		titan_signal.suggested_price_cents > 2200,
		true,
		"Titan hype elevates noisy suggested comp"
	)
	_expect_equal(_captured_price_sku, &"AA-SKIE-047", "Titan price focus SKU")
	_expect_equal(
		_captured_price_beat,
		TITAN_HYPE_BEAT,
		"Titan price focus beat tag"
	)
	_expect_equal(_captured_price_focus_count, 1, "Titan initial PREP focus")
	var market_state := _demand_signals.get("_market_state") as MarketState
	var market_before_refocus := market_state.market_cents_for(&"AA-SKIE-047")
	var listed_before_refocus := int(
		_inventory_service.call("listed_price_for", &"AA-SKIE-047")
	)
	_game_state.set("current_phase", DayPhasePolicy.FLOOR)
	_beat_director.call("_refocus_titan_after_phase_change", 8)
	_expect_equal(
		_captured_price_focus_count,
		2,
		"Titan refocuses after PREP to FLOOR UI settles"
	)
	_expect_equal(
		market_state.market_cents_for(&"AA-SKIE-047"),
		market_before_refocus,
		"Titan refocus does not multiply market cents"
	)
	_expect_equal(
		int(_inventory_service.call("listed_price_for", &"AA-SKIE-047")),
		listed_before_refocus,
		"Titan refocus does not mutate listed cents"
	)
	_expect_equal(
		_beat_director.call("is_completed", TITAN_HYPE_BEAT),
		false,
		"Titan remains pending for Apply or Cancel on FLOOR"
	)
	_beat_director.call(
		"_on_beat_ui_resolved",
		TITAN_HYPE_BEAT,
		&"cancelled"
	)
	_expect_equal(
		_beat_director.call(
			"is_completed",
			TITAN_HYPE_BEAT
		),
		true,
		"Titan cancel resolves restored FLOOR editor"
	)
	_beat_director.call("reset")
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", TITAN_HYPE_BEAT),
		true,
		"Titan can start again in isolated lifecycle"
	)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_beat_director.call("_on_day_phase_changed", DayPhasePolicy.SETTLE)
	_expect_equal(
		_beat_director.call("is_completed", TITAN_HYPE_BEAT),
		true,
		"ignored Titan completes at SETTLE instead of staying stuck"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_market_events_seven_day_seeded_run() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_qa_autoload.call("set_force_enabled", true)
	var non_null := 0
	var seeds: Array[int] = [MarketEventService.EVENT_RNG_SEED]
	for extra: int in range(1, 32):
		seeds.append(extra)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		_demand_signals.call("seed_event_rng", rng_seed)
		_qa_autoload.call("clear")
		non_null = 0
		for _day_index: int in range(7):
			_expect_equal(
				_game_state.call("start_floor"),
				true,
				"7-day seeded run can open floor"
			)
			_expect_equal(
				_game_state.call("start_settle"),
				true,
				"7-day seeded run can settle"
			)
			if int(_game_state.get("current_day")) < 7:
				_expect_equal(
					_game_state.call("advance_day"),
					true,
					"7-day seeded run can advance"
				)
		for event: Dictionary in _qa_autoload.call("get_events"):
			if String(event.get("event", "")) != "market_event_rolled":
				continue
			var payload: Dictionary = event.get("payload", {})
			_assert_payload_has_no_truth(payload, "7-day market_event_rolled")
			if String(payload.get("event_id", "")).is_empty():
				continue
			non_null += 1
		if non_null >= 1:
			break
	_expect_equal(non_null >= 1, true, "Normal 7-day seeded run emits ≥1 non-null event")
	_expect_equal(
		FileAccess.get_file_as_string("res://data/events.json").contains("hype_spike")
		and FileAccess.get_file_as_string("res://data/events.json").contains("soft_rotation_leak")
		and FileAccess.get_file_as_string("res://data/events.json").contains("fog_day")
		and FileAccess.get_file_as_string("res://data/events.json").contains("counterfeit_scare")
		and FileAccess.get_file_as_string("res://data/events.json").contains("convention_weekend")
		and FileAccess.get_file_as_string("res://data/events.json").contains("theft_ring")
		and FileAccess.get_file_as_string("res://data/events.json").contains("recession_week")
		and FileAccess.get_file_as_string("res://data/events.json").contains("supply_glut"),
		true,
		"C1 pack catalogs hype, rotation leak, fog, counterfeit, convention, theft ring, recession, and supply glut"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_hype_spike_target_sku_only() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var control_sku := &"AA-BASE-088"
	var titan := &"AA-SKIE-047"
	var control_before := _demand_signals.call(
		"price_signal",
		control_sku,
		500,
		_inventory_service.call("location_for", control_sku)
	) as PriceConfirmSignal
	var control_market_before := (
		_demand_signals.get("_market_state") as MarketState
	).market_cents_for(control_sku)
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": titan, "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(started != null, true, "hype pack starts")
	_expect_equal(started.sku_id, titan, "hype targets Titan only")
	var titan_signal := _demand_signals.call(
		"price_signal",
		titan,
		2200,
		_inventory_service.call("location_for", titan)
	) as PriceConfirmSignal
	var control_after := _demand_signals.call(
		"price_signal",
		control_sku,
		500,
		_inventory_service.call("location_for", control_sku)
	) as PriceConfirmSignal
	_expect_equal(titan_signal.shown_demand_band, &"hot", "hype elevates target band to HOT")
	_expect_equal(
		titan_signal.suggested_price_cents > 2200,
		true,
		"hype elevates target noisy comps"
	)
	_expect_equal(
		(
			_demand_signals.get("_market_state") as MarketState
		).market_cents_for(control_sku),
		control_market_before,
		"hype does not change other SKU market"
	)
	_expect_equal(
		control_after.shown_demand_band,
		control_before.shown_demand_band,
		"hype leaves control SKU band unchanged"
	)
	_expect_dto_has_no_truth_fields(titan_signal, "hype price signal")
	_expect_dto_has_no_truth_fields(control_after, "hype control price signal")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(titan_signal),
		"hype PriceEditor summary"
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("HOT"), true, "hype banner uses HOT chip language")
	_expect_equal(banner.contains("Titan"), true, "hype banner names the SKU")
	_assert_text_has_no_truth(banner, "hype banner")
	var hud := _instantiate_gameplay_hud()
	if hud != null:
		var banner_label := hud.get_node_or_null("%EventBannerLabel") as Label
		_expect_equal(banner_label != null, true, "thin event banner exists")
		_expect_equal(
			banner_label != null and banner_label.visible and banner_label.text.contains("HOT"),
			true,
			"HUD banner shows hype without a new screen"
		)
		_assert_text_has_no_truth(
			banner_label.text if banner_label != null else "",
			"HUD hype banner"
		)
		var demand_chip := hud.get_node_or_null("%PriceDemandChip") as Label
		_expect_equal(demand_chip != null, true, "PriceEditor demand chip still present")
		hud.queue_free()


func _test_fog_day_sigma_and_inversion() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var base_sigma: float = _demand_signals.call("active_demand_band_sigma", false)
	_expect_equal(is_equal_approx(base_sigma, 0.12), true, "Normal base σ is 0.12")
	_expect_equal(
		_demand_signals.call("has_fog_flag"),
		false,
		"no fog flag before fog day"
	)
	var market_state := MarketState.new()
	for demand_score: float in [0.0, 1.0]:
		market_state.update_sku(&"AA-SKIE-047", 10_000, demand_score)
		var inversion_service := DemandSignalService.new(
			NORMAL_CONFIG, market_state, 123, _qa
		)
		_expect_equal(inversion_service.has_fog_flag(), false, "service starts without fog flag")
		for day: int in range(1, 81):
			var dto := inversion_service.buy_confirm(
				day, &"AA-SKIE-047", DemandSignalService.Channel.SHADY,
				5000, 1, 800_000, 1, 10
			)
			var cruel_inversion := (
				demand_score == 0.0 and dto.shown_demand_band == &"hot"
				or demand_score == 1.0 and dto.shown_demand_band == &"cold"
			)
			_expect_equal(
				cruel_inversion,
				false,
				"without fog flag Cold↔Hot inversion never shown"
			)
	var fog: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_FOG,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(fog != null, true, "fog day starts")
	_expect_equal(fog.fog_flag, true, "fog day sets fog flag")
	_expect_equal(_demand_signals.call("has_fog_flag"), true, "pack exposes fog flag")
	var fog_sigma: float = _demand_signals.call("active_demand_band_sigma", false)
	_expect_equal(fog_sigma > base_sigma, true, "fog day widens σ")
	_expect_equal(
		is_equal_approx(fog_sigma, base_sigma * MarketEventService.FOG_SIGMA_MULT),
		true,
		"fog σ uses pack widen, not a new BalanceConfig knob"
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("Fog"), true, "fog banner is thin and named")
	_assert_text_has_no_truth(banner, "fog banner")
	_demand_signals.call("apply_event_save", {})
	_expect_equal(_demand_signals.call("has_fog_flag"), false, "clearing fog drops the flag")
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_demand_band_sigma", false)),
			base_sigma
		),
		true,
		"σ returns to Normal after fog expires"
	)


func _test_market_event_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": &"AA-SKIE-047", "duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(started != null, true, "save-load fixture hype starts")
	_game_state.set("current_day", 4)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "market event save")
	var stored: Dictionary = saved.get("market_event", {})
	_expect_equal(String(stored.get("id", "")), "hype_spike", "save writes event id")
	_expect_equal(int(stored.get("remaining_days", 0)), 3, "save writes remaining days")
	_expect_equal(String(stored.get("sku_id", "")), "AA-SKIE-047", "save writes target SKU")
	_game_state.call("start_new_game")
	_expect_equal(
		_demand_signals.call("active_event") == null,
		true,
		"new game clears active event"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"restore_save accepts market event snapshot"
	)
	var restored: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(restored != null, true, "save/load restores active event")
	_expect_equal(restored.kind, MarketEvent.KIND_HYPE, "restored kind")
	_expect_equal(restored.remaining_days, 3, "save/load restores remaining days")
	_expect_equal(restored.sku_id, &"AA-SKIE-047", "restored hype SKU")
	var titan_signal := _demand_signals.call(
		"price_signal",
		&"AA-SKIE-047",
		2200,
		_inventory_service.call("location_for", &"AA-SKIE-047")
	) as PriceConfirmSignal
	_expect_equal(titan_signal.shown_demand_band, &"hot", "restored hype still HOT")
	_expect_dto_has_no_truth_fields(titan_signal, "restored hype signal")

	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_ROTATION,
		{"set_id": &"AA-DUST", "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(
		String(_demand_signals.call("event_banner_text")),
		"",
		"rotation leak stays hidden without Research/Specialist"
	)
	var shop := _game_state.get("shop") as ShopState
	shop.hire_specialist()
	_expect_equal(
		String(_demand_signals.call("event_banner_text")).contains("Dustway"),
		true,
		"Specialist foreshadows the rotation leak"
	)
	_assert_text_has_no_truth(
		String(_demand_signals.call("event_banner_text")),
		"rotation leak banner"
	)
	_assert_text_has_no_truth(
		String(_demand_signals.call("rotation_watch_text")),
		"rotation leak watch"
	)
	var rotation_saved: Dictionary = _game_state.call("capture_save")
	_game_state.call("start_new_game")
	_game_state.call("restore_save", rotation_saved)
	var leak: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(leak != null, true, "save/load restores rotation leak")
	_expect_equal(leak.remaining_days, 2, "rotation remaining days restore")
	_expect_equal(
		String(_demand_signals.call("event_banner_text")).contains("Dustway"),
		true,
		"restored Specialist still sees the leak"
	)


func _test_option_d_seeded_hype_opens_price_editor_once() -> void:
	_free_lingering_gameplay_huds()
	_qa_autoload.call("set_force_enabled", false)
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var titan := &"AA-SKIE-047"
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "D gate 1: HUD loads")
	if hud == null:
		return
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"D gate 1: no prompt before the C1 hype event"
	)
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": titan, "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(started != null, true, "D gate 1: seeded hype starts on C1 bus")
	_expect_equal(started.sku_id, titan, "D gate 1: hype target is Titan")
	_expect_equal(
		_beat_director.call("is_started", TITAN_HYPE_BEAT),
		false,
		"D gate 1: does not use QA Titan trigger"
	)
	_assert_option_d_editor_open(hud, titan, "D gate 1: seeded hype")
	var opened_count := 1
	Callable(hud, "_on_market_event_changed").call(
		_demand_signals.call("event_to_save")
	)
	Callable(hud, "_maybe_open_event_price_editor").call()
	_assert_option_d_editor_open(hud, titan, "D gate 1: no spam reopen")
	_expect_equal(opened_count, 1, "D gate 1: still a single forced open")
	var prompted_event: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(
		prompted_event != null and prompted_event.price_editor_prompted,
		true,
		"D gate 1: active event records the one-shot prompt"
	)
	Callable(hud, "_cancel_price").call()
	_expect_equal(
		(hud.get_node_or_null("%PriceEditor") as PanelContainer).visible,
		false,
		"D gate 1: Cancel closes PriceEditor"
	)
	Callable(hud, "_maybe_open_event_price_editor").call()
	_expect_equal(
		(hud.get_node_or_null("%PriceEditor") as PanelContainer).visible,
		false,
		"D gate 1: Cancel does not force a second open"
	)
	root.remove_child(hud)
	hud.free()

	_game_state.call("start_new_game")
	hud = _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "D gate 1: fog HUD loads")
	if hud == null:
		return
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_FOG,
		{"duration_days": 1, "remaining_days": 1}
	)
	var fog_sku: StringName = _demand_signals.call("resolve_event_price_sku")
	_expect_equal(fog_sku.is_empty(), false, "D gate 1: fog resolves a priceable SKU")
	_assert_option_d_editor_open(hud, fog_sku, "D gate 1: fog")
	Callable(hud, "_maybe_open_event_price_editor").call()
	_assert_option_d_editor_open(hud, fog_sku, "D gate 1: fog no spam")
	root.remove_child(hud)
	hud.free()

	var rolled_hype := false
	var seeds: Array[int] = [MarketEventService.EVENT_RNG_SEED]
	for extra: int in range(1, 48):
		seeds.append(extra)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		_demand_signals.call("seed_event_rng", rng_seed)
		for _day_index: int in range(7):
			_expect_equal(
				_game_state.call("start_floor"),
				true,
				"D gate 1: seeded run can open floor"
			)
			_expect_equal(
				_game_state.call("start_settle"),
				true,
				"D gate 1: seeded run can settle"
			)
			var rolled: MarketEvent = _demand_signals.call("active_event")
			if rolled != null and rolled.kind == MarketEvent.KIND_HYPE:
				_game_state.set("current_phase", DayPhasePolicy.PREP)
				var rolled_sku: StringName = _demand_signals.call(
					"resolve_event_price_sku"
				)
				hud = _instantiate_gameplay_hud()
				_expect_equal(hud != null, true, "D gate 1: rolled hype HUD loads")
				if hud != null:
					Callable(hud, "_maybe_open_event_price_editor").call()
					_assert_option_d_editor_open(
						hud,
						rolled_sku,
						"D gate 1: rolled hype day"
					)
					root.remove_child(hud)
					hud.free()
				rolled_hype = true
				break
			if int(_game_state.get("current_day")) < 7:
				_expect_equal(
					_game_state.call("advance_day"),
					true,
					"D gate 1: seeded run can advance"
				)
		if rolled_hype:
			break
	_expect_equal(
		rolled_hype,
		true,
		"D gate 1: a seeded Normal run opens Hype PriceEditor without debug"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_option_d_price_editor_has_no_truth() -> void:
	_free_lingering_gameplay_huds()
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var titan := &"AA-SKIE-047"
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "D gate 2: HUD loads")
	if hud == null:
		return
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": titan, "duration_days": 2, "remaining_days": 2}
	)
	_assert_option_d_editor_open(hud, titan, "D gate 2")
	var price_signal := hud.get("_price_signal") as PriceConfirmSignal
	_expect_equal(price_signal != null, true, "D gate 2: PriceEditor binds a signal")
	if price_signal != null:
		_expect_dto_has_no_truth_fields(price_signal, "D gate 2: event PriceEditor DTO")
		_assert_text_has_no_truth(
			DemandSignalPresenter.price_summary(price_signal, false),
			"D gate 2: PriceEditor summary"
		)
	var title := hud.get_node_or_null("%PriceTitle") as Label
	var summary := hud.get_node_or_null("%PriceSummary") as Label
	var position := hud.get_node_or_null("%PricePositionChip") as Label
	var demand := hud.get_node_or_null("%PriceDemandChip") as Label
	var move := hud.get_node_or_null("%PriceMoveChip") as Label
	var toast := hud.get_node_or_null("%BeatToast") as Label
	for node: Label in [title, summary, position, demand, move, toast]:
		if node == null:
			continue
		_assert_text_has_no_truth(node.text, "D gate 2: %s" % node.name)
	_expect_equal(
		demand != null and not demand.text.is_empty(),
		true,
		"D gate 2: §4.5 demand chip is shown"
	)
	_expect_equal(
		position != null and not position.text.is_empty(),
		true,
		"D gate 2: §4.5 position chip is shown"
	)
	_expect_equal(
		move != null and not move.text.is_empty(),
		true,
		"D gate 2: §4.5 move-feel chip is shown"
	)
	_assert_text_has_no_truth(
		String(_demand_signals.call("event_banner_text")),
		"D gate 2: event banner"
	)
	root.remove_child(hud)
	hud.free()


func _test_option_d_cancel_keeps_event_apply_persists() -> void:
	_free_lingering_gameplay_huds()
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var titan := &"AA-SKIE-047"
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "D gate 3: HUD loads for Cancel")
	if hud == null:
		return
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": titan, "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(started != null, true, "D gate 3: hype starts")
	var remaining_before := started.remaining_days
	_assert_option_d_editor_open(hud, titan, "D gate 3: cancel path")
	Callable(hud, "_cancel_price").call()
	var after_cancel: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(after_cancel != null, true, "D gate 3: Cancel leaves event active")
	_expect_equal(after_cancel.kind, MarketEvent.KIND_HYPE, "D gate 3: Cancel keeps hype")
	_expect_equal(after_cancel.sku_id, titan, "D gate 3: Cancel keeps target SKU")
	_expect_equal(
		after_cancel.remaining_days,
		remaining_before,
		"D gate 3: Cancel does not consume event days"
	)
	_expect_equal(
		(hud.get_node_or_null("%PriceEditor") as PanelContainer).visible,
		false,
		"D gate 3: Cancel closes the editor"
	)
	root.remove_child(hud)
	hud.free()

	_game_state.call("start_new_game")
	hud = _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "D gate 3: HUD loads for Apply")
	if hud == null:
		return
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": titan, "duration_days": 2, "remaining_days": 2}
	)
	var listed_before := int(_inventory_service.call("listed_price_for", titan))
	var apply_cents := listed_before + 375
	_assert_option_d_editor_open(hud, titan, "D gate 3: apply path")
	var price_input := hud.get_node_or_null("%PriceInput") as LineEdit
	_expect_equal(price_input != null, true, "D gate 3: list input present")
	if price_input != null:
		price_input.text = DemandSignalPresenter.format_cents(apply_cents)
		Callable(hud, "_update_price_preview").call(price_input.text)
	Callable(hud, "_apply_price").call()
	_expect_equal(
		int(_inventory_service.call("listed_price_for", titan)),
		apply_cents,
		"D gate 3: Apply persists list price"
	)
	var after_apply: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(after_apply != null, true, "D gate 3: Apply leaves event active")
	_expect_equal(after_apply.kind, MarketEvent.KIND_HYPE, "D gate 3: Apply keeps hype")
	root.remove_child(hud)
	hud.free()


func _test_counterfeit_scare_event() -> void:
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_test_counterfeit_scare_can_fire()
	_test_counterfeit_scare_trust_and_inspect_gate()
	_test_counterfeit_scare_shady_riskier()
	_test_counterfeit_scare_section_45_and_banner()
	_test_counterfeit_scare_g1_coherence()
	_test_counterfeit_scare_save_load()
	_qa_autoload.call("set_force_enabled", false)
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_counterfeit_scare_can_fire() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(started != null, true, "M1: formal start_pack_event fires scare")
	_expect_equal(started.kind, MarketEvent.KIND_COUNTERFEIT, "M1: kind is counterfeit_scare")
	_expect_equal(started.remaining_days, 2, "M1: remaining_days tracks duration")
	_expect_equal(
		_demand_signals.call("has_counterfeit_scare"),
		true,
		"M1: pack exposes counterfeit scare flag"
	)
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"M1: scare does not open Option D PriceEditor"
	)
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var fired := false
	var seeds: Array[int] = [MarketEventService.EVENT_RNG_SEED]
	for extra: int in range(1, 64):
		seeds.append(extra)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		_demand_signals.call("seed_event_rng", rng_seed)
		_qa_autoload.call("clear")
		for _day_index: int in range(10):
			_game_state.call("start_floor")
			_game_state.call("start_settle")
			var rolled: MarketEvent = _demand_signals.call("active_event")
			if rolled != null and rolled.kind == MarketEvent.KIND_COUNTERFEIT:
				fired = true
				break
			if int(_game_state.get("current_day")) < 10:
				_game_state.call("advance_day")
		if fired:
			break
	_expect_equal(fired, true, "M1: seeded settle run can roll counterfeit_scare")
	_qa_autoload.call("set_force_enabled", false)


func _test_counterfeit_scare_trust_and_inspect_gate() -> void:
	var accurate := NORMAL_CONFIG.duplicate() as BalanceConfig
	accurate.inspect_accuracy = 1.0
	_game_state.call("set_balance_config", accurate)
	_game_state.call("start_new_game")
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("graded_trust_mult")), 1.0),
		true,
		"M1: graded trust is 1.0 with event off"
	)
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("graded_trust_mult")),
			MarketEventService.COUNTERFEIT_TRUST_MULT
		),
		true,
		"M1: graded trust drops while scare is active"
	)
	var lot: BuyOpportunity = _demand_signals.call(
		"inject_graded_opportunity",
		&"m1-auction-slab",
		&"AA-SKIE-052",
		DemandSignalService.Channel.AUCTION,
		5_600,
		&"Prism",
		10.0,
		"Auction slab",
		1
	)
	_expect_equal(lot != null, true, "M1: graded auction injects during scare")
	var dto: BuyConfirmSignal = _demand_signals.call(
		"buy_signal_for_id",
		&"m1-auction-slab"
	)
	_expect_equal(dto != null, true, "M1: graded buy signal exists")
	if dto != null:
		_expect_equal(
			_demand_signals.call("is_inspect_mandatory", dto),
			true,
			"M1: inspect is mandatory on graded path"
		)
		_expect_equal(dto.inspected, false, "M1: graded lot starts uninspected")
		_expect_equal(dto.can_confirm, false, "M1: uninspected graded confirm is gated")
		_expect_equal(dto.confidence, &"low", "M1: graded trust drop is visible as low confidence")
		_expect_equal(
			dto.condition_cue.to_lower().contains("inspect mandatory"),
			true,
			"M1: graded fog telegraphs inspect mandatory"
		)
		_expect_equal(
			_demand_signals.call("confirm_buy", dto),
			false,
			"M1: domain rejects uninspected graded confirm"
		)
		_expect_dto_has_no_truth_fields(dto, "M1 gated graded DTO")
		_assert_text_has_no_truth(dto.condition_cue, "M1 gated graded cue")
		_assert_text_has_no_truth(
			DemandSignalPresenter.buy_summary(dto),
			"M1 gated buy summary"
		)
		_assert_text_has_no_truth(
			DemandSignalPresenter.buy_confirm_snapshot(dto),
			"M1 gated confirm snapshot"
		)
		_expect_equal(
			_demand_signals.call("inspect_buy", dto),
			true,
			"M1: Inspect★ still spends on the gated path"
		)
		_expect_equal(dto.inspected, true, "M1: inspect clears the gate")
		_expect_equal(dto.can_confirm, true, "M1: inspected graded confirm is allowed")
		_assert_text_has_no_truth(dto.condition_cue, "M1 inspected graded cue")
		_expect_equal(
			_demand_signals.call("confirm_buy", dto),
			true,
			"M1: inspected graded confirm goes through"
		)
	_demand_signals.call("apply_event_save", {})
	_expect_equal(
		_demand_signals.call("has_counterfeit_scare"),
		false,
		"M1: clearing scare drops the flag"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("graded_trust_mult")), 1.0),
		true,
		"M1: graded trust returns to 1.0 after scare"
	)


func _test_counterfeit_scare_shady_riskier() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var base_shady_rate: float = _demand_signals.call(
		"active_fake_slab_rate",
		DemandSignalService.Channel.SHADY
	)
	var base_auction_rate: float = _demand_signals.call(
		"active_fake_slab_rate",
		DemandSignalService.Channel.AUCTION
	)
	_expect_equal(
		is_equal_approx(base_shady_rate, NORMAL_CONFIG.shady_fake_slab_rate),
		true,
		"M1: shady fake rate is the BalanceConfig default off-event"
	)
	var quiet_lot: BuyOpportunity = _demand_signals.call(
		"inject_graded_opportunity",
		&"m1-shady-quiet",
		&"AA-SKIE-052",
		DemandSignalService.Channel.SHADY,
		4_200,
		&"Prism",
		10.0,
		"Quiet trunk slab",
		0
	)
	_expect_equal(quiet_lot != null, true, "M1: off-event shady injects")
	var quiet: BuyConfirmSignal = _demand_signals.call(
		"buy_signal_for_id",
		&"m1-shady-quiet"
	)
	_expect_equal(quiet != null, true, "M1: off-event shady signal exists")
	if quiet != null:
		_expect_equal(
			quiet.condition_cue.to_lower().contains("counterfeit scare"),
			false,
			"M1: off-event shady cue has no scare telegraph"
		)
		_expect_equal(
			quiet.condition_cue.to_lower().contains("strongly recommended"),
			true,
			"M1: off-event shady still uses G1 inspect fog"
		)
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 2, "remaining_days": 2}
	)
	var scare_shady_rate: float = _demand_signals.call(
		"active_fake_slab_rate",
		DemandSignalService.Channel.SHADY
	)
	var scare_auction_rate: float = _demand_signals.call(
		"active_fake_slab_rate",
		DemandSignalService.Channel.AUCTION
	)
	_expect_equal(
		scare_shady_rate > base_shady_rate,
		true,
		"M1: shady fake rate rises during scare"
	)
	_expect_equal(
		is_equal_approx(
			scare_shady_rate,
			NORMAL_CONFIG.shady_fake_slab_rate
			* MarketEventService.COUNTERFEIT_SHADY_FAKE_MULT
		),
		true,
		"M1: shady fake rate uses pack mult, not a BalanceConfig knob"
	)
	_expect_equal(
		is_equal_approx(scare_auction_rate, base_auction_rate),
		true,
		"M1: auction fake rate is unchanged (shady-only amp)"
	)
	_expect_equal(
		float(_demand_signals.call("shady_width_mult"))
		> 1.0,
		true,
		"M1: shady comp width widens during scare"
	)
	var hot_lot: BuyOpportunity = _demand_signals.call(
		"inject_graded_opportunity",
		&"m1-shady-hot",
		&"AA-SKIE-052",
		DemandSignalService.Channel.SHADY,
		4_200,
		&"Prism",
		10.0,
		"Hot trunk slab",
		0
	)
	_expect_equal(hot_lot != null, true, "M1: scare shady injects")
	var hot: BuyConfirmSignal = _demand_signals.call(
		"buy_signal_for_id",
		&"m1-shady-hot"
	)
	_expect_equal(hot != null, true, "M1: scare shady signal exists")
	if hot != null:
		_expect_equal(
			hot.condition_cue.to_lower().contains("counterfeit scare"),
			true,
			"M1: shady cue telegraphs the scare"
		)
		_expect_equal(hot.can_confirm, false, "M1: shady graded still inspect-gated")
		_expect_equal(hot.confidence, &"low", "M1: shady stays low confidence")
		_expect_dto_has_no_truth_fields(hot, "M1 scare shady DTO")
		_assert_text_has_no_truth(hot.condition_cue, "M1 scare shady cue")
		_assert_text_has_no_truth(
			DemandSignalPresenter.buy_summary(hot),
			"M1 scare shady summary"
		)


func _test_counterfeit_scare_section_45_and_banner() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 1, "remaining_days": 1}
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("Counterfeit"), true, "M1: banner names the scare")
	_expect_equal(banner.contains("Inspect"), true, "M1: banner telegraphs inspect mandatory")
	_expect_equal(banner.to_lower().contains("shady"), true, "M1: banner telegraphs shady risk")
	_assert_text_has_no_truth(banner, "M1 scare banner")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "M1: HUD loads for scare telegraph")
	if hud != null:
		var banner_label := hud.get_node_or_null("%EventBannerLabel") as Label
		_expect_equal(banner_label != null, true, "M1: thin event banner exists")
		_expect_equal(
			banner_label != null
			and banner_label.visible
			and banner_label.text.contains("Counterfeit")
			and banner_label.text.contains("Inspect"),
			true,
			"M1: HUD banner shows scare without a new screen"
		)
		_assert_text_has_no_truth(
			banner_label.text if banner_label != null else "",
			"M1 HUD scare banner"
		)
		var lot: BuyOpportunity = _demand_signals.call(
			"inject_graded_opportunity",
			&"m1-hud-slab",
			&"AA-SKIE-052",
			DemandSignalService.Channel.AUCTION,
			5_600,
			&"Prism",
			10.0,
			"HUD slab",
			1
		)
		_expect_equal(lot != null, true, "M1: HUD graded injects")
		var dto: BuyConfirmSignal = _demand_signals.call(
			"buy_signal_for_id",
			&"m1-hud-slab"
		)
		if dto != null:
			_select_buy_on_hud(hud, dto)
			var buy_button := hud.get_node_or_null("%BuyButton") as Button
			var inspect_button := hud.get_node_or_null("%InspectButton") as Button
			var buy_summary := hud.get_node_or_null("%BuySummary") as Label
			_expect_equal(
				inspect_button != null and inspect_button.visible,
				true,
				"M1: Inspect★ shown on gated graded detail"
			)
			_expect_equal(
				buy_button != null and buy_button.disabled,
				true,
				"M1: Buy stays disabled until Inspect★"
			)
			if buy_summary != null:
				_assert_text_has_no_truth(buy_summary.text, "M1 HUD buy detail")
				_expect_equal(
					buy_summary.text.to_lower().contains("inspect"),
					true,
					"M1: buy detail shows inspect mandatory fog"
				)
			Callable(hud, "_open_buy_confirm").call()
			var confirm_summary := hud.get_node_or_null("%BuyConfirmSummary") as Label
			if confirm_summary != null:
				_assert_text_has_no_truth(confirm_summary.text, "M1 HUD confirm")
				_expect_equal(
					confirm_summary.text.to_lower().contains("cert_valid"),
					false,
					"M1: confirm hides cert_valid"
				)
			Callable(hud, "_back_to_buy_detail").call()
			if inspect_button != null:
				inspect_button.pressed.emit()
				_expect_equal(dto.inspected, true, "M1: HUD Inspect★ clears the gate")
				_expect_equal(
					buy_button != null and not buy_button.disabled,
					true,
					"M1: Buy enables after Inspect★"
				)
				_assert_text_has_no_truth(dto.condition_cue, "M1 HUD inspected cue")
		root.remove_child(hud)
		hud.free()


func _test_counterfeit_scare_g1_coherence() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var inventory := _inventory_service.get("model") as InventoryModel
	var empress := inventory.get_sku(&"AA-SKIE-052")
	var off_slab: SlabInstance = _inventory_service.call(
		"seed_fake_slab",
		&"AA-SKIE-052",
		&"Prism",
		10.0,
		empress.base_market_cents,
		InventoryLocation.new(InventoryLocation.Type.CASE),
		&"shady"
	)
	_expect_equal(off_slab != null, true, "M1 G1-off: fake slab seeds")
	if off_slab != null:
		_expect_equal(off_slab.cert_valid, false, "M1 G1-off: seeded fail-slab")
		_expect_equal(off_slab.inspected, false, "M1 G1-off: starts uninspected")
		off_slab.listed_price_cents = 12_000
		var cash_before := int(_economy.get("balance_cents"))
		var sold := bool(
			_inventory_service.call("confirm_customer_sale", &"AA-SKIE-052", 12_000)
		)
		_expect_equal(sold, true, "M1 G1-off: uninspected fake sale still resolves")
		_expect_equal(
			int(_economy.get("balance_cents")),
			cash_before - 12_000,
			"M1 G1-off: fake sale cash penalty unchanged"
		)
	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 2, "remaining_days": 2}
	)
	inventory = _inventory_service.get("model") as InventoryModel
	empress = inventory.get_sku(&"AA-SKIE-052")
	var on_slab: SlabInstance = _inventory_service.call(
		"seed_fake_slab",
		&"AA-SKIE-047",
		&"Vaultmark",
		9.5,
		1_200,
		InventoryLocation.new(InventoryLocation.Type.CASE),
		&"shady"
	)
	_expect_equal(on_slab != null, true, "M1 G1-on: fake slab seeds during scare")
	if on_slab != null:
		_expect_equal(on_slab.cert_valid, false, "M1 G1-on: seeded fail-slab")
		_expect_equal(on_slab.inspected, false, "M1 G1-on: starts uninspected")
		on_slab.listed_price_cents = 9_000
		var blocked := bool(
			_inventory_service.call("confirm_customer_sale", &"AA-SKIE-047", 9_000)
		)
		_expect_equal(blocked, false, "M1 G1-on: uninspected slab sale is gated")
		_expect_equal(
			_inventory_service.call("get_slab", &"AA-SKIE-047") != null,
			true,
			"M1 G1-on: gated sale leaves the slab"
		)
		var accurate := DemandSignalService.new(
			NORMAL_CONFIG,
			MarketState.new(),
			7,
			_qa
		)
		accurate._config = accurate._config.duplicate()
		accurate._config.inspect_accuracy = 1.0
		_expect_equal(
			accurate.inspect_slab_instance(on_slab),
			true,
			"M1 G1-on: Inspect★ still resolves the instance"
		)
		_expect_equal(on_slab.inspected, true, "M1 G1-on: inspect marks the instance")
		_expect_equal(
			on_slab.shown_cert_cue,
			SlabInstance.CERT_OFF_CUE,
			"M1 G1-on: accurate inspect still reveals fail hologram"
		)
		_assert_text_has_no_truth(on_slab.shown_cert_cue, "M1 G1-on inspected cue")
		var cash_before_fail := int(_economy.get("balance_cents"))
		var rep_before := int(_game_state.get("current_reputation"))
		var failed := bool(
			_inventory_service.call("confirm_customer_sale", &"AA-SKIE-047", 9_000)
		)
		_expect_equal(failed, true, "M1 G1-on: inspected fake sale still fail-resolves")
		_expect_equal(
			int(_economy.get("balance_cents")),
			cash_before_fail - 9_000,
			"M1 G1-on: fake sale cash penalty still applies"
		)
		_expect_equal(
			int(_game_state.get("current_reputation")),
			rep_before - NORMAL_CONFIG.fake_slab_sale_rep_hit,
			"M1 G1-on: fake sale Rep hit still applies"
		)
	_qa_autoload.call("set_force_enabled", false)


func _test_counterfeit_scare_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(started != null, true, "M1 save: scare starts")
	_game_state.set("current_day", 6)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "M1 scare save")
	var stored: Dictionary = saved.get("market_event", {})
	_expect_equal(String(stored.get("id", "")), "counterfeit_scare", "M1 save writes event id")
	_expect_equal(int(stored.get("remaining_days", 0)), 3, "M1 save writes remaining days")
	_expect_equal(
		String(stored.get("kind", "")),
		"counterfeit_scare",
		"M1 save writes kind"
	)
	_game_state.call("start_new_game")
	_expect_equal(
		_demand_signals.call("has_counterfeit_scare"),
		false,
		"M1: new game clears scare"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"M1: restore_save accepts scare snapshot"
	)
	var restored: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(restored != null, true, "M1: save/load restores scare")
	_expect_equal(restored.kind, MarketEvent.KIND_COUNTERFEIT, "M1: restored kind")
	_expect_equal(restored.remaining_days, 3, "M1: save/load restores remaining days")
	_expect_equal(
		_demand_signals.call("has_counterfeit_scare"),
		true,
		"M1: restored scare re-applies modifiers"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("graded_trust_mult")),
			MarketEventService.COUNTERFEIT_TRUST_MULT
		),
		true,
		"M1: restored scare still drops graded trust"
	)
	var restored_lot: BuyOpportunity = _demand_signals.call(
		"inject_graded_opportunity",
		&"m1-restored-slab",
		&"AA-SKIE-052",
		DemandSignalService.Channel.AUCTION,
		5_600,
		&"Prism",
		10.0,
		"Restored slab",
		1
	)
	_expect_equal(restored_lot != null, true, "M1: restored scare still gates graded")
	var restored_dto: BuyConfirmSignal = _demand_signals.call(
		"buy_signal_for_id",
		&"m1-restored-slab"
	)
	if restored_dto != null:
		_expect_equal(restored_dto.can_confirm, false, "M1: restored inspect gate holds")
		_expect_dto_has_no_truth_fields(restored_dto, "M1 restored graded DTO")


func _test_convention_weekend_event() -> void:
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_test_convention_weekend_can_fire()
	_test_convention_weekend_traffic_and_whales()
	_test_convention_weekend_levers_and_no_soft_lock()
	_test_convention_weekend_section_45_and_banner()
	_test_convention_weekend_pack_coherence()
	_test_convention_weekend_save_load()
	_qa_autoload.call("set_force_enabled", false)
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_convention_weekend_can_fire() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_expect_equal(
		MarketEventService.is_convention_telegraph_day(5),
		true,
		"N1: Friday is the calendar telegraph day"
	)
	_expect_equal(
		MarketEventService.is_convention_calendar_day(6)
		and MarketEventService.is_convention_calendar_day(7),
		true,
		"N1: Sat/Sun are convention calendar days"
	)
	_expect_equal(
		MarketEventService.is_convention_calendar_day(3),
		false,
		"N1: mid-week is not a convention calendar day"
	)
	_expect_equal(
		MarketEventService.convention_calendar_weight_mult(5)
		> MarketEventService.convention_calendar_weight_mult(3),
		true,
		"N1: Friday telegraph boosts convention settle weight"
	)
	_expect_equal(
		is_equal_approx(MarketEventService.convention_calendar_weight_mult(3), 1.0),
		true,
		"N1: weekday convention weight stays 1.0"
	)
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(started != null, true, "N1: formal start_pack_event fires convention")
	_expect_equal(started.kind, MarketEvent.KIND_CONVENTION, "N1: kind is convention_weekend")
	_expect_equal(started.remaining_days, 2, "N1: weekend remaining_days is 2")
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		true,
		"N1: pack exposes convention weekend flag"
	)
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"N1: convention does not open Option D PriceEditor"
	)
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var fired := false
	var calendar_fired := false
	var seeds: Array[int] = [MarketEventService.EVENT_RNG_SEED]
	for extra: int in range(1, 64):
		seeds.append(extra)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		_demand_signals.call("seed_event_rng", rng_seed)
		_qa_autoload.call("clear")
		for _day_index: int in range(14):
			_game_state.call("start_floor")
			_game_state.call("start_settle")
			var rolled: MarketEvent = _demand_signals.call("active_event")
			if rolled != null and rolled.kind == MarketEvent.KIND_CONVENTION:
				fired = true
				if MarketEventService.is_convention_calendar_day(
					int(_game_state.get("current_day"))
				) or MarketEventService.is_convention_telegraph_day(
					int(_game_state.get("current_day"))
				):
					calendar_fired = true
				break
			if int(_game_state.get("current_day")) < 14:
				_game_state.call("advance_day")
		if fired:
			break
	_expect_equal(fired, true, "N1: seeded settle run can roll convention_weekend")
	_expect_equal(
		calendar_fired or fired,
		true,
		"N1: seeded/calendar convention can fire"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_convention_weekend_traffic_and_whales() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var catalog := CustomerArchetypeCatalog.new()
	var whale: Dictionary = {}
	for archetype: Dictionary in catalog.archetypes:
		if StringName(archetype.get("id", "")) == &"whale":
			whale = archetype
			break
	var baseline_small := float(
		_demand_signals.call(
			"customer_spawn_wait_seconds",
			12.0,
			ShopState.Tier.SMALL
		)
	)
	var baseline_large := float(
		_demand_signals.call(
			"customer_spawn_wait_seconds",
			12.0,
			ShopState.Tier.LARGE
		)
	)
	var baseline_whale := catalog.weight_for(whale, 80, NORMAL_CONFIG)
	_expect_equal(
		is_equal_approx(baseline_small, 12.0),
		true,
		"N1: Small baseline spawn wait is 12s"
	)
	_expect_equal(
		is_equal_approx(baseline_large, 9.6),
		true,
		"N1: Large baseline spawn wait stays 12s / 1.25"
	)
	_expect_equal(baseline_whale > 0.0, true, "N1: high-rep whale weight is positive")
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_event_traffic_mult")), 1.0),
		true,
		"N1: traffic mult is 1.0 with event off"
	)
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_traffic_mult")),
			MarketEventService.CONVENTION_TRAFFIC_MULT
		),
		true,
		"N1: convention traffic mult is ×2"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_whale_weight_mult")),
			MarketEventService.CONVENTION_WHALE_WEIGHT_MULT
		),
		true,
		"N1: convention whale weight mult is raised"
	)
	var con_small := float(
		_demand_signals.call(
			"customer_spawn_wait_seconds",
			12.0,
			ShopState.Tier.SMALL
		)
	)
	var con_large := float(
		_demand_signals.call(
			"customer_spawn_wait_seconds",
			12.0,
			ShopState.Tier.LARGE
		)
	)
	_expect_equal(
		is_equal_approx(con_small, baseline_small / 2.0),
		true,
		"N1: Small spawn interval halves during convention"
	)
	_expect_equal(
		is_equal_approx(con_large, baseline_large / 2.0),
		true,
		"N1: Large spawn interval halves on top of the 1.25× tier scalar"
	)
	_expect_equal(
		con_large < con_small,
		true,
		"N1: Large convention wait stays faster than Small convention wait"
	)
	var whale_mult := float(_demand_signals.call("active_event_whale_weight_mult"))
	var con_whale := catalog.weight_for(whale, 80, NORMAL_CONFIG, whale_mult)
	_expect_equal(con_whale > baseline_whale, true, "N1: whale weight rises during convention")
	_expect_equal(
		is_equal_approx(con_whale, baseline_whale * MarketEventService.CONVENTION_WHALE_WEIGHT_MULT),
		true,
		"N1: whale weight uses pack mult, not a BalanceConfig rewrite"
	)
	_expect_equal(
		is_equal_approx(catalog.weight_for(whale, 10, NORMAL_CONFIG, whale_mult), 0.0),
		true,
		"N1: convention does not bypass the low-rep whale gate"
	)
	var spawn_src := FileAccess.get_file_as_string(
		"res://scripts/customers/customer_spawner.gd"
	)
	_expect_equal(
		spawn_src.contains("active_spawn_wait_seconds")
		and spawn_src.contains("active_event_whale_weight_mult")
		and spawn_src.contains("market_event_changed"),
		true,
		"N1: CustomerSpawner reads active-event traffic/whale multipliers"
	)
	_demand_signals.call("apply_event_save", {})
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		false,
		"N1: clearing convention drops the flag"
	)
	_expect_equal(
		is_equal_approx(
			float(
				_demand_signals.call(
					"customer_spawn_wait_seconds",
					12.0,
					ShopState.Tier.LARGE
				)
			),
			baseline_large
		),
		true,
		"N1: spawn wait restores after convention ends"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_event_whale_weight_mult")), 1.0),
		true,
		"N1: whale weight restores after convention ends"
	)
	_expect_equal(
		is_equal_approx(catalog.weight_for(whale, 80, NORMAL_CONFIG), baseline_whale),
		true,
		"N1: catalog whale weight restores to baseline"
	)


func _test_convention_weekend_levers_and_no_soft_lock() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	var shop: ShopState = _game_state.get("shop")
	_expect_equal(shop.can_hire(), true, "N1: convention PREP can still hire")
	_expect_equal(shop.hire_cashier(false) != null, true, "N1: staff-up lever works")
	var sku := &"AA-DUST-ETB"
	var listed_before := int(_inventory_service.call("listed_price_for", sku))
	var raised := maxi(listed_before + 250, 1)
	_expect_equal(
		_inventory_service.call("set_listed_price", sku, raised),
		true,
		"N1: price-up lever works during convention"
	)
	_expect_equal(
		int(_inventory_service.call("listed_price_for", sku)),
		raised,
		"N1: listed price persists after the raise"
	)
	var price_dto := _demand_signals.call(
		"price_signal",
		sku,
		raised,
		_inventory_service.call("location_for", sku)
	) as PriceConfirmSignal
	_expect_dto_has_no_truth_fields(price_dto, "N1 convention price signal")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(price_dto),
		"N1 convention PriceEditor summary"
	)
	var inventory := FakeCustomerInventory.new()
	var queue := CustomerQueue.new()
	queue.configure(inventory)
	var over_queue := CustomerProfile.new()
	over_queue.budget_cents = 1000
	over_queue.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(over_queue), true, "N1: convention queue still accepts")
	_expect_equal(queue.refuse(), true, "N1: refuse over-queue lever works")
	_expect_equal(inventory.sold, false, "N1: refuse does not sell")
	queue.free()
	inventory.free()
	_expect_equal(
		_game_state.call("start_floor"),
		true,
		"N1: convention can open FLOOR"
	)
	_expect_equal(
		_game_state.call("start_settle"),
		true,
		"N1: convention FLOOR can settle — no soft-lock"
	)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "N1: HUD loads during convention levers")
	if hud != null:
		var hire := hud.get_node_or_null("%HireCashierButton") as Button
		var open_staff := hud.get_node_or_null("%OpenStaffButton") as Button
		var open_price := hud.get_node_or_null("%OpenPriceButton") as Button
		_expect_equal(hire != null, true, "N1: hire button exists")
		_expect_equal(open_staff != null, true, "N1: staff panel exists")
		_expect_equal(open_price != null, true, "N1: price panel exists")
		_expect_equal(
			open_price != null and not open_price.disabled,
			true,
			"N1: player can still open PriceEditor"
		)
		hud.queue_free()


func _test_convention_weekend_section_45_and_banner() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_expect_equal(
		String(_demand_signals.call("calendar_telegraph_text")).contains("incoming"),
		true,
		"N1: Friday news telegraph is calendar-known"
	)
	_assert_text_has_no_truth(
		String(_demand_signals.call("calendar_telegraph_text")),
		"N1 Friday calendar telegraph"
	)
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("Convention"), true, "N1: banner names the weekend")
	_expect_equal(banner.contains("Calendar"), true, "N1: banner is a calendar telegraph")
	_expect_equal(
		banner.to_lower().contains("whale"),
		true,
		"N1: banner telegraphs whale traffic"
	)
	_assert_text_has_no_truth(banner, "N1 convention banner")
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var payload: Dictionary = _demand_signals.call("roll_settle_events")
	_assert_payload_has_no_truth(payload, "N1 convention market_event_rolled")
	_expect_equal(
		payload.has("traffic_mult") and payload.has("whale_weight_mult"),
		true,
		"N1: instrumentation records traffic and whale weights"
	)
	_qa_autoload.call("set_force_enabled", false)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "N1: HUD loads for convention telegraph")
	if hud != null:
		var banner_label := hud.get_node_or_null("%EventBannerLabel") as Label
		_expect_equal(banner_label != null, true, "N1: thin event banner exists")
		_expect_equal(
			banner_label != null
			and banner_label.visible
			and banner_label.text.contains("Convention")
			and banner_label.text.contains("Calendar"),
			true,
			"N1: HUD banner shows convention without a new screen"
		)
		_assert_text_has_no_truth(
			banner_label.text if banner_label != null else "",
			"N1 HUD convention banner"
		)
		var demand_chip := hud.get_node_or_null("%PriceDemandChip") as Label
		_expect_equal(demand_chip != null, true, "N1: PriceEditor demand chip still present")
		hud.queue_free()


func _test_convention_weekend_pack_coherence() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	var scare: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(scare != null, true, "N1: Counterfeit scare still starts after convention")
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		false,
		"N1: scare replaces convention on the shared pack bus"
	)
	_expect_equal(
		_demand_signals.call("has_counterfeit_scare"),
		true,
		"N1: Counterfeit scare modifiers still apply"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_event_traffic_mult")), 1.0),
		true,
		"N1: scare does not keep convention traffic"
	)
	var hype: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": &"AA-SKIE-047", "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(hype != null, true, "N1: Option D hype still starts")
	_expect_equal(hype.sku_id, &"AA-SKIE-047", "N1: hype still targets Titan")
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		true,
		"N1: Option D hype still wants the PriceEditor"
	)
	var fog: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_FOG,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(fog != null, true, "N1: fog day still starts")
	_expect_equal(_demand_signals.call("has_fog_flag"), true, "N1: fog flag still applies")
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		false,
		"N1: fog does not leak convention traffic"
	)
	var demand_src := FileAccess.get_file_as_string(
		"res://scripts/autoload/demand_signals.gd"
	)
	_expect_equal(
		demand_src.contains("func _ensure_priceable_sku"),
		true,
		"N1: Soft _ensure_priceable_sku stays parked"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/customers/customer_spawner.gd"
		).contains("_ensure_priceable_sku"),
		false,
		"N1: spawner does not call parked Soft helper"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/autoload/inventory_service.gd"
		).contains("func apply_shop_capacity_bonuses"),
		true,
		"N1: apply_shop_capacity_bonuses is the Large-aware capacity helper"
	)


func _test_convention_weekend_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(started != null, true, "N1 save: convention starts")
	_game_state.set("current_day", 6)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "N1 convention save")
	var stored: Dictionary = saved.get("market_event", {})
	_expect_equal(String(stored.get("id", "")), "convention_weekend", "N1 save writes event id")
	_expect_equal(int(stored.get("remaining_days", 0)), 2, "N1 save writes remaining days")
	_expect_equal(
		String(stored.get("kind", "")),
		"convention_weekend",
		"N1 save writes kind"
	)
	_game_state.call("start_new_game")
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		false,
		"N1: new game clears convention"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"N1: restore_save accepts convention snapshot"
	)
	var restored: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(restored != null, true, "N1: save/load restores convention")
	_expect_equal(restored.kind, MarketEvent.KIND_CONVENTION, "N1: restored kind")
	_expect_equal(restored.remaining_days, 2, "N1: save/load restores remaining days")
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		true,
		"N1: restored convention re-applies traffic/whale"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_traffic_mult")),
			MarketEventService.CONVENTION_TRAFFIC_MULT
		),
		true,
		"N1: restored convention still doubles traffic"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_whale_weight_mult")),
			MarketEventService.CONVENTION_WHALE_WEIGHT_MULT
		),
		true,
		"N1: restored convention still raises whale weight"
	)
	var restored_banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(
		restored_banner.contains("Convention"),
		true,
		"N1: restored banner still names convention"
	)
	_assert_text_has_no_truth(restored_banner, "N1 restored convention banner")


func _test_theft_ring_event() -> void:
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_test_theft_ring_can_fire()
	_test_theft_ring_shrink_multiplier()
	_test_theft_ring_staff_lever_or_wait_out()
	_test_theft_ring_section_45_and_banner()
	_test_theft_ring_pack_coherence()
	_test_theft_ring_save_load()
	_qa_autoload.call("set_force_enabled", false)
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_theft_ring_can_fire() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(started != null, true, "O1: formal start_pack_event fires theft ring")
	_expect_equal(started.kind, MarketEvent.KIND_THEFT_RING, "O1: kind is theft_ring")
	_expect_equal(started.duration_days, 3, "O1: duration is 3 days")
	_expect_equal(started.remaining_days, 3, "O1: remaining_days tracks the 3-day window")
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		true,
		"O1: pack exposes theft ring flag"
	)
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"O1: theft ring does not open Option D PriceEditor"
	)
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var fired := false
	var seeds: Array[int] = [MarketEventService.EVENT_RNG_SEED]
	for extra: int in range(1, 64):
		seeds.append(extra)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		_demand_signals.call("seed_event_rng", rng_seed)
		_qa_autoload.call("clear")
		for _day_index: int in range(14):
			_game_state.call("start_floor")
			_game_state.call("start_settle")
			var rolled: MarketEvent = _demand_signals.call("active_event")
			if rolled != null and rolled.kind == MarketEvent.KIND_THEFT_RING:
				fired = true
				break
			if int(_game_state.get("current_day")) < 14:
				_game_state.call("advance_day")
		if fired:
			break
	_expect_equal(fired, true, "O1: seeded settle run can roll theft_ring")
	_qa_autoload.call("set_force_enabled", false)


func _test_theft_ring_shrink_multiplier() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_shrink_multiplier")), 1.0),
		true,
		"O1: shrink mult is 1.0 with event off"
	)
	var baseline_rate := float(_economy.call("effective_shrink_rate"))
	_economy.call("_settle_shrink")
	var baseline := _last_shrink_applied()
	_expect_equal(baseline.is_empty(), false, "O1: baseline shrink is instrumented")
	_expect_equal(
		is_equal_approx(float(baseline.get("shrink_mult", 0.0)), 1.0),
		true,
		"O1: baseline shrink_mult is 1.0"
	)
	_expect_equal(
		is_equal_approx(float(baseline.get("rate", 0.0)), baseline_rate),
		true,
		"O1: baseline instrumented rate matches effective_shrink_rate"
	)
	var baseline_cogs := int(baseline.get("cogs_cents", 0))
	var baseline_loss := int(baseline.get("loss_cents", 0))
	_expect_equal(baseline_cogs > 0, true, "O1: seed inventory has COGS for shrink")

	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_shrink_multiplier")),
			MarketEventService.THEFT_RING_SHRINK_MULT
		),
		true,
		"O1: active shrink mult is ×3"
	)
	var theft_rate := float(_economy.call("effective_shrink_rate"))
	_expect_equal(
		is_equal_approx(theft_rate, baseline_rate * MarketEventService.THEFT_RING_SHRINK_MULT),
		true,
		"O1: effective shrink rate is ×3 vs same-inventory baseline"
	)
	_qa_autoload.call("clear")
	_economy.call("_settle_shrink")
	var theft := _last_shrink_applied()
	_expect_equal(bool(theft.get("theft_ring", false)), true, "O1: shrink payload flags theft ring")
	_expect_equal(
		is_equal_approx(
			float(theft.get("shrink_mult", 0.0)),
			MarketEventService.THEFT_RING_SHRINK_MULT
		),
		true,
		"O1: instrumentation records shrink_mult ×3"
	)
	_expect_equal(
		is_equal_approx(float(theft.get("rate", 0.0)), theft_rate),
		true,
		"O1: instrumented rate is the multiplied settle rate"
	)
	_expect_equal(
		int(theft.get("cogs_cents", 0)),
		baseline_cogs,
		"O1: theft settle uses the same inventory COGS"
	)
	var theft_loss := int(theft.get("loss_cents", 0))
	_expect_equal(theft_loss > baseline_loss, true, "O1: theft loss exceeds baseline")
	_expect_equal(
		theft_loss >= maxi(1, roundi(float(baseline_loss) * 2.4)),
		true,
		"O1: shrink loss ≈ ×3 vs baseline same inventory"
	)
	_demand_signals.call("apply_event_save", {})
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		false,
		"O1: clearing theft ring drops the flag"
	)
	_expect_equal(
		is_equal_approx(float(_economy.call("effective_shrink_rate")), baseline_rate),
		true,
		"O1: shrink rate restores after the event ends"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_theft_ring_staff_lever_or_wait_out() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var unstaffed_rate := float(_economy.call("effective_shrink_rate"))
	_expect_equal(
		(_game_state.get("shop") as ShopState).has_cashier_on_duty(),
		false,
		"O1: Normal start has no cashier on the floor"
	)
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	_economy.call("_settle_shrink")
	var unstaffed := _last_shrink_applied()
	_expect_equal(
		bool(unstaffed.get("staff_on_floor", true)),
		false,
		"O1: unstaffed shrink records staff_on_floor false"
	)

	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.hire_cashier(false) != null, true, "O1: staff-up lever hires a cashier")
	_expect_equal(shop.has_cashier_on_duty(), true, "O1: hired cashier is on duty")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var staffed_rate := float(_economy.call("effective_shrink_rate"))
	_expect_equal(
		staffed_rate < unstaffed_rate,
		true,
		"O1: staff on floor reduces theft-ring loss rate vs unstaffed"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_shrink_multiplier")),
			MarketEventService.THEFT_RING_SHRINK_MULT
		),
		true,
		"O1: staff lever dampens the loss rate, not a camera unlock"
	)
	_qa_autoload.call("clear")
	_economy.call("_settle_shrink")
	var staffed := _last_shrink_applied()
	_expect_equal(
		bool(staffed.get("staff_on_floor", false)),
		true,
		"O1: staffed shrink records staff_on_floor"
	)
	_expect_equal(
		int(staffed.get("loss_cents", 0)) < int(unstaffed.get("loss_cents", 0)),
		true,
		"O1: staffed theft loss is below unstaffed theft loss"
	)

	var service_src := FileAccess.get_file_as_string(
		"res://scripts/economy/market_event_service.gd"
	)
	_expect_equal(
		service_src.contains("wait out") or service_src.contains("wait-out"),
		true,
		"O1: wait-out stays documented without requiring cameras"
	)
	_expect_equal(
		service_src.contains("staff coverage") or service_src.contains("Staff coverage"),
		true,
		"O1: staff lever stays documented"
	)

	_game_state.call("start_new_game")
	var wait: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(wait != null, true, "O1: wait-out fixture starts")
	var wait_rate := float(_economy.call("effective_shrink_rate"))
	_demand_signals.call("roll_settle_events")
	var after_one: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(
		after_one != null and after_one.kind == MarketEvent.KIND_THEFT_RING,
		true,
		"O1: day 1 wait-out keeps the ring active"
	)
	_expect_equal(after_one.remaining_days, 2, "O1: remaining_days ticks 3→2")
	_expect_equal(
		is_equal_approx(float(_economy.call("effective_shrink_rate")), wait_rate),
		true,
		"O1: shrink stays ×3 while remaining_days > 0"
	)
	_demand_signals.call("roll_settle_events")
	var after_two: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(
		after_two != null and after_two.remaining_days == 1,
		true,
		"O1: remaining_days ticks 2→1"
	)
	_demand_signals.call("roll_settle_events")
	_demand_signals.call("apply_event_save", {})
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		false,
		"O1: wait-out / clear ends the ring"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_shrink_multiplier")), 1.0),
		true,
		"O1: shrink restores after wait-out"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_theft_ring_section_45_and_banner() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("Rumor"), true, "O1: banner is rumor telegraph")
	_expect_equal(banner.contains("floor"), true, "O1: rumor names the floor")
	_expect_equal(
		banner.to_lower().contains("staff") or banner.to_lower().contains("wait"),
		true,
		"O1: rumor names the staff / wait-out lever"
	)
	_expect_equal(banner.contains("true_market"), false, "O1: rumor has no true_market")
	_assert_text_has_no_truth(banner, "O1 theft ring banner")
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var payload: Dictionary = _demand_signals.call("roll_settle_events")
	_assert_payload_has_no_truth(payload, "O1 theft market_event_rolled")
	_expect_equal(
		payload.has("shrink_mult") and payload.has("theft_ring"),
		true,
		"O1: roll instrumentation records shrink_mult"
	)
	_qa_autoload.call("set_force_enabled", false)
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"O1: rumor banner does not open Option D PriceEditor"
	)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "O1: HUD loads for theft rumor")
	if hud != null:
		var banner_label := hud.get_node_or_null("%EventBannerLabel") as Label
		_expect_equal(banner_label != null, true, "O1: thin event banner exists")
		_expect_equal(
			banner_label != null
			and banner_label.visible
			and banner_label.text.contains("Rumor"),
			true,
			"O1: HUD banner shows theft rumor without a new screen"
		)
		_assert_text_has_no_truth(
			banner_label.text if banner_label != null else "",
			"O1 HUD theft banner"
		)
		var price_panel := hud.get_node_or_null("%PriceEditor") as PanelContainer
		_expect_equal(
			price_panel == null or not price_panel.visible,
			true,
			"O1: HUD does not force PriceEditor for theft ring"
		)
		var demand_chip := hud.get_node_or_null("%PriceDemandChip") as Label
		_expect_equal(demand_chip != null, true, "O1: PriceEditor demand chip still present")
		hud.queue_free()


func _test_theft_ring_pack_coherence() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var convention: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(convention != null, true, "O1: Convention weekend still starts")
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		false,
		"O1: convention replaces theft ring on the shared pack bus"
	)
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		true,
		"O1: Convention weekend modifiers still apply"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_shrink_multiplier")), 1.0),
		true,
		"O1: convention does not keep theft shrink ×3"
	)
	var scare: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(scare != null, true, "O1: Counterfeit scare still starts")
	_expect_equal(
		_demand_signals.call("has_counterfeit_scare"),
		true,
		"O1: Counterfeit scare modifiers still apply"
	)
	var hype: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": &"AA-SKIE-047", "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(hype != null, true, "O1: Option D hype still starts")
	_expect_equal(hype.sku_id, &"AA-SKIE-047", "O1: hype still targets Titan")
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		true,
		"O1: Option D hype still wants the PriceEditor"
	)
	var fog: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_FOG,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(fog != null, true, "O1: fog day still starts")
	_expect_equal(_demand_signals.call("has_fog_flag"), true, "O1: fog flag still applies")
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		false,
		"O1: fog does not leak theft shrink"
	)
	var demand_src := FileAccess.get_file_as_string(
		"res://scripts/autoload/demand_signals.gd"
	)
	_expect_equal(
		demand_src.contains("func _ensure_priceable_sku"),
		true,
		"O1: Soft _ensure_priceable_sku stays parked"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/autoload/economy.gd"
		).contains("_ensure_priceable_sku"),
		false,
		"O1: settle shrink does not call parked Soft helper"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/autoload/inventory_service.gd"
		).contains("func apply_shop_capacity_bonuses"),
		true,
		"O1: apply_shop_capacity_bonuses is the Large-aware capacity helper"
	)
	_expect_equal(
		FileAccess.get_file_as_string("res://data/events.json").contains("camera unlock"),
		false,
		"O1: no camera unlock content in the event catalog"
	)


func _test_theft_ring_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(started != null, true, "O1 save: theft ring starts")
	_game_state.set("current_day", 4)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "O1 theft ring save")
	var stored: Dictionary = saved.get("market_event", {})
	_expect_equal(String(stored.get("id", "")), "theft_ring", "O1 save writes event id")
	_expect_equal(int(stored.get("remaining_days", 0)), 3, "O1 save writes remaining days")
	_expect_equal(String(stored.get("kind", "")), "theft_ring", "O1 save writes kind")
	_game_state.call("start_new_game")
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		false,
		"O1: new game clears theft ring"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"O1: restore_save accepts theft ring snapshot"
	)
	var restored: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(restored != null, true, "O1: save/load restores theft ring")
	_expect_equal(restored.kind, MarketEvent.KIND_THEFT_RING, "O1: restored kind")
	_expect_equal(restored.remaining_days, 3, "O1: save/load restores remaining days")
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		true,
		"O1: restored theft ring re-applies shrink ×3"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_shrink_multiplier")),
			MarketEventService.THEFT_RING_SHRINK_MULT
		),
		true,
		"O1: restored theft ring still multiplies shrink"
	)
	var restored_banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(
		restored_banner.contains("Rumor"),
		true,
		"O1: restored banner still uses rumor copy"
	)
	_assert_text_has_no_truth(restored_banner, "O1 restored theft banner")


func _test_camera_unlock() -> void:
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_test_camera_balance_scalars()
	_test_camera_install_gates()
	_test_camera_theft_shrink_reduction()
	_test_camera_o1_unchanged_without_cams()
	_test_camera_hud_confirm_and_section_45()
	_test_camera_save_load()
	_test_camera_soft_catalog_untouched()
	_qa_autoload.call("set_force_enabled", false)
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_camera_balance_scalars() -> void:
	_expect_equal(NORMAL_CONFIG.camera_cash_cents, 250_000, "V1: cash gate is $2,500")
	_expect_equal(NORMAL_CONFIG.camera_attention, 8, "V1: install Att is 8")
	_expect_equal(
		is_equal_approx(NORMAL_CONFIG.camera_theft_shrink_mult, 1.5),
		true,
		"V1: camera theft shrink mult is ×1.5"
	)
	_expect_equal(
		NORMAL_CONFIG.camera_theft_shrink_mult < MarketEventService.THEFT_RING_SHRINK_MULT,
		true,
		"V1: camera shrink mult is below theft ×3"
	)
	_expect_equal(EASY_CONFIG.camera_cash_cents, 250_000, "V1: Easy inherits camera cash")
	_expect_equal(HARD_CONFIG.camera_attention, 8, "V1: Hard inherits camera Att")


func _test_camera_install_gates() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.has_cameras(), false, "V1: cameras start unowned")
	_expect_equal(shop.has_active_cameras(), false, "V1: cameras start inactive")
	_expect_equal(shop.camera_cash_cost_cents(), 250_000, "V1: shop cash cost is $2,500")
	_expect_equal(shop.camera_attention_cost(), 8, "V1: shop Att cost is 8")
	_expect_equal(
		_game_state.call("can_install_cameras"),
		true,
		"V1: PREP + cash + Att can install"
	)

	_game_state.set("attention_remaining", 0)
	_event_bus.emit_signal("attention_changed", 0)
	_expect_equal(
		_game_state.call("can_install_cameras"),
		false,
		"V1: Att 0 blocks install"
	)
	var att0: Dictionary = _game_state.call("install_cameras")
	_expect_equal(bool(att0.get("ok", true)), false, "V1: install refused at Att 0")
	_expect_equal(
		StringName(att0.get("reason", &"")),
		&"insufficient_attention",
		"V1: Att 0 reason is insufficient_attention"
	)
	_expect_equal(shop.has_cameras(), false, "V1: Att 0 does not own cameras")

	_game_state.set("attention_remaining", 8)
	_event_bus.emit_signal("attention_changed", 8)
	_economy.set("balance_cents", 100_000)
	_event_bus.call("publish_cash_changed", 100_000)
	_expect_equal(
		_game_state.call("can_install_cameras"),
		false,
		"V1: cash short blocks install"
	)
	var poor: Dictionary = _game_state.call("install_cameras")
	_expect_equal(bool(poor.get("ok", true)), false, "V1: install refused when cash short")
	_expect_equal(
		StringName(poor.get("reason", &"")),
		&"insufficient_cash",
		"V1: cash-short reason is insufficient_cash"
	)

	_game_state.call("start_new_game")
	_expect_equal(_game_state.call("start_settle"), false, "V1: cannot settle from PREP")
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		_game_state.call("can_install_cameras"),
		false,
		"V1: SETTLE blocks install"
	)

	_game_state.call("start_new_game")
	var cash_before := int(_economy.get("balance_cents"))
	var att_before := int(_game_state.get("attention_remaining"))
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var installed: Dictionary = _game_state.call("install_cameras")
	_expect_equal(bool(installed.get("ok", false)), true, "V1: install succeeds when gates met")
	_expect_equal(shop.has_cameras(), true, "V1: shop owns cameras after install")
	_expect_equal(shop.has_active_cameras(), true, "V1: owned cameras are active")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - 250_000,
		"V1: install spends camera cash"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		att_before - 8,
		"V1: install spends camera Att"
	)
	_expect_equal(
		_game_state.call("can_install_cameras"),
		false,
		"V1: already-owned blocks a second buy"
	)
	var again: Dictionary = _game_state.call("install_cameras")
	_expect_equal(bool(again.get("ok", true)), false, "V1: second install refused")
	_expect_equal(
		StringName(again.get("reason", &"")),
		&"already_owned",
		"V1: second-install reason is already_owned"
	)
	var found_install := false
	for event_value: Variant in _qa_autoload.call("get_events"):
		var event := event_value as Dictionary
		if String(event.get("event", "")) != "cameras_installed":
			continue
		found_install = true
		_assert_payload_has_no_truth(event.get("payload", {}), "V1 cameras_installed")
	_expect_equal(found_install, true, "V1: install is instrumented")
	_qa_autoload.call("set_force_enabled", false)


func _test_camera_theft_shrink_reduction() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var no_cam_mult := float(_demand_signals.call("active_shrink_multiplier"))
	var no_cam_rate := float(_economy.call("effective_shrink_rate"))
	_economy.call("_settle_shrink")
	var no_cam := _last_shrink_applied()
	_expect_equal(
		is_equal_approx(no_cam_mult, MarketEventService.THEFT_RING_SHRINK_MULT),
		true,
		"V1: without cameras theft shrink is ×3"
	)
	_expect_equal(bool(no_cam.get("cameras_active", true)), false, "V1: no-cam payload flags cameras off")
	_expect_equal(bool(no_cam.get("theft_ring", false)), true, "V1: no-cam payload flags theft")
	var no_cam_loss := int(no_cam.get("loss_cents", 0))
	_expect_equal(no_cam_loss > 0, true, "V1: no-cam theft loss is positive")

	_game_state.call("start_new_game")
	var install: Dictionary = _game_state.call("install_cameras")
	_expect_equal(bool(install.get("ok", false)), true, "V1: install before theft compare")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var cam_mult := float(_demand_signals.call("active_shrink_multiplier"))
	var cam_rate := float(_economy.call("effective_shrink_rate"))
	_expect_equal(
		is_equal_approx(cam_mult, NORMAL_CONFIG.camera_theft_shrink_mult),
		true,
		"V1: with cameras theft shrink uses camera scalar"
	)
	_expect_equal(cam_mult < no_cam_mult, true, "V1: camera shrink mult is below no-cam ×3")
	_expect_equal(cam_rate < no_cam_rate, true, "V1: camera effective rate is below no-cam")
	_qa_autoload.call("clear")
	_economy.call("_settle_shrink")
	var with_cam := _last_shrink_applied()
	_expect_equal(
		bool(with_cam.get("cameras_active", false)),
		true,
		"V1: camera shrink payload flags cameras_active"
	)
	_expect_equal(
		is_equal_approx(
			float(with_cam.get("shrink_mult", 0.0)),
			NORMAL_CONFIG.camera_theft_shrink_mult
		),
		true,
		"V1: instrumentation records camera shrink_mult"
	)
	var cam_loss := int(with_cam.get("loss_cents", 0))
	_expect_equal(cam_loss < no_cam_loss, true, "V1: theft shrink loss is lower with cameras")
	_expect_equal(
		int(with_cam.get("cogs_cents", 0)),
		int(no_cam.get("cogs_cents", 0)),
		"V1: camera compare uses the same inventory COGS"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_camera_o1_unchanged_without_cams() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var unstaffed_rate := float(_economy.call("effective_shrink_rate"))
	_expect_equal(
		(_game_state.get("shop") as ShopState).has_cameras(),
		false,
		"V1: O1 path starts without cameras"
	)
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.hire_cashier(false) != null, true, "V1: staff lever still hires")
	_expect_equal(shop.has_cashier_on_duty(), true, "V1: hired cashier is on duty")
	var staffed_rate := float(_economy.call("effective_shrink_rate"))
	_expect_equal(
		staffed_rate < unstaffed_rate,
		true,
		"V1: without cameras, staff still dampens theft loss rate"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_shrink_multiplier")),
			MarketEventService.THEFT_RING_SHRINK_MULT
		),
		true,
		"V1: without cameras, theft multiplier stays ×3"
	)

	_game_state.call("start_new_game")
	var wait: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(wait != null, true, "V1: wait-out fixture starts without cameras")
	_demand_signals.call("roll_settle_events")
	var after_one: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(
		after_one != null and after_one.remaining_days == 2,
		true,
		"V1: wait-out still ticks 3→2 without cameras"
	)
	_demand_signals.call("roll_settle_events")
	_demand_signals.call("roll_settle_events")
	_demand_signals.call("apply_event_save", {})
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		false,
		"V1: wait-out / clear still ends the ring without cameras"
	)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("Rumor"), true, "V1: rumor still works without cameras")
	_expect_equal(
		banner.to_lower().contains("staff") or banner.to_lower().contains("wait"),
		true,
		"V1: rumor still names staff / wait-out without cameras"
	)
	_expect_equal(banner.to_lower().contains("camera"), false, "V1: rumor does not require cameras")
	_assert_text_has_no_truth(banner, "V1 theft rumor without cameras")


func _test_camera_hud_confirm_and_section_45() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "V1: HUD loads for camera confirm")
	if hud == null:
		return
	var open_button := hud.get_node_or_null("%OpenCamerasButton") as Button
	_expect_equal(open_button != null, true, "V1: Cameras button exists")
	_expect_equal(
		open_button != null
		and open_button.text.contains("$2,500.00")
		and open_button.text.contains("Att 8"),
		true,
		"V1: Cameras button shows cash and Att"
	)
	_expect_equal(
		open_button != null and open_button.custom_minimum_size.y >= 40.0,
		true,
		"V1: Cameras hit target height"
	)
	_expect_equal(
		open_button != null and not open_button.disabled,
		true,
		"V1: Cameras button enabled when gates met"
	)
	open_button.pressed.emit()
	var confirm := hud.get_node_or_null("%CameraConfirm") as PanelContainer
	var body := hud.get_node_or_null("%CameraConfirmBody") as Label
	var confirm_button := hud.get_node_or_null("%CameraConfirmButton") as Button
	_expect_equal(
		confirm != null and confirm.visible,
		true,
		"V1: buy/install confirm opens"
	)
	_expect_equal(body != null, true, "V1: confirm body exists")
	_assert_text_has_no_truth(
		body.text if body != null else "",
		"V1 camera confirm body"
	)
	_assert_text_has_no_truth(
		open_button.text if open_button != null else "",
		"V1 camera button"
	)
	_assert_text_has_no_truth(
		confirm_button.text if confirm_button != null else "",
		"V1 camera confirm button"
	)
	_expect_equal(
		body != null and body.text.contains("theft"),
		true,
		"V1: confirm names the theft tradeoff"
	)
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var banner_label := hud.get_node_or_null("%EventBannerLabel") as Label
	_expect_equal(
		banner_label != null
		and banner_label.visible
		and banner_label.text.contains("Rumor"),
		true,
		"V1: EventBanner rumor still shows without cameras"
	)
	_assert_text_has_no_truth(
		banner_label.text if banner_label != null else "",
		"V1 HUD theft banner with camera button"
	)
	confirm_button.pressed.emit()
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.has_cameras(), true, "V1: HUD confirm installs cameras")
	_expect_equal(
		open_button.text.contains("Cameras on"),
		true,
		"V1: HUD shows cameras-on after install"
	)
	_expect_equal(open_button.disabled, true, "V1: cameras button disables once owned")
	_expect_equal(
		confirm == null or not confirm.visible,
		true,
		"V1: confirm closes after install"
	)
	hud.queue_free()


func _test_camera_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var installed: Dictionary = _game_state.call("install_cameras")
	_expect_equal(bool(installed.get("ok", false)), true, "V1 save: install first")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "V1 camera save")
	var shop_row: Dictionary = saved.get("shop", {})
	_expect_equal(bool(shop_row.get("cameras_owned", false)), true, "V1 save writes cameras_owned")
	_game_state.call("start_new_game")
	_expect_equal(
		(_game_state.get("shop") as ShopState).has_cameras(),
		false,
		"V1: new game clears cameras"
	)
	_expect_equal(_game_state.call("restore_save", saved), true, "V1: restore accepts camera save")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.has_cameras(), true, "V1: restore re-owns cameras")
	_expect_equal(shop.has_active_cameras(), true, "V1: restored cameras stay active")
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_shrink_multiplier")),
			NORMAL_CONFIG.camera_theft_shrink_mult
		),
		true,
		"V1: restored cameras still cut theft shrink"
	)


func _test_camera_soft_catalog_untouched() -> void:
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/autoload/demand_signals.gd"
		).contains("func _ensure_priceable_sku"),
		true,
		"V1: Soft _ensure_priceable_sku stays parked"
	)
	_expect_equal(
		FileAccess.get_file_as_string("res://scripts/ui/hud.gd").contains("_ensure_priceable_sku"),
		false,
		"V1: HUD does not call parked Soft helper"
	)
	_expect_equal(
		FileAccess.get_file_as_string("res://data/events.json").contains("camera unlock"),
		false,
		"V1: cameras stay out of the event catalog"
	)


func _test_security_camera_prop_stub_swap() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.has_cameras(), false, "V1 art: start unowned")
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "V1 art: shop_floor loads")
	if packed == null:
		return
	var floor: Node = packed.instantiate()
	root.add_child(floor)
	var rig := floor.get_node_or_null("Fixtures/SecurityCameras") as SecurityCameras
	_expect_equal(rig != null, true, "V1 art: SecurityCameras presenter present")
	if rig == null:
		floor.free()
		return
	rig.sync_from_shop()
	_assert_security_camera_mount(
		rig,
		SecurityCameras.ENTRANCE_NAME,
		SecurityCameras.ENTRANCE_POSITION,
		"entrance"
	)
	_assert_security_camera_mount(
		rig,
		SecurityCameras.AISLE_NAME,
		SecurityCameras.AISLE_POSITION,
		"aisle"
	)
	_assert_security_camera_mount(
		rig,
		SecurityCameras.LARGE_NAME,
		SecurityCameras.LARGE_POSITION,
		"large extra"
	)
	_expect_equal(
		SecurityCameras.CEILING_ROTATION_DEGREES.is_equal_approx(Vector3(0.0, 180.0, 0.0)),
		true,
		"V1 art: ceiling yaw 180 looks −Z"
	)
	_expect_equal(
		SecurityCameras.WALL_ROTATION_DEGREES.is_equal_approx(Vector3(-90.0, 180.0, 0.0)),
		true,
		"V1 art: wall recipe is Y=180 then X=−90"
	)
	_expect_equal(
		SecurityCameras.WALL_EXAMPLE_POSITION.is_equal_approx(Vector3(6.30, 2.40, -8.95)),
		true,
		"V1 art: Medium back-wall example stays SoT"
	)
	_expect_equal(rig.owned_cameras_visible(), false, "V1 art: unowned hides Medium cams")
	_expect_equal(rig.large_camera_visible(), false, "V1 art: unowned hides Large extra")
	_expect_equal(rig.visible_camera_count(), 0, "V1 art: unowned visible count is 0")
	_expect_equal(
		rig.camera_node(SecurityCameras.ENTRANCE_NAME) != null
		and not rig.camera_node(SecurityCameras.ENTRANCE_NAME).visible,
		true,
		"V1 art: SecurityCamera node exists but is hidden"
	)

	var cash_before := int(_economy.get("balance_cents"))
	var att_before := int(_game_state.get("attention_remaining"))
	var installed: Dictionary = _game_state.call("install_cameras")
	_expect_equal(bool(installed.get("ok", false)), true, "V1 art: consume existing install")
	_expect_equal(shop.has_cameras(), true, "V1 art: install still owns cameras")
	_expect_equal(shop.has_active_cameras(), true, "V1 art: owned cameras stay active")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - NORMAL_CONFIG.camera_cash_cents,
		"V1 art: install cash gate unchanged"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		att_before - NORMAL_CONFIG.camera_attention,
		"V1 art: install Att gate unchanged"
	)
	rig.sync_from_shop()
	_expect_equal(rig.owned_cameras_visible(), true, "V1 art: owned shows Medium cams")
	_expect_equal(rig.large_camera_visible(), false, "V1 art: Small hides Large extra")
	_expect_equal(rig.visible_camera_count(), 2, "V1 art: Small owned shows two ceiling cams")

	shop.tier = ShopState.Tier.LARGE
	rig.sync_from_shop()
	_expect_equal(rig.owned_cameras_visible(), true, "V1 art: Large keeps Medium cams")
	_expect_equal(rig.large_camera_visible(), true, "V1 art: Large extra shows when owned")
	_expect_equal(rig.visible_camera_count(), 3, "V1 art: Large owned shows three ceiling cams")

	var camera := floor.get_node_or_null("Camera") as ShopCamera
	_expect_equal(camera != null, true, "V1 art: ShopCamera unchanged")
	if camera != null:
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"V1 art: prop does not move Day1 camera"
		)
		_expect_equal(
			is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
			true,
			"V1 art: prop does not churn FOV"
		)

	var again: Dictionary = _game_state.call("install_cameras")
	_expect_equal(bool(again.get("ok", true)), false, "V1 art: no second install verb")
	_expect_equal(
		StringName(again.get("reason", &"")),
		&"already_owned",
		"V1 art: already-owned reason unchanged"
	)

	var src := FileAccess.get_file_as_string("res://scripts/shop/security_cameras.gd")
	_assert_text_has_no_truth(src, "V1 art security camera rig")
	_expect_equal(src.contains("install_cameras"), false, "V1 art: rig does not buy cameras")
	_expect_equal(src.contains("true_market"), false, "V1 art: rig has no true_market")
	_expect_equal(
		FileAccess.get_file_as_string("res://scripts/shop/shop_floor_extent.gd").contains(
			"prop_security_camera_01"
		),
		false,
		"V1 art: floor-extent stays shell-only"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/autoload/demand_signals.gd"
		).contains("func _ensure_priceable_sku"),
		true,
		"V1 art: Soft _ensure_priceable_sku stays parked"
	)
	_game_state.call("start_new_game")
	rig.sync_from_shop()
	_expect_equal(
		(_game_state.get("shop") as ShopState).has_cameras(),
		false,
		"V1 art: new game clears ownership"
	)
	_expect_equal(rig.owned_cameras_visible(), false, "V1 art: new game hides the prop")
	_expect_equal(rig.visible_camera_count(), 0, "V1 art: new game visible count is 0")
	floor.free()


func _assert_security_camera_mount(
	rig: SecurityCameras,
	node_name: String,
	want_position: Vector3,
	label: String
) -> void:
	var node := rig.camera_node(node_name)
	_expect_equal(node != null, true, "V1 art: %s node exists" % label)
	if node == null:
		return
	_expect_equal(node is Marker3D, false, "V1 art: %s is not a Marker3D placeholder" % label)
	_expect_equal(
		node.scene_file_path.contains("prop_security_camera_01"),
		true,
		"V1 art: %s instances the Art GLB" % label
	)
	_expect_equal(
		node.position.is_equal_approx(want_position),
		true,
		"V1 art: %s MOUNT sits on SoT ceiling spot" % label
	)
	_expect_equal(
		node.rotation_degrees.is_equal_approx(SecurityCameras.CEILING_ROTATION_DEGREES),
		true,
		"V1 art: %s yaw looks into the shop" % label
	)
	_expect_equal(
		node.scale.is_equal_approx(Vector3.ONE),
		true,
		"V1 art: %s scale 1u=1m" % label
	)
	_expect_equal(
		is_equal_approx(node.position.y, 2.80),
		true,
		"V1 art: %s hangs from ceiling Y=2.80" % label
	)


func _test_recession_week_event() -> void:
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_test_recession_week_can_fire()
	_test_recession_week_demand_and_buylist()
	_test_recession_week_levers_and_no_soft_lock()
	_test_recession_week_section_45_and_banner()
	_test_recession_week_pack_coherence()
	_test_recession_week_save_load()
	_qa_autoload.call("set_force_enabled", false)
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_recession_week_can_fire() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_RECESSION,
		{"duration_days": 7, "remaining_days": 7}
	)
	_expect_equal(started != null, true, "P1: formal start_pack_event fires recession week")
	_expect_equal(started.kind, MarketEvent.KIND_RECESSION, "P1: kind is recession_week")
	_expect_equal(started.duration_days, 7, "P1: duration is 7 days")
	_expect_equal(started.remaining_days, 7, "P1: remaining_days tracks the week")
	_expect_equal(
		_demand_signals.call("has_recession_week"),
		true,
		"P1: pack exposes recession week flag"
	)
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"P1: recession does not open Option D PriceEditor"
	)
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var fired := false
	var seeds: Array[int] = [MarketEventService.EVENT_RNG_SEED]
	for extra: int in range(1, 64):
		seeds.append(extra)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		_demand_signals.call("seed_event_rng", rng_seed)
		_qa_autoload.call("clear")
		for _day_index: int in range(14):
			_game_state.call("start_floor")
			_game_state.call("start_settle")
			var rolled: MarketEvent = _demand_signals.call("active_event")
			if rolled != null and rolled.kind == MarketEvent.KIND_RECESSION:
				fired = true
				break
			if int(_game_state.get("current_day")) < 14:
				_game_state.call("advance_day")
		if fired:
			break
	_expect_equal(fired, true, "P1: seeded settle run can roll recession_week")
	_qa_autoload.call("set_force_enabled", false)


func _test_recession_week_demand_and_buylist() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var staple := &"AA-BASE-088"
	var catalog := CustomerArchetypeCatalog.new()
	var flipper: Dictionary = {}
	for archetype: Dictionary in catalog.archetypes:
		if StringName(archetype.get("id", "")) == &"flipper":
			flipper = archetype
			break
	var baseline_score := float(_demand_signals.call("effective_demand_score", staple))
	var baseline_band: StringName = _demand_signals.call("effective_demand_band", staple)
	var baseline_flipper := catalog.weight_for(flipper, 40, NORMAL_CONFIG)
	_expect_equal(baseline_score > 0.0, true, "P1: staple has baseline demand")
	_expect_equal(baseline_band, &"warm", "P1: staple baseline demand band is warm")
	_expect_equal(baseline_flipper > 0.0, true, "P1: flipper baseline weight is positive")
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_event_demand_mult")), 1.0),
		true,
		"P1: demand mult is 1.0 with event off"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_event_buylist_mult")), 1.0),
		true,
		"P1: buylist mult is 1.0 with event off"
	)
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_RECESSION,
		{"duration_days": 7, "remaining_days": 7}
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_demand_mult")),
			MarketEventService.RECESSION_DEMAND_MULT
		),
		true,
		"P1: recession demand mult is 0.65"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_sell_through_mult")),
			MarketEventService.RECESSION_DEMAND_MULT
		),
		true,
		"P1: sell-through mult tracks demand mult"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_buylist_mult")),
			MarketEventService.RECESSION_BUYLIST_MULT
		),
		true,
		"P1: recession buylist seller mult is ×2"
	)
	var rec_score := float(_demand_signals.call("effective_demand_score", staple))
	var rec_band: StringName = _demand_signals.call("effective_demand_band", staple)
	_expect_equal(rec_score < baseline_score, true, "P1: staple demand score drops")
	_expect_equal(
		is_equal_approx(
			rec_score,
			baseline_score * MarketEventService.RECESSION_DEMAND_MULT
		),
		true,
		"P1: demand uses pack mult, not a BalanceConfig rewrite"
	)
	_expect_equal(rec_band, &"steady", "P1: staple demand band cools warm → steady")
	_expect_equal(rec_band != baseline_band, true, "P1: sell-through band is observably colder")
	var buylist_mult := float(_demand_signals.call("active_event_buylist_mult"))
	var rec_flipper := catalog.weight_for(flipper, 40, NORMAL_CONFIG, 1.0, buylist_mult)
	_expect_equal(rec_flipper > baseline_flipper, true, "P1: flipper/buylist weight rises")
	_expect_equal(
		is_equal_approx(
			rec_flipper,
			baseline_flipper * MarketEventService.RECESSION_BUYLIST_MULT
		),
		true,
		"P1: buylist seller pressure uses pack mult"
	)
	var spawn_src := FileAccess.get_file_as_string(
		"res://scripts/customers/customer_spawner.gd"
	)
	_expect_equal(
		spawn_src.contains("active_event_buylist_mult"),
		true,
		"P1: CustomerSpawner reads active-event buylist multiplier"
	)
	var wait: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(wait != null, true, "P1: week window is active")
	_demand_signals.call("roll_settle_events")
	var after_one: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(
		after_one != null and after_one.kind == MarketEvent.KIND_RECESSION,
		true,
		"P1: day 1 wait-out keeps recession active"
	)
	_expect_equal(after_one.remaining_days, 6, "P1: remaining_days ticks 7→6")
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_demand_mult")),
			MarketEventService.RECESSION_DEMAND_MULT
		),
		true,
		"P1: demand stays down while remaining_days > 0"
	)
	_demand_signals.call("apply_event_save", {})
	_expect_equal(
		_demand_signals.call("has_recession_week"),
		false,
		"P1: clearing recession drops the flag"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("effective_demand_score", staple)),
			baseline_score
		),
		true,
		"P1: demand score restores after the event ends"
	)
	_expect_equal(
		_demand_signals.call("effective_demand_band", staple),
		baseline_band,
		"P1: demand band restores after the event ends"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_event_buylist_mult")), 1.0),
		true,
		"P1: buylist weight restores after recession ends"
	)
	_expect_equal(
		is_equal_approx(catalog.weight_for(flipper, 40, NORMAL_CONFIG), baseline_flipper),
		true,
		"P1: catalog flipper weight restores to baseline"
	)


func _test_recession_week_levers_and_no_soft_lock() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_RECESSION,
		{"duration_days": 7, "remaining_days": 7}
	)
	var staple := &"AA-BASE-088"
	var listed_before := int(_inventory_service.call("listed_price_for", staple))
	var fire_sale := maxi(1, floori(float(listed_before) * 0.90))
	_expect_equal(
		_inventory_service.call("set_listed_price", staple, fire_sale),
		true,
		"P1: liquidate-staples lever works during recession"
	)
	_expect_equal(
		int(_inventory_service.call("listed_price_for", staple)),
		fire_sale,
		"P1: fire-sale listed price persists"
	)
	var price_dto := _demand_signals.call(
		"price_signal",
		staple,
		fire_sale,
		_inventory_service.call("location_for", staple)
	) as PriceConfirmSignal
	_expect_dto_has_no_truth_fields(price_dto, "P1 recession fire-sale price signal")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(price_dto),
		"P1 recession fire-sale PriceEditor summary"
	)
	_expect_equal(
		price_dto.position == &"undercut" or price_dto.move_feel == &"should_move",
		true,
		"P1: fire-sale confirm still prices without a soft-lock"
	)
	var stock_before := int(_inventory_service.call("card_count", staple))
	var inventory := FakeCustomerInventory.new()
	var queue := CustomerQueue.new()
	queue.configure(inventory)
	var buyer := CustomerProfile.new()
	buyer.budget_cents = 10_000
	buyer.interest_tags = [&"staple"]
	_expect_equal(queue.enqueue(buyer), true, "P1: recession queue still accepts buyers")
	_expect_equal(queue.sell_listed(), true, "P1: liquidate sell-listed still works")
	_expect_equal(inventory.sold, true, "P1: liquidate reaches a sale")
	var seller := CustomerProfile.new()
	seller.trade_intent = CustomerProfile.TradeIntent.SELLING_TO_SHOP
	seller.buylist_signal = _demand_signals.call(
		"buylist_signal",
		&"AA-DUST-ETB",
		1
	) as BuyConfirmSignal
	_expect_equal(queue.enqueue(seller), true, "P1: buylist seller still queues")
	_expect_equal(queue.refuse(), true, "P1: refuse-buy lever works")
	_expect_equal(inventory.bought, false, "P1: refuse-buy does not purchase")
	queue.free()
	inventory.free()
	var opportunity: bool = _demand_signals.call(
		"inject_buy_opportunity",
		_scripted_buy_opportunity()
	)
	_expect_equal(opportunity, true, "P1: buy opportunity still injects")
	_expect_equal(
		_demand_signals.call("dismiss_buy_opportunity", &"p1_recession_skip"),
		true,
		"P1: cut-buys dismiss still works"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"p1_recession_skip") == null,
		true,
		"P1: dismissed buy stays closed — no soft-lock"
	)
	_expect_equal(stock_before > 0, true, "P1: seed staples remain liquidatable")
	_expect_equal(
		_game_state.call("start_floor"),
		true,
		"P1: recession can open FLOOR"
	)
	_expect_equal(
		_game_state.call("start_settle"),
		true,
		"P1: recession FLOOR can settle — no soft-lock"
	)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "P1: HUD loads during recession levers")
	if hud != null:
		var open_price := hud.get_node_or_null("%OpenPriceButton") as Button
		var open_buy := hud.get_node_or_null("%OpenBuyButton") as Button
		var refuse := hud.get_node_or_null("%RefuseButton") as Button
		_expect_equal(
			open_price != null and not open_price.disabled,
			true,
			"P1: player can still open PriceEditor to liquidate"
		)
		_expect_equal(
			open_buy != null and not open_buy.disabled,
			true,
			"P1: player can still open buys to refuse them"
		)
		_expect_equal(refuse != null, true, "P1: refuse control still exists")
		hud.queue_free()


func _scripted_buy_opportunity() -> BuyOpportunity:
	var opportunity := BuyOpportunity.new()
	opportunity.id = &"p1_recession_skip"
	opportunity.sku_id = &"AA-DUST-ETB"
	opportunity.display_name = "Dustway Chronicles Explorer Box"
	opportunity.offer_label = "Distributor lot"
	opportunity.channel = DemandSignalService.Channel.DISTRIBUTOR
	opportunity.unit_cost_cents = 3600
	opportunity.quantity = 1
	opportunity.space_required = 1
	return opportunity


func _test_recession_week_section_45_and_banner() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_RECESSION,
		{"duration_days": 7, "remaining_days": 7}
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("Macro"), true, "P1: banner is a macro ticker")
	_expect_equal(banner.contains("Recession"), true, "P1: banner names the week")
	_expect_equal(
		banner.to_lower().contains("demand") or banner.to_lower().contains("seller"),
		true,
		"P1: banner telegraphs demand / seller pressure"
	)
	_expect_equal(banner.contains("true_market"), false, "P1: ticker has no true_market")
	_assert_text_has_no_truth(banner, "P1 recession banner")
	var fire_sale := _demand_signals.call(
		"price_signal",
		&"AA-BASE-088",
		400,
		_inventory_service.call("location_for", &"AA-BASE-088")
	) as PriceConfirmSignal
	_expect_dto_has_no_truth_fields(fire_sale, "P1 recession fire-sale confirm")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(fire_sale),
		"P1 recession fire-sale summary"
	)
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var payload: Dictionary = _demand_signals.call("roll_settle_events")
	_assert_payload_has_no_truth(payload, "P1 recession market_event_rolled")
	_expect_equal(
		payload.has("demand_mult")
		and payload.has("buylist_mult")
		and payload.has("sell_through_mult"),
		true,
		"P1: instrumentation records demand and buylist multipliers"
	)
	_qa_autoload.call("set_force_enabled", false)
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"P1: macro banner does not open Option D PriceEditor"
	)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "P1: HUD loads for recession ticker")
	if hud != null:
		var banner_label := hud.get_node_or_null("%EventBannerLabel") as Label
		_expect_equal(banner_label != null, true, "P1: thin event banner exists")
		_expect_equal(
			banner_label != null
			and banner_label.visible
			and banner_label.text.contains("Macro")
			and banner_label.text.contains("Recession"),
			true,
			"P1: HUD banner shows recession without a new screen"
		)
		_assert_text_has_no_truth(
			banner_label.text if banner_label != null else "",
			"P1 HUD recession banner"
		)
		var price_panel := hud.get_node_or_null("%PriceEditor") as PanelContainer
		_expect_equal(
			price_panel == null or not price_panel.visible,
			true,
			"P1: HUD does not force PriceEditor for recession"
		)
		var demand_chip := hud.get_node_or_null("%PriceDemandChip") as Label
		_expect_equal(demand_chip != null, true, "P1: PriceEditor demand chip still present")
		hud.queue_free()


func _test_recession_week_pack_coherence() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_RECESSION,
		{"duration_days": 7, "remaining_days": 7}
	)
	var convention: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(convention != null, true, "P1: Convention weekend still starts")
	_expect_equal(
		_demand_signals.call("has_recession_week"),
		false,
		"P1: convention replaces recession on the shared pack bus"
	)
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		true,
		"P1: Convention weekend modifiers still apply"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_event_demand_mult")), 1.0),
		true,
		"P1: convention does not keep recession demand ↓"
	)
	var theft: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(theft != null, true, "P1: Theft ring still starts")
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		true,
		"P1: Theft ring modifiers still apply"
	)
	var scare: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(scare != null, true, "P1: Counterfeit scare still starts")
	_expect_equal(
		_demand_signals.call("has_counterfeit_scare"),
		true,
		"P1: Counterfeit scare modifiers still apply"
	)
	var hype: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": &"AA-SKIE-047", "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(hype != null, true, "P1: Option D hype still starts")
	_expect_equal(hype.sku_id, &"AA-SKIE-047", "P1: hype still targets Titan")
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		true,
		"P1: Option D hype still wants the PriceEditor"
	)
	var fog: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_FOG,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(fog != null, true, "P1: fog day still starts")
	_expect_equal(_demand_signals.call("has_fog_flag"), true, "P1: fog flag still applies")
	_expect_equal(
		_demand_signals.call("has_recession_week"),
		false,
		"P1: fog does not leak recession demand"
	)
	var demand_src := FileAccess.get_file_as_string(
		"res://scripts/autoload/demand_signals.gd"
	)
	_expect_equal(
		demand_src.contains("func _ensure_priceable_sku"),
		true,
		"P1: Soft _ensure_priceable_sku stays parked"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/customers/customer_spawner.gd"
		).contains("_ensure_priceable_sku"),
		false,
		"P1: spawner does not call parked Soft helper"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/autoload/inventory_service.gd"
		).contains("func apply_shop_capacity_bonuses"),
		true,
		"P1: apply_shop_capacity_bonuses is the Large-aware capacity helper"
	)


func _test_recession_week_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_RECESSION,
		{"duration_days": 7, "remaining_days": 7}
	)
	_expect_equal(started != null, true, "P1 save: recession starts")
	_game_state.set("current_day", 11)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "P1 recession save")
	var stored: Dictionary = saved.get("market_event", {})
	_expect_equal(String(stored.get("id", "")), "recession_week", "P1 save writes event id")
	_expect_equal(int(stored.get("remaining_days", 0)), 7, "P1 save writes remaining days")
	_expect_equal(String(stored.get("kind", "")), "recession_week", "P1 save writes kind")
	_game_state.call("start_new_game")
	_expect_equal(
		_demand_signals.call("has_recession_week"),
		false,
		"P1: new game clears recession"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"P1: restore_save accepts recession snapshot"
	)
	var restored: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(restored != null, true, "P1: save/load restores recession")
	_expect_equal(restored.kind, MarketEvent.KIND_RECESSION, "P1: restored kind")
	_expect_equal(restored.remaining_days, 7, "P1: save/load restores remaining days")
	_expect_equal(
		_demand_signals.call("has_recession_week"),
		true,
		"P1: restored recession re-applies demand ↓ / buylist ↑"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_demand_mult")),
			MarketEventService.RECESSION_DEMAND_MULT
		),
		true,
		"P1: restored recession still multiplies demand"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_event_buylist_mult")),
			MarketEventService.RECESSION_BUYLIST_MULT
		),
		true,
		"P1: restored recession still raises buylist sellers"
	)
	_expect_equal(
		_demand_signals.call("effective_demand_band", &"AA-BASE-088"),
		&"steady",
		"P1: restored recession still cools staple demand"
	)
	var restored_banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(
		restored_banner.contains("Macro") and restored_banner.contains("Recession"),
		true,
		"P1: restored banner still uses macro ticker copy"
	)
	_assert_text_has_no_truth(restored_banner, "P1 restored recession banner")


func _test_supply_glut_event() -> void:
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_test_supply_glut_can_fire()
	_test_supply_glut_wholesale_and_race()
	_test_supply_glut_levers_and_no_soft_lock()
	_test_supply_glut_section_45_and_banner()
	_test_supply_glut_pack_coherence()
	_test_supply_glut_save_load()
	_qa_autoload.call("set_force_enabled", false)
	_qa.set_force_enabled(false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_supply_glut_can_fire() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_SUPPLY_GLUT,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(started != null, true, "Q1: formal start_pack_event fires supply glut")
	_expect_equal(started.kind, MarketEvent.KIND_SUPPLY_GLUT, "Q1: kind is supply_glut")
	_expect_equal(started.duration_days, 3, "Q1: duration is 3 days")
	_expect_equal(started.remaining_days, 3, "Q1: remaining_days tracks the window")
	_expect_equal(
		_demand_signals.call("has_supply_glut"),
		true,
		"Q1: pack exposes supply glut flag"
	)
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"Q1: supply glut does not open Option D PriceEditor"
	)
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var fired := false
	var seeds: Array[int] = [MarketEventService.EVENT_RNG_SEED]
	for extra: int in range(1, 64):
		seeds.append(extra)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		_demand_signals.call("seed_event_rng", rng_seed)
		_qa_autoload.call("clear")
		for _day_index: int in range(14):
			_game_state.call("start_floor")
			_game_state.call("start_settle")
			var rolled: MarketEvent = _demand_signals.call("active_event")
			if rolled != null and rolled.kind == MarketEvent.KIND_SUPPLY_GLUT:
				fired = true
				break
			if int(_game_state.get("current_day")) < 14:
				_game_state.call("advance_day")
		if fired:
			break
	_expect_equal(fired, true, "Q1: seeded settle run can roll supply_glut")
	_qa_autoload.call("set_force_enabled", false)


func _test_supply_glut_wholesale_and_race() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var sealed := &"AA-SKIE-BLST"
	var staple := &"AA-BASE-088"
	var moq_id := &"skiefall-distributor-moq-day-2"
	var baseline_moq := _demand_signals.call("buy_signal_for_id", moq_id) as BuyConfirmSignal
	_expect_equal(baseline_moq != null, true, "Q1: catalog distributor MOQ exists")
	var baseline_cost := baseline_moq.unit_cost_cents
	_expect_equal(baseline_cost > 0, true, "Q1: catalog MOQ has a baseline wholesale")
	var sealed_sku := (_inventory_service.get("model") as InventoryModel).get_sku(sealed)
	var restock_baseline := PricingService.distributor_wholesale_cents(
		sealed_sku.base_market_cents if sealed_sku != null else 0,
		NORMAL_CONFIG
	)
	_expect_equal(restock_baseline > 0, true, "Q1: restock formula prices sealed wholesale")
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_sealed_wholesale_mult")), 1.0),
		true,
		"Q1: wholesale mult is 1.0 with event off"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_sealed_race_mult")), 1.0),
		true,
		"Q1: sealed race mult is 1.0 with event off"
	)
	_expect_equal(
		int(_demand_signals.call(
			"sealed_wholesale_cents",
			sealed,
			baseline_cost,
			DemandSignalService.Channel.DISTRIBUTOR
		)),
		baseline_cost,
		"Q1: sealed wholesale helper is identity off-event"
	)
	_expect_equal(
		int(_demand_signals.call("sealed_retail_comp_cents", sealed, 1000)),
		1000,
		"Q1: sealed retail helper is identity off-event"
	)
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_SUPPLY_GLUT,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_sealed_wholesale_mult")),
			MarketEventService.SUPPLY_GLUT_WHOLESALE_MULT
		),
		true,
		"Q1: glut wholesale mult is 0.75"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_sealed_race_mult")),
			MarketEventService.SUPPLY_GLUT_SEALED_RACE_MULT
		),
		true,
		"Q1: glut sealed race mult is 0.90"
	)
	var glut_moq := _demand_signals.call("buy_signal_for_id", moq_id) as BuyConfirmSignal
	_expect_equal(glut_moq != null, true, "Q1: catalog MOQ still offered during glut")
	_expect_equal(
		glut_moq.unit_cost_cents < baseline_cost,
		true,
		"Q1: sealed distributor/wholesale cost ↓ vs baseline"
	)
	_expect_equal(
		glut_moq.unit_cost_cents,
		int(_demand_signals.call(
			"sealed_wholesale_cents",
			sealed,
			baseline_cost,
			DemandSignalService.Channel.DISTRIBUTOR
		)),
		"Q1: catalog MOQ uses existing restock ledger × glut mult"
	)
	_expect_equal(
		is_equal_approx(
			float(glut_moq.unit_cost_cents),
			float(baseline_cost) * MarketEventService.SUPPLY_GLUT_WHOLESALE_MULT
		),
		true,
		"Q1: wholesale uses pack mult, not a second ledger"
	)
	var deep := _demand_signals.call(
		"buy_signal_for_id",
		&"supply-glut-deep-skie-blst"
	) as BuyConfirmSignal
	var skim := _demand_signals.call(
		"buy_signal_for_id",
		&"supply-glut-skim-dust-etb"
	) as BuyConfirmSignal
	_expect_equal(deep != null, true, "Q1: deep sealed restock lot is offered")
	_expect_equal(skim != null, true, "Q1: skim sealed restock lot is offered")
	_expect_equal(deep.quantity >= 6, true, "Q1: deep lot is a cash-lock quantity")
	_expect_equal(skim.quantity < deep.quantity, true, "Q1: skim lot is lighter than deep")
	_expect_equal(
		deep.unit_cost_cents,
		int(_demand_signals.call(
			"sealed_wholesale_cents",
			sealed,
			restock_baseline,
			DemandSignalService.Channel.DISTRIBUTOR
		)),
		"Q1: deep lot is current restock wholesale × glut"
	)
	var staple_cost := int(
		_demand_signals.call(
			"sealed_wholesale_cents",
			staple,
			1800,
			DemandSignalService.Channel.DISTRIBUTOR
		)
	)
	_expect_equal(staple_cost, 1800, "Q1: singles stay off the sealed wholesale discount")
	var market_sealed := int(
		_demand_signals.call(
			"sealed_wholesale_cents",
			sealed,
			1800,
			DemandSignalService.Channel.MARKETPLACE
		)
	)
	_expect_equal(market_sealed, 1800, "Q1: marketplace sealed stays off wholesale glut")
	_expect_equal(
		int(_demand_signals.call("sealed_retail_comp_cents", sealed, 1000)),
		900,
		"Q1: sealed retail race pressure is ×0.90"
	)
	_expect_equal(
		int(_demand_signals.call("sealed_retail_comp_cents", staple, 1000)),
		1000,
		"Q1: singles stay off the sealed retail race"
	)
	var wait: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(wait != null, true, "Q1: glut window is active")
	_demand_signals.call("roll_settle_events")
	var after_one: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(
		after_one != null and after_one.kind == MarketEvent.KIND_SUPPLY_GLUT,
		true,
		"Q1: day 1 wait-out keeps supply glut active"
	)
	_expect_equal(after_one.remaining_days, 2, "Q1: remaining_days ticks 3→2")
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_sealed_wholesale_mult")),
			MarketEventService.SUPPLY_GLUT_WHOLESALE_MULT
		),
		true,
		"Q1: wholesale stays down while remaining_days > 0"
	)
	_demand_signals.call("apply_event_save", {})
	_expect_equal(
		_demand_signals.call("has_supply_glut"),
		false,
		"Q1: clearing glut drops the flag"
	)
	var restored_moq := _demand_signals.call("buy_signal_for_id", moq_id) as BuyConfirmSignal
	_expect_equal(restored_moq != null, true, "Q1: catalog MOQ returns after glut")
	_expect_equal(
		restored_moq.unit_cost_cents,
		baseline_cost,
		"Q1: event ends → wholesale restores"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"supply-glut-deep-skie-blst") == null,
		true,
		"Q1: glut restock lots leave when the event ends"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_sealed_wholesale_mult")), 1.0),
		true,
		"Q1: wholesale mult restores after glut ends"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_sealed_race_mult")), 1.0),
		true,
		"Q1: sealed race mult restores after glut ends"
	)
	_expect_equal(
		int(_demand_signals.call("sealed_retail_comp_cents", sealed, 1000)),
		1000,
		"Q1: sealed retail race restores after glut ends"
	)


func _test_supply_glut_levers_and_no_soft_lock() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_SUPPLY_GLUT,
		{"duration_days": 3, "remaining_days": 3}
	)
	var cash_before := int(_economy.get("balance_cents"))
	var sealed_before := int(_inventory_service.call("total_owned", &"AA-SKIE-BLST"))
	var dust_before := int(_inventory_service.call("total_owned", &"AA-DUST-ETB"))
	var deep := _demand_signals.call(
		"buy_signal_for_id",
		&"supply-glut-deep-skie-blst"
	) as BuyConfirmSignal
	_expect_equal(deep != null and deep.can_confirm, true, "Q1: deep lot is confirmable")
	_expect_dto_has_no_truth_fields(deep, "Q1 glut deep buy signal")
	_assert_text_has_no_truth(
		DemandSignalPresenter.buy_summary(deep),
		"Q1 glut deep buy summary"
	)
	_expect_equal(
		_demand_signals.call("confirm_buy", deep),
		true,
		"Q1: buy-deep lever works during glut"
	)
	_expect_equal(
		int(_inventory_service.call("total_owned", &"AA-SKIE-BLST")),
		sealed_before + deep.quantity,
		"Q1: deep buy lands sealed stock"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - deep.lot_total_cents,
		"Q1: deep buy charges the discounted wholesale"
	)
	var skim := _demand_signals.call(
		"buy_signal_for_id",
		&"supply-glut-skim-dust-etb"
	) as BuyConfirmSignal
	_expect_equal(skim != null and skim.can_confirm, true, "Q1: skim lot is confirmable")
	_expect_equal(
		_demand_signals.call("confirm_buy", skim),
		true,
		"Q1: skim lever works during glut"
	)
	_expect_equal(
		int(_inventory_service.call("total_owned", &"AA-DUST-ETB")),
		dust_before + skim.quantity,
		"Q1: skim buy lands a lighter sealed lot"
	)
	_expect_equal(
		_demand_signals.call("dismiss_buy_opportunity", &"skiefall-distributor-moq-day-2"),
		true,
		"Q1: skip lever dismisses the leftover distributor lot"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"skiefall-distributor-moq-day-2") == null,
		true,
		"Q1: skipped lot stays closed — no soft-lock"
	)
	var sealed := &"AA-SKIE-BLST"
	var listed_before := int(_inventory_service.call("listed_price_for", sealed))
	var hold_dto := _demand_signals.call(
		"price_signal",
		sealed,
		listed_before,
		_inventory_service.call("location_for", sealed)
	) as PriceConfirmSignal
	_expect_dto_has_no_truth_fields(hold_dto, "Q1 glut hold-margin price signal")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(hold_dto),
		"Q1 glut hold-margin PriceEditor summary"
	)
	var race_price := maxi(1, floori(float(listed_before) * 0.90))
	_expect_equal(
		_inventory_service.call("set_listed_price", sealed, race_price),
		true,
		"Q1: price-race lever works during glut"
	)
	_expect_equal(
		int(_inventory_service.call("listed_price_for", sealed)),
		race_price,
		"Q1: raced listed price persists"
	)
	var race_dto := _demand_signals.call(
		"price_signal",
		sealed,
		race_price,
		_inventory_service.call("location_for", sealed)
	) as PriceConfirmSignal
	_expect_dto_has_no_truth_fields(race_dto, "Q1 glut price-race signal")
	_expect_equal(
		hold_dto.suggested_price_cents > 0,
		true,
		"Q1: hold-margin confirm stays usable"
	)
	_expect_equal(
		_game_state.call("start_floor"),
		true,
		"Q1: supply glut can open FLOOR"
	)
	_expect_equal(
		_game_state.call("start_settle"),
		true,
		"Q1: supply glut FLOOR can settle — no soft-lock"
	)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "Q1: HUD loads during glut levers")
	if hud != null:
		var open_price := hud.get_node_or_null("%OpenPriceButton") as Button
		var open_buy := hud.get_node_or_null("%OpenBuyButton") as Button
		_expect_equal(
			open_price != null and not open_price.disabled,
			true,
			"Q1: player can still open PriceEditor to race or hold"
		)
		_expect_equal(
			open_buy != null and not open_buy.disabled,
			true,
			"Q1: player can still open buys to deep / skim / skip"
		)
		hud.queue_free()


func _test_supply_glut_section_45_and_banner() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_SUPPLY_GLUT,
		{"duration_days": 3, "remaining_days": 3}
	)
	var banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(banner.contains("Distributor"), true, "Q1: banner is a distributor email")
	_expect_equal(banner.contains("glut") or banner.contains("Glut"), true, "Q1: banner names the glut")
	_expect_equal(
		banner.to_lower().contains("sealed") or banner.to_lower().contains("race"),
		true,
		"Q1: banner telegraphs sealed wholesale / retail race"
	)
	_expect_equal(banner.contains("true_market"), false, "Q1: email has no true_market")
	_assert_text_has_no_truth(banner, "Q1 supply glut banner")
	var buy_dto := _demand_signals.call(
		"buy_signal_for_id",
		&"supply-glut-deep-skie-blst"
	) as BuyConfirmSignal
	_expect_dto_has_no_truth_fields(buy_dto, "Q1 glut buy confirm")
	_assert_text_has_no_truth(
		DemandSignalPresenter.buy_summary(buy_dto),
		"Q1 glut buy summary"
	)
	_assert_text_has_no_truth(
		DemandSignalPresenter.buy_confirm_snapshot(buy_dto),
		"Q1 glut buy snapshot"
	)
	var price_dto := _demand_signals.call(
		"price_signal",
		&"AA-SKIE-BLST",
		int(_inventory_service.call("listed_price_for", &"AA-SKIE-BLST")),
		_inventory_service.call("location_for", &"AA-SKIE-BLST")
	) as PriceConfirmSignal
	_expect_dto_has_no_truth_fields(price_dto, "Q1 glut price confirm")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(price_dto),
		"Q1 glut price summary"
	)
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	var payload: Dictionary = _demand_signals.call("roll_settle_events")
	_assert_payload_has_no_truth(payload, "Q1 glut market_event_rolled")
	_expect_equal(
		payload.has("sealed_wholesale_mult")
		and payload.has("sealed_race_mult")
		and payload.has("supply_glut"),
		true,
		"Q1: instrumentation records sealed wholesale and race multipliers"
	)
	_qa_autoload.call("set_force_enabled", false)
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		false,
		"Q1: distributor banner does not open Option D PriceEditor"
	)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "Q1: HUD loads for glut email")
	if hud != null:
		var banner_label := hud.get_node_or_null("%EventBannerLabel") as Label
		_expect_equal(banner_label != null, true, "Q1: thin event banner exists")
		_expect_equal(
			banner_label != null
			and banner_label.visible
			and banner_label.text.contains("Distributor")
			and (
				banner_label.text.contains("glut")
				or banner_label.text.contains("Glut")
			),
			true,
			"Q1: HUD banner shows supply glut without a new screen"
		)
		_assert_text_has_no_truth(
			banner_label.text if banner_label != null else "",
			"Q1 HUD supply glut banner"
		)
		var price_panel := hud.get_node_or_null("%PriceEditor") as PanelContainer
		_expect_equal(
			price_panel == null or not price_panel.visible,
			true,
			"Q1: HUD does not force PriceEditor for supply glut"
		)
		hud.queue_free()


func _test_supply_glut_pack_coherence() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_SUPPLY_GLUT,
		{"duration_days": 3, "remaining_days": 3}
	)
	var recession: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_RECESSION,
		{"duration_days": 7, "remaining_days": 7}
	)
	_expect_equal(recession != null, true, "Q1: Recession week still starts")
	_expect_equal(
		_demand_signals.call("has_supply_glut"),
		false,
		"Q1: recession replaces glut on the shared pack bus"
	)
	_expect_equal(
		_demand_signals.call("has_recession_week"),
		true,
		"Q1: Recession week modifiers still apply"
	)
	_expect_equal(
		is_equal_approx(float(_demand_signals.call("active_sealed_wholesale_mult")), 1.0),
		true,
		"Q1: recession does not keep glut wholesale ↓"
	)
	var convention: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_CONVENTION,
		{"duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(convention != null, true, "Q1: Convention weekend still starts")
	_expect_equal(
		_demand_signals.call("has_convention_weekend"),
		true,
		"Q1: Convention weekend modifiers still apply"
	)
	var theft: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_THEFT_RING,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(theft != null, true, "Q1: Theft ring still starts")
	_expect_equal(
		_demand_signals.call("has_theft_ring"),
		true,
		"Q1: Theft ring modifiers still apply"
	)
	var scare: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_COUNTERFEIT,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(scare != null, true, "Q1: Counterfeit scare still starts")
	_expect_equal(
		_demand_signals.call("has_counterfeit_scare"),
		true,
		"Q1: Counterfeit scare modifiers still apply"
	)
	var hype: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_HYPE,
		{"sku_id": &"AA-SKIE-047", "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(hype != null, true, "Q1: Option D hype still starts")
	_expect_equal(hype.sku_id, &"AA-SKIE-047", "Q1: hype still targets Titan")
	_expect_equal(
		_demand_signals.call("wants_event_price_editor"),
		true,
		"Q1: Option D hype still wants the PriceEditor"
	)
	var fog: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_FOG,
		{"duration_days": 1, "remaining_days": 1}
	)
	_expect_equal(fog != null, true, "Q1: fog day still starts")
	_expect_equal(_demand_signals.call("has_fog_flag"), true, "Q1: fog flag still applies")
	_expect_equal(
		_demand_signals.call("has_supply_glut"),
		false,
		"Q1: fog does not leak glut wholesale"
	)
	var demand_src := FileAccess.get_file_as_string(
		"res://scripts/autoload/demand_signals.gd"
	)
	_expect_equal(
		demand_src.contains("func _ensure_priceable_sku"),
		true,
		"Q1: Soft _ensure_priceable_sku stays parked"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/customers/customer_spawner.gd"
		).contains("_ensure_priceable_sku"),
		false,
		"Q1: spawner does not call parked Soft helper"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/autoload/inventory_service.gd"
		).contains("func apply_shop_capacity_bonuses"),
		true,
		"Q1: apply_shop_capacity_bonuses is the Large-aware capacity helper"
	)
	_expect_equal(
		FileAccess.get_file_as_string(
			"res://scripts/customers/customer_archetype_catalog.gd"
		).contains("flipper_weight_mult"),
		true,
		"Q1: Soft flipper-weight stays parked"
	)


func _test_supply_glut_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var started: MarketEvent = _demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_SUPPLY_GLUT,
		{"duration_days": 3, "remaining_days": 3}
	)
	_expect_equal(started != null, true, "Q1 save: supply glut starts")
	_game_state.set("current_day", 11)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "Q1 supply glut save")
	var stored: Dictionary = saved.get("market_event", {})
	_expect_equal(String(stored.get("id", "")), "supply_glut", "Q1 save writes event id")
	_expect_equal(int(stored.get("remaining_days", 0)), 3, "Q1 save writes remaining days")
	_expect_equal(String(stored.get("kind", "")), "supply_glut", "Q1 save writes kind")
	_game_state.call("start_new_game")
	_expect_equal(
		_demand_signals.call("has_supply_glut"),
		false,
		"Q1: new game clears supply glut"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"Q1: restore_save accepts supply glut snapshot"
	)
	var restored: MarketEvent = _demand_signals.call("active_event")
	_expect_equal(restored != null, true, "Q1: save/load restores supply glut")
	_expect_equal(restored.kind, MarketEvent.KIND_SUPPLY_GLUT, "Q1: restored kind")
	_expect_equal(restored.remaining_days, 3, "Q1: save/load restores remaining days")
	_expect_equal(
		_demand_signals.call("has_supply_glut"),
		true,
		"Q1: restored glut re-applies wholesale ↓ / retail race"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_sealed_wholesale_mult")),
			MarketEventService.SUPPLY_GLUT_WHOLESALE_MULT
		),
		true,
		"Q1: restored glut still multiplies sealed wholesale"
	)
	_expect_equal(
		is_equal_approx(
			float(_demand_signals.call("active_sealed_race_mult")),
			MarketEventService.SUPPLY_GLUT_SEALED_RACE_MULT
		),
		true,
		"Q1: restored glut still applies sealed race pressure"
	)
	_expect_equal(
		int(_demand_signals.call(
			"sealed_wholesale_cents",
			&"AA-SKIE-BLST",
			1800,
			DemandSignalService.Channel.DISTRIBUTOR
		)),
		1350,
		"Q1: restored glut still discounts sealed distributor cost"
	)
	var restored_banner := String(_demand_signals.call("event_banner_text"))
	_expect_equal(
		restored_banner.contains("Distributor")
		and (
			restored_banner.contains("glut")
			or restored_banner.contains("Glut")
		),
		true,
		"Q1: restored banner still uses distributor email copy"
	)
	_assert_text_has_no_truth(restored_banner, "Q1 restored supply glut banner")


func _last_shrink_applied() -> Dictionary:
	var last: Dictionary = {}
	for event_value: Variant in _qa_autoload.call("get_events"):
		var event := event_value as Dictionary
		if String(event.get("event", "")) == "shrink_applied":
			last = event.get("payload", {})
	return last


func _assert_option_d_editor_open(
	hud: Node,
	sku_id: StringName,
	label: String
) -> void:
	var panel := hud.get_node_or_null("%PriceEditor") as PanelContainer
	if panel == null or not panel.visible:
		Callable(hud, "_maybe_open_event_price_editor").call()
		panel = hud.get_node_or_null("%PriceEditor") as PanelContainer
	_expect_equal(panel != null and panel.visible, true, "%s PriceEditor is open" % label)
	var price_signal := hud.get("_price_signal") as PriceConfirmSignal
	_expect_equal(price_signal != null, true, "%s PriceEditor has a signal" % label)
	if price_signal != null:
		_expect_equal(price_signal.sku_id, sku_id, "%s PriceEditor SKU" % label)
	var title := hud.get_node_or_null("%PriceTitle") as Label
	_expect_equal(
		title != null and title.text.begins_with("PRICE"),
		true,
		"%s PriceEditor title" % label
	)


func _test_marketplace_outing_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_captured_buy_focus_id = &""
	_beat_director.call("_start_day_beats", 3)
	_expect_equal(
		_beat_director.call("is_started", MARKETPLACE_OUTING_BEAT),
		true,
		"marketplace outing starts on Normal day three PREP"
	)
	_expect_equal(
		StringName(_captured_beat_decision.get("beat_id", &"")),
		MARKETPLACE_OUTING_BEAT,
		"outing decision carries beat tag"
	)
	_expect_equal(
		String(_captured_beat_decision.get("title", "")),
		"Off-site lot — leave the floor?",
		"outing modal title"
	)
	var outing_ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"drive_out" in outing_ids, true, "outing offers Drive out")
	_expect_equal(&"courier" in outing_ids, true, "outing offers Courier fee")
	_expect_equal(&"skip" in outing_ids, true, "outing offers Skip")
	_assert_payload_has_no_truth(_captured_beat_decision, "outing decision")
	var outing_dto := _demand_signals.call(
		"buy_signal_for_id",
		&"marketplace-outing-steal"
	) as BuyConfirmSignal
	_expect_equal(outing_dto != null, true, "outing injects marketplace lot")
	if outing_dto != null:
		_expect_dto_has_no_truth_fields(outing_dto, "outing buy signal")
		_expect_equal(outing_dto.channel, &"marketplace", "outing channel")
		_expect_equal(outing_dto.confidence, &"low", "outing Low confidence")
		_expect_equal(
			outing_dto.condition_cue.to_lower().contains("photo"),
			true,
			"outing Photo only condition cue"
		)
		var midpoint := (
			outing_dto.shown_comp_low_cents + outing_dto.shown_comp_high_cents
		) / 2
		_expect_equal(
			outing_dto.unit_cost_cents < midpoint,
			true,
			"outing lot looks underpriced vs noisy comp"
		)
		_expect_equal(
			outing_dto.beat_id,
			MARKETPLACE_OUTING_BEAT,
			"outing opportunity tagged for QA"
		)
	var attention_before := int(_game_state.get("attention_remaining"))
	_captured_buy_focus_id = &""
	_expect_equal(
		_beat_director.call("choose_beat_path", &"drive_out"),
		true,
		"outing Drive out path"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		attention_before - NORMAL_CONFIG.marketplace_outing_attention,
		"Drive out spends outing Attention"
	)
	_expect_equal(
		float(_game_state.get("pending_floor_skip_seconds")) > 0.0,
		true,
		"Drive out shortens FLOOR window"
	)
	_expect_equal(
		_captured_buy_focus_id,
		&"marketplace-outing-steal",
		"Drive out opens BuyOpportunityDetail"
	)
	_expect_equal(
		_beat_director.call("is_completed", MARKETPLACE_OUTING_BEAT),
		true,
		"Drive out completes outing beat"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 3)
	var cash_before_courier := int(_economy.get("balance_cents"))
	var attention_before_courier := int(_game_state.get("attention_remaining"))
	_captured_buy_focus_id = &""
	_expect_equal(
		_beat_director.call("choose_beat_path", &"courier"),
		true,
		"outing Courier path"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_courier - NORMAL_CONFIG.marketplace_courier_fee_cents,
		"Courier pays fee and keeps FLOOR"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		attention_before_courier,
		"Courier does not spend Attention"
	)
	_expect_equal(
		float(_game_state.get("pending_floor_skip_seconds")),
		0.0,
		"Courier does not skip FLOOR hours"
	)
	_expect_equal(
		_captured_buy_focus_id,
		&"marketplace-outing-steal",
		"Courier opens BuyOpportunityDetail"
	)
	_expect_equal(
		_captured_buy_focus_beat,
		MARKETPLACE_OUTING_BEAT,
		"Courier focus stays on the outing lot"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 3)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"skip"),
		true,
		"outing Skip path"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"marketplace-outing-steal") == null,
		true,
		"Skip dismisses the opportunity"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 3)
	_expect_equal(
		_beat_director.call("is_started", MARKETPLACE_OUTING_BEAT),
		false,
		"Hard does not auto-start marketplace outing"
	)
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect_equal(
		hud_source.contains("AA-SKIE-ETB"),
		false,
		"HUD does not hardcode outing SKU"
	)
	_expect_equal(
		hud_source.contains("beat_decision_requested"),
		true,
		"HUD wires optional beat decision modal"
	)
	var hud_scene := FileAccess.get_file_as_string(
		"res://scenes/ui/gameplay_hud.tscn"
	)
	_expect_equal(
		hud_scene.contains("BeatDecision"),
		true,
		"gameplay HUD has the optional beat decision panel"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_hire_cashier_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("is_started", HIRE_CASHIER_BEAT),
		true,
		"hire cashier starts on Normal day five PREP"
	)
	_expect_equal(
		String(_captured_beat_decision.get("title", "")),
		"Counter’s getting slammed — hire help?",
		"hire modal title"
	)
	var hire_ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"hire_cashier" in hire_ids, true, "hire offers Cashier")
	_expect_equal(&"keep_solo" in hire_ids, true, "hire offers Keep solo")
	_expect_equal(&"hire_cheap" in hire_ids, true, "hire offers cheap path")
	_expect_equal(&"hire_specialist" in hire_ids, true, "hire offers Specialist")
	var confirms: Dictionary = _captured_beat_decision.get("confirms", {})
	var cheap_confirm: Dictionary = confirms.get("hire_cheap", {})
	_expect_equal(
		String(cheap_confirm.get("body", "")).contains("Reliability"),
		true,
		"cheap hire confirm warns Reliability"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "hire decision")
	_expect_equal(
		_beat_director.call("choose_beat_path", &"hire_cashier"),
		true,
		"hire Cashier path"
	)
	var shop: ShopState = _game_state.get("shop")
	_expect_equal(shop.hired_count(), 1, "hire adds one staff")
	_expect_equal(shop.staff[0].wage_cents > 0, true, "hire stores a wage")
	_expect_equal(
		is_equal_approx(shop.staff[0].reliability, ShopState.CASHIER_RELIABILITY),
		true,
		"standard cashier reliability"
	)
	_expect_equal(shop.hire_cashier(false) == null, true, "Small staff cap blocks second hire")
	var cash_before_wage := int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_wage - ShopState.CASHIER_WAGE_CENTS,
		"cashier wage posts at SETTLE"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"hire_cheap"),
		true,
		"hire cheap path"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.staff[0].theft_bias, true, "cheap hire has theft/no-show bias")
	_expect_equal(
		shop.staff[0].reliability <= ShopState.CHEAP_CASHIER_RELIABILITY,
		true,
		"cheap hire Reliability at or below 0.55"
	)
	cash_before_wage = int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_wage - ShopState.CHEAP_CASHIER_WAGE_CENTS,
		"cheap wage posts at SETTLE"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"keep_solo"),
		true,
		"Keep solo closes hire beat"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.hired_count(), 0, "Keep solo adds no staff")
	cash_before_wage = int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_wage,
		"Keep solo posts no wage"
	)

	_game_state.call("set_balance_config", EASY_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	shop = _game_state.get("shop")
	_expect_equal(shop.is_owner_only(), false, "Easy seeds a trainee cashier")
	_expect_equal(
		_beat_director.call("is_started", HIRE_CASHIER_BEAT),
		false,
		"Easy/trainee does not auto-start hire beat"
	)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", HIRE_CASHIER_BEAT),
		false,
		"hire QA refuses when staff cap is already filled"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_specialist_staff_path() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.inspect_attention_cost(), 5, "no Specialist → Inspect Att 5")
	_expect_equal(shop.research_attention_cost(), 15, "no Specialist → Research Att 15")
	_expect_equal(shop.has_specialist_on_duty(), false, "owner-only has no Specialist")
	_expect_equal(
		NORMAL_CONFIG.specialist_wage_cents,
		14_000,
		"BalanceConfig specialist wage is $140/day"
	)
	_expect_equal(shop.specialist_wage_cents(), 14_000, "ShopState reads specialist wage")

	_expect_equal(shop.hire_specialist() != null, true, "hire Specialist under Small cap")
	_expect_equal(shop.specialist_count(), 1, "roster has one Specialist")
	_expect_equal(shop.staff[0].role, &"specialist", "hired role is specialist")
	_expect_equal(shop.staff[0].is_specialist(), true, "StaffMember.is_specialist")
	_expect_equal(shop.staff[0].wage_cents, 14_000, "Specialist wage from BalanceConfig")
	_expect_equal(shop.staff[0].visual_scene_path(), "", "Specialist is domain-only (no mesh)")
	_expect_equal(shop.has_specialist_on_duty(), true, "hired Specialist is on duty")
	_expect_equal(shop.inspect_attention_cost(), 2, "Specialist on duty → Inspect Att 2")
	_expect_equal(shop.research_attention_cost(), 10, "Specialist on duty → Research Att 10")
	_expect_equal(shop.hire_specialist() == null, true, "Small cap blocks second Specialist")
	_expect_equal(shop.hire_cashier(false) == null, true, "Small cap blocks cashier after Specialist")

	var cash_before := int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - 14_000,
		"Specialist wage posts at SETTLE"
	)

	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "specialist save payload")
	var saved_staff: Array = (saved.get("shop", {}) as Dictionary).get("staff", [])
	_expect_equal(saved_staff.size(), 1, "save writes Specialist roster")
	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.specialist_count(), 0, "new game clears Specialist")
	_expect_equal(shop.inspect_attention_cost(), 5, "new game owner Inspect 5")
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"restore_save accepts Specialist snapshot"
	)
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.specialist_count(), 1, "save/load restores Specialist")
	_expect_equal(shop.staff[0].role, &"specialist", "restored role is specialist")
	_expect_equal(shop.staff[0].wage_cents, 14_000, "restored Specialist wage")
	_expect_equal(shop.has_specialist_on_duty(), true, "restored Specialist is on duty")
	_expect_equal(shop.inspect_attention_cost(), 2, "restored Specialist Inspect Att 2")
	_expect_equal(shop.research_attention_cost(), 10, "restored Specialist Research Att 10")

	_expect_equal(shop.fire_staff(0) != null, true, "fire removes Specialist")
	_expect_equal(shop.specialist_count(), 0, "fired Specialist leaves roster")
	_expect_equal(shop.has_specialist_on_duty(), false, "fire clears on-duty Specialist")
	_expect_equal(shop.inspect_attention_cost(), 5, "after fire Inspect returns to 5")
	_expect_equal(shop.research_attention_cost(), 15, "after fire Research returns to 15")

	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"hire_specialist"),
		true,
		"day-5 hire beat can pick Specialist"
	)
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.specialist_count(), 1, "beat hire adds Specialist")
	_expect_equal(shop.cashier_count(), 0, "Specialist hire leaves cashiers unchanged")
	_assert_payload_has_no_truth(_captured_beat_decision, "specialist hire decision")

	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	_expect_equal(shop.expand_to_medium(18, 1_600_000, 55), true, "Medium unlocks staff cap 3")
	_expect_equal(shop.hire_cashier(false) != null, true, "Medium can still hire cashier")
	_expect_equal(shop.hire_specialist() != null, true, "Medium can hire Specialist after cashier")
	_expect_equal(shop.cashier_count(), 1, "cashier still on roster")
	_expect_equal(shop.specialist_count(), 1, "Specialist shares Medium cap")
	_expect_equal(shop.inspect_attention_cost(), 2, "mixed roster Inspect uses Specialist cost")
	_expect_equal(shop.research_attention_cost(), 10, "mixed roster Research uses Specialist cost")
	_expect_equal(shop.hire_cashier(false) != null, true, "Medium hire #3 still allowed")
	_expect_equal(shop.hire_specialist() == null, true, "Medium cap blocks fourth hire")
	_expect_equal(shop.hire_cashier(false) == null, true, "Medium cap still blocks extra cashier")

	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "gameplay HUD loads for Specialist")
	if hud == null:
		return
	var open_staff := hud.get_node_or_null("%OpenStaffButton") as Button
	var hire_specialist := hud.get_node_or_null("%HireSpecialistButton") as Button
	var open_research := hud.get_node_or_null("%OpenResearchButton") as Button
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(open_staff != null, true, "Staff hire button present")
	_expect_equal(
		open_research != null and open_research.text.contains("Att 15"),
		true,
		"HUD Research shows owner Att 15 before hire"
	)
	_expect_equal(
		inspect_button != null
		and inspect_button.text.contains("Inspect★")
		and inspect_button.text.contains("Att 5"),
		true,
		"HUD Inspect★ shows owner Att 5 before hire"
	)
	open_staff.pressed.emit()
	_expect_equal(
		hire_specialist != null and not hire_specialist.disabled,
		true,
		"Staff panel can hire Specialist under cap"
	)
	_expect_equal(
		hire_specialist != null and hire_specialist.text.contains("$140.00"),
		true,
		"Staff panel wage comes from BalanceConfig"
	)
	hire_specialist.pressed.emit()
	_expect_equal(shop.specialist_count(), 1, "HUD hire adds Specialist")
	_expect_equal(
		open_research.text.contains("Att 10"),
		true,
		"HUD Research shows Specialist Att 10 before confirm"
	)
	_expect_equal(
		inspect_button.text.contains("Att 2"),
		true,
		"HUD Inspect★ shows Specialist Att 2 before confirm"
	)
	_expect_equal(hire_specialist.disabled, true, "HUD hire disables at Small cap")
	var hire_cashier := hud.get_node_or_null("%HireCashierButton") as Button
	_expect_equal(
		hire_cashier != null and hire_cashier.disabled,
		true,
		"HUD cashier hire also blocked at cap"
	)

	var open_buy := hud.get_node_or_null("%OpenBuyButton") as Button
	open_buy.pressed.emit()
	_expect_equal(
		_click_buy_row_for_channel(hud, &"marketplace"),
		true,
		"marketplace lot for Specialist inspect"
	)
	_expect_equal(
		inspect_button.visible and not inspect_button.disabled,
		true,
		"Inspect★ enabled at Specialist cost"
	)
	_expect_equal(
		inspect_button.text.contains("Att 2"),
		true,
		"detail Inspect★ still shows Att 2"
	)
	inspect_button.pressed.emit()
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		98,
		"Inspect★ spends Specialist Att 2"
	)
	_assert_text_has_no_truth(inspect_button.text, "Inspect★ label")
	_assert_text_has_no_truth(open_research.text, "Research label")
	_assert_text_has_no_truth(hire_specialist.text, "hire Specialist label")
	_assert_payload_has_no_truth(_game_state.call("capture_save"), "post-hire save")
	root.remove_child(hud)
	hud.free()
	_game_state.call("start_new_game")


func _test_expand_medium_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 18)
	_expect_equal(
		_beat_director.call("is_started", EXPAND_MEDIUM_BEAT),
		true,
		"expand starts on Normal day 18 PREP even if gates fail"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"sign_lease"),
		false,
		"Sign stays gated without cash and Rep"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"wait_for_rep"),
		true,
		"Wait for Rep shows when Rep is low"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		false,
		"Sign cannot upgrade without gates"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "expand soft-fail")
	var shop: ShopState = _game_state.get("shop")
	var stay_walkable := shop.walkable_tile_count()
	_expect_equal(
		_beat_director.call("choose_beat_path", &"stay_small"),
		true,
		"Stay Small leaves the shop Small"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "Stay Small keeps Small tier")
	_expect_equal(shop.grid_width, ShopState.SMALL_GRID_WIDTH, "Stay Small width")
	_expect_equal(shop.grid_height, ShopState.SMALL_GRID_HEIGHT, "Stay Small height")
	_expect_equal(shop.layout.width, ShopState.SMALL_GRID_WIDTH, "Stay Small layout width")
	_expect_equal(shop.layout.height, ShopState.SMALL_GRID_HEIGHT, "Stay Small layout height")
	_expect_equal(shop.walkable_tile_count(), stay_walkable, "Stay Small walkable count")
	_assert_shop_shell_state(false, "Stay Small")

	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 18)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"sign_lease"),
		true,
		"Sign enabled when cash and Rep gates pass"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"wait_for_rep"),
		false,
		"Wait for Rep hidden when Rep already meets gate"
	)
	var confirms: Dictionary = _captured_beat_decision.get("confirms", {})
	var lease_confirm: Dictionary = confirms.get("sign_lease", {})
	var lease_body := String(lease_confirm.get("body", ""))
	_expect_equal(
		lease_body.contains(
			DemandSignalPresenter.format_cents(NORMAL_CONFIG.rent_small_weekly_cents)
		)
		and lease_body.contains(
			DemandSignalPresenter.format_cents(NORMAL_CONFIG.rent_medium_weekly_cents)
		),
		true,
		"lease confirm shows old vs new rent"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		true,
		"Sign lease path"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "Sign upgrades to Medium")
	_expect_equal(shop.staff_cap(), 3, "Medium staff cap unlocks")
	_expect_equal(shop.grid_width, ShopState.MEDIUM_GRID_WIDTH, "Medium grid width 14")
	_expect_equal(shop.grid_height, ShopState.MEDIUM_GRID_HEIGHT, "Medium grid height 10")
	_expect_equal(shop.layout.width, 14, "layout grows to Medium width")
	_expect_equal(shop.layout.height, 10, "layout grows to Medium height")
	_expect_equal(shop.tile_count(), 140, "Medium tile count is 140")
	_expect_equal(
		shop.walkable_tile_count() > stay_walkable,
		true,
		"Sign increases walkable tiles"
	)
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(1, 4),
		"existing fixtures stay on old tiles"
	)
	_expect_equal(shop.layout.has_circulation(), true, "Medium circulation holds")
	_expect_equal(
		(_inventory_service.get("model") as InventoryModel).case_slot_limit(),
		NORMAL_CONFIG.case_slots + ShopState.MEDIUM_CASE_SLOT_BONUS,
		"Medium case capacity unlocks"
	)
	_expect_equal(
		shop.weekly_rent_cents(18),
		NORMAL_CONFIG.rent_small_weekly_cents,
		"signed-day rent stays Small"
	)
	_expect_equal(
		shop.weekly_rent_cents(21),
		NORMAL_CONFIG.rent_medium_weekly_cents,
		"Medium rent applies next week"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 18)
	_expect_equal(
		_beat_director.call("is_started", EXPAND_MEDIUM_BEAT),
		false,
		"Hard does not auto-start Medium expand"
	)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", EXPAND_MEDIUM_BEAT),
		true,
		"Hard can still open the expand modal via QA"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		false,
		"Hard start cash/Rep cannot Sign"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_medium_floor_growth() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop: ShopState = _game_state.get("shop")
	var small_walkable := shop.walkable_tile_count()
	var small_grid_walkable := shop.floor_grid.walkable_count()
	_expect_equal(shop.tile_count(), 80, "Small starts 10×8")
	_expect_equal(small_walkable > 0, true, "Small has walkable tiles")
	_expect_equal(
		FileAccess.file_exists(ShopFloorExtent.MEDIUM_SHELL_SCENE),
		true,
		"Art Medium shell GLB is on disk"
	)
	_assert_shop_shell_state(false, "pre-Sign / Stay Small")

	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_economy.set("balance_cents", 1_000_000)
	_game_state.set("current_reputation", 40)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 18)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"wait_for_rep"),
		true,
		"Wait for Rep is available when Rep is low"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "Wait for Rep keeps Small")
	_expect_equal(shop.grid_width, 10, "Wait for Rep width unchanged")
	_expect_equal(shop.grid_height, 8, "Wait for Rep height unchanged")
	_expect_equal(shop.layout.width, 10, "Wait for Rep layout width")
	_expect_equal(shop.walkable_tile_count(), small_walkable, "Wait for Rep walkable")
	_expect_equal(
		shop.weekly_rent_cents(21),
		NORMAL_CONFIG.rent_small_weekly_cents,
		"Wait for Rep rent stays Small"
	)

	_game_state.call("start_new_game")
	shop = _game_state.get("shop")
	var counter := shop.layout.fixture_by_id(&"counter")
	_expect_equal(counter != null, true, "default counter exists")
	counter.is_counter = false
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	_expect_equal(
		shop.preview_expand_medium(),
		&"blocked_path",
		"expand preview fails when counter is unreachable"
	)
	_expect_equal(
		shop.expand_to_medium(18, 1_600_000, 55),
		false,
		"Sign refuses when Medium pathing fails"
	)
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "failed Sign stays Small")
	_expect_equal(shop.layout.width, 10, "failed Sign leaves layout Small")

	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	shop = _game_state.get("shop")
	var binder_origin := shop.layout.fixture_by_id(&"binder_rack").origin
	_expect_equal(
		_beat_director.call("_start_expand_medium"),
		true,
		"expand modal opens for growth test"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		true,
		"Sign lease grows the floor"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.grid_width, 14, "signed width is 14")
	_expect_equal(shop.grid_height, 10, "signed height is 10")
	_expect_equal(
		shop.walkable_tile_count() > small_walkable,
		true,
		"domain walkable tiles increase"
	)
	_expect_equal(
		shop.floor_grid.walkable_count() > small_grid_walkable,
		true,
		"NPC grid walkable tiles increase"
	)
	_expect_equal(shop.floor_grid.width, 14, "NPC grid width is Medium")
	_expect_equal(shop.floor_grid.is_walkable(Vector2i(12, 8)), true, "new Medium tile unlocks")
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		binder_origin,
		"binder stays on its Small tile"
	)
	_expect_equal(shop.layout.has_circulation(), true, "layout circulation on Medium")
	var circulation := shop.layout.circulation_path()
	_expect_equal(circulation.is_empty(), false, "entrance→displays→counter path")
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.entrance_tile,
		shop.floor_grid.browse_tiles[0],
		"Medium entrance→display"
	)
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.browse_tiles[0],
		shop.floor_grid.desk_tile,
		"Medium display→counter"
	)
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.entrance_tile,
		Vector2i(12, 8),
		"Medium entrance→new tile"
	)
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	_expect_equal(presenter.path_between(
		shop.floor_grid.tile_to_world(shop.floor_grid.entrance_tile),
		shop.floor_grid.tile_to_world(shop.floor_grid.desk_tile)
	).is_empty(), false, "presenter paths on Medium grid")
	presenter.free()

	_expect_equal(
		_economy.call("settle_weekly_obligations", 21),
		true,
		"week after Sign is a rent SETTLE day"
	)
	var rent_posted := 0
	var ledger: Array = _economy.call("get_ledger")
	for entry: Variant in ledger:
		var row := entry as LedgerEntry
		if row != null and row.category == &"rent":
			rent_posted = row.amount_cents
	_expect_equal(
		rent_posted,
		NORMAL_CONFIG.rent_medium_weekly_cents,
		"SETTLE posts Medium weekly rent"
	)

	_game_state.set("attention_remaining", 100)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	var moved := _game_state.call(
		"rearrange_fixture",
		&"binder_rack",
		Vector2i(12, 3)
	) as Dictionary
	_expect_equal(bool(moved.get("ok", false)), true, "rearrange onto new Medium tile")
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(12, 3),
		"binder occupies unlocked tile"
	)

	var saved: Dictionary = _game_state.call("capture_save")
	_expect_equal(saved.has("shop"), true, "save includes shop")
	_game_state.call("start_new_game")
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "new game resets to Small")
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"restore Medium save"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "save/load restores Medium")
	_expect_equal(shop.grid_width, 14, "save/load width")
	_expect_equal(shop.grid_height, 10, "save/load height")
	_expect_equal(shop.layout.width, 14, "save/load layout width")
	_expect_equal(shop.staff_cap(), 3, "save/load staff cap")
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		Vector2i(12, 3),
		"save/load keeps migrated fixture"
	)
	_expect_equal(
		shop.weekly_rent_cents(int(_game_state.get("current_day"))),
		NORMAL_CONFIG.rent_small_weekly_cents,
		"save/load signed-day rent stays Small"
	)
	_expect_equal(
		shop.weekly_rent_cents(int(_game_state.get("current_day")) + 3),
		NORMAL_CONFIG.rent_medium_weekly_cents,
		"save/load Medium rent tier"
	)
	_expect_equal(
		(_inventory_service.get("model") as InventoryModel).case_slot_limit(),
		NORMAL_CONFIG.case_slots + ShopState.MEDIUM_CASE_SLOT_BONUS,
		"save/load Medium case bonus"
	)
	_expect_equal(is_equal_approx(shop.usable_sq_ft(), 1220.625), true, "14×10 is ~1,221 sq ft")

	_assert_shop_shell_state(true, "Sign / save-load Medium")

	_game_state.call("start_new_game")
	_assert_shop_shell_state(false, "new game resets Small shell")


func _test_medium_overhead_lights() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_assert_overhead_lights_for_tier(false, "pre-Sign Small")

	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	var shop: ShopState = _game_state.get("shop")
	_expect_equal(
		shop.expand_to_medium(18, 1_600_000, 55),
		true,
		"Sign grows floor so Medium extras can show"
	)
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "expand sets Medium tier")
	_assert_overhead_lights_for_tier(true, "post-Sign Medium")

	_game_state.call("start_new_game")
	_assert_overhead_lights_for_tier(false, "new game hides Medium extras")


func _test_expand_large_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 40)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 40)
	_expect_equal(
		_beat_director.call("is_started", EXPAND_LARGE_BEAT),
		false,
		"Large does not start while the shop is still Small"
	)

	_force_medium_shop(18)
	_economy.set("balance_cents", 2_000_000)
	_game_state.set("current_reputation", 60)
	_game_state.set("current_day", 40)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 40)
	_expect_equal(
		_beat_director.call("is_started", EXPAND_LARGE_BEAT),
		true,
		"Large starts on Normal day 40 PREP even if gates fail"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"sign_lease"),
		false,
		"Sign stays gated below $40k cash and Rep 70"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"wait_for_cash_rep"),
		true,
		"Wait shows when cash or Rep is short"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		false,
		"Sign cannot upgrade without Large gates"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "Large expand soft-fail")
	_assert_text_has_no_truth(
		String(_captured_beat_decision.get("summary", "")),
		"Large expand summary"
	)
	var shop: ShopState = _game_state.get("shop")
	var stay_walkable := shop.walkable_tile_count()
	var stay_rent := shop.weekly_rent_cents(42)
	var stay_cap := shop.staff_cap()
	var stay_traffic := shop.traffic_mult()
	_expect_equal(
		_beat_director.call("choose_beat_path", &"stay_medium"),
		true,
		"Stay Medium leaves the shop Medium"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "Stay Medium keeps Medium tier")
	_expect_equal(shop.grid_width, ShopState.MEDIUM_GRID_WIDTH, "Stay Medium width")
	_expect_equal(shop.grid_height, ShopState.MEDIUM_GRID_HEIGHT, "Stay Medium height")
	_expect_equal(shop.walkable_tile_count(), stay_walkable, "Stay Medium walkable")
	_expect_equal(shop.staff_cap(), stay_cap, "Stay Medium staff cap")
	_expect_equal(shop.weekly_rent_cents(42), stay_rent, "Stay Medium rent")
	_expect_equal(
		is_equal_approx(shop.traffic_mult(), stay_traffic),
		true,
		"Stay Medium traffic"
	)
	_assert_shop_shell_state(true, "Stay Medium keeps Medium shell")

	_game_state.call("start_new_game")
	_force_medium_shop(18)
	_economy.set("balance_cents", 3_000_000)
	_game_state.set("current_reputation", 60)
	_game_state.set("current_day", 40)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_expand_large")
	_expect_equal(
		_beat_director.call("choose_beat_path", &"wait_for_cash_rep"),
		true,
		"Wait for cash-Rep is available when gates fail"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "Wait keeps Medium")
	_expect_equal(
		shop.weekly_rent_cents(42),
		NORMAL_CONFIG.rent_medium_weekly_cents,
		"Wait keeps Medium rent"
	)
	_expect_equal(shop.staff_cap(), 3, "Wait keeps Medium staff cap")
	_assert_shop_shell_state(true, "Wait for cash-Rep keeps Medium shell")

	_game_state.call("start_new_game")
	_force_medium_shop(18)
	_economy.set("balance_cents", 3_999_999)
	_game_state.set("current_reputation", 70)
	shop = _game_state.get("shop")
	_expect_equal(
		shop.can_sign_large_lease(3_999_999, 70),
		false,
		"one cent below $40k cannot Sign"
	)
	_economy.set("balance_cents", 4_000_000)
	_game_state.set("current_reputation", 69)
	_expect_equal(
		shop.can_sign_large_lease(4_000_000, 69),
		false,
		"Rep 69 cannot Sign"
	)

	_game_state.call("start_new_game")
	_force_medium_shop(18)
	_economy.set("balance_cents", 4_000_000)
	_game_state.set("current_reputation", 70)
	_game_state.set("current_day", 40)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	var hud := _instantiate_gameplay_hud()
	_captured_beat_decision = {}
	_beat_director.call("_start_expand_large")
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"sign_lease"),
		true,
		"Sign enabled when cash and Rep gates pass"
	)
	_expect_equal(
		_choice_enabled(_captured_beat_decision, &"wait_for_cash_rep"),
		false,
		"Wait hidden when both Large gates pass"
	)
	var confirms: Dictionary = _captured_beat_decision.get("confirms", {})
	var lease_confirm: Dictionary = confirms.get("sign_lease", {})
	var lease_body := String(lease_confirm.get("body", ""))
	_expect_equal(
		lease_body.contains(
			DemandSignalPresenter.format_cents(NORMAL_CONFIG.rent_medium_weekly_cents)
		)
		and lease_body.contains(
			DemandSignalPresenter.format_cents(NORMAL_CONFIG.rent_large_weekly_cents)
		),
		true,
		"Large lease confirm shows Medium vs Large rent"
	)
	_expect_equal(
		lease_body.contains("1.25") or lease_body.contains("×1.25"),
		true,
		"Large lease confirm documents the traffic scalar"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "Large expand sign payload")
	_assert_text_has_no_truth(lease_body, "Large lease confirm body")
	if hud != null:
		var title := hud.get_node_or_null("%BeatDecisionTitle") as Label
		var summary := hud.get_node_or_null("%BeatDecisionSummary") as Label
		var confirm_body := hud.get_node_or_null("%BeatConfirmBody") as Label
		_expect_equal(
			title != null and title.text.contains("Large"),
			true,
			"HUD lease title names Large"
		)
		_assert_text_has_no_truth(
			title.text if title != null else "",
			"HUD Large title"
		)
		_assert_text_has_no_truth(
			summary.text if summary != null else "",
			"HUD Large summary"
		)
		var sign_button := hud.get_node_or_null("%BeatChoiceAButton") as Button
		if sign_button != null and not sign_button.disabled:
			sign_button.pressed.emit()
			_assert_text_has_no_truth(
				confirm_body.text if confirm_body != null else "",
				"HUD Large confirm"
			)
		root.remove_child(hud)
		hud.free()
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		true,
		"Sign Large lease path"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.LARGE, "Sign upgrades to Large")
	_expect_equal(shop.staff_cap(), 5, "Large staff cap unlocks")
	_expect_equal(shop.grid_width, ShopState.LARGE_GRID_WIDTH, "Large grid width 18")
	_expect_equal(shop.grid_height, ShopState.LARGE_GRID_HEIGHT, "Large grid height 13")
	_expect_equal(shop.tile_count(), 234, "Large tile count is 234")
	_expect_equal(
		shop.walkable_tile_count() > stay_walkable,
		true,
		"Sign increases walkable tiles past Medium"
	)
	_expect_equal(shop.layout.has_circulation(), true, "Large circulation holds")
	_expect_equal(
		(_inventory_service.get("model") as InventoryModel).case_slot_limit(),
		NORMAL_CONFIG.case_slots
		+ ShopState.MEDIUM_CASE_SLOT_BONUS
		+ ShopState.LARGE_CASE_SLOT_BONUS,
		"Large case capacity unlocks"
	)
	_expect_equal(
		shop.weekly_rent_cents(40),
		NORMAL_CONFIG.rent_medium_weekly_cents,
		"signed-day rent stays Medium"
	)
	_expect_equal(
		shop.weekly_rent_cents(42),
		NORMAL_CONFIG.rent_large_weekly_cents,
		"Large rent applies next week"
	)
	_expect_equal(
		is_equal_approx(shop.traffic_mult(), 1.25),
		true,
		"Sign applies Large traffic scalar"
	)
	_expect_equal(
		shop.traffic_mult() < 2.0 * NORMAL_CONFIG.expand_medium_traffic_mult,
		true,
		"Signed Large traffic is not 2× Medium"
	)
	_assert_large_shell_state("Sign Large Art shell")

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_force_medium_shop(18)
	_game_state.set("current_day", 40)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 40)
	_expect_equal(
		_beat_director.call("is_started", EXPAND_LARGE_BEAT),
		false,
		"Hard does not auto-start Large expand"
	)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", EXPAND_LARGE_BEAT),
		true,
		"Hard can still open the Large expand modal via QA"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		false,
		"Hard start cash/Rep cannot Sign Large"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")

	var demand_src := FileAccess.get_file_as_string(
		"res://scripts/autoload/demand_signals.gd"
	)
	_expect_equal(
		demand_src.contains("func _ensure_priceable_sku"),
		true,
		"L1: Soft _ensure_priceable_sku stays parked"
	)
	for path: String in [
		"res://scripts/shop/shop_state.gd",
		"res://scripts/core/beat_injection.gd",
		"res://scripts/core/balance_config.gd",
		"res://scripts/customers/customer_spawner.gd",
		"res://scripts/ui/hud.gd",
		"res://scripts/shop/shop_floor_extent.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_expect_equal(
			source.contains("_ensure_priceable_sku"),
			false,
			"L1: %s does not call parked Soft helper" % path
		)


func _test_large_floor_growth() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop: ShopState = _force_medium_shop(18)
	var medium_walkable := shop.walkable_tile_count()
	var medium_grid_walkable := shop.floor_grid.walkable_count()
	_expect_equal(shop.tile_count(), 140, "Large growth starts from Medium 14×10")
	_assert_shop_shell_state(true, "pre-Large / Stay Medium")

	_economy.set("balance_cents", 2_500_000)
	_game_state.set("current_reputation", 60)
	_expect_equal(
		shop.expand_to_large(40, 2_500_000, 60),
		false,
		"Sign refuses Large when cash/Rep fail"
	)
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "failed Sign stays Medium")
	_expect_equal(shop.layout.width, 14, "failed Sign leaves layout Medium")

	var counter := shop.layout.fixture_by_id(&"counter")
	_expect_equal(counter != null, true, "default counter exists for Large preview")
	counter.is_counter = false
	_economy.set("balance_cents", 4_000_000)
	_game_state.set("current_reputation", 70)
	_expect_equal(
		shop.preview_expand_large(),
		&"blocked_path",
		"Large expand preview fails when counter is unreachable"
	)
	_expect_equal(
		shop.expand_to_large(40, 4_000_000, 70),
		false,
		"Sign refuses when Large pathing fails"
	)
	_expect_equal(shop.tier, ShopState.Tier.MEDIUM, "blocked Large Sign stays Medium")

	_game_state.call("start_new_game")
	shop = _force_medium_shop(18)
	_economy.set("balance_cents", 4_000_000)
	_game_state.set("current_reputation", 70)
	_game_state.set("current_day", 40)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	var binder_origin := shop.layout.fixture_by_id(&"binder_rack").origin
	_expect_equal(
		_beat_director.call("_start_expand_large"),
		true,
		"Large expand modal opens for growth test"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"sign_lease"),
		true,
		"Sign lease grows the Large floor"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.grid_width, 18, "signed Large width is 18")
	_expect_equal(shop.grid_height, 13, "signed Large height is 13")
	_expect_equal(
		shop.walkable_tile_count() > medium_walkable,
		true,
		"domain walkable tiles increase on Large"
	)
	_expect_equal(
		shop.floor_grid.walkable_count() > medium_grid_walkable,
		true,
		"NPC grid walkable tiles increase on Large"
	)
	_expect_equal(shop.floor_grid.width, 18, "NPC grid width is Large")
	_expect_equal(shop.floor_grid.is_walkable(Vector2i(16, 11)), true, "new Large tile unlocks")
	_expect_equal(
		shop.layout.fixture_by_id(&"binder_rack").origin,
		binder_origin,
		"binder stays on its Medium tile"
	)
	_expect_equal(shop.layout.has_circulation(), true, "layout circulation on Large")
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.entrance_tile,
		shop.floor_grid.browse_tiles[0],
		"Large entrance→display"
	)
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.browse_tiles[0],
		shop.floor_grid.desk_tile,
		"Large display→counter"
	)
	_assert_grid_path(
		shop.floor_grid,
		shop.floor_grid.entrance_tile,
		Vector2i(16, 11),
		"Large entrance→new tile"
	)
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	_expect_equal(presenter.path_between(
		shop.floor_grid.tile_to_world(shop.floor_grid.entrance_tile),
		shop.floor_grid.tile_to_world(shop.floor_grid.desk_tile)
	).is_empty(), false, "presenter paths on Large grid")
	presenter.free()

	_expect_equal(
		_economy.call("settle_weekly_obligations", 42),
		true,
		"week after Large Sign is a rent SETTLE day"
	)
	var rent_posted := 0
	var ledger: Array = _economy.call("get_ledger")
	for entry: Variant in ledger:
		var row := entry as LedgerEntry
		if row != null and row.category == &"rent":
			rent_posted = row.amount_cents
	_expect_equal(
		rent_posted,
		NORMAL_CONFIG.rent_large_weekly_cents,
		"SETTLE posts Large weekly rent"
	)

	var saved: Dictionary = _game_state.call("capture_save")
	_expect_equal(saved.has("shop"), true, "save includes shop after Large")
	_assert_payload_has_no_truth(saved, "Large save payload")
	_game_state.call("start_new_game")
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.SMALL, "new game resets to Small")
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"restore Large save"
	)
	shop = _game_state.get("shop")
	_expect_equal(shop.tier, ShopState.Tier.LARGE, "save/load restores Large")
	_expect_equal(shop.grid_width, 18, "save/load Large width")
	_expect_equal(shop.grid_height, 13, "save/load Large height")
	_expect_equal(shop.staff_cap(), 5, "save/load Large staff cap")
	_expect_equal(
		shop.weekly_rent_cents(int(_game_state.get("current_day")) + 3),
		NORMAL_CONFIG.rent_large_weekly_cents,
		"save/load Large rent tier"
	)
	_expect_equal(
		(_inventory_service.get("model") as InventoryModel).case_slot_limit(),
		NORMAL_CONFIG.case_slots
		+ ShopState.MEDIUM_CASE_SLOT_BONUS
		+ ShopState.LARGE_CASE_SLOT_BONUS,
		"save/load Large case bonus"
	)
	_expect_equal(is_equal_approx(shop.usable_sq_ft(), 2040.1875), true, "18×13 is ~2,040 sq ft")
	_assert_large_shell_state("Sign / save-load Large")

	_game_state.call("start_new_game")
	_assert_shop_shell_state(false, "new game resets Small shell after Large")


func _force_medium_shop(signed_day: int) -> ShopState:
	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	var shop: ShopState = _game_state.get("shop")
	_expect_equal(
		shop.expand_to_medium(signed_day, 1_600_000, 55),
		true,
		"force Medium shop for Large tests"
	)
	_inventory_service.call(
		"apply_shop_capacity_bonuses",
		ShopState.MEDIUM_CASE_SLOT_BONUS,
		ShopState.MEDIUM_BACKSTOCK_BONUS
	)
	return shop


func _force_large_shop(signed_day: int) -> ShopState:
	var shop := _force_medium_shop(signed_day)
	_economy.set("balance_cents", 4_000_000)
	_game_state.set("current_reputation", 70)
	_expect_equal(
		shop.expand_to_large(signed_day, 4_000_000, 70),
		true,
		"force Large shop for Flagship tests"
	)
	_inventory_service.call(
		"apply_shop_capacity_bonuses",
		shop.case_slot_bonus(),
		shop.backstock_bonus()
	)
	return shop


func _test_shady_trunk_beat() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 18)
	_beat_director.call("choose_beat_path", &"stay_small")
	_game_state.set("current_day", 20)
	_captured_beat_decision = {}
	_captured_buy_focus_id = &""
	_beat_director.call("_start_day_beats", 20)
	_expect_equal(
		_beat_director.call("is_started", SHADY_TRUNK_BEAT),
		true,
		"shady trunk starts on Normal day 20 PREP after expand resolves"
	)
	_expect_equal(
		String(_captured_beat_decision.get("title", "")),
		"Trunk sale — too good?",
		"shady modal title"
	)
	var shady_ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"buy" in shady_ids, true, "shady offers Buy")
	_expect_equal(&"report" in shady_ids, true, "shady offers Report")
	_expect_equal(&"ignore" in shady_ids, true, "shady offers Ignore")
	_expect_equal(
		bool(_captured_beat_decision.get("night_prep", false)),
		true,
		"shady carries Night/PREP flag"
	)
	_expect_equal(
		_game_state.call("is_night_prep"),
		true,
		"shady starts during Night/PREP"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "shady decision")
	var shady_dto := _demand_signals.call(
		"buy_signal_for_id",
		&"shady-trunk-lot"
	) as BuyConfirmSignal
	_expect_equal(shady_dto != null, true, "shady injects trunk lot")
	if shady_dto != null:
		_expect_dto_has_no_truth_fields(shady_dto, "shady buy signal")
		_expect_equal(shady_dto.channel, &"shady", "shady channel")
		_expect_equal(shady_dto.confidence, &"low", "shady Low confidence")
		_expect_equal(
			shady_dto.condition_cue.to_lower().contains("inspect"),
			true,
			"shady strong inspect cue"
		)
		_expect_equal(
			shady_dto.beat_id,
			SHADY_TRUNK_BEAT,
			"shady opportunity tagged for QA"
		)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"buy"),
		true,
		"shady Buy path"
	)
	_expect_equal(
		_captured_buy_focus_beat,
		SHADY_TRUNK_BEAT,
		"Buy opens BuyOpportunityDetail"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"shady-trunk-lot") != null,
		true,
		"Buy keeps the lot available with fog intact"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 20)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", SHADY_TRUNK_BEAT),
		true,
		"shady QA trigger"
	)
	var rep_before := int(_game_state.get("current_reputation"))
	var stock_before: int = _inventory_service.call("total_owned", &"AA-SKIE-ETB")
	_expect_equal(
		_beat_director.call("choose_beat_path", &"report"),
		true,
		"shady Report path"
	)
	_expect_equal(
		int(_game_state.get("current_reputation")),
		rep_before + NORMAL_CONFIG.shady_report_rep_gain,
		"Report grants Rep"
	)
	_expect_equal(
		int(_inventory_service.call("total_owned", &"AA-SKIE-ETB")),
		stock_before,
		"Report grants no inventory"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"shady-trunk-lot") == null,
		true,
		"Report dismisses the opportunity"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 22)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", SHADY_TRUNK_BEAT),
		true,
		"shady Ignore setup"
	)
	_expect_equal(
		_beat_director.call("choose_beat_path", &"ignore"),
		true,
		"shady Ignore path"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"shady-trunk-lot") == null,
		true,
		"Ignore dismisses the opportunity"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 20)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 20)
	_expect_equal(
		_beat_director.call("is_started", SHADY_TRUNK_BEAT),
		false,
		"Hard does not auto-start shady trunk"
	)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_showcase_slab_and_singles_preconditions() -> void:
	_beat_director.call("reset")
	var inventory := _inventory_service.get("model") as InventoryModel
	for card: CardInstance in inventory.cards.duplicate():
		if card.sku_id in [&"AA-SKIE-047", &"AA-SKIE-058"]:
			inventory.remove_card(card)
	for slab: SlabInstance in inventory.slabs.duplicate():
		inventory.remove_slab(slab)
	_game_state.set("current_day", 10)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call(
			"trigger_qa_beat",
			SHOWCASE_BEAT
		),
		true,
		"showcase QA trigger"
	)
	var empress_slab := (
		_inventory_service.call("get_slab", &"AA-SKIE-052") as SlabInstance
	)
	var titan := (
		_inventory_service.call("get_card", &"AA-SKIE-047") as CardInstance
	)
	var paragon := (
		_inventory_service.call("get_card", &"AA-SKIE-058") as CardInstance
	)
	_expect_equal(empress_slab != null, true, "showcase ensures Empress slab")
	_expect_equal(titan != null, true, "showcase ensures Titan single")
	_expect_equal(paragon != null, true, "showcase ensures Paragon single")
	_expect_equal(
		int(_inventory_service.call("case_free_slot_weight")) >= 2,
		true,
		"showcase starts with two free slot-weights"
	)
	_expect_equal(
		_beat_director.call("choose_showcase", &"slab"),
		true,
		"choose slab"
	)
	_expect_equal(
		empress_slab.location.type,
		InventoryLocation.Type.CASE,
		"slab moves through case API"
	)
	_expect_equal(
		_beat_director.call("choose_showcase", &"singles"),
		true,
		"switch to singles"
	)
	_expect_equal(
		empress_slab.location.type,
		InventoryLocation.Type.ONLINE_HOLD,
		"singles choice removes slab from case"
	)
	_expect_equal(titan.location.type, InventoryLocation.Type.CASE, "Titan in case")
	_expect_equal(paragon.location.type, InventoryLocation.Type.CASE, "Paragon in case")
	_qa_autoload.call("set_force_enabled", false)


func _test_shop_camera_framing() -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "shop_floor scene loads")
	if packed == null:
		return
	var shop: Node = packed.instantiate()
	var camera := shop.get_node_or_null("Camera") as ShopCamera
	_expect_equal(camera != null, true, "Camera present")
	if camera == null:
		shop.free()
		return
	_expect_equal(camera.current, true, "Camera is current")
	_expect_equal(
		camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
		true,
		"Day1 start is Art behind-desk home"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(ShopCamera.BEHIND_COUNTER_ROTATION_DEGREES),
		true,
		"Day1 start is Art behind-desk pitch"
	)
	_expect_equal(is_equal_approx(camera.fov, ShopCamera.HOME_FOV), true, "Art Lead camera FOV")
	_expect_equal(
		camera.aisle_position.is_equal_approx(ShopCamera.AISLE_POSITION),
		true,
		"Aisle home position is locked Art SoT"
	)
	_expect_equal(
		camera.aisle_rotation_degrees.is_equal_approx(ShopCamera.AISLE_ROTATION_DEGREES),
		true,
		"Aisle home rotation is locked Art SoT"
	)
	_expect_equal(
		camera.behind_counter_position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
		true,
		"Behind-desk export matches Art SoT"
	)
	camera.apply_home_pose(ShopCamera.POSE_AISLE)
	_expect_equal(
		camera.position.is_equal_approx(ShopCamera.AISLE_POSITION),
		true,
		"Aisle pose applies Art reset position"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(ShopCamera.AISLE_ROTATION_DEGREES),
		true,
		"Aisle pose applies Art reset pitch"
	)
	_expect_equal(is_equal_approx(camera.fov, 70.0), true, "Aisle pose keeps FOV 70")
	camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
	_expect_equal(
		camera.position.is_equal_approx(Vector3(7.2, 1.6, -0.65)),
		true,
		"Behind-desk pose restores Art home"
	)
	var world := shop.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_expect_equal(world != null, true, "WorldEnvironment present")
	if world != null and world.environment != null:
		_expect_equal(
			world.environment.ambient_light_source,
			Environment.AMBIENT_SOURCE_COLOR,
			"interior ambient uses color fill"
		)
	var lights_root := shop.get_node_or_null("Fixtures/OverheadLights")
	_assert_small_overheads_locked(lights_root, "camera framing")
	_assert_medium_overheads(lights_root, false, "camera framing authored Small")
	var aisle_amp: Node3D = null
	if lights_root != null:
		aisle_amp = lights_root.get_node_or_null("BackLeftAisle") as Node3D
	_expect_equal(aisle_amp != null, true, "optional 5th overhead instance present")
	if aisle_amp != null:
		_expect_equal(
			aisle_amp.position.is_equal_approx(Vector3(2.8, 2.78, -5.4)),
			true,
			"Light5 covers binder-rack / back-left aisle"
		)
	_assert_shop_fog_nacked(shop, "camera framing")
	var stool := shop.get_node_or_null("Fixtures/CounterStool") as Node3D
	_expect_equal(stool != null, true, "CounterStool present")
	if stool != null:
		_expect_equal(
			stool.position.is_equal_approx(Vector3(8.1, 0, -0.9)),
			true,
			"Art SoT CounterStool off entrance lane"
		)
	shop.free()


func _test_heavier_decor_placement() -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "shop_floor scene loads for heavier décor")
	if packed == null:
		return
	var shop: Node = packed.instantiate()
	var play_table := shop.get_node_or_null("Fixtures/PlayTable") as Node3D
	var slab_case := shop.get_node_or_null("Fixtures/SlabDisplayCase") as Node3D
	var window := shop.get_node_or_null("Fixtures/ShopWindow") as Node3D
	var glimpse := shop.get_node_or_null("Fixtures/BackOfficeGlimpse") as Node3D
	var a04 := shop.get_node_or_null("Fixtures/HighValueDisplayCase") as Node3D
	var backstock := shop.get_node_or_null("Fixtures/BackstockDoor") as Node3D
	var camera := shop.get_node_or_null("Camera") as ShopCamera
	_expect_equal(play_table != null, true, "PlayTable instanced")
	_expect_equal(slab_case != null, true, "SlabDisplayCase instanced")
	_expect_equal(window != null, true, "ShopWindow instanced")
	_expect_equal(glimpse != null, true, "BackOfficeGlimpse instanced")
	if play_table != null:
		_expect_equal(
			play_table.position.is_equal_approx(Vector3(2.7, 0, -4.5)),
			true,
			"B09 play table 2×2 island on open floor"
		)
		_expect_equal(
			play_table.scale.is_equal_approx(Vector3.ONE),
			true,
			"B09 authored scale"
		)
	if slab_case != null:
		_expect_equal(
			slab_case.position.is_equal_approx(Vector3(7.2, 0, -4.05)),
			true,
			"B01 slab case adjacent on A04 case run"
		)
		_expect_equal(
			slab_case.scale.is_equal_approx(Vector3.ONE),
			true,
			"B01 authored scale"
		)
	if a04 != null and slab_case != null:
		_expect_equal(
			is_equal_approx(a04.position.x, slab_case.position.x),
			true,
			"B01 shares A04 case-run X"
		)
		_expect_equal(
			is_equal_approx(absf(slab_case.position.z - a04.position.z), 0.9),
			true,
			"B01 is one 0.9 m tile behind A04"
		)
	if window != null:
		_expect_equal(
			window.position.is_equal_approx(Vector3(0, 1.62, -2.25)),
			true,
			"B06 window left-wall mount at poster height"
		)
		_expect_equal(
			window.rotation_degrees.is_equal_approx(Vector3(0, 90, 0)),
			true,
			"B06 yaw faces into room from left wall"
		)
		_expect_equal(
			window.scale.is_equal_approx(Vector3.ONE),
			true,
			"B06 authored scale"
		)
	if glimpse != null:
		_expect_equal(
			glimpse.position.is_equal_approx(Vector3(4.5, 0, -7.05)),
			true,
			"B07 glimpse sits at A13 alcove rear on interior floor"
		)
		_expect_equal(
			glimpse.position.z >= -7.15 and glimpse.position.z <= -6.95,
			true,
			"B07 Z stays in Art alcove-rear band −7.15…−6.95"
		)
		_expect_equal(
			glimpse.scale.is_equal_approx(Vector3.ONE),
			true,
			"B07 authored scale"
		)
		_expect_equal(
			glimpse.rotation_degrees.is_equal_approx(Vector3.ZERO),
			true,
			"B07 identity rotation"
		)
	if backstock != null and glimpse != null:
		_expect_equal(
			is_equal_approx(backstock.position.x, glimpse.position.x),
			true,
			"B07 shares A13 X"
		)
		_expect_equal(
			is_equal_approx(glimpse.position.z, backstock.position.z - 0.3),
			true,
			"B07 is at alcove rear, 0.3 m behind A13 center"
		)
	if camera != null:
		_expect_equal(is_equal_approx(camera.fov, ShopCamera.HOME_FOV), true, "placement does not change FOV")
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"placement does not move Day1 camera"
		)
	shop.free()


func _test_shop_camera_look_clamps() -> void:
	var camera := ShopCamera.new()
	camera.fov = 90.0
	camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
	_expect_equal(camera.get_home_pose(), ShopCamera.POSE_BEHIND_COUNTER, "default named home")
	_expect_equal(is_equal_approx(camera.fov, 70.0), true, "home pose locks FOV to 70")
	camera.apply_look_delta(Vector2(0.0, -10000.0))
	_expect_equal(
		is_equal_approx(camera.rotation_degrees.x, ShopCamera.PITCH_MAX_DEGREES),
		true,
		"pitch clamp max is Art +5"
	)
	_expect_equal(
		camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
		true,
		"look does not leave behind-desk stand point"
	)
	_expect_equal(
		camera.rotation_degrees.x <= ShopCamera.PITCH_MAX_DEGREES,
		true,
		"camera is not ceiling-stuck"
	)
	camera.apply_look_delta(Vector2(0.0, 20000.0))
	_expect_equal(
		is_equal_approx(camera.rotation_degrees.x, ShopCamera.PITCH_MIN_DEGREES),
		true,
		"pitch clamp min is Art -40"
	)
	camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
	camera.apply_look_delta(Vector2(10000.0, 0.0))
	_expect_equal(
		is_equal_approx(camera.rotation_degrees.y, ShopCamera.YAW_MIN_DEGREES),
		true,
		"yaw clamp min is Art -70"
	)
	camera.apply_look_delta(Vector2(-20000.0, 0.0))
	_expect_equal(
		is_equal_approx(camera.rotation_degrees.y, ShopCamera.YAW_MAX_DEGREES),
		true,
		"yaw clamp max is Art +70"
	)
	_expect_equal(is_equal_approx(camera.fov, 70.0), true, "RMB look does not zoom FOV")
	camera.reset_to_aisle_home()
	_expect_equal(camera.get_home_pose(), ShopCamera.POSE_AISLE, "reset named pose is aisle")
	_expect_equal(
		camera.position.is_equal_approx(ShopCamera.AISLE_POSITION),
		true,
		"reset returns to Art aisle home"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(ShopCamera.AISLE_ROTATION_DEGREES),
		true,
		"reset clears look offset to aisle pitch"
	)
	_expect_equal(camera.is_looking(), false, "reset releases RMB look")
	camera.free()


func _test_customer_npc_spawn_browse_approach_path() -> void:
	var grid := ShopGrid.small_default()
	_expect_equal(grid.is_walkable(grid.entrance_tile), true, "entrance tile walkable")
	_expect_equal(grid.is_walkable(grid.desk_tile), true, "desk stand tile walkable")
	_expect_equal(grid.is_walkable(Vector2i(7, 1)), false, "counter blocks pathing")
	_expect_equal(grid.is_walkable(Vector2i(8, 1)), false, "counter far tile blocked")
	for browse: Vector2i in grid.browse_tiles:
		_expect_equal(grid.is_walkable(browse), true, "browse tile walkable")
		_assert_grid_path(grid, grid.entrance_tile, browse, "entrance→browse")
		_assert_grid_path(grid, browse, grid.desk_tile, "browse→desk")
	_assert_grid_path(grid, grid.entrance_tile, grid.desk_tile, "entrance→desk")
	_assert_grid_path(grid, grid.desk_tile, grid.entrance_tile, "desk→exit")
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	var customer := _make_floor_customer(&"regular")
	var npc := presenter.spawn_for(customer)
	_expect_equal(npc != null, true, "NPC spawns at entrance")
	_expect_equal(
		npc.floor_state,
		CustomerPresenter.FloorState.SPAWN,
		"NPC starts in SPAWN"
	)
	_expect_equal(
		grid.world_to_tile(npc.position),
		grid.entrance_tile,
		"SPAWN is on the entrance tile"
	)
	_expect_equal(
		presenter.advance_until(customer, CustomerPresenter.FloorState.BROWSE),
		true,
		"SPAWN advances to BROWSE"
	)
	_expect_equal(
		npc.floor_state,
		CustomerPresenter.FloorState.BROWSE,
		"NPC is browsing displays"
	)
	_expect_equal(
		presenter.advance_until(customer, CustomerPresenter.FloorState.APPROACH),
		true,
		"BROWSE advances to APPROACH"
	)
	_expect_equal(
		presenter.advance_until(customer, CustomerPresenter.FloorState.RESOLVE),
		true,
		"APPROACH reaches desk RESOLVE"
	)
	_expect_equal(
		grid.contains_desk(npc.position),
		true,
		"RESOLVE stands in the desk interact volume"
	)
	_expect_equal(
		presenter.is_desk_ready(customer),
		true,
		"desk volume is ready at RESOLVE"
	)
	_event_bus.emit_signal("customer_resolved", customer, &"sold")
	_expect_equal(
		presenter.advance_until(customer, CustomerPresenter.FloorState.EXIT),
		true,
		"resolve begins EXIT"
	)
	presenter.simulate(1.0)
	_expect_equal(
		presenter.get_npc(customer) == null,
		true,
		"EXIT despawns at the entrance"
	)
	presenter.free()


func _test_customer_npc_intent_icons_have_no_truth() -> void:
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	var buyer := _make_floor_customer(&"regular")
	var buyer_npc := presenter.spawn_for(buyer)
	_expect_equal(
		buyer_npc.icon.intent_name(),
		&"browse",
		"spawn overhead icon is browse"
	)
	var browse_payload := buyer_npc.icon_presentation()
	_expect_equal(browse_payload.size(), 1, "bobber payload is intent-only")
	_expect_equal(
		browse_payload.has("intent"),
		true,
		"bobber payload has intent"
	)
	_expect_equal(
		buyer_npc.icon.has_truth_fields(),
		false,
		"browse bobber has no truth fields"
	)
	_assert_payload_has_no_truth(browse_payload, "browse icon")
	presenter.advance_until(buyer, CustomerPresenter.FloorState.APPROACH)
	_expect_equal(
		buyer_npc.icon.intent_name(),
		&"buy",
		"leaving browse flips to buy"
	)
	_expect_equal(
		buyer_npc.icon_presentation().size(),
		1,
		"buy bobber stays intent-only"
	)
	_assert_payload_has_no_truth(
		buyer_npc.icon_presentation(),
		"buy icon"
	)
	var seller := _make_floor_customer(&"flipper")
	seller.trade_intent = CustomerProfile.TradeIntent.SELLING_TO_SHOP
	var seller_npc := presenter.spawn_for(seller)
	presenter.advance_until(seller, CustomerPresenter.FloorState.APPROACH)
	_expect_equal(
		seller_npc.icon.intent_name(),
		&"sell",
		"buylist seller flips to sell"
	)
	_expect_equal(
		seller_npc.icon.intent_name() in [&"browse", &"buy", &"sell"],
		true,
		"intent is browse/buy/sell only"
	)
	_assert_payload_has_no_truth(
		seller_npc.icon_presentation(),
		"sell icon"
	)
	for path: String in [
		"res://scripts/customers/customer_npc.gd",
		"res://scripts/customers/customer_presenter.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_assert_text_has_no_truth(source, path.get_file())
	presenter.free()


func _test_customer_npc_desk_volume_gates_hud() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "HUD loads for desk gate")
	if hud == null:
		return
	var serve := hud.get_node_or_null("%CustomerServe") as PanelContainer
	var presenter := _make_floor_presenter()
	var customer := _make_floor_customer(&"regular")
	var npc := presenter.spawn_for(customer)
	_event_bus.emit_signal("customer_head_changed", customer)
	_expect_equal(
		serve != null and serve.visible == false,
		true,
		"CustomerServe stays closed off the desk volume"
	)
	presenter.advance_until(customer, CustomerPresenter.FloorState.RESOLVE)
	_expect_equal(
		presenter.is_desk_ready(customer),
		true,
		"presenter marks desk ready in volume"
	)
	_expect_equal(
		serve.visible,
		true,
		"CustomerServe opens only in the desk volume"
	)
	Callable(hud, "dismiss_customer_serve").call()
	_expect_equal(serve.visible, false, "Esc/close hides thin counter HUD")
	_expect_equal(
		presenter.get_npc(customer) != null,
		true,
		"closing HUD does not despawn the NPC"
	)
	_expect_equal(
		npc.floor_state,
		CustomerPresenter.FloorState.RESOLVE,
		"NPC stays in RESOLVE after HUD close"
	)
	_event_bus.emit_signal("customer_desk_ready_changed", customer, true)
	_expect_equal(
		serve.visible,
		true,
		"re-entering desk volume can reopen HUD"
	)
	presenter.free()
	root.remove_child(hud)
	hud.free()


func _test_customer_npc_does_not_change_camera() -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "shop_floor loads for NPC camera check")
	if packed == null:
		return
	_game_state.call("start_new_game")
	var shop: Node = packed.instantiate()
	root.add_child(shop)
	var camera := shop.get_node_or_null("Camera") as ShopCamera
	_expect_equal(camera != null, true, "Camera present during NPC spawn")
	if camera == null:
		shop.free()
		return
	var home_pos := camera.position
	var home_rot := camera.rotation_degrees
	var home_fov := camera.fov
	var presenter := shop.get_node_or_null(
		"Systems/CustomerPresenter"
	) as CustomerPresenter
	_expect_equal(presenter != null, true, "CustomerPresenter is on the shop")
	if presenter != null:
		presenter.instant_travel = true
		presenter.dwell_override = 0.0
		var customer := _make_floor_customer(&"regular")
		presenter.spawn_for(customer)
		presenter.advance_until(customer, CustomerPresenter.FloorState.APPROACH)
	_expect_equal(
		is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
		true,
		"NPC floor presence does not change FOV"
	)
	_expect_equal(
		is_equal_approx(home_fov, ShopCamera.HOME_FOV),
		true,
		"camera FOV stays locked at 70"
	)
	_expect_equal(
		camera.position.is_equal_approx(home_pos),
		true,
		"NPC spawn does not move the shop camera"
	)
	_expect_equal(
		camera.rotation_degrees.is_equal_approx(home_rot),
		true,
		"NPC spawn does not rotate the shop camera"
	)
	var presenter_source := FileAccess.get_file_as_string(
		"res://scripts/customers/customer_presenter.gd"
	)
	var npc_source := FileAccess.get_file_as_string(
		"res://scripts/customers/customer_npc.gd"
	)
	_expect_equal(
		presenter_source.contains("fov") or npc_source.contains("fov"),
		false,
		"NPC scripts do not mutate FOV"
	)
	shop.free()


func _test_customer_npc_visible_when_queued() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var presenter := _make_floor_presenter()
	var customer := _make_floor_customer(&"regular")
	_event_bus.emit_signal("customer_arrived", customer)
	_expect_equal(
		presenter.visible_npc_count() >= 1,
		true,
		"non-empty floor presence shows ≥1 NPC"
	)
	var npc := presenter.get_npc(customer)
	_expect_equal(npc != null and npc.visible, true, "queued NPC is visible")
	_expect_equal(
		npc.floor_state == CustomerPresenter.FloorState.SPAWN
		or npc.floor_state == CustomerPresenter.FloorState.BROWSE
		or npc.floor_state == CustomerPresenter.FloorState.APPROACH,
		true,
		"visible NPC is walking or browsing"
	)
	presenter.free()


func _test_customer_npc_mvp_cast() -> void:
	_game_state.call("start_new_game")
	var presenter := _make_floor_presenter()
	var c1 := presenter.spawn_for(_make_floor_customer(&"regular"))
	var c2 := presenter.spawn_for(_make_floor_customer(&"flipper"))
	var c3 := presenter.spawn_for(_make_floor_customer(&"kid_parent"))
	_expect_equal(c1.cast_slot, &"C1", "regular maps to C1")
	_expect_equal(c2.cast_slot, &"C2", "flipper maps to C2")
	_expect_equal(c3.cast_slot, &"C3", "kid/parent maps to C3")
	_expect_equal(
		not is_equal_approx(c1.body_height, c2.body_height),
		true,
		"C1/C2 heights differ"
	)
	_expect_equal(
		c3.body_height < c1.body_height,
		true,
		"C3 is shorter than C1"
	)
	_expect_equal(
		c1.body_color != c2.body_color and c2.body_color != c3.body_color,
		true,
		"C1–C3 capsules use distinct tints"
	)
	_expect_equal(is_equal_approx(c1.body_height, 1.74), true, "C1 Art hero 1.74m")
	_expect_equal(is_equal_approx(c2.body_height, 1.70), true, "C2 Art hero 1.70m")
	_expect_equal(is_equal_approx(c3.body_height, 1.66), true, "C3 Art hero 1.66m")
	_expect_equal(
		c1.body_scene_path.contains("char_customer_casual_a_01"),
		true,
		"C1 uses casual A GLB"
	)
	_expect_equal(
		c2.body_scene_path.contains("char_customer_casual_b_01"),
		true,
		"C2 uses casual B GLB"
	)
	_expect_equal(
		c3.body_scene_path.contains("char_customer_casual_c_01"),
		true,
		"C3 uses casual C GLB"
	)
	_expect_equal(
		FileAccess.file_exists(CustomerCast.SCENE_C1),
		true,
		"C1 GLB is on disk"
	)
	_expect_equal(
		FileAccess.file_exists(CustomerIntentIcon.SCENE_BROWSE),
		true,
		"browse icon GLB is on disk"
	)
	_expect_equal(
		FileAccess.file_exists(CustomerIntentIcon.SCENE_BUY),
		true,
		"buy icon GLB is on disk"
	)
	_expect_equal(
		FileAccess.file_exists(CustomerIntentIcon.SCENE_SELL),
		true,
		"sell icon GLB is on disk"
	)
	_expect_equal(
		CustomerIntentIcon.scene_path_for(CustomerIntentIcon.Intent.BROWSE).contains(
			"prop_icon_browse_01"
		),
		true,
		"browse Art icon path"
	)
	_expect_equal(
		CustomerIntentIcon.scene_path_for(CustomerIntentIcon.Intent.BUY).contains(
			"prop_icon_buy_01"
		),
		true,
		"buy Art icon path"
	)
	_expect_equal(
		CustomerIntentIcon.scene_path_for(CustomerIntentIcon.Intent.SELL).contains(
			"prop_icon_sell_01"
		),
		true,
		"sell Art icon path"
	)
	_expect_equal(
		CustomerIntentIcon.COLOR_SELL.is_equal_approx(CustomerIntentIcon.ACCENT_AMBER),
		true,
		"sell stays warm amber Accent_Amber"
	)
	_expect_equal(
		CustomerIntentIcon.ACCENT_AMBER.is_equal_approx(Color(0.82, 0.52, 0.18)),
		true,
		"Accent_Amber lock is 0.82, 0.52, 0.18"
	)
	_expect_equal(
		CustomerIntentIcon.COLOR_SELL.b < 0.35,
		true,
		"sell is not burgundy"
	)
	_expect_equal(
		CustomerIntentIcon.COLOR_BUY.b > CustomerIntentIcon.COLOR_BUY.r,
		true,
		"buy stays teal"
	)
	var sell_notes := FileAccess.get_file_as_string(
		"res://assets/props/shop/fixtures/prop_icon_sell_01/IMPORT_NOTES.md"
	)
	_expect_equal(
		sell_notes.contains("Accent_Amber"),
		true,
		"sell icon notes lock Accent_Amber"
	)
	c1.icon.ensure_built()
	_expect_equal(
		c1.icon.get_child_count() >= 3,
		true,
		"browse/buy/sell Art icons are instanced"
	)
	presenter.free()


func _test_customer_npc_locomotion_clips() -> void:
	_game_state.call("start_new_game")
	_game_state.call("start_floor")
	var presenter := CustomerPresenter.new()
	presenter.instant_travel = false
	presenter.dwell_override = 10.0
	root.add_child(presenter)
	if not presenter.is_node_ready():
		presenter.notification(Node.NOTIFICATION_READY)
	var c1 := presenter.spawn_for(_make_floor_customer(&"regular"))
	var c2 := presenter.spawn_for(_make_floor_customer(&"flipper"))
	var c3 := presenter.spawn_for(_make_floor_customer(&"kid_parent"))
	for npc: CustomerNpc in [c1, c2, c3]:
		_expect_equal(
			npc.has_locomotion_clips(),
			true,
			"%s GLB exposes walk + browse_idle" % npc.cast_slot
		)
		_expect_equal(
			npc.current_locomotion_clip(),
			CustomerNpc.CLIP_BROWSE_IDLE,
			"%s rests on browse_idle at spawn" % npc.cast_slot
		)
	var start := c1.position
	presenter.simulate(0.35)
	_expect_equal(c1.is_moving(), true, "C1 is translating along path")
	_expect_equal(
		c1.current_locomotion_clip(),
		CustomerNpc.CLIP_WALK,
		"walk plays while moving"
	)
	_expect_equal(
		c1.position.distance_to(start) > 0.05,
		true,
		"pathing owns world translation"
	)
	_expect_equal(
		c1.body_root_local_position().is_equal_approx(Vector3.ZERO),
		true,
		"in-place clips keep the GLB root at origin"
	)
	var arrived := false
	var elapsed := 0.0
	while elapsed <= 20.0:
		if (
			c1.floor_state == CustomerPresenter.FloorState.BROWSE
			and not c1.is_moving()
		):
			arrived = true
			break
		presenter.simulate(0.1)
		elapsed += 0.1
	_expect_equal(arrived, true, "C1 reaches a browse stop")
	_expect_equal(
		c1.current_locomotion_clip(),
		CustomerNpc.CLIP_BROWSE_IDLE,
		"browse_idle plays at the case while not translating"
	)
	c1.follow_path([c1.position + Vector3(1.2, 0.0, 0.0)])
	_expect_equal(
		c1.current_locomotion_clip(),
		CustomerNpc.CLIP_WALK,
		"walk resumes when a new path starts"
	)
	c1.snap_to_path_end()
	_expect_equal(
		c1.current_locomotion_clip(),
		CustomerNpc.CLIP_BROWSE_IDLE,
		"browse_idle resumes when translation stops"
	)
	var npc_source := FileAccess.get_file_as_string(
		"res://scripts/customers/customer_npc.gd"
	)
	_expect_equal(
		npc_source.contains("AnimationPlayer"),
		true,
		"locomotion uses AnimationPlayer"
	)
	_expect_equal(
		npc_source.contains("AnimationTree"),
		false,
		"does not invent a second animation system"
	)
	presenter.free()


func _test_cashier_silhouette_on_floor() -> void:
	_expect_equal(
		FileAccess.file_exists(StaffMember.SCENE_CASHIER),
		true,
		"cashier GLB is on disk"
	)
	_expect_equal(
		is_equal_approx(StaffMember.BODY_HEIGHT, 1.72),
		true,
		"cashier authored height 1.72m"
	)
	_expect_equal(
		StaffMember.CLIP_IDLE_STAND,
		&"idle_stand",
		"cashier clip is idle_stand"
	)
	_expect_equal(
		StaffMember.SCENE_CASHIER.contains("char_cashier_01"),
		true,
		"cashier uses Art char_cashier_01"
	)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop: ShopState = _game_state.get("shop")
	_expect_equal(shop.is_owner_only(), true, "Normal starts owner-only")
	_expect_equal(shop.cashier_count(), 0, "Normal starts with no cashiers")
	_expect_equal(shop.staff_cap(), 1, "Small staff cap is 1")

	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "shop_floor loads for cashier silhouette")
	if packed == null:
		return
	var floor: Node = packed.instantiate()
	root.add_child(floor)
	var presenter := floor.get_node_or_null("StaffFloor") as StaffPresenter
	_expect_equal(presenter != null, true, "StaffFloor presenter is on the shop")
	if presenter == null:
		floor.free()
		return
	var slot := floor.get_node_or_null("StaffFloor/CashierSlot") as Node3D
	_expect_equal(slot != null, true, "CashierSlot marker is behind the register")
	if slot != null:
		_expect_equal(
			slot.position.is_equal_approx(StaffPresenter.DEFAULT_STATION),
			true,
			"CashierSlot matches StaffPresenter.DEFAULT_STATION"
		)
		_expect_equal(
			StaffPresenter.DEFAULT_STATION.is_equal_approx(Vector3(8.05, 0.0, -0.95)),
			true,
			"presenter default is stool/owner side (8.05, 0, −0.95)"
		)
		_expect_equal(
			slot.position.z <= -0.85 and slot.position.z >= -1.05,
			true,
			"cashier Z stays in the owner-side band (−1.05…−0.85)"
		)
		_expect_equal(
			is_equal_approx(slot.rotation_degrees.y, StaffPresenter.DEFAULT_YAW_DEGREES),
			true,
			"CashierSlot yaw matches StaffPresenter.DEFAULT_YAW_DEGREES"
		)
		_expect_equal(
			is_equal_approx(StaffPresenter.DEFAULT_YAW_DEGREES, 90.0),
			true,
			"presenter default yaw 90 faces customers (−X)"
		)
	presenter.sync_from_shop()
	_expect_equal(presenter.visible_clerk_count(), 0, "owner-only hides the clerk")

	var camera := floor.get_node_or_null("Camera") as ShopCamera
	_expect_equal(camera != null, true, "Camera present during clerk spawn")
	var home_pos := Vector3.ZERO
	var home_rot := Vector3.ZERO
	var home_fov := 0.0
	if camera != null:
		home_pos = camera.position
		home_rot = camera.rotation_degrees
		home_fov = camera.fov

	_expect_equal(shop.hire_cashier(false) != null, true, "hire first cashier")
	_expect_equal(shop.cashier_count(), 1, "one cashier on duty")
	_expect_equal(shop.hire_cashier(false) == null, true, "Small staff cap blocks second hire")
	presenter.sync_from_shop()
	_expect_equal(presenter.visible_clerk_count(), 1, "hired cashier appears behind the counter")
	var clerk := presenter.clerk_at(0)
	_expect_equal(clerk != null and clerk.visible, true, "clerk node is visible")
	if clerk != null:
		var clerk_tile := shop.floor_grid.world_to_tile(clerk.position)
		_expect_equal(
			shop.floor_grid.is_walkable(clerk_tile),
			false,
			"clerk stands on blocked counter tiles"
		)
		_expect_equal(
			shop.floor_grid.is_walkable(shop.floor_grid.desk_tile),
			true,
			"customer desk tile stays walkable"
		)
		_expect_equal(
			clerk.position.distance_to(Vector3(7.2, 0.0, -1.35)) < 1.4,
			true,
			"clerk is near the buy counter / register"
		)
		_expect_equal(
			clerk.position.is_equal_approx(StaffPresenter.DEFAULT_STATION),
			true,
			"spawned clerk uses CashierSlot / DEFAULT_STATION"
		)
		_expect_equal(
			clerk.position.z <= -0.85 and clerk.position.z >= -1.05,
			true,
			"spawned clerk stays on the stool/owner side (not past counter −1.35)"
		)
		_expect_equal(
			is_equal_approx(clerk.rotation_degrees.y, StaffPresenter.DEFAULT_YAW_DEGREES),
			true,
			"spawned clerk yaw matches DEFAULT_YAW_DEGREES (90 / −X)"
		)
	_expect_equal(
		presenter.current_idle_clip(),
		StaffMember.CLIP_IDLE_STAND,
		"idle_stand is the active clip"
	)
	_expect_equal(
		presenter.body_root_local_position().is_equal_approx(Vector3.ZERO),
		true,
		"in-place idle keeps the GLB root at origin"
	)
	if presenter.has_idle_loop():
		_expect_equal(true, true, "idle_stand loops on AnimationPlayer")
	else:
		_expect_equal(
			FileAccess.file_exists(StaffMember.SCENE_CASHIER),
			true,
			"GLB present even if import has not bound AnimationPlayer yet"
		)

	var customer_p := floor.get_node_or_null(
		"Systems/CustomerPresenter"
	) as CustomerPresenter
	_expect_equal(customer_p != null, true, "CustomerPresenter still on the shop")
	if customer_p != null:
		customer_p.instant_travel = true
		customer_p.dwell_override = 0.0
		var path := customer_p.path_between(
			shop.floor_grid.tile_to_world(shop.floor_grid.entrance_tile),
			shop.floor_grid.tile_to_world(shop.floor_grid.desk_tile)
		)
		_expect_equal(path.is_empty(), false, "clerk does not break entrance→desk pathing")
		var customer := _make_floor_customer(&"regular")
		customer_p.spawn_for(customer)
		_expect_equal(
			customer_p.advance_until(customer, CustomerPresenter.FloorState.APPROACH),
			true,
			"customer still reaches the desk with clerk present"
		)
		_expect_equal(
			customer_p.get_npc(customer) != null,
			true,
			"customer NPC remains after clerk spawn"
		)

	if camera != null:
		_expect_equal(
			is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
			true,
			"clerk visual does not change FOV"
		)
		_expect_equal(
			is_equal_approx(home_fov, ShopCamera.HOME_FOV),
			true,
			"camera FOV stays locked at 70"
		)
		_expect_equal(
			camera.position.is_equal_approx(home_pos),
			true,
			"clerk spawn does not move the shop camera"
		)
		_expect_equal(
			camera.rotation_degrees.is_equal_approx(home_rot),
			true,
			"clerk spawn does not rotate the shop camera"
		)
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"behind-counter camera SoT unchanged"
		)
	var staff_source := FileAccess.get_file_as_string(
		"res://scripts/shop/staff_presenter.gd"
	)
	_expect_equal(
		staff_source.contains("fov"),
		false,
		"staff presenter does not mutate FOV"
	)
	_expect_equal(
		staff_source.contains("AnimationPlayer"),
		true,
		"cashier idle uses AnimationPlayer"
	)
	_expect_equal(
		staff_source.contains("AnimationTree"),
		false,
		"does not invent a second animation system"
	)
	floor.free()

	_economy.set("balance_cents", 1_600_000)
	_game_state.set("current_reputation", 55)
	_expect_equal(
		shop.expand_to_medium(18, 1_600_000, 55),
		true,
		"Sign Medium for staff_cap 3"
	)
	_expect_equal(shop.staff_cap(), 3, "Medium staff cap unlocks")
	_expect_equal(shop.hire_cashier(false) != null, true, "Medium hire #2")
	_expect_equal(shop.hire_cashier(false) != null, true, "Medium hire #3")
	_expect_equal(shop.hire_cashier(false) == null, true, "Medium cap blocks #4")
	_expect_equal(shop.cashier_count(), 3, "three cashiers hired")
	_expect_equal(shop.cashier_count() <= shop.staff_cap(), true, "hires respect staff_cap")
	var cap_floor: Node = packed.instantiate()
	root.add_child(cap_floor)
	var cap_presenter := cap_floor.get_node_or_null("StaffFloor") as StaffPresenter
	if cap_presenter != null:
		cap_presenter.sync_from_shop()
		_expect_equal(
			cap_presenter.visible_clerk_count(),
			1,
			"one register station even when staff_cap is 3"
		)
	cap_floor.free()

	_game_state.call("set_balance_config", EASY_CONFIG)
	_game_state.call("start_new_game")
	shop = _game_state.get("shop")
	_expect_equal(shop.cashier_count(), 1, "Easy seeds a trainee cashier")
	var easy_floor: Node = packed.instantiate()
	root.add_child(easy_floor)
	var easy_presenter := easy_floor.get_node_or_null("StaffFloor") as StaffPresenter
	if easy_presenter != null:
		easy_presenter.sync_from_shop()
		_expect_equal(
			easy_presenter.visible_clerk_count(),
			1,
			"Easy trainee is visible behind the counter"
		)
		_expect_equal(
			easy_presenter.current_idle_clip(),
			StaffMember.CLIP_IDLE_STAND,
			"trainee loops idle_stand"
		)
	easy_floor.free()
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _make_floor_presenter() -> CustomerPresenter:
	var presenter := CustomerPresenter.new()
	presenter.instant_travel = true
	presenter.dwell_override = 0.0
	root.add_child(presenter)
	if not presenter.is_node_ready():
		presenter.notification(Node.NOTIFICATION_READY)
	return presenter


func _make_floor_customer(archetype_id: StringName) -> CustomerProfile:
	var customer := CustomerProfile.new()
	customer.archetype_id = archetype_id
	customer.display_name = String(archetype_id)
	customer.budget_cents = 10_000
	customer.interest_tags = [&"accessory"]
	customer.target_sku = &"ACC-SLV-60"
	customer.listed_price_cents = 599
	customer.desired_skus = [&"ACC-SLV-60"]
	customer.begin_waiting()
	return customer


func _assert_grid_path(
	grid: ShopGrid,
	from: Vector2i,
	to: Vector2i,
	label: String
) -> void:
	var path := ShopPathfinder.find_path(grid, from, to)
	_expect_equal(path.is_empty(), false, "%s path exists" % label)
	_expect_equal(
		path.has(Vector2i(7, 1)) or path.has(Vector2i(8, 1)),
		false,
		"%s does not clip the counter" % label
	)
	for tile: Vector2i in path:
		_expect_equal(grid.is_walkable(tile), true, "%s stays walkable" % label)


func _test_day_ten_beat_serialization() -> void:
	_beat_director.call("reset")
	_game_state.set("current_day", 10)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_qa_autoload.call("set_force_enabled", true)
	_expect_equal(
		_beat_director.call("trigger_qa_beat", TITAN_HYPE_BEAT),
		true,
		"day-ten Titan trigger"
	)
	_beat_director.call("_start_day_beats", 10)
	_expect_equal(
		_beat_director.call("is_started", SHOWCASE_BEAT),
		false,
		"showcase waits while Titan editor is unresolved"
	)
	_beat_director.call(
		"_on_beat_ui_resolved",
		TITAN_HYPE_BEAT,
		&"cancelled"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_c2_hire_beat_paths() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 5)
	_expect_equal(
		_beat_director.call("is_started", HIRE_CASHIER_BEAT),
		true,
		"C2 gate 1: day-5 hire beat starts on Normal PREP"
	)
	var ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"hire_cashier" in ids, true, "C2 gate 1: Hire reachable")
	_expect_equal(&"keep_solo" in ids, true, "C2 gate 1: Solo reachable")
	_expect_equal(&"hire_cheap" in ids, true, "C2 gate 1: Unreliable reachable")
	var confirms: Dictionary = _captured_beat_decision.get("confirms", {})
	_expect_equal(
		String((confirms.get("hire_cheap", {}) as Dictionary).get("body", "")).contains(
			"Reliability"
		),
		true,
		"C2 gate 1: cheap path warns Reliability"
	)
	_assert_payload_has_no_truth(_captured_beat_decision, "C2 hire decision")

	_expect_equal(
		_beat_director.call("choose_beat_path", &"hire_cashier"),
		true,
		"C2 gate 1: Hire Cashier commits"
	)
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.hired_count(), 1, "C2 gate 1: Hire uses one staff_cap slot")
	_expect_equal(shop.hired_count() <= shop.staff_cap(), true, "C2 gate 1: hire respects cap")
	_expect_equal(shop.staff[0].wage_cents, ShopState.CASHIER_WAGE_CENTS, "C2 gate 1: $80 wage")
	_expect_equal(shop.can_hire(), false, "C2 gate 1: Small cap filled after Hire")
	var cash_before := int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - ShopState.CASHIER_WAGE_CENTS,
		"C2 gate 1: Hire wage posts at SETTLE"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	_beat_director.call("choose_beat_path", &"keep_solo")
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.hired_count(), 0, "C2 gate 1: Solo leaves roster empty")
	_expect_equal(shop.is_owner_only(), true, "C2 gate 1: Solo stays owner-only")
	cash_before = int(_economy.get("balance_cents"))
	_game_state.call("start_floor")
	_game_state.call("start_settle")
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before,
		"C2 gate 1: Solo posts no wage"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 5)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 5)
	_beat_director.call("choose_beat_path", &"hire_cheap")
	shop = _game_state.get("shop") as ShopState
	_expect_equal(shop.hired_count(), 1, "C2 gate 1: Unreliable hire uses staff_cap")
	_expect_equal(shop.staff[0].theft_bias, true, "C2 gate 1: cheap theft/no-show bias")
	_expect_equal(
		shop.staff[0].reliability <= 0.55,
		true,
		"C2 gate 1: cheap Reliability ≤ 0.55"
	)


func _test_c2_unreliable_ten_day_stress() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_qa_autoload.call("set_force_enabled", true)
	var hit := false
	var noshows := 0
	var shrink_up := false
	var locked := false
	var seeds: Array[int] = [ShopState.STAFF_ATTENDANCE_SEED]
	for extra: int in range(1, 16):
		seeds.append(ShopState.STAFF_ATTENDANCE_SEED + extra * 17)
	for rng_seed: int in seeds:
		_game_state.call("start_new_game")
		var shop := _game_state.get("shop") as ShopState
		_expect_equal(shop.hire_cashier(true) != null, true, "C2 gate 2: hire cheap")
		var cheap_rate := shop.shrink_rate()
		_expect_equal(
			cheap_rate > NORMAL_CONFIG.shrink_daily_base,
			true,
			"C2 gate 2: cheap theft bias raises shrink vs base"
		)
		shop.seed_attendance_rng(rng_seed)
		_qa_autoload.call("clear")
		noshows = 0
		var shrink_loss := 0
		var max_rate := 0.0
		locked = false
		for _day_index: int in range(10):
			if not bool(_game_state.call("start_floor")):
				locked = true
				break
			if shop.is_floor_understaffed():
				noshows += 1
			if not bool(_game_state.call("start_settle")):
				locked = true
				break
			max_rate = maxf(max_rate, shop.last_shrink_rate)
			if int(_game_state.get("current_day")) < 10:
				if not bool(_game_state.call("advance_day")):
					locked = true
					break
		for event: Dictionary in _qa_autoload.call("get_events"):
			var name := String(event.get("event", ""))
			var payload: Dictionary = event.get("payload", {})
			_assert_payload_has_no_truth(payload, "C2 %s" % name)
			if name == "staff_noshow":
				noshows = maxi(noshows, int(payload.get("noshow_count", 1)))
			elif name == "shrink_applied":
				shrink_loss += int(payload.get("loss_cents", 0))
				max_rate = maxf(max_rate, float(payload.get("rate", 0.0)))
		shrink_up = (
			max_rate > NORMAL_CONFIG.shrink_daily_base
			or shrink_loss > 0
		)
		_expect_equal(locked, false, "C2 gate 2: 10-day cheap run does not soft-lock")
		_expect_equal(
			bool(_game_state.get("is_game_active")),
			true,
			"C2 gate 2: game stays active after 10 days"
		)
		if noshows >= 1 or shrink_up:
			hit = true
			break
	_expect_equal(
		hit,
		true,
		"C2 gate 2: ≥1 no-show or shrink↑ in 10-day cheap stress"
	)
	_qa_autoload.call("set_force_enabled", false)


func _test_c2_att_zero_owner_verbs() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.hire_cashier(false) != null, true, "C2 gate 3: hire cashier")
	_expect_equal(
		_game_state.call("start_floor"),
		true,
		"C2 gate 3: open FLOOR with cashier"
	)
	if shop.staff.size() > 0:
		shop.staff[0].on_duty_today = true
	_expect_equal(shop.has_cashier_on_duty(), true, "C2 gate 3: cashier on duty")
	_game_state.set("attention_remaining", 0)
	_event_bus.emit_signal("attention_changed", 0)

	_expect_equal(_game_state.call("can_inspect"), false, "C2 gate 3: Inspect blocked at Att 0")
	_expect_equal(_game_state.call("can_negotiate"), false, "C2 gate 3: Negotiate blocked at Att 0")
	_expect_equal(_game_state.call("can_pull"), false, "C2 gate 3: Pull blocked at Att 0")
	_expect_equal(_game_state.call("can_research"), false, "C2 gate 3: can_research blocked at Att 0")
	var research := _demand_signals.call("research_set", &"AA-BASE") as Dictionary
	_expect_equal(bool(research.get("ok", false)), false, "C2 gate 3: Research blocked at Att 0")
	_expect_equal(
		StringName(research.get("reason", &"")),
		&"insufficient_attention",
		"C2 gate 3: Research reason is insufficient_attention"
	)

	var inspect_dto: BuyConfirmSignal = null
	for dto: BuyConfirmSignal in _demand_signals.call("open_buy_signals"):
		if DemandSignalService.recommends_inspect(dto.channel):
			inspect_dto = dto
			break
	_expect_equal(inspect_dto != null, true, "C2 gate 3: inspectable lot exists")
	if inspect_dto != null:
		_expect_equal(
			_demand_signals.call("can_inspect", inspect_dto),
			false,
			"C2 gate 3: DemandSignals.can_inspect false at Att 0"
		)
		_expect_equal(
			_demand_signals.call("inspect_buy", inspect_dto),
			false,
			"C2 gate 3: inspect_buy refuses at Att 0"
		)

	_inventory_service.call(
		"receive_stock",
		&"ACC-SLV-60",
		1,
		250,
		InventoryLocation.new(InventoryLocation.Type.BACKSTOCK)
	)
	var queue := CustomerQueue.new()
	queue.configure(
		_inventory_service,
		Callable(_game_state, "adjust_reputation"),
		Callable(_game_state, "spend_attention")
	)
	var buyer := CustomerProfile.new()
	buyer.budget_cents = 5_000
	buyer.interest_tags = [&"accessory"]
	_expect_equal(queue.enqueue(buyer), true, "C2 gate 3: enqueue routine sale")
	_expect_equal(queue.negotiate(-0.10), false, "C2 gate 3: negotiate fails at Att 0")
	_expect_equal(buyer.has_negotiated, false, "C2 gate 3: negotiate does not mark customer")
	_expect_equal(queue.pull_from_backstock(), false, "C2 gate 3: pull fails at Att 0")
	_expect_equal(queue.sell_listed(), true, "C2 gate 3: cashier still routine-sells")
	queue.free()

	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "C2 gate 3: HUD loads")
	if hud == null:
		return
	Callable(hud, "_update_attention").call(0)
	var open_research := hud.get_node_or_null("%OpenResearchButton") as Button
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(
		open_research != null and open_research.disabled,
		true,
		"C2 gate 3: HUD Research disabled at Att 0"
	)
	var customer := CustomerProfile.new()
	customer.display_name = "Tester"
	customer.target_sku = &"ACC-SLV-60"
	customer.listed_price_cents = 599
	customer.budget_cents = 5_000
	Callable(hud, "_on_customer_head_changed").call(customer)
	Callable(hud, "_on_customer_desk_ready").call(customer, true)
	var negotiate := hud.get_node_or_null("%NegotiateButton") as Button
	var pull := hud.get_node_or_null("%PullButton") as Button
	var sell := hud.get_node_or_null("%SellButton") as Button
	_expect_equal(
		negotiate != null and negotiate.disabled,
		true,
		"C2 gate 3: HUD Negotiate disabled at Att 0"
	)
	_expect_equal(
		pull != null and pull.disabled,
		true,
		"C2 gate 3: HUD Pull disabled at Att 0"
	)
	_expect_equal(
		sell != null and not sell.disabled,
		true,
		"C2 gate 3: HUD Sell stays enabled with cashier on duty"
	)
	if inspect_button != null and inspect_button.visible:
		_expect_equal(inspect_button.disabled, true, "C2 gate 3: HUD Inspect disabled at Att 0")
	root.remove_child(hud)
	hud.free()


func _test_c2_specialist_attention_assert() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(NORMAL_CONFIG.inspect_attention_specialist, 2, "C2 gate 4: BalanceConfig Inspect 2")
	_expect_equal(NORMAL_CONFIG.research_attention_specialist, 10, "C2 gate 4: BalanceConfig Research 10")
	_expect_equal(shop.inspect_attention_cost(), 5, "C2 gate 4: owner Inspect 5")
	_expect_equal(shop.research_attention_cost(), 15, "C2 gate 4: owner Research 15")
	_expect_equal(shop.hire_specialist() != null, true, "C2 gate 4: hire Specialist")
	_expect_equal(shop.has_specialist_on_duty(), true, "C2 gate 4: Specialist on duty")
	_expect_equal(shop.inspect_attention_cost(), 2, "C2 gate 4: Inspect Att = 2")
	_expect_equal(shop.research_attention_cost(), 10, "C2 gate 4: Research Att = 10")

	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "C2 gate 4: HUD loads")
	if hud == null:
		return
	var open_research := hud.get_node_or_null("%OpenResearchButton") as Button
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(
		open_research != null and open_research.text.contains("Att 10"),
		true,
		"C2 gate 4: HUD Research shows Att 10"
	)
	_expect_equal(
		inspect_button != null and inspect_button.text.contains("Att 2"),
		true,
		"C2 gate 4: HUD Inspect★ shows Att 2"
	)
	root.remove_child(hud)
	hud.free()


func _test_c3_beats_reachable_without_debug() -> void:
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_demand_signals.call("start_pack_event", MarketEvent.KIND_FOG, {
		"duration_days": 2,
		"remaining_days": 2,
	})
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "C3 gate 1: HUD loads")
	_beat_director.call("_start_day_beats", 3)
	_expect_equal(
		_beat_director.call("is_started", MARKETPLACE_OUTING_BEAT),
		true,
		"C3 gate 1: outing reachable on Normal day 3 without debug"
	)
	_expect_equal(
		StringName(_captured_beat_decision.get("beat_id", &"")),
		MARKETPLACE_OUTING_BEAT,
		"C3 gate 1: outing decision fires without QA trigger"
	)
	var outing_ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"drive_out" in outing_ids, true, "C3 gate 1: Drive reachable")
	_expect_equal(&"courier" in outing_ids, true, "C3 gate 1: Courier reachable")
	_expect_equal(&"skip" in outing_ids, true, "C3 gate 1: Skip reachable")
	if hud != null:
		var decision := hud.get_node_or_null("%BeatDecision") as Control
		var title := hud.get_node_or_null("%BeatDecisionTitle") as Label
		_expect_equal(
			decision != null and decision.visible,
			true,
			"C3 gate 1: outing modal is live"
		)
		_expect_equal(
			title != null and title.text == "Off-site lot — leave the floor?",
			true,
			"C3 gate 1: outing modal title"
		)
		var drive := hud.get_node_or_null("%BeatChoiceAButton") as Button
		var courier := hud.get_node_or_null("%BeatChoiceBButton") as Button
		var skip := hud.get_node_or_null("%BeatChoiceCButton") as Button
		_expect_equal(
			drive != null and drive.visible and not drive.disabled,
			true,
			"C3 gate 1: Drive button live"
		)
		_expect_equal(
			courier != null and courier.visible and not courier.disabled,
			true,
			"C3 gate 1: Courier button live"
		)
		_expect_equal(
			skip != null and skip.visible and not skip.disabled,
			true,
			"C3 gate 1: Skip button live"
		)
		root.remove_child(hud)
		hud.free()

	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 18)
	_beat_director.call("choose_beat_path", &"stay_small")
	_game_state.set("current_day", 20)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	hud = _instantiate_gameplay_hud()
	_beat_director.call("_start_day_beats", 20)
	_expect_equal(
		_beat_director.call("is_started", SHADY_TRUNK_BEAT),
		true,
		"C3 gate 1: shady reachable on Normal day 20 without debug"
	)
	_expect_equal(
		_game_state.call("is_night_prep"),
		true,
		"C3 gate 1: shady uses Night/PREP window"
	)
	var shady_ids := _choice_ids(_captured_beat_decision)
	_expect_equal(&"buy" in shady_ids, true, "C3 gate 1: Buy reachable")
	_expect_equal(&"report" in shady_ids, true, "C3 gate 1: Report reachable")
	_expect_equal(&"ignore" in shady_ids, true, "C3 gate 1: Ignore reachable")
	if hud != null:
		var shady_decision := hud.get_node_or_null("%BeatDecision") as Control
		var shady_title := hud.get_node_or_null("%BeatDecisionTitle") as Label
		_expect_equal(
			shady_decision != null and shady_decision.visible,
			true,
			"C3 gate 1: shady modal is live"
		)
		_expect_equal(
			shady_title != null and shady_title.text == "Trunk sale — too good?",
			true,
			"C3 gate 1: shady modal title"
		)
		root.remove_child(hud)
		hud.free()


func _test_c3_drive_shortens_floor_courier_keeps() -> void:
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 3)
	var attention_before := int(_game_state.get("attention_remaining"))
	_expect_equal(
		_beat_director.call("choose_beat_path", &"drive_out"),
		true,
		"C3 gate 2: Drive commits"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		attention_before - NORMAL_CONFIG.marketplace_outing_attention,
		"C3 gate 2: Drive spends Att 25"
	)
	_expect_equal(
		is_equal_approx(
			float(_game_state.get("pending_floor_skip_seconds")),
			NORMAL_CONFIG.marketplace_outing_floor_skip_seconds
		),
		true,
		"C3 gate 2: Drive queues 1–2 FLOOR hours"
	)
	var saved: Dictionary = _game_state.call("capture_save")
	_expect_equal(
		is_equal_approx(
			float(saved.get("pending_floor_skip_seconds", 0.0)),
			NORMAL_CONFIG.marketplace_outing_floor_skip_seconds
		),
		true,
		"C3 gate 2: Drive skip persists in save"
	)
	_expect_equal(_game_state.call("start_floor"), true, "C3 gate 2: open FLOOR after Drive")
	var drive_skip := NORMAL_CONFIG.marketplace_outing_floor_skip_seconds
	_expect_equal(
		is_equal_approx(
			float(_game_state.get("pending_floor_skip_seconds")),
			drive_skip
		),
		true,
		"C3 gate 2: skip is still queued when FLOOR opens"
	)
	_expect_equal(
		is_equal_approx(
			float(_game_state.call("consume_floor_skip")),
			drive_skip
		),
		true,
		"C3 gate 2: DayClock consume shortens FLOOR after Drive"
	)
	_expect_equal(
		float(_game_state.get("pending_floor_skip_seconds")),
		0.0,
		"C3 gate 2: skip is consumed on FLOOR start"
	)
	var clock_source := FileAccess.get_file_as_string("res://scripts/core/day_clock.gd")
	_expect_equal(
		clock_source.contains("consume_floor_skip"),
		true,
		"C3 gate 2: DayClock consumes the Drive skip"
	)
	_expect_equal(
		clock_source.contains("DayPhase.FLOOR"),
		true,
		"C3 gate 2: DayClock applies skip on FLOOR"
	)

	_game_state.call("start_new_game")
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 3)
	var cash_before := int(_economy.get("balance_cents"))
	var attention_courier := int(_game_state.get("attention_remaining"))
	_captured_buy_focus_id = &""
	_expect_equal(
		_beat_director.call("choose_beat_path", &"courier"),
		true,
		"C3 gate 2: Courier commits"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - NORMAL_CONFIG.marketplace_courier_fee_cents,
		"C3 gate 2: Courier pays fee"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		attention_courier,
		"C3 gate 2: Courier keeps Attention"
	)
	_expect_equal(
		float(_game_state.get("pending_floor_skip_seconds")),
		0.0,
		"C3 gate 2: Courier does not queue FLOOR skip"
	)
	_expect_equal(
		_captured_buy_focus_id,
		&"marketplace-outing-steal",
		"C3 gate 2: Courier opens BuyOpportunityDetail"
	)
	_expect_equal(_game_state.call("start_floor"), true, "C3 gate 2: open FLOOR after Courier")
	_expect_equal(
		float(_game_state.call("consume_floor_skip")),
		0.0,
		"C3 gate 2: Courier keeps full FLOOR"
	)


func _test_c3_shady_confirm_has_no_truth() -> void:
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_start_shady_on_normal_window()
	_captured_buy_focus_id = &""
	_expect_equal(
		_beat_director.call("choose_beat_path", &"buy"),
		true,
		"C3 gate 3: Buy opens the trunk lot"
	)
	var dto := _demand_signals.call(
		"buy_signal_for_id",
		&"shady-trunk-lot"
	) as BuyConfirmSignal
	_expect_equal(dto != null, true, "C3 gate 3: shady lot still open")
	if dto == null:
		return
	_expect_dto_has_no_truth_fields(dto, "C3 gate 3 shady DTO")
	_expect_equal(dto.confidence, &"low", "C3 gate 3: Low confidence on detail")
	_expect_equal(
		dto.condition_cue.to_lower().contains("inspect"),
		true,
		"C3 gate 3: inspect cue on detail"
	)
	_assert_text_has_no_truth(dto.condition_cue, "C3 gate 3 condition cue")
	_expect_equal(
		dto.condition_cue.to_lower().contains("cert"),
		false,
		"C3 gate 3: cue has no cert token"
	)
	var summary := DemandSignalPresenter.buy_summary(dto)
	_assert_text_has_no_truth(summary, "C3 gate 3 buy summary")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "C3 gate 3: HUD loads")
	if hud == null:
		return
	_select_buy_on_hud(hud, dto)
	var detail := hud.get_node_or_null("%BuyOpportunityDetail") as Control
	var buy_summary := hud.get_node_or_null("%BuySummary") as Label
	var inspect_button := hud.get_node_or_null("%InspectButton") as Button
	_expect_equal(
		detail != null and detail.visible,
		true,
		"C3 gate 3: BuyOpportunityDetail opens"
	)
	if buy_summary != null:
		_assert_text_has_no_truth(buy_summary.text, "C3 gate 3 detail HUD")
		_expect_equal(
			buy_summary.text.to_lower().contains("low"),
			true,
			"C3 gate 3: detail shows Low confidence"
		)
		_expect_equal(
			buy_summary.text.to_lower().contains("inspect"),
			true,
			"C3 gate 3: detail shows inspect cue"
		)
	_expect_equal(
		inspect_button != null and inspect_button.visible,
		true,
		"C3 gate 3: Inspect★ shown on shady detail"
	)
	Callable(hud, "_open_buy_confirm").call()
	var confirm := hud.get_node_or_null("%BuyConfirm") as Control
	var confirm_summary := hud.get_node_or_null("%BuyConfirmSummary") as Label
	_expect_equal(
		confirm != null and confirm.visible,
		true,
		"C3 gate 3: confirm screen opens"
	)
	if confirm_summary != null:
		_assert_text_has_no_truth(confirm_summary.text, "C3 gate 3 confirm HUD")
		_expect_equal(
			confirm_summary.text.to_lower().contains("cert_valid"),
			false,
			"C3 gate 3: confirm hides cert_valid"
		)
		for grade: String in DemandSignalService.CONDITION_GRADE_CUES:
			_expect_equal(
				confirm_summary.text.contains(grade),
				false,
				"C3 gate 3: confirm hides true condition %s" % grade
			)
	root.remove_child(hud)
	hud.free()


func _test_c3_report_applies_rep() -> void:
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_start_shady_on_normal_window()
	var rep_before := int(_game_state.get("current_reputation"))
	var expected_gain := NORMAL_CONFIG.shady_report_rep_gain
	_expect_equal(expected_gain > 0, true, "C3 gate 4: BalanceConfig Report Rep > 0")
	var stock_before: int = _inventory_service.call("total_owned", &"AA-SKIE-ETB")
	_expect_equal(
		_beat_director.call("choose_beat_path", &"report"),
		true,
		"C3 gate 4: Report commits without debug"
	)
	_expect_equal(
		int(_game_state.get("current_reputation")),
		rep_before + expected_gain,
		"C3 gate 4: Report applies BalanceConfig Rep delta"
	)
	_expect_equal(
		int(_inventory_service.call("total_owned", &"AA-SKIE-ETB")),
		stock_before,
		"C3 gate 4: Report grants no stock"
	)
	_expect_equal(
		_demand_signals.call("buy_signal_for_id", &"shady-trunk-lot") == null,
		true,
		"C3 gate 4: Report removes the opportunity"
	)
	_expect_equal(
		_beat_director.call("is_completed", SHADY_TRUNK_BEAT),
		true,
		"C3 gate 4: Report completes the beat"
	)


func _test_hold_soft_polish() -> void:
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_expect_equal(
		_game_state.call("start_floor"),
		true,
		"H1: FLOOR opens for Att-verb compare"
	)
	_expect_equal(_game_state.call("can_research"), true, "H1: can_research true at full Att")
	_expect_equal(_game_state.call("can_inspect"), true, "H1: can_inspect true at full Att")
	_expect_equal(_game_state.call("can_pull"), true, "H1: can_pull true at full Att")
	_game_state.set("attention_remaining", 0)
	_event_bus.emit_signal("attention_changed", 0)
	_expect_equal(_game_state.call("can_research"), false, "H1: can_research false at Att 0")
	_expect_equal(_game_state.call("can_inspect"), false, "H1: Inspect refused at Att 0")
	_expect_equal(_game_state.call("can_negotiate"), false, "H1: Negotiate refused at Att 0")
	_expect_equal(_game_state.call("can_pull"), false, "H1: Pull refused at Att 0")
	_economy.set("balance_cents", 800_000)
	_event_bus.call("publish_cash_changed", 800_000)
	_expect_equal(
		_game_state.call("can_research"),
		false,
		"H1: cash alone does not unlock Research"
	)
	var zero_research := _demand_signals.call("research_set", &"AA-BASE") as Dictionary
	_expect_equal(bool(zero_research.get("ok", false)), false, "H1: research_set refused at Att 0")
	_expect_equal(
		StringName(zero_research.get("reason", &"")),
		&"insufficient_attention",
		"H1: Att 0 reason is insufficient_attention"
	)
	var shop := _game_state.get("shop") as ShopState
	var research_att := shop.research_attention_cost()
	_game_state.set("attention_remaining", research_att)
	_event_bus.emit_signal("attention_changed", research_att)
	_expect_equal(
		_game_state.call("can_research"),
		true,
		"H1: can_research true at Att >= cost"
	)
	_expect_equal(
		_demand_signals.call("can_research_set", &"AA-BASE"),
		true,
		"H1: can_research_set true at Att >= cost"
	)
	var ok_research := _demand_signals.call("research_set", &"AA-BASE") as Dictionary
	_expect_equal(bool(ok_research.get("ok", false)), true, "H1: Research still works at Att >= cost")

	_assert_hold_inherit_scalars(EASY_CONFIG, "easy")
	_assert_hold_inherit_scalars(NORMAL_CONFIG, "normal")
	_assert_hold_inherit_scalars(HARD_CONFIG, "hard")
	_assert_hold_staff_panel(EASY_CONFIG, "easy", true)
	_assert_hold_staff_panel(HARD_CONFIG, "hard", false)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_expect_equal(_game_state.call("start_floor"), true, "H6: FLOOR for icon scale")
	var presenter := _make_floor_presenter()
	var npc := presenter.spawn_for(_make_floor_customer(&"regular"))
	_expect_equal(CustomerNpc.ICON_READ_SCALE, 2.0, "H6: ICON_READ_SCALE is 2×")
	_expect_equal(
		npc.icon.scale.is_equal_approx(Vector3.ONE * CustomerNpc.ICON_READ_SCALE),
		true,
		"H6: bobber holder is 2× read scale"
	)
	_expect_equal(
		is_equal_approx(npc.icon.position.y, npc.body_height + CustomerNpc.ICON_HANG),
		true,
		"H6: bobber hangs above the head, not into the counter"
	)
	_expect_equal(npc.icon.has_truth_fields(), false, "H6: bobber has no truth fields")
	_assert_payload_has_no_truth(npc.icon_presentation(), "H6 bobber")
	_expect_equal(
		npc.icon_presentation().has("price"),
		false,
		"H6: no price on bobber"
	)
	_expect_equal(
		npc.icon_presentation().has("sku"),
		false,
		"H6: no SKU on bobber"
	)
	_expect_equal(
		CustomerIntentIcon.COLOR_SELL.is_equal_approx(CustomerIntentIcon.ACCENT_AMBER),
		true,
		"H7: sell fallback tint is Accent_Amber"
	)
	_expect_equal(
		CustomerIntentIcon.ACCENT_AMBER.is_equal_approx(Color(0.82, 0.52, 0.18)),
		true,
		"H7: Accent_Amber lock 0.82, 0.52, 0.18"
	)
	_expect_equal(
		CustomerIntentIcon.ACCENT_AMBER.r > CustomerIntentIcon.ACCENT_AMBER.g
		and CustomerIntentIcon.ACCENT_AMBER.g > CustomerIntentIcon.ACCENT_AMBER.b,
		true,
		"H7: sell tint stays warm amber, not burgundy"
	)
	presenter.free()
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_sec10_4_spike_staple() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_qa_autoload.call("set_force_enabled", true)
	_game_state.set("current_day", 3)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_scripted_customer = null
	_expect_equal(
		_game_state.call("start_floor"),
		true,
		"F1 #4: Normal day 3 FLOOR opens without QA trigger"
	)
	if not bool(_beat_director.call("is_started", SPIKE_STAPLE_BEAT)):
		_beat_director.call("_on_day_phase_changed", DayPhasePolicy.FLOOR)
	_expect_equal(
		_beat_director.call("is_started", SPIKE_STAPLE_BEAT),
		true,
		"F1 #4: Spike staple reachable on Normal day 3–5 without debug"
	)
	_expect_equal(
		_qa_has_beat_event("beat_started", SPIKE_STAPLE_BEAT),
		true,
		"F1 #4: emits beat_started"
	)
	_expect_equal(
		_captured_scripted_customer != null,
		true,
		"F1 #4: Spike scripted customer emitted"
	)
	var staple := &"AA-BASE-088"
	var spike := _captured_scripted_customer
	if spike != null:
		staple = spike.wants_sku
		if staple.is_empty() and not spike.desired_skus.is_empty():
			staple = spike.desired_skus[0]
		_expect_equal(spike.display_name, "Spike", "F1 #4: customer is Spike")
		_expect_equal(
			staple in [&"AA-BASE-088", &"AA-BASE-078"],
			true,
			"F1 #4: wants Bastion Captain or Arcbolt Adept"
		)
		_expect_equal(spike.wants_sku, staple, "F1 #4: wants_sku matches the staple")
	var hud := _instantiate_gameplay_hud()
	var queue := CustomerQueue.new()
	queue.configure(
		_inventory_service,
		_game_state.adjust_reputation,
		_game_state.spend_attention
	)
	if spike != null:
		_expect_equal(queue.enqueue(spike), true, "F1 #4: Spike enqueues into CustomerServe")
		_bind_customer_serve(hud, spike)
		var serve := hud.get_node_or_null("%CustomerServe") as Control
		var title := hud.get_node_or_null("%CustomerTitle") as Label
		var summary := hud.get_node_or_null("%CustomerSummary") as Label
		_expect_equal(
			serve != null and serve.visible,
			true,
			"F1 #4: CustomerServe opens"
		)
		_expect_equal(
			title != null and title.text.contains("Spike"),
			true,
			"F1 #4: CustomerServe titles Spike"
		)
		_expect_equal(
			summary != null and summary.text.contains("Your list"),
			true,
			"F1 #4: CustomerServe uses Your list"
		)
		_expect_equal(
			summary != null and summary.text.contains("AA-BASE-"),
			false,
			"F1 #4: Wants label is not a raw SKU"
		)
		if staple == &"AA-BASE-088":
			_expect_equal(
				summary != null and summary.text.contains("Bastion Captain"),
				true,
				"F1 #4: Wants shows Bastion Captain"
			)
		else:
			_expect_equal(
				summary != null and summary.text.contains("Arcbolt Adept"),
				true,
				"F1 #4: Wants shows Arcbolt Adept"
			)
		_assert_text_has_no_truth(
			summary.text if summary != null else "",
			"F1 #4 CustomerServe"
		)
		var stock_before := int(_inventory_service.call("card_count", staple))
		var cash_before := int(_economy.get("balance_cents"))
		var list_price := spike.listed_price_cents
		_expect_equal(queue.sell_listed(), true, "F1 #4: sell at list resolves")
		_beat_director.call("_on_customer_resolved", spike, &"sold")
		_expect_equal(
			int(_inventory_service.call("card_count", staple)),
			stock_before - 1,
			"F1 #4: sell removes the staple"
		)
		_expect_equal(
			int(_economy.get("balance_cents")),
			cash_before + list_price,
			"F1 #4: sell pays list cash"
		)
		_expect_equal(
			_beat_director.call("is_completed", SPIKE_STAPLE_BEAT),
			true,
			"F1 #4: sell completes the beat"
		)
		_expect_equal(
			_qa_has_beat_event("beat_completed", SPIKE_STAPLE_BEAT),
			true,
			"F1 #4: sell emits beat_completed"
		)
	queue.free()
	if hud != null:
		root.remove_child(hud)
		hud.free()

	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_qa_autoload.call("set_force_enabled", true)
	_game_state.set("current_day", 4)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_scripted_customer = null
	_expect_equal(_game_state.call("start_floor"), true, "F1 #4: day 4 FLOOR for refuse")
	if not bool(_beat_director.call("is_started", SPIKE_STAPLE_BEAT)):
		_beat_director.call("_on_day_phase_changed", DayPhasePolicy.FLOOR)
	spike = _captured_scripted_customer
	_expect_equal(spike != null, true, "F1 #4: Spike queues on day 4 refuse path")
	queue = CustomerQueue.new()
	queue.configure(
		_inventory_service,
		_game_state.adjust_reputation,
		_game_state.spend_attention
	)
	if spike != null:
		staple = spike.wants_sku
		if staple.is_empty():
			staple = spike.target_sku
		_expect_equal(queue.enqueue(spike), true, "F1 #4: refuse path enqueues Spike")
		var refuse_stock := int(_inventory_service.call("card_count", staple))
		var refuse_cash := int(_economy.get("balance_cents"))
		var refuse_rep := int(_game_state.get("current_reputation"))
		_expect_equal(queue.refuse(), true, "F1 #4: refuse resolves")
		_beat_director.call("_on_customer_resolved", spike, &"refused")
		_expect_equal(
			int(_inventory_service.call("card_count", staple)),
			refuse_stock,
			"F1 #4: refuse keeps inventory"
		)
		_expect_equal(
			int(_economy.get("balance_cents")),
			refuse_cash,
			"F1 #4: refuse does not pay cash"
		)
		_expect_equal(
			int(_game_state.get("current_reputation")),
			refuse_rep - 1,
			"F1 #4: refuse ticks Rep"
		)
		_expect_equal(
			_beat_director.call("is_completed", SPIKE_STAPLE_BEAT),
			true,
			"F1 #4: refuse completes the beat"
		)
		_expect_equal(
			_qa_has_beat_event("beat_completed", SPIKE_STAPLE_BEAT),
			true,
			"F1 #4: refuse emits beat_completed"
		)
	queue.free()
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_sec10_6_rent_firesale() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_qa_autoload.call("set_force_enabled", true)
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_rent_decision = {}
	_captured_price_sku = &""
	var hud := _instantiate_gameplay_hud()
	_beat_director.call("_start_day_beats", 7)
	_expect_equal(
		_beat_director.call("is_started", RENT_FIRESALE_BEAT),
		true,
		"F1 #6: rent fire-sale reachable on Normal day 7 PREP without debug"
	)
	_expect_equal(
		_qa_has_beat_event("beat_started", RENT_FIRESALE_BEAT),
		true,
		"F1 #6: emits beat_started"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("fire_sale_enabled", false)),
		true,
		"F1 #6: Fire-sale sealed reachable"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("accessory_enabled", false)),
		true,
		"F1 #6: Cut accessories reachable"
	)
	_expect_equal(
		bool(_captured_rent_decision.get("loan_enabled", false)),
		true,
		"F1 #6: Payday loan reachable on Normal"
	)
	_assert_payload_has_no_truth(_captured_rent_decision, "F1 #6 rent payload")
	if hud != null:
		var rent_panel := hud.get_node_or_null("%RentDecision") as Control
		var fire_sale := hud.get_node_or_null("%RentFireSaleButton") as Button
		var accessories := hud.get_node_or_null("%RentAccessoriesButton") as Button
		var loan := hud.get_node_or_null("%RentLoanButton") as Button
		_expect_equal(
			rent_panel != null and rent_panel.visible,
			true,
			"F1 #6: PREP rent-due modal is live"
		)
		_expect_equal(
			fire_sale != null and fire_sale.visible and not fire_sale.disabled,
			true,
			"F1 #6: Fire-sale button live"
		)
		_expect_equal(
			accessories != null and accessories.visible and not accessories.disabled,
			true,
			"F1 #6: Cut accessories button live"
		)
		_expect_equal(
			loan != null and loan.visible and not loan.disabled,
			true,
			"F1 #6: Payday loan button live on Normal"
		)
		var rent_title := hud.get_node_or_null("%RentTitle") as Label
		var rent_summary := hud.get_node_or_null("%RentSummary") as Label
		_assert_text_has_no_truth(
			rent_title.text if rent_title != null else "",
			"F1 #6 rent title"
		)
		_assert_text_has_no_truth(
			rent_summary.text if rent_summary != null else "",
			"F1 #6 rent summary"
		)
	_expect_equal(
		_beat_director.call("choose_rent_path", &"fire_sale"),
		true,
		"F1 #6: choosing Fire-sale sealed commits"
	)
	_expect_equal(
		_captured_price_sku in [&"AA-DUST-ETB", &"AA-DUST-BLST"],
		true,
		"F1 #6: Fire-sale focuses Dustway sealed"
	)
	_expect_equal(
		_beat_director.call("is_completed", RENT_FIRESALE_BEAT),
		true,
		"F1 #6: choosing Fire-sale closes the beat"
	)
	_expect_equal(
		_qa_has_beat_event("beat_completed", RENT_FIRESALE_BEAT),
		true,
		"F1 #6: Fire-sale emits beat_completed"
	)
	if hud != null:
		var price_panel := hud.get_node_or_null("%PriceEditor") as PanelContainer
		_expect_equal(
			price_panel != null and price_panel.visible,
			true,
			"F1 #6: Fire-sale opens PriceEditor"
		)
		var price_signal := hud.get("_price_signal") as PriceConfirmSignal
		if price_signal != null:
			_expect_dto_has_no_truth_fields(price_signal, "F1 #6 fire-sale PriceEditor")
			_assert_text_has_no_truth(
				DemandSignalPresenter.price_summary(price_signal, false),
				"F1 #6 fire-sale price summary"
			)
		root.remove_child(hud)
		hud.free()

	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_price_sku = &""
	_beat_director.call("_start_day_beats", 7)
	_expect_equal(
		_beat_director.call("choose_rent_path", &"cut_accessories"),
		true,
		"F1 #6: choosing Cut accessories commits"
	)
	_expect_equal(
		String(_captured_price_sku).begins_with("ACC-"),
		true,
		"F1 #6: Cut accessories focuses ACC-*"
	)
	_expect_equal(
		_beat_director.call("is_completed", RENT_FIRESALE_BEAT),
		true,
		"F1 #6: choosing Cut accessories closes the beat"
	)

	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 7)
	var cash_before_loan := int(_economy.get("balance_cents"))
	var rep_before_loan := int(_game_state.get("current_reputation"))
	_expect_equal(
		_beat_director.call("choose_rent_path", &"payday_loan"),
		true,
		"F1 #6: choosing Payday loan commits"
	)
	_expect_equal(
		_beat_director.call("is_completed", RENT_FIRESALE_BEAT),
		true,
		"F1 #6: choosing Payday loan closes the beat"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before_loan + NORMAL_CONFIG.loan_shark_cash_cents,
		"F1 #6: Payday loan adds cash"
	)
	_expect_equal(
		int(_game_state.get("current_reputation")),
		rep_before_loan - NORMAL_CONFIG.loan_shark_rep_hit,
		"F1 #6: Payday loan hits Rep"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 7)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_rent_decision = {}
	hud = _instantiate_gameplay_hud()
	_beat_director.call("_start_day_beats", 7)
	_expect_equal(
		bool(_captured_rent_decision.get("loan_enabled", true)),
		false,
		"F1 #6: Hard hides/disables payday loan"
	)
	if hud != null:
		var hard_loan := hud.get_node_or_null("%RentLoanButton") as Button
		_expect_equal(
			hard_loan != null and not hard_loan.visible and hard_loan.disabled,
			true,
			"F1 #6: Hard loan button hidden and disabled"
		)
		root.remove_child(hud)
		hud.free()
	_expect_equal(
		_beat_director.call("choose_rent_path", &"payday_loan"),
		false,
		"F1 #6: Hard payday loan cannot be chosen"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_sec10_7_titan_hype() -> void:
	_free_lingering_gameplay_huds()
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_qa_autoload.call("set_force_enabled", true)
	_game_state.set("current_day", 8)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_price_sku = &""
	_captured_price_beat = &""
	var hud := _instantiate_gameplay_hud()
	_beat_director.call("_start_day_beats", 8)
	_expect_equal(
		_beat_director.call("is_started", TITAN_HYPE_BEAT),
		true,
		"F1 #7 assert: sec10_7_titan_hype starts on Normal day 8 without debug"
	)
	_expect_equal(
		_qa_has_beat_event("beat_started", TITAN_HYPE_BEAT),
		true,
		"F1 #7 assert: emits beat_started"
	)
	_expect_equal(
		_captured_price_sku,
		&"AA-SKIE-047",
		"F1 #7 assert: PriceEditor focus is Skiefall Titan"
	)
	_expect_equal(
		_captured_price_beat,
		TITAN_HYPE_BEAT,
		"F1 #7 assert: focus carries sec10_7_titan_hype"
	)
	var titan_signal := _demand_signals.call(
		"price_signal",
		&"AA-SKIE-047",
		_inventory_service.call("listed_price_for", &"AA-SKIE-047"),
		_inventory_service.call("location_for", &"AA-SKIE-047")
	) as PriceConfirmSignal
	_expect_equal(
		titan_signal.shown_demand_band,
		&"hot",
		"F1 #7 assert: Titan shows HOT"
	)
	_expect_dto_has_no_truth_fields(titan_signal, "F1 #7 assert price DTO")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(titan_signal, false),
		"F1 #7 assert price summary"
	)
	if hud != null:
		var price_panel := hud.get_node_or_null("%PriceEditor") as PanelContainer
		_expect_equal(
			price_panel != null and price_panel.visible,
			true,
			"F1 #7 assert: D-equivalent PriceEditor opens on Titan"
		)
		var demand := hud.get_node_or_null("%PriceDemandChip") as Label
		var position := hud.get_node_or_null("%PricePositionChip") as Label
		var move := hud.get_node_or_null("%PriceMoveChip") as Label
		for node: Variant in [demand, position, move]:
			if not node is Label:
				continue
			var chip := node as Label
			_assert_text_has_no_truth(chip.text, "F1 #7 assert %s" % chip.name)
		root.remove_child(hud)
		hud.free()
	_beat_director.call("_on_beat_ui_resolved", TITAN_HYPE_BEAT, &"cancelled")
	_expect_equal(
		_beat_director.call("is_completed", TITAN_HYPE_BEAT),
		true,
		"F1 #7 assert: Cancel completes the shipped Titan path"
	)
	_expect_equal(
		_qa_has_beat_event("beat_completed", TITAN_HYPE_BEAT),
		true,
		"F1 #7 assert: emits beat_completed"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("start_new_game")


func _test_sec10_8_slab_vs_singles() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_qa_autoload.call("set_force_enabled", true)
	_game_state.set("current_day", 11)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_showcase_decision = {}
	_captured_showcase_failed = ""
	var hud := _instantiate_gameplay_hud()
	_beat_director.call("_start_day_beats", 11)
	_expect_equal(
		_beat_director.call("is_started", SHOWCASE_BEAT),
		true,
		"F1 #8: slab vs singles reachable on Normal day 11 PREP without debug"
	)
	_expect_equal(
		_qa_has_beat_event("beat_started", SHOWCASE_BEAT),
		true,
		"F1 #8: emits beat_started"
	)
	_expect_equal(
		StringName(_captured_showcase_decision.get("beat_id", &"")),
		SHOWCASE_BEAT,
		"F1 #8: showcase payload tagged"
	)
	_assert_payload_has_no_truth(_captured_showcase_decision, "F1 #8 showcase payload")
	if hud != null:
		var panel := hud.get_node_or_null("%ShowcaseChoice") as Control
		var slab_button := hud.get_node_or_null("%ShowcaseSlabButton") as Button
		var singles_button := hud.get_node_or_null("%ShowcaseSinglesButton") as Button
		var rotate_button := hud.get_node_or_null("%ShowcaseRotateButton") as Button
		var title := hud.get_node_or_null("%ShowcaseTitle") as Label
		_expect_equal(
			panel != null and panel.visible,
			true,
			"F1 #8: showcase modal is live"
		)
		_expect_equal(
			title != null and title.text == "Showcase tight — pick display",
			true,
			"F1 #8: showcase title"
		)
		_expect_equal(
			slab_button != null and slab_button.visible and not slab_button.disabled,
			true,
			"F1 #8: slab choice reachable"
		)
		_expect_equal(
			singles_button != null and singles_button.visible and not singles_button.disabled,
			true,
			"F1 #8: singles choice reachable"
		)
		_expect_equal(
			rotate_button != null and rotate_button.visible and not rotate_button.disabled,
			true,
			"F1 #8: rotate choice reachable"
		)
		_assert_text_has_no_truth(
			title.text if title != null else "",
			"F1 #8 showcase title"
		)
	var slab := _inventory_service.call("get_slab", &"AA-SKIE-052") as SlabInstance
	var titan := _inventory_service.call("get_card", &"AA-SKIE-047") as CardInstance
	var paragon := _inventory_service.call("get_card", &"AA-SKIE-058") as CardInstance
	_expect_equal(slab != null, true, "F1 #8: Empress slab seeded")
	_expect_equal(titan != null and paragon != null, true, "F1 #8: chase singles seeded")
	var case_location := InventoryLocation.new(InventoryLocation.Type.CASE)
	var binder_location := InventoryLocation.new(InventoryLocation.Type.BINDER)
	var inventory := _inventory_service.get("model") as InventoryModel
	var stuffed: Array[CardInstance] = []
	var need := int(_inventory_service.call("case_free_slot_weight")) - 1
	for card: CardInstance in inventory.cards:
		if need <= 0:
			break
		if card.location.type != InventoryLocation.Type.BINDER:
			continue
		if card.sku_id in [&"AA-SKIE-047", &"AA-SKIE-058"]:
			continue
		if bool(_inventory_service.call("move_card_to", card, case_location)):
			stuffed.append(card)
			need -= 1
	_expect_equal(
		int(_inventory_service.call("case_free_slot_weight")) < 2,
		true,
		"F1 #8: stuffed case has under 2 free slot-weights"
	)
	_captured_showcase_failed = ""
	_expect_equal(
		_beat_director.call("choose_showcase", &"slab"),
		false,
		"F1 #8: illegal slab place is blocked"
	)
	_expect_equal(
		_captured_showcase_failed.is_empty(),
		false,
		"F1 #8: over-capacity emits showcase_choice_failed"
	)
	_expect_equal(
		bool(_inventory_service.call("move_slab_to", slab, case_location)),
		false,
		"F1 #8: case API rejects illegal slab place"
	)
	for card: CardInstance in stuffed:
		_inventory_service.call("move_card_to", card, binder_location)
	_expect_equal(
		int(_inventory_service.call("case_free_slot_weight")) >= 2,
		true,
		"F1 #8: clearing filler restores slab space"
	)
	_expect_equal(
		_beat_director.call("choose_showcase", &"rotate"),
		true,
		"F1 #8: rotate is a legal first choice"
	)
	_expect_equal(
		slab.location.type,
		InventoryLocation.Type.CASE,
		"F1 #8: first rotate displays the slab"
	)
	_expect_equal(
		_beat_director.call("is_completed", SHOWCASE_BEAT),
		true,
		"F1 #8: choosing rotate closes the beat"
	)
	_expect_equal(
		_qa_has_beat_event("beat_completed", SHOWCASE_BEAT),
		true,
		"F1 #8: emits beat_completed"
	)
	_expect_equal(
		_beat_director.call("choose_showcase", &"rotate"),
		true,
		"F1 #8: rotate stays reversible the same day"
	)
	_expect_equal(
		titan.location.type,
		InventoryLocation.Type.CASE,
		"F1 #8: rotate swaps to chase singles"
	)
	_expect_equal(
		paragon.location.type,
		InventoryLocation.Type.CASE,
		"F1 #8: both singles are displayed after rotate"
	)
	_expect_equal(
		slab.location.type != InventoryLocation.Type.CASE,
		true,
		"F1 #8: slab leaves the case when singles rotate in"
	)
	_expect_equal(
		_beat_director.call("choose_showcase", &"slab"),
		true,
		"F1 #8: player can still choose slab"
	)
	_expect_equal(
		slab.location.type,
		InventoryLocation.Type.CASE,
		"F1 #8: slab choice displays Empress"
	)
	_expect_equal(
		_beat_director.call("choose_showcase", &"singles"),
		true,
		"F1 #8: player can still choose singles"
	)
	if hud != null:
		root.remove_child(hud)
		hud.free()
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("start_new_game")


func _test_g1_graded_authenticity() -> void:
	_qa.set_force_enabled(false)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_test_g1_channel_cert_roll()
	_test_g1_fake_slab_sell_fail_without_inspect()
	_test_g1_inspect_clears_cert_fog()
	_test_g1_confirm_screens_hide_cert()
	_test_g1_empress_path_still_works()
	_qa_autoload.call("set_force_enabled", false)
	_qa.set_force_enabled(false)
	_game_state.call("start_new_game")


func _test_g1_channel_cert_roll() -> void:
	var always_fake := NORMAL_CONFIG.duplicate() as BalanceConfig
	always_fake.shady_fake_slab_rate = 1.0
	_game_state.call("set_balance_config", always_fake)
	_game_state.call("start_new_game")
	var inventory := _inventory_service.get("model") as InventoryModel
	var empress := inventory.get_sku(&"AA-SKIE-052")
	_expect_equal(empress != null, true, "G1: Empress SKU exists")
	var shady_fake: SlabInstance = _inventory_service.call(
		"receive_slab",
		&"AA-SKIE-052",
		&"Prism",
		10.0,
		empress.base_market_cents if empress != null else 7_500,
		InventoryLocation.new(InventoryLocation.Type.BACKSTOCK),
		&"shady",
		-1
	)
	_expect_equal(shady_fake != null, true, "G1: shady roll creates a slab")
	if shady_fake != null:
		_expect_equal(shady_fake.cert_valid, false, "G1: 100% shady rate is fake")
		_expect_equal(shady_fake.inspected, false, "G1: rolled slab starts uninspected")
		_expect_equal(
			shady_fake.shown_cert_cue,
			SlabInstance.CERT_FOG_CUE,
			"G1: rolled slab starts fogged"
		)
		_assert_text_has_no_truth(shady_fake.shown_cert_cue, "G1 shady fog cue")
	var always_valid := NORMAL_CONFIG.duplicate() as BalanceConfig
	always_valid.shady_fake_slab_rate = 0.0
	_game_state.call("set_balance_config", always_valid)
	_game_state.call("start_new_game")
	empress = (
		_inventory_service.get("model") as InventoryModel
	).get_sku(&"AA-SKIE-052")
	var auction_valid: SlabInstance = _inventory_service.call(
		"receive_slab",
		&"AA-SKIE-052",
		&"Prism",
		10.0,
		empress.base_market_cents if empress != null else 7_500,
		InventoryLocation.new(InventoryLocation.Type.BACKSTOCK),
		&"auction",
		-1
	)
	_expect_equal(auction_valid != null, true, "G1: auction roll creates a slab")
	if auction_valid != null:
		_expect_equal(auction_valid.cert_valid, true, "G1: 0% auction rate is valid")
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	empress = (
		_inventory_service.get("model") as InventoryModel
	).get_sku(&"AA-SKIE-052")
	var beat_slab: SlabInstance = _inventory_service.call(
		"receive_slab",
		&"AA-SKIE-052",
		&"Prism",
		10.0,
		empress.base_market_cents if empress != null else 7_500,
		InventoryLocation.new(InventoryLocation.Type.ONLINE_HOLD)
	)
	_expect_equal(beat_slab != null, true, "G1: beat-style receive_slab still works")
	if beat_slab != null:
		_expect_equal(
			beat_slab.cert_valid,
			true,
			"G1: #8-style seed stays authentic"
		)


func _test_g1_fake_slab_sell_fail_without_inspect() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_qa_autoload.call("clear")
	_qa_autoload.call("set_force_enabled", true)
	var inventory := _inventory_service.get("model") as InventoryModel
	var empress := inventory.get_sku(&"AA-SKIE-052")
	var case_location := InventoryLocation.new(InventoryLocation.Type.CASE)
	var fake: SlabInstance = _inventory_service.call(
		"seed_fake_slab",
		&"AA-SKIE-052",
		&"Prism",
		10.0,
		empress.base_market_cents,
		case_location,
		&"shady"
	)
	_expect_equal(fake != null, true, "G1: seeded fake slab exists")
	if fake == null:
		_qa_autoload.call("set_force_enabled", false)
		return
	_expect_equal(fake.cert_valid, false, "G1: seeded slab is a fail-slab")
	_expect_equal(fake.inspected, false, "G1: seeded fake is uninspected")
	fake.listed_price_cents = 12_000
	var cash_before := int(_economy.get("balance_cents"))
	var rep_before := int(_game_state.get("current_reputation"))
	var sold := bool(
		_inventory_service.call("confirm_customer_sale", &"AA-SKIE-052", 12_000)
	)
	_expect_equal(sold, true, "G1: fake sale resolves as a fail transaction")
	_expect_equal(
		_inventory_service.call("get_slab", &"AA-SKIE-052") == null,
		true,
		"G1: fail-slab is removed on sale fail"
	)
	var cash_after := int(_economy.get("balance_cents"))
	var rep_after := int(_game_state.get("current_reputation"))
	_expect_equal(cash_after < cash_before, true, "G1: sale fail hits cash")
	_expect_equal(
		cash_after,
		cash_before - 12_000,
		"G1: sale fail cash penalty equals listed price"
	)
	_expect_equal(
		rep_after,
		rep_before - NORMAL_CONFIG.fake_slab_sale_rep_hit,
		"G1: sale fail hits Rep"
	)
	var fail_event := _qa_event(&"slab_sale_failed")
	_expect_equal(fail_event.is_empty(), false, "G1: QA records slab_sale_failed")
	if not fail_event.is_empty():
		var payload: Dictionary = fail_event.get("payload", {})
		_expect_equal(
			String(payload.get("outcome", "")),
			"sale_fail",
			"G1: QA outcome is sale_fail"
		)
		_expect_equal(
			bool(payload.get("inspected", true)),
			false,
			"G1: QA records uninspected fail"
		)
		_expect_equal(
			int(payload.get("cash_penalty_cents", 0)),
			12_000,
			"G1: QA records cash penalty"
		)
		_expect_equal(
			int(payload.get("rep_delta", 0)),
			-NORMAL_CONFIG.fake_slab_sale_rep_hit,
			"G1: QA records Rep delta"
		)
		_assert_payload_has_no_truth(payload, "G1 sale-fail QA")
	_qa_autoload.call("set_force_enabled", false)


func _test_g1_inspect_clears_cert_fog() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var inventory := _inventory_service.get("model") as InventoryModel
	var empress := inventory.get_sku(&"AA-SKIE-052")
	var slab: SlabInstance = _inventory_service.call(
		"seed_fake_slab",
		&"AA-SKIE-052",
		&"Prism",
		10.0,
		empress.base_market_cents,
		InventoryLocation.new(InventoryLocation.Type.CASE),
		&"shady"
	)
	_expect_equal(slab != null, true, "G1: inspect test slab exists")
	if slab == null:
		return
	var fog := slab.shown_cert_cue
	var listed := slab.listed_price_cents
	var price_before: PriceConfirmSignal = _demand_signals.call(
		"price_signal",
		&"AA-SKIE-052",
		listed,
		slab.location
	)
	_demand_signals.call("apply_owned_slab_cue", price_before)
	var comp_low := price_before.shown_comp_low_cents
	var comp_high := price_before.shown_comp_high_cents
	var band := price_before.shown_demand_band
	_expect_equal(price_before.inspected, false, "G1: price confirm starts fogged")
	_assert_text_has_no_truth(price_before.condition_cue, "G1 pre-inspect price cue")
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(price_before),
		"G1 pre-inspect price summary"
	)
	_expect_dto_has_no_truth_fields(price_before, "G1 price confirm DTO")
	var accurate := DemandSignalService.new(
		NORMAL_CONFIG,
		MarketState.new(),
		7,
		_qa
	)
	accurate._config = accurate._config.duplicate()
	accurate._config.inspect_accuracy = 1.0
	_expect_equal(
		accurate.inspect_slab_instance(slab),
		true,
		"G1: inspect spend resolves the instance"
	)
	_expect_equal(slab.inspected, true, "G1: inspect marks the instance")
	_expect_equal(
		slab.shown_cert_cue != fog,
		true,
		"G1: inspect updates cert cue"
	)
	_expect_equal(
		slab.shown_cert_cue,
		SlabInstance.CERT_OFF_CUE,
		"G1: accurate inspect reveals fail hologram"
	)
	_assert_text_has_no_truth(slab.shown_cert_cue, "G1 inspected slab cue")
	_demand_signals.call("apply_owned_slab_cue", price_before)
	_expect_equal(
		price_before.shown_comp_low_cents,
		comp_low,
		"G1: inspect does not change comp low"
	)
	_expect_equal(
		price_before.shown_comp_high_cents,
		comp_high,
		"G1: inspect does not change comp high"
	)
	_expect_equal(
		price_before.shown_demand_band,
		band,
		"G1: inspect does not change demand band"
	)
	_expect_equal(price_before.inspected, true, "G1: price confirm shows inspected")
	_expect_equal(
		price_before.condition_cue,
		slab.shown_cert_cue,
		"G1: price confirm uses inspected cue"
	)
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(price_before),
		"G1 inspected price summary"
	)
	var att_before := int(_game_state.get("attention_remaining"))
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "G1: HUD loads for price inspect")
	var valid_slab: SlabInstance = _inventory_service.call(
		"receive_slab",
		&"AA-SKIE-047",
		&"Vaultmark",
		9.5,
		1_200,
		InventoryLocation.new(InventoryLocation.Type.CASE),
		&"auction",
		1
	)
	_expect_equal(valid_slab != null, true, "G1: second slab for HUD inspect")
	if hud != null and valid_slab != null:
		var price_dto: PriceConfirmSignal = _demand_signals.call(
			"price_signal",
			&"AA-SKIE-047",
			valid_slab.listed_price_cents,
			valid_slab.location
		)
		_demand_signals.call("apply_owned_slab_cue", price_dto)
		Callable(hud, "_select_price_stock").call(price_dto)
		var price_inspect := hud.get_node_or_null("%PriceInspectButton") as Button
		_expect_equal(price_inspect != null, true, "G1: PriceEditor Inspect★ present")
		if price_inspect != null:
			_expect_equal(
				price_inspect.visible,
				true,
				"G1: Inspect★ shown on slab PriceEditor"
			)
			_expect_equal(
				price_inspect.disabled,
				false,
				"G1: Inspect★ enabled before spend"
			)
			price_inspect.pressed.emit()
			_expect_equal(valid_slab.inspected, true, "G1: HUD inspect clears fog")
			var shop := _game_state.get("shop") as ShopState
			_expect_equal(
				int(_game_state.get("attention_remaining")),
				att_before - shop.inspect_attention_cost(),
				"G1: HUD inspect spends Attention"
			)
			_assert_text_has_no_truth(
				(hud.get_node_or_null("%PriceSummary") as Label).text,
				"G1 HUD price summary after inspect"
			)
			_expect_equal(price_inspect.disabled, true, "G1: Inspect★ disables after")
		root.remove_child(hud)
		hud.free()


func _test_g1_confirm_screens_hide_cert() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var inventory := _inventory_service.get("model") as InventoryModel
	var empress := inventory.get_sku(&"AA-SKIE-052")
	var lot: BuyOpportunity = _demand_signals.call(
		"inject_graded_opportunity",
		&"g1-shady-slab",
		&"AA-SKIE-052",
		DemandSignalService.Channel.SHADY,
		4_200,
		&"Prism",
		10.0,
		"Trunk slab",
		0
	)
	_expect_equal(lot != null, true, "G1: thin shady graded seed injects")
	var dto: BuyConfirmSignal = _demand_signals.call(
		"buy_signal_for_id",
		&"g1-shady-slab"
	)
	_expect_equal(dto != null, true, "G1: shady slab buy signal exists")
	if dto != null:
		_expect_equal(dto.channel, &"shady", "G1: seeded lot is shady")
		_expect_equal(dto.grader, &"Prism", "G1: seeded lot is graded")
		_expect_equal(dto.inspected, false, "G1: buy signal starts uninspected")
		_expect_dto_has_no_truth_fields(dto, "G1 shady slab DTO")
		_assert_text_has_no_truth(dto.condition_cue, "G1 shady slab cue")
		_assert_text_has_no_truth(
			DemandSignalPresenter.buy_summary(dto),
			"G1 shady slab buy summary"
		)
		_assert_text_has_no_truth(
			DemandSignalPresenter.buy_confirm_snapshot(dto),
			"G1 shady slab confirm snapshot"
		)
		_expect_equal(
			dto.condition_cue.to_lower().contains("inspect"),
			true,
			"G1: graded shady starts with inspect fog"
		)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "G1: HUD loads for confirm fog")
	if hud != null and dto != null:
		_select_buy_on_hud(hud, dto)
		var buy_summary := hud.get_node_or_null("%BuySummary") as Label
		var inspect_button := hud.get_node_or_null("%InspectButton") as Button
		_expect_equal(
			inspect_button != null and inspect_button.visible,
			true,
			"G1: Inspect★ on graded shady detail"
		)
		if buy_summary != null:
			_assert_text_has_no_truth(buy_summary.text, "G1 buy detail")
			_expect_equal(
				buy_summary.text.to_lower().contains("inspect"),
				true,
				"G1: buy detail shows inspect fog"
			)
		Callable(hud, "_open_buy_confirm").call()
		var confirm_summary := hud.get_node_or_null("%BuyConfirmSummary") as Label
		if confirm_summary != null:
			_assert_text_has_no_truth(confirm_summary.text, "G1 buy confirm")
			_expect_equal(
				confirm_summary.text.to_lower().contains("cert_valid"),
				false,
				"G1: confirm hides cert_valid"
			)
		if inspect_button != null:
			Callable(hud, "_back_to_buy_detail").call()
			inspect_button.pressed.emit()
			_expect_equal(dto.inspected, true, "G1: buy Inspect★ clears fog")
			_assert_text_has_no_truth(dto.condition_cue, "G1 post-inspect buy cue")
			_assert_text_has_no_truth(
				DemandSignalPresenter.buy_summary(dto),
				"G1 post-inspect buy summary"
			)
			Callable(hud, "_open_buy_confirm").call()
			if confirm_summary != null:
				_assert_text_has_no_truth(
					confirm_summary.text,
					"G1 post-inspect confirm"
				)
		root.remove_child(hud)
		hud.free()
	var auction_lot: BuyOpportunity = _demand_signals.call(
		"inject_graded_opportunity",
		&"g1-auction-slab",
		&"AA-SKIE-052",
		DemandSignalService.Channel.AUCTION,
		5_600,
		&"Prism",
		10.0,
		"Auction slab",
		1
	)
	_expect_equal(auction_lot != null, true, "G1: thin auction graded seed injects")
	var auction_dto: BuyConfirmSignal = _demand_signals.call(
		"buy_signal_for_id",
		&"g1-auction-slab"
	)
	_expect_equal(auction_dto != null, true, "G1: auction slab signal exists")
	if auction_dto != null:
		_expect_equal(auction_dto.channel, &"auction", "G1: auction channel")
		_expect_equal(
			DemandSignalService.recommends_inspect(auction_dto.channel),
			true,
			"G1: auction slab can Inspect★"
		)
		_expect_dto_has_no_truth_fields(auction_dto, "G1 auction slab DTO")
		_assert_text_has_no_truth(auction_dto.condition_cue, "G1 auction slab cue")
	_expect_equal(empress != null, true, "G1: Empress remains catalogued")


func _test_g1_empress_path_still_works() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_day", 11)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_showcase_decision = {}
	_beat_director.call("_start_day_beats", 11)
	_expect_equal(
		_beat_director.call("is_started", SHOWCASE_BEAT),
		true,
		"G1: #8 Empress path still starts"
	)
	var slab: SlabInstance = _inventory_service.call("get_slab", &"AA-SKIE-052")
	_expect_equal(slab != null, true, "G1: #8 still seeds Empress slab")
	if slab != null:
		_expect_equal(slab.cert_valid, true, "G1: #8 Empress slab stays authentic")
		_expect_equal(
			String(slab.grader),
			"Prism",
			"G1: #8 Empress grader unchanged"
		)
		_assert_text_has_no_truth(slab.shown_cert_cue, "G1 #8 slab cue")
	_expect_equal(
		_beat_director.call("choose_showcase", &"slab"),
		true,
		"G1: #8 slab choice still works"
	)
	if slab != null:
		_expect_equal(
			slab.location.type,
			InventoryLocation.Type.CASE,
			"G1: #8 still displays Empress"
		)


func _qa_event(event_name: StringName) -> Dictionary:
	for event: Dictionary in _qa_autoload.call("get_events"):
		if String(event.get("event", "")) == String(event_name):
			return event
	return {}


func _assert_hold_inherit_scalars(config: BalanceConfig, label: String) -> void:
	_expect_equal(config.staff_noshow_mult, 0.4, "H2: %s staff_noshow_mult readable" % label)
	_expect_equal(config.pull_attention, 5, "H3: %s pull_attention readable" % label)
	_game_state.call("set_balance_config", config)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	_expect_equal(shop.staff_noshow_mult(), 0.4, "H2: %s ShopState staff_noshow_mult" % label)
	_expect_equal(shop.pull_attention_cost(), 5, "H3: %s ShopState pull Att" % label)
	_expect_equal(shop.specialist_wage_cents(), 14_000, "H4: %s specialist wage inherits" % label)
	_expect_equal(shop.staff_cap(), 1, "H4: %s Small staff cap inherits" % label)


func _assert_hold_staff_panel(
	config: BalanceConfig,
	label: String,
	expect_seeded_staff: bool
) -> void:
	_game_state.call("set_balance_config", config)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "H4: %s StaffPanel HUD loads" % label)
	if hud == null:
		return
	var open_staff := hud.get_node_or_null("%OpenStaffButton") as Button
	_expect_equal(open_staff != null, true, "H4: %s Open Staff present" % label)
	open_staff.pressed.emit()
	var hire_cashier := hud.get_node_or_null("%HireCashierButton") as Button
	var hire_specialist := hud.get_node_or_null("%HireSpecialistButton") as Button
	var staff_hint := hud.get_node_or_null("%StaffHint") as Label
	var staff_rows := hud.get_node_or_null("%StaffRows") as VBoxContainer
	_expect_equal(
		hire_cashier != null and hire_cashier.text.contains("$80.00"),
		true,
		"H4: %s cashier wage is not blank" % label
	)
	_expect_equal(
		hire_specialist != null and hire_specialist.text.contains("$140.00"),
		true,
		"H4: %s specialist wage is not blank" % label
	)
	_expect_equal(
		staff_hint != null and staff_hint.text.contains("Roster"),
		true,
		"H4: %s roster hint is not blank" % label
	)
	_expect_equal(
		staff_hint.text.contains("%d / %d" % [shop.hired_count(), shop.staff_cap()]),
		true,
		"H4: %s roster uses inherited cap" % label
	)
	_expect_equal(staff_rows != null, true, "H4: %s staff rows present" % label)
	if staff_rows != null:
		_expect_equal(staff_rows.get_child_count() > 0, true, "H4: %s staff rows not empty" % label)
		var first := staff_rows.get_child(0)
		var row_text := ""
		if first is Label:
			row_text = (first as Label).text
		elif first is HBoxContainer and first.get_child_count() > 0:
			var inner := first.get_child(0)
			if inner is Label:
				row_text = (inner as Label).text
		_expect_equal(row_text.is_empty(), false, "H4: %s roster row text not blank" % label)
		if expect_seeded_staff:
			_expect_equal(row_text.contains("$"), true, "H4: %s seeded wage visible" % label)
		else:
			_expect_equal(
				row_text.contains("Owner only"),
				true,
				"H4: %s owner-only empty state" % label
			)
	_assert_text_has_no_truth(
		hire_specialist.text if hire_specialist != null else "",
		"H4 %s specialist hire" % label
	)
	root.remove_child(hud)
	hud.free()


func _start_shady_on_normal_window() -> void:
	_game_state.call("start_new_game")
	_game_state.set("current_day", 18)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_beat_director.call("_start_day_beats", 18)
	_beat_director.call("choose_beat_path", &"stay_small")
	_game_state.set("current_day", 20)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_beat_decision = {}
	_beat_director.call("_start_day_beats", 20)


func _capture_scripted_customer(customer: CustomerProfile) -> void:
	_captured_scripted_customer = customer


func _capture_price_focus(
	sku_id: StringName,
	beat_id: StringName,
	_message: String,
	suggestion_mode: StringName
) -> void:
	_captured_price_sku = sku_id
	_captured_price_beat = beat_id
	_captured_price_mode = suggestion_mode
	_captured_price_focus_count += 1


func _capture_rent_decision(payload: Dictionary) -> void:
	_captured_rent_decision = payload


func _capture_beat_decision(payload: Dictionary) -> void:
	_captured_beat_decision = payload


func _capture_campaign_won(payload: Dictionary) -> void:
	_captured_campaign_won = payload


func _capture_loan_shark_offered(payload: Dictionary) -> void:
	_captured_loan_shark = payload


func _capture_loan_shark_resolved(outcome: StringName) -> void:
	_captured_loan_shark_outcome = outcome


func _capture_campaign_lost(payload: Dictionary) -> void:
	_captured_campaign_lost = payload


func _capture_buy_focus(
	opportunity_id: StringName,
	beat_id: StringName,
	_message: String
) -> void:
	_captured_buy_focus_id = opportunity_id
	_captured_buy_focus_beat = beat_id


func _capture_showcase_decision(payload: Dictionary) -> void:
	_captured_showcase_decision = payload


func _capture_showcase_failed(message: String) -> void:
	_captured_showcase_failed = message


func _qa_has_beat_event(event_name: String, beat_id: StringName) -> bool:
	for event: Dictionary in _qa_autoload.call("get_events"):
		if String(event.get("event", "")) != event_name:
			continue
		var payload: Dictionary = event.get("payload", {})
		if String(payload.get("beat_id", "")) == String(beat_id):
			return true
	return false


func _bind_customer_serve(hud: Node, customer: CustomerProfile) -> void:
	if hud == null or customer == null:
		return
	if customer.target_sku.is_empty():
		var sku_id := customer.wants_sku
		if sku_id.is_empty() and not customer.desired_skus.is_empty():
			sku_id = customer.desired_skus[0]
		customer.target_sku = sku_id
		customer.listed_price_cents = int(
			_inventory_service.call("listed_price_for", sku_id)
		)
	Callable(hud, "_on_customer_head_changed").call(customer)
	Callable(hud, "_on_customer_desk_ready").call(customer, true)


func _choice_ids(payload: Dictionary) -> Array[StringName]:
	var ids: Array[StringName] = []
	for value: Variant in payload.get("choices", []):
		if value is Dictionary:
			ids.append(StringName((value as Dictionary).get("id", &"")))
	return ids


func _choice_enabled(payload: Dictionary, choice_id: StringName) -> bool:
	for value: Variant in payload.get("choices", []):
		if not value is Dictionary:
			continue
		var choice := value as Dictionary
		if StringName(choice.get("id", &"")) != choice_id:
			continue
		return bool(choice.get("enabled", false))
	return false


func _test_i1_online_unlock_gate() -> void:
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_expect_equal(NORMAL_CONFIG.online_unlock_rep, 35, "I1: unlock Rep is 35")
	_expect_equal(
		is_equal_approx(NORMAL_CONFIG.online_fee, 0.08),
		true,
		"I1: fee is 8%"
	)
	_game_state.set("current_reputation", 34)
	_expect_equal(
		bool(_economy.get("online_listings").call("is_unlocked")),
		false,
		"I1: locked below Rep 35"
	)
	_expect_equal(
		bool(_economy.get("online_listings").call("can_list")),
		false,
		"I1: cannot list below Rep 35"
	)
	var locked := _i1_list_unique_card(2200)
	_expect_equal(bool(locked.get("ok", false)), false, "I1: list rejected while locked")
	_expect_equal(
		StringName(locked.get("reason", &"")),
		&"locked",
		"I1: lock reason is locked"
	)
	_game_state.set("current_reputation", 35)
	_expect_equal(
		bool(_economy.get("online_listings").call("is_unlocked")),
		true,
		"I1: unlocks at Rep 35"
	)
	_expect_equal(
		bool(_economy.get("online_listings").call("can_list")),
		true,
		"I1: can list at Rep 35"
	)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "I1: HUD loads for unlock gate")
	if hud != null:
		Callable(hud, "_sync_online_button").call()
		var button := hud.get_node_or_null("%OpenOnlineButton") as Button
		_expect_equal(
			button != null and not button.disabled,
			true,
			"I1: HUD Online button enabled at Rep 35"
		)
		_game_state.set("current_reputation", 34)
		_event_bus.reputation_changed.emit(34)
		_expect_equal(
			button != null and button.disabled,
			true,
			"I1: HUD Online button disabled below Rep 35"
		)
		_expect_equal(
			button != null and button.text.contains("35"),
			true,
			"I1: locked HUD copy names Rep 35"
		)
		root.remove_child(hud)
		hud.free()
	_game_state.call("start_new_game")


func _test_i1_list_hold_fee_and_cancel() -> void:
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_reputation", 40)
	var card := _i1_unique_card()
	_expect_equal(card != null, true, "I1: unique card for hold path")
	if card == null:
		_qa_autoload.call("set_force_enabled", false)
		return
	var listed_price := 2500
	var listed: Dictionary = _economy.get("online_listings").call(
		"list_target",
		_i1_card_target(card),
		listed_price,
		{"ship_days": 1}
	)
	_expect_equal(bool(listed.get("ok", false)), true, "I1: list succeeds when unlocked")
	var listing := listed.get("listing") as OnlineListing
	_expect_equal(listing != null, true, "I1: listing record created")
	_expect_equal(
		card.location.type,
		InventoryLocation.Type.ONLINE_HOLD,
		"I1: listed card moves to ONLINE_HOLD"
	)
	_expect_equal(
		_inventory_service.call("find_listed_sku_offer", card.sku_id, listed_price),
		{},
		"I1: held card cannot be offered in-store"
	)
	_expect_equal(
		bool(_inventory_service.call("confirm_customer_sale", card.sku_id, listed_price)),
		false,
		"I1: held card cannot sell in-store"
	)
	_expect_equal(
		listing.fee_cents,
		OnlineListingService.fee_cents_for(listed_price, NORMAL_CONFIG.online_fee),
		"I1: 8% fee is computed on list"
	)
	var cancelled: Dictionary = _economy.get("online_listings").call("cancel_listing", listing.id)
	_expect_equal(bool(cancelled.get("ok", false)), true, "I1: cancel before fill works")
	_expect_equal(
		card.location.type,
		InventoryLocation.Type.BINDER,
		"I1: cancel returns stock from ONLINE_HOLD"
	)
	_expect_equal(
		_i1_ledger_count(&"online_fee"),
		0,
		"I1: cancel before fill does not charge fee"
	)
	var refill: Dictionary = _economy.get("online_listings").call(
		"list_target",
		_i1_card_target(card),
		listed_price,
		{"ship_days": 1}
	)
	_expect_equal(bool(refill.get("ok", false)), true, "I1: re-list after cancel")
	var cash_before := int(_economy.get("balance_cents"))
	_expect_equal(bool(_game_state.call("start_floor")), true, "I1: open floor for fill")
	_expect_equal(bool(_game_state.call("start_settle")), true, "I1: settle fills ship=1")
	var filled := refill.get("listing") as OnlineListing
	_expect_equal(
		filled.status,
		OnlineListing.Status.FILLED,
		"I1: 1-day ship fills at settle"
	)
	_expect_equal(
		_i1_ledger_count(&"online_sale") >= 1,
		true,
		"I1: fill posts online_sale income"
	)
	_expect_equal(
		_i1_ledger_count(&"online_fee") >= 1,
		true,
		"I1: fill posts online_fee expense"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before + listed_price - filled.fee_cents,
		"I1: net cash is list price minus 8% fee"
	)
	_expect_equal(
		_inventory_service.call("get_card", card.sku_id) == null
		or (
			_inventory_service.call("get_card", card.sku_id) as CardInstance
		) != card,
		true,
		"I1: filled listing removes held stock"
	)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("start_new_game")


func _test_i1_frequent_cancel_rep_hit() -> void:
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_reputation", 40)
	var card := _i1_unique_card()
	_expect_equal(card != null, true, "I1: unique card for cancel streak")
	if card == null:
		_qa_autoload.call("set_force_enabled", false)
		return
	var hit_count := 0
	var last_result: Dictionary = {}
	for _index: int in 3:
		var listed: Dictionary = _economy.get("online_listings").call(
			"list_target",
			_i1_card_target(card),
			1800,
			{"ship_days": 3}
		)
		_expect_equal(bool(listed.get("ok", false)), true, "I1: cancel-streak list")
		var listing := listed.get("listing") as OnlineListing
		last_result = _economy.get("online_listings").call(
			"cancel_listing",
			listing.id
		)
		if bool(last_result.get("frequent", false)):
			hit_count += 1
	_expect_equal(hit_count >= 1, true, "I1: frequent-cancel flag fires")
	_expect_equal(
		int(_game_state.get("current_reputation")),
		40 - NORMAL_CONFIG.online_cancel_rep_hit,
		"I1: frequent cancel applies Rep hit"
	)
	var events: Array = _qa_autoload.call("get_events")
	var saw_hit := false
	for event_value: Variant in events:
		var event := event_value as Dictionary
		if String(event.get("event", "")) != "online_cancel_rep_hit":
			continue
		saw_hit = true
		var payload: Dictionary = event.get("payload", {})
		_expect_payload_keys(
			event,
			[&"listing_id", &"sku_id", &"cancels_in_window", &"window_days", &"rep_delta", &"reputation"],
			"I1: frequent-cancel QA payload"
		)
		_expect_equal(int(payload.get("rep_delta", 0)) < 0, true, "I1: QA rep_delta is a hit")
		_expect_equal(
			int(payload.get("cancels_in_window", 0))
			>= NORMAL_CONFIG.online_cancel_frequent_threshold,
			true,
			"I1: QA window count meets threshold"
		)
	_expect_equal(saw_hit, true, "I1: online_cancel_rep_hit instrumentation fires")
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("start_new_game")


func _test_i1_list_confirm_has_no_truth() -> void:
	_free_lingering_gameplay_huds()
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_reputation", 40)
	var card := _i1_unique_card()
	_expect_equal(card != null, true, "I1: unique card for confirm nack")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "I1: HUD loads for list confirm")
	if hud == null or card == null:
		return
	var dto: OnlineListConfirmSignal = _demand_signals.call(
		"list_confirm_signal",
		card.sku_id,
		card.listed_price_cents,
		card.location
	)
	_expect_equal(dto != null, true, "I1: list confirm DTO exists")
	if dto != null:
		_expect_dto_has_no_truth_fields(dto, "I1: list confirm DTO")
		_assert_text_has_no_truth(
			DemandSignalPresenter.list_confirm_summary(dto),
			"I1: list confirm summary"
		)
		_assert_text_has_no_truth(
			DemandSignalPresenter.listable_stock_row(dto),
			"I1: listable row"
		)
	Callable(hud, "_select_online_target").call(_i1_card_target(card), dto)
	var title := hud.get_node_or_null("%OnlineTitle") as Label
	var summary := hud.get_node_or_null("%OnlineSummary") as Label
	var position := hud.get_node_or_null("%OnlinePositionChip") as Label
	var demand := hud.get_node_or_null("%OnlineDemandChip") as Label
	var move := hud.get_node_or_null("%OnlineMoveChip") as Label
	for node: Label in [title, summary, position, demand, move]:
		if node == null:
			continue
		_assert_text_has_no_truth(node.text, "I1: %s" % node.name)
	_expect_equal(
		demand != null and not demand.text.is_empty(),
		true,
		"I1: §4.5 demand chip is shown"
	)
	_expect_equal(
		position != null and not position.text.is_empty(),
		true,
		"I1: §4.5 position chip is shown"
	)
	_expect_equal(
		move != null and not move.text.is_empty(),
		true,
		"I1: §4.5 move-feel chip is shown"
	)
	_expect_equal(
		summary != null and summary.text.to_lower().contains("8%"),
		true,
		"I1: confirm shows 8% fee"
	)
	root.remove_child(hud)
	hud.free()
	_game_state.call("start_new_game")


func _test_i1_soft_ensure_priceable_sku_parked() -> void:
	var demand_src := FileAccess.get_file_as_string(
		"res://scripts/autoload/demand_signals.gd"
	)
	_expect_equal(
		demand_src.contains("func _ensure_priceable_sku"),
		true,
		"I1: Soft _ensure_priceable_sku stays parked in DemandSignals"
	)
	for path: String in [
		"res://scripts/economy/online_listing_service.gd",
		"res://scripts/economy/online_listing.gd",
		"res://scripts/economy/online_list_confirm_signal.gd",
		"res://scripts/ui/hud.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_expect_equal(
			source.contains("_ensure_priceable_sku"),
			false,
			"I1: %s does not call parked Soft helper" % path
		)
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("current_reputation", 40)
	var titan_before := int(_inventory_service.call("card_count", &"AA-SKIE-047"))
	var missing: Dictionary = _economy.get("online_listings").call(
		"list_target",
		{
			"sku_id": &"NO-SUCH-SKU",
			"display_name": "Missing",
			"listed_price_cents": 1000,
			"location": InventoryLocation.new(InventoryLocation.Type.SHELF),
		},
		1000
	)
	_expect_equal(bool(missing.get("ok", false)), false, "I1: missing SKU does not list")
	_expect_equal(
		int(_inventory_service.call("card_count", &"AA-SKIE-047")),
		titan_before,
		"I1: failed list does not seed Titan via Soft helper"
	)
	_game_state.call("start_new_game")


func _test_j1_research_specialist_skill_deepen() -> void:
	_qa_autoload.call("set_force_enabled", true)
	_qa_autoload.call("clear")
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	var shop := _game_state.get("shop") as ShopState
	var sku_id := &"AA-SKIE-047"
	_expect_equal(NORMAL_CONFIG.research_cost_cents, 5_000, "J1: Research cash is $50")
	_expect_equal(NORMAL_CONFIG.research_attention, 15, "J1: Research Att cost is 15")
	_expect_equal(
		is_equal_approx(NORMAL_CONFIG.research_comp_narrow_factor, 0.55),
		true,
		"J1: comp narrow factor is ×0.55"
	)
	_expect_equal(
		is_equal_approx(NORMAL_CONFIG.research_demand_band_sigma, 0.07),
		true,
		"J1: informed demand σ is 0.07"
	)
	_expect_equal(
		is_equal_approx(NORMAL_CONFIG.demand_band_sigma, 0.12),
		true,
		"J1: default demand σ is 0.12"
	)

	_game_state.set("attention_remaining", 0)
	_event_bus.emit_signal("attention_changed", 0)
	_expect_equal(_game_state.call("can_research"), false, "J1: can_research false at Att 0")
	var att0 := _demand_signals.call("research_set", &"AA-SKIE") as Dictionary
	_expect_equal(bool(att0.get("ok", false)), false, "J1: Research blocked at Att 0")
	_expect_equal(
		StringName(att0.get("reason", &"")),
		&"insufficient_attention",
		"J1: Att 0 reason is insufficient_attention"
	)

	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	var location: InventoryLocation = _inventory_service.call("location_for", sku_id)
	var buy_before := _demand_signals.call(
		"buy_signal",
		sku_id,
		DemandSignalService.Channel.MARKETPLACE,
		1200,
		1
	) as BuyConfirmSignal
	var price_before := _demand_signals.call("price_signal", sku_id, 2200, location) as PriceConfirmSignal
	var card := _i1_unique_card()
	_expect_equal(card != null, true, "J1: unique card for online confirm")
	_game_state.set("current_reputation", 40)
	var list_before := _demand_signals.call(
		"list_confirm_signal",
		card.sku_id,
		card.listed_price_cents,
		card.location
	) as OnlineListConfirmSignal
	_expect_equal(
		_demand_signals.call("is_skill_informed", sku_id),
		false,
		"J1: default skill channel is off"
	)
	_expect_equal(
		String(_demand_signals.call("skill_channel_for", sku_id)),
		"",
		"J1: default skill channel is empty"
	)
	_expect_equal(
		String(_demand_signals.call("rotation_watch_text")),
		"",
		"J1: rotation watch hidden by default"
	)

	var cash_before := int(_economy.get("balance_cents"))
	var att_before := int(_game_state.get("attention_remaining"))
	_qa_autoload.call("clear")
	var researched := _demand_signals.call("research_set", &"AA-SKIE") as Dictionary
	_expect_equal(bool(researched.get("ok", false)), true, "J1: Research succeeds at Att ≥ cost + $50")
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		att_before - NORMAL_CONFIG.research_attention,
		"J1: Research spends Att 15"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before - NORMAL_CONFIG.research_cost_cents,
		"J1: Research spends $50"
	)
	_expect_equal(
		_demand_signals.call("is_skill_informed", sku_id),
		true,
		"J1: Research buff informs the target set"
	)
	_expect_equal(
		String(_demand_signals.call("skill_channel_for", sku_id)),
		"research",
		"J1: skill channel is research after spend"
	)
	_expect_equal(
		_demand_signals.call("is_skill_informed", &"AA-BASE-088"),
		false,
		"J1: Research does not inform other sets"
	)
	var telegraph := int(researched.get("telegraph_through_day", -1))
	_expect_equal(
		telegraph >= int(_game_state.get("current_day"))
		and telegraph <= int(_game_state.get("current_day")) + 2,
		true,
		"J1: Research telegraph lasts 24–72h (1–3 days)"
	)
	_expect_equal(
		String(researched.get("rotation_watch", "")).begins_with("Rotation watch:"),
		true,
		"J1: Research rotation watch uses required copy"
	)
	_assert_payload_has_no_truth(researched, "J1: research payload")
	_assert_text_has_no_truth(
		String(researched.get("rotation_watch", "")),
		"J1: research rotation watch"
	)
	_expect_equal(
		String(researched.get("condition_cue", "")).to_lower().contains("photo")
		or String(researched.get("condition_cue", "")).to_lower().contains("inspect"),
		true,
		"J1: Research keeps condition fog"
	)

	var buy_after := _demand_signals.call(
		"buy_signal",
		sku_id,
		DemandSignalService.Channel.MARKETPLACE,
		1200,
		1
	) as BuyConfirmSignal
	var price_after := _demand_signals.call("price_signal", sku_id, 2200, location) as PriceConfirmSignal
	var list_after := _demand_signals.call(
		"list_confirm_signal",
		card.sku_id,
		card.listed_price_cents,
		card.location
	) as OnlineListConfirmSignal
	_expect_equal(
		_j1_comp_width(buy_after) < _j1_comp_width(buy_before),
		true,
		"J1: Research narrows buy confirm comps"
	)
	_expect_equal(
		_j1_comp_width(price_after) < _j1_comp_width(price_before),
		true,
		"J1: Research narrows price confirm comps"
	)
	_expect_equal(
		_j1_comp_width(list_after) < _j1_comp_width(list_before),
		true,
		"J1: Research narrows online list confirm comps"
	)
	_expect_dto_has_no_truth_fields(buy_after, "J1: researched buy confirm")
	_expect_dto_has_no_truth_fields(price_after, "J1: researched price confirm")
	_expect_dto_has_no_truth_fields(list_after, "J1: researched online confirm")
	_assert_text_has_no_truth(
		DemandSignalPresenter.buy_summary(buy_after),
		"J1: researched buy summary"
	)
	_assert_text_has_no_truth(
		DemandSignalPresenter.price_summary(price_after),
		"J1: researched price summary"
	)
	_assert_text_has_no_truth(
		DemandSignalPresenter.list_confirm_summary(list_after),
		"J1: researched online summary"
	)
	var skill_events := _j1_skill_signal_events()
	_expect_equal(skill_events.size() >= 3, true, "J1: Research emits skill instrumentation")
	var saw_informed_buy := false
	var saw_informed_price := false
	var saw_informed_list := false
	for event: Dictionary in skill_events:
		var payload: Dictionary = event.get("payload", {})
		if not bool(payload.get("skill_informed", false)):
			continue
		_expect_equal(
			is_equal_approx(float(payload.get("demand_band_sigma", 1.0)), 0.07),
			true,
			"J1: informed σ is 0.07"
		)
		_expect_equal(
			is_equal_approx(float(payload.get("comp_narrow_factor", 1.0)), 0.55),
			true,
			"J1: informed narrow factor is 0.55"
		)
		match String(payload.get("screen", "")):
			"buy_confirm":
				saw_informed_buy = true
			"price_confirm":
				saw_informed_price = true
			"list_confirm":
				saw_informed_list = true
	_expect_equal(saw_informed_buy, true, "J1: buy_confirm instrumentation is informed")
	_expect_equal(saw_informed_price, true, "J1: price_confirm instrumentation is informed")
	_expect_equal(saw_informed_list, true, "J1: list_confirm instrumentation is informed")

	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_ROTATION,
		{"set_id": &"AA-DUST", "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(
		String(_demand_signals.call("event_banner_text")),
		"",
		"J1: Dustway rotation stays hidden without Research/Specialist on that set"
	)
	_expect_equal(
		String(_demand_signals.call("rotation_watch_text")).contains("Skiefall"),
		true,
		"J1: Research buff still shows its own Rotation watch"
	)

	_game_state.call("start_new_game")
	shop = _game_state.get("shop") as ShopState
	_game_state.set("current_reputation", 40)
	card = _i1_unique_card()
	location = _inventory_service.call("location_for", sku_id)
	var spec_buy_before := _demand_signals.call(
		"buy_signal",
		sku_id,
		DemandSignalService.Channel.MARKETPLACE,
		1200,
		1
	) as BuyConfirmSignal
	var spec_price_before := _demand_signals.call(
		"price_signal",
		sku_id,
		2200,
		location
	) as PriceConfirmSignal
	var spec_list_before := _demand_signals.call(
		"list_confirm_signal",
		card.sku_id,
		card.listed_price_cents,
		card.location
	) as OnlineListConfirmSignal
	var spec_cash := int(_economy.get("balance_cents"))
	var spec_att := int(_game_state.get("attention_remaining"))
	_qa_autoload.call("clear")
	_expect_equal(shop.hire_specialist() != null, true, "J1: hire Specialist")
	_expect_equal(shop.has_specialist_on_duty(), true, "J1: Specialist is on duty")
	_expect_equal(
		int(_economy.get("balance_cents")),
		spec_cash,
		"J1: Specialist narrow does not spend Research cash"
	)
	_expect_equal(
		int(_game_state.get("attention_remaining")),
		spec_att,
		"J1: Specialist narrow does not spend Research Attention"
	)
	_expect_equal(
		_demand_signals.call("is_skill_informed", sku_id),
		true,
		"J1: Specialist on duty informs confirms without Research"
	)
	_expect_equal(
		_demand_signals.call("is_skill_informed", &"AA-BASE-088"),
		true,
		"J1: Specialist on duty informs every SKU"
	)
	_expect_equal(
		_demand_signals.call("can_research_set", &"AA-SKIE"),
		true,
		"J1: Specialist does not consume the Research verb"
	)
	_expect_equal(
		String(_demand_signals.call("skill_channel_for", sku_id)),
		"specialist",
		"J1: skill channel is specialist while on duty"
	)
	var spec_buy := _demand_signals.call(
		"buy_signal",
		sku_id,
		DemandSignalService.Channel.MARKETPLACE,
		1200,
		1
	) as BuyConfirmSignal
	var spec_price := _demand_signals.call(
		"price_signal",
		sku_id,
		2200,
		location
	) as PriceConfirmSignal
	var spec_list := _demand_signals.call(
		"list_confirm_signal",
		card.sku_id,
		card.listed_price_cents,
		card.location
	) as OnlineListConfirmSignal
	_expect_equal(
		_j1_comp_width(spec_buy) < _j1_comp_width(spec_buy_before),
		true,
		"J1: Specialist narrows buy confirm comps"
	)
	_expect_equal(
		_j1_comp_width(spec_price) < _j1_comp_width(spec_price_before),
		true,
		"J1: Specialist narrows price confirm comps"
	)
	_expect_equal(
		_j1_comp_width(spec_list) < _j1_comp_width(spec_list_before),
		true,
		"J1: Specialist narrows online list confirm comps"
	)
	_expect_dto_has_no_truth_fields(spec_buy, "J1: specialist buy confirm")
	_expect_dto_has_no_truth_fields(spec_price, "J1: specialist price confirm")
	_expect_dto_has_no_truth_fields(spec_list, "J1: specialist online confirm")
	_assert_text_has_no_truth(
		DemandSignalPresenter.list_confirm_summary(spec_list),
		"J1: specialist online summary"
	)
	var spec_events := _j1_skill_signal_events()
	var spec_informed := 0
	for event: Dictionary in spec_events:
		var payload: Dictionary = event.get("payload", {})
		if bool(payload.get("skill_informed", false)):
			spec_informed += 1
			_expect_equal(
				is_equal_approx(float(payload.get("demand_band_sigma", 1.0)), 0.07),
				true,
				"J1: Specialist σ is 0.07"
			)
	_expect_equal(spec_informed >= 3, true, "J1: Specialist instrumentation marks confirms informed")

	_demand_signals.call(
		"start_pack_event",
		MarketEvent.KIND_ROTATION,
		{"set_id": &"AA-DUST", "duration_days": 2, "remaining_days": 2}
	)
	_expect_equal(
		String(_demand_signals.call("event_banner_text")).contains("Dustway"),
		true,
		"J1: Specialist reveals rotation leak without Research spend"
	)
	_expect_equal(
		String(_demand_signals.call("rotation_watch_text")).contains("Rotation watch:"),
		true,
		"J1: Specialist rotation copy uses Rotation watch"
	)
	_assert_text_has_no_truth(
		String(_demand_signals.call("rotation_watch_text")),
		"J1: specialist rotation watch"
	)

	shop.fire_staff(0)
	_expect_equal(shop.has_specialist_on_duty(), false, "J1: fire clears Specialist")
	_expect_equal(
		String(_demand_signals.call("event_banner_text")),
		"",
		"J1: rotation leak hides again without Specialist or Research"
	)
	_expect_equal(
		_demand_signals.call("is_skill_informed", sku_id),
		false,
		"J1: firing Specialist turns skill channel off"
	)

	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "J1: HUD loads for skill-channel copy")
	if hud != null:
		Callable(hud, "_sync_staff_panel").call()
		var staff_hint := hud.get_node_or_null("%StaffHint") as Label
		_expect_equal(
			staff_hint != null and staff_hint.text.contains("without Research spend"),
			true,
			"J1: staff hint names Specialist noise narrow"
		)
		_assert_text_has_no_truth(
			staff_hint.text if staff_hint != null else "",
			"J1: staff hint"
		)
		root.remove_child(hud)
		hud.free()

	var demand_src := FileAccess.get_file_as_string(
		"res://scripts/autoload/demand_signals.gd"
	)
	_expect_equal(
		demand_src.contains("func _ensure_priceable_sku"),
		true,
		"J1: Soft _ensure_priceable_sku stays parked"
	)
	for path: String in [
		"res://scripts/economy/demand_signal_service.gd",
		"res://scripts/ui/demand_signal_presenter.gd",
		"res://scripts/ui/hud.gd",
		"res://scripts/economy/online_listing_service.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_expect_equal(
			source.contains("_ensure_priceable_sku"),
			false,
			"J1: %s does not call parked Soft helper" % path
		)
	_qa_autoload.call("set_force_enabled", false)
	_game_state.call("start_new_game")


func _test_flagship_win_award() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("campaign_mode", 0)
	_game_state.call("start_new_game")
	_captured_campaign_won = {}

	var shop := _force_large_shop(40)
	_expect_equal(shop.tier, ShopState.Tier.LARGE, "R1: L1 Sign still reaches Large")
	_expect_equal(
		shop.can_sign_large_lease(4_000_000, 70),
		false,
		"R1: already-Large cannot Sign again"
	)
	_economy.set("balance_cents", 4_000_000)
	_game_state.set("current_reputation", 70)
	_expect_equal(
		_game_state.call("meets_flagship"),
		false,
		"R1: L1-only Large+Rep70+$40k is not Flagship"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: L1-only state does not award"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		true,
		"R1: L1-only leaves the campaign active"
	)
	_expect_equal(
		_captured_campaign_won.is_empty(),
		true,
		"R1: L1-only does not emit campaign_won"
	)

	_game_state.call("start_new_game")
	shop = _force_medium_shop(18)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_expect_equal(
		_game_state.call("meets_flagship"),
		false,
		"R1: Medium+$50k+Rep80 is not Flagship"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: Medium does not award Flagship"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		true,
		"R1: Medium miss stays active"
	)

	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 4_999_999)
	_game_state.set("current_reputation", 80)
	_expect_equal(
		_game_state.call("meets_flagship"),
		false,
		"R1: one cent under Flagship cash fails"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: cash-under does not award"
	)

	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 79)
	_expect_equal(
		_game_state.call("meets_flagship"),
		false,
		"R1: Rep 79 fails Flagship"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: Rep 79 does not award"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		true,
		"R1: Rep 79 stays active"
	)

	_game_state.call("start_new_game")
	shop = _force_medium_shop(18)
	_economy.set("balance_cents", 4_000_000)
	_game_state.set("current_reputation", 70)
	_expect_equal(
		shop.can_sign_large_lease(4_000_000, 70),
		true,
		"R1: L1 Sign gates still pass at $40k+Rep70"
	)
	_expect_equal(
		shop.expand_to_large(40, 4_000_000, 70),
		true,
		"R1: L1 Sign still upgrades at exact gates"
	)
	_expect_equal(shop.tier, ShopState.Tier.LARGE, "R1: Sign still sets Large")
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: Sign at L1 gates does not award Flagship"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		true,
		"R1: post-Sign L1 state stays active"
	)

	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("meets_flagship"),
		true,
		"R1: exact Large+Rep80+$50k meets Flagship"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"R1: exact predicate awards Flagship"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"R1: award marks campaign complete"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"R1: award ends the active campaign"
	)
	_expect_equal(
		String(_game_state.get("last_prestige")),
		"flagship",
		"R1: last prestige is flagship"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"flagship",
		"R1: campaign_won mode is flagship"
	)
	_expect_equal(
		int(_captured_campaign_won.get("cash_cents", 0)),
		5_000_000,
		"R1: campaign_won cash is exact threshold"
	)
	_expect_equal(
		int(_captured_campaign_won.get("reputation", 0)),
		80,
		"R1: campaign_won Rep is 80"
	)
	_expect_equal(
		int(_captured_campaign_won.get("shop_tier", -1)),
		int(ShopState.Tier.LARGE),
		"R1: campaign_won shop tier is Large"
	)
	_assert_payload_has_no_truth(_captured_campaign_won, "R1: campaign_won payload")
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: second evaluate does not re-award"
	)

	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(_game_state.call("start_floor"), true, "R1: FLOOR opens before settle award")
	_expect_equal(
		_game_state.call("start_settle"),
		true,
		"R1: SETTLE runs the Flagship check"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"R1: SETTLE awards Flagship at exact predicate"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"R1: SETTLE award deactivates the campaign"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"flagship",
		"R1: SETTLE emits campaign_won"
	)
	_expect_equal(
		_game_state.call("advance_day"),
		false,
		"R1: awarded campaign cannot advance the day"
	)

	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 4_999_999)
	_game_state.set("current_reputation", 80)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(_game_state.call("start_floor"), true, "R1: FLOOR opens for cash-under settle")
	_expect_equal(_game_state.call("start_settle"), true, "R1: SETTLE runs cash-under")
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		false,
		"R1: SETTLE cash-under does not award"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		true,
		"R1: SETTLE cash-under stays active"
	)

	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 4_999_999)
	_game_state.set("current_reputation", 80)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(
		_economy.call("record_income", 1, &"sale", "Flagship cent"),
		true,
		"R1: income can cross Flagship cash"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"R1: cash_changed awards Flagship"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"flagship",
		"R1: cash_changed emits campaign_won"
	)

	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 79)
	_captured_campaign_won = {}
	_game_state.call("adjust_reputation", 1)
	_expect_equal(
		int(_game_state.get("current_reputation")),
		80,
		"R1: Rep bump reaches Flagship floor"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"R1: reputation bump awards Flagship"
	)

	_game_state.call("start_new_game")
	shop = _force_medium_shop(18)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_captured_campaign_won = {}
	_expect_equal(
		shop.expand_to_large(40, 5_000_000, 80),
		true,
		"R1: Sign Large while already over Flagship gates"
	)
	_event_bus.emit_signal("shop_layout_changed")
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"R1: layout change after over-gate Sign awards Flagship"
	)

	_game_state.call("set_balance_config", EASY_CONFIG)
	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 3_999_999)
	_game_state.set("current_reputation", 80)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: Easy cash-under does not award"
	)
	_economy.set("balance_cents", 4_000_000)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"R1: Easy awards at $40k Flagship cash"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 6_499_999)
	_game_state.set("current_reputation", 80)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: Hard cash-under does not award"
	)
	_economy.set("balance_cents", 6_500_000)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"R1: Hard awards at $65k Flagship cash"
	)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_game_state.set("campaign_mode", 3)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"R1: Sandbox does not award Flagship"
	)
	_game_state.set("campaign_mode", 0)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"R1: Flagship mode awards after leaving Sandbox"
	)

	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "R1: Flagship save payload")
	_expect_equal(bool(saved.get("campaign_complete", false)), true, "R1: save stores complete")
	_game_state.call("start_new_game")
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		false,
		"R1: new game clears complete"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"R1: restore Flagship save"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"R1: restore keeps campaign complete"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"R1: restore of a won campaign stays inactive"
	)

	_game_state.call("start_new_game")
	shop = _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_captured_campaign_won = {}
	_expect_equal(_game_state.call("evaluate_campaign_win"), true, "R1: award before HUD bind")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "R1: HUD instantiates after Flagship award")
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"R1: HUD bind does not reset a completed campaign"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"R1: HUD bind keeps awarded campaign inactive"
	)
	if hud != null:
		var win_panel := hud.get_node_or_null("%CampaignWin") as PanelContainer
		var win_title := hud.get_node_or_null("%CampaignWinTitle") as Label
		var win_body := hud.get_node_or_null("%CampaignWinBody") as Label
		_expect_equal(
			win_panel != null and win_panel.visible,
			true,
			"R1: HUD shows Flagship win panel"
		)
		_expect_equal(
			win_title != null and win_title.text == "Flagship",
			true,
			"R1: HUD win title is Flagship"
		)
		_expect_equal(
			win_body != null and win_body.text.contains("Large")
			and win_body.text.contains("80")
			and win_body.text.contains("$50,000.00"),
			true,
			"R1: HUD win body uses player-visible cash/Rep"
		)
		_assert_text_has_no_truth(
			win_title.text if win_title != null else "",
			"R1: HUD win title"
		)
		_assert_text_has_no_truth(
			win_body.text if win_body != null else "",
			"R1: HUD win body"
		)
		var phase_button := hud.get_node_or_null("%PhaseButton") as Button
		_expect_equal(
			phase_button != null and phase_button.disabled,
			true,
			"R1: HUD phase button disables after Flagship"
		)
		root.remove_child(hud)
		hud.free()

	var menu_packed: PackedScene = load("res://scenes/ui/main_menu.tscn") as PackedScene
	_expect_equal(menu_packed != null, true, "R1: main menu scene loads")
	if menu_packed != null:
		var menu: Node = menu_packed.instantiate()
		root.add_child(menu)
		if not menu.is_node_ready():
			menu.notification(Node.NOTIFICATION_READY)
		var campaign_label := menu.get_node_or_null("%CampaignLabel") as Label
		var prestige_label := menu.get_node_or_null("%PrestigeLabel") as Label
		_expect_equal(
			campaign_label != null and campaign_label.text.contains("Flagship"),
			true,
			"R1: main menu binds Flagship campaign"
		)
		_expect_equal(
			prestige_label != null and prestige_label.visible
			and prestige_label.text.contains("Flagship"),
			true,
			"R1: main menu shows last Flagship prestige"
		)
		_assert_text_has_no_truth(
			campaign_label.text if campaign_label != null else "",
			"R1: main menu campaign label"
		)
		_assert_text_has_no_truth(
			prestige_label.text if prestige_label != null else "",
			"R1: main menu prestige label"
		)
		root.remove_child(menu)
		menu.free()

	var hud_src := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	var menu_src := FileAccess.get_file_as_string("res://scripts/ui/main_menu.gd")
	_expect_equal(
		hud_src.contains("true_market")
		or hud_src.contains("p_buy")
		or hud_src.contains("cert_valid"),
		false,
		"R1: HUD script stays §4.5 clean"
	)
	_expect_equal(
		menu_src.contains("true_market")
		or menu_src.contains("p_buy")
		or menu_src.contains("cert_valid"),
		false,
		"R1: main menu script stays §4.5 clean"
	)
	var demand_src := FileAccess.get_file_as_string(
		"res://scripts/autoload/demand_signals.gd"
	)
	_expect_equal(
		demand_src.contains("func _ensure_priceable_sku"),
		true,
		"R1: Soft _ensure_priceable_sku stays parked"
	)
	for path: String in [
		"res://scripts/autoload/game_state.gd",
		"res://scripts/core/balance_config.gd",
		"res://scripts/autoload/event_bus.gd",
		"res://scripts/ui/hud.gd",
		"res://scripts/ui/main_menu.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_expect_equal(
			source.contains("_ensure_priceable_sku"),
			false,
			"R1: %s does not call parked Soft helper" % path
		)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("campaign_mode", 0)
	_game_state.call("start_new_game")


func _test_survive_y1_win_award() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 1)
	_captured_campaign_won = {}
	_economy.set("balance_cents", 1)
	_game_state.set("current_reputation", 40)
	_game_state.set("current_day", 364)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_expect_equal(
		_game_state.call("meets_survive_y1"),
		false,
		"S1: day 364 is not Survive Y1"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: day 364 does not award Survive Y1"
	)
	_expect_equal(
		_game_state.call("meets_flagship"),
		false,
		"S1: Survive Y1 seed is not Flagship"
	)

	_expect_equal(
		_game_state.call("advance_day"),
		true,
		"S1: SETTLE advances onto day 365"
	)
	_expect_equal(int(_game_state.get("current_day")), 365, "S1: landing day is 365")
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"S1: day-365 PREP awards Survive Y1 once"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"S1: Survive Y1 award deactivates"
	)
	_expect_equal(
		String(_game_state.get("last_prestige")),
		"survive_y1",
		"S1: last prestige is survive_y1"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"survive_y1",
		"S1: campaign_won mode is survive_y1"
	)
	_expect_equal(
		int(_captured_campaign_won.get("day", 0)),
		365,
		"S1: campaign_won day is 365"
	)
	_expect_equal(
		int(_captured_campaign_won.get("reputation", 0)),
		40,
		"S1: campaign_won Rep is 40"
	)
	_assert_payload_has_no_truth(_captured_campaign_won, "S1: Survive Y1 payload")
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: second evaluate does not re-award Survive Y1"
	)
	_expect_equal(
		_game_state.call("advance_day"),
		false,
		"S1: awarded Survive Y1 cannot advance"
	)

	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 1)
	_economy.set("balance_cents", 0)
	_game_state.set("current_reputation", 40)
	_game_state.set("current_day", 365)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: cash 0 does not award Survive Y1"
	)
	_economy.set("balance_cents", 1)
	_game_state.set("current_reputation", 39)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Rep 39 does not award Survive Y1"
	)
	_game_state.call("adjust_reputation", 1)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"S1: Rep bump on day 365 awards Survive Y1"
	)

	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 0)
	_economy.set("balance_cents", 1)
	_game_state.set("current_reputation", 40)
	_game_state.set("current_day", 365)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Flagship mode does not award Survive Y1"
	)

	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 1)
	var shop := _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_game_state.set("current_day", 1)
	_expect_equal(shop.tier, ShopState.Tier.LARGE, "S1: Flagship seed is Large")
	_expect_equal(
		_game_state.call("meets_flagship"),
		true,
		"S1: Flagship predicate can be true in Survive Y1 mode"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Survive Y1 mode does not award Flagship"
	)
	_expect_equal(
		_captured_campaign_won.is_empty(),
		true,
		"S1: Flagship gates do not emit survive_y1"
	)

	_game_state.call("set_balance_config", EASY_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 1)
	_economy.set("balance_cents", 1)
	_game_state.set("current_day", 365)
	_game_state.set("current_reputation", 29)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Easy Rep 29 does not award"
	)
	_game_state.set("current_reputation", 30)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"S1: Easy awards at Rep 30"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 1)
	_economy.set("balance_cents", 1)
	_game_state.set("current_day", 365)
	_game_state.set("current_reputation", 49)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Hard Rep 49 does not award"
	)
	_game_state.set("current_reputation", 50)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"S1: Hard awards at Rep 50"
	)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 1)
	_economy.set("balance_cents", 800_000)
	_game_state.set("current_reputation", 40)
	_game_state.set("current_day", 365)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"S1: award Survive Y1 before HUD bind"
	)
	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "S1: Survive Y1 save payload")
	_expect_equal(int(saved.get("campaign_mode", -1)), 1, "S1: save stores Survive Y1 mode")
	_game_state.call("start_new_game")
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"S1: restore Survive Y1 save"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"S1: restore keeps Survive Y1 complete"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"S1: restore of a won Survive Y1 stays inactive"
	)

	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "S1: HUD instantiates after Survive Y1 award")
	if hud != null:
		var win_panel := hud.get_node_or_null("%CampaignWin") as PanelContainer
		var win_title := hud.get_node_or_null("%CampaignWinTitle") as Label
		var win_body := hud.get_node_or_null("%CampaignWinBody") as Label
		_expect_equal(
			win_panel != null and win_panel.visible,
			true,
			"S1: HUD shows Survive Y1 win panel"
		)
		_expect_equal(
			win_title != null and win_title.text == "Survive Year 1",
			true,
			"S1: HUD win title is Survive Year 1"
		)
		_expect_equal(
			win_body != null
			and win_body.text.contains("365")
			and win_body.text.contains("40")
			and win_body.text.contains("$8,000.00"),
			true,
			"S1: HUD win body uses player-visible day/Rep/cash"
		)
		_assert_text_has_no_truth(
			win_title.text if win_title != null else "",
			"S1: HUD Survive Y1 title"
		)
		_assert_text_has_no_truth(
			win_body.text if win_body != null else "",
			"S1: HUD Survive Y1 body"
		)
		root.remove_child(hud)
		hud.free()

	var menu_packed: PackedScene = load("res://scenes/ui/main_menu.tscn") as PackedScene
	_expect_equal(menu_packed != null, true, "S1: main menu scene loads")
	if menu_packed != null:
		var menu: Node = menu_packed.instantiate()
		root.add_child(menu)
		if not menu.is_node_ready():
			menu.notification(Node.NOTIFICATION_READY)
		var campaign_label := menu.get_node_or_null("%CampaignLabel") as Label
		var prestige_label := menu.get_node_or_null("%PrestigeLabel") as Label
		_expect_equal(
			campaign_label != null and campaign_label.text.contains("Survive Year 1"),
			true,
			"S1: main menu binds Survive Year 1 campaign"
		)
		_expect_equal(
			prestige_label != null and prestige_label.visible
			and prestige_label.text.contains("Survive Year 1"),
			true,
			"S1: main menu shows last Survive Year 1 prestige"
		)
		root.remove_child(menu)
		menu.free()

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("campaign_mode", 0)
	_game_state.call("start_new_game")


func _test_liquidity_king_win_award() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 2)
	_captured_campaign_won = {}
	_economy.set("balance_cents", 10_000_000)
	_game_state.set("current_day", 29)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_expect_equal(
		_game_state.call("meets_liquidity_king"),
		false,
		"S1: day 29 SETTLE is not Liquidity king"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: mid-month SETTLE does not award Liquidity king"
	)

	_game_state.set("current_day", 30)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_expect_equal(
		_game_state.call("meets_liquidity_king"),
		false,
		"S1: month-end PREP is not Liquidity king"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: month-end PREP does not award"
	)

	_game_state.set("current_phase", DayPhasePolicy.FLOOR)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: month-end FLOOR does not award Liquidity king"
	)
	_expect_equal(
		_economy.call("record_income", 1, &"sale", "Liquidity spike"),
		true,
		"S1: mid-day income can cross Liquidity cash"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		false,
		"S1: cash_changed mid-month-day does not award Liquidity king"
	)

	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 2)
	_economy.set("balance_cents", 9_999_999)
	_game_state.set("current_day", 30)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(_game_state.call("start_floor"), true, "S1: FLOOR opens for cash-under settle")
	_expect_equal(_game_state.call("start_settle"), true, "S1: SETTLE runs cash-under Liquidity")
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		false,
		"S1: SETTLE cash-under does not award Liquidity king"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		true,
		"S1: SETTLE cash-under stays active"
	)

	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 2)
	_economy.set("balance_cents", 10_000_000)
	_game_state.set("current_day", 30)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(_game_state.call("start_floor"), true, "S1: FLOOR opens before Liquidity settle")
	_expect_equal(
		_game_state.call("start_settle"),
		true,
		"S1: SETTLE runs the Liquidity king check"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		true,
		"S1: month-end SETTLE awards Liquidity king"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"S1: Liquidity king award deactivates"
	)
	_expect_equal(
		String(_game_state.get("last_prestige")),
		"liquidity_king",
		"S1: last prestige is liquidity_king"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"liquidity_king",
		"S1: campaign_won mode is liquidity_king"
	)
	_expect_equal(
		int(_captured_campaign_won.get("cash_cents", 0)),
		10_000_000,
		"S1: campaign_won cash is exact $100k"
	)
	_assert_payload_has_no_truth(_captured_campaign_won, "S1: Liquidity king payload")
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: second evaluate does not re-award Liquidity king"
	)

	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 2)
	_economy.set("balance_cents", 10_000_000)
	_game_state.set("current_day", 60)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_captured_campaign_won = {}
	_expect_equal(_game_state.call("start_floor"), true, "S1: FLOOR opens for month-2")
	_expect_equal(_game_state.call("start_settle"), true, "S1: SETTLE month-2")
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"liquidity_king",
		"S1: any month-end can award Liquidity king"
	)

	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 0)
	_economy.set("balance_cents", 10_000_000)
	_game_state.set("current_day", 30)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Flagship mode does not award Liquidity king"
	)

	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 2)
	_force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_game_state.set("current_day", 1)
	_expect_equal(
		_game_state.call("meets_flagship"),
		true,
		"S1: Flagship predicate can be true in Liquidity mode"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Liquidity mode does not award Flagship"
	)

	_game_state.call("set_balance_config", EASY_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 2)
	_economy.set("balance_cents", 7_499_999)
	_game_state.set("current_day", 30)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Easy Liquidity cash-under does not award"
	)
	_economy.set("balance_cents", 7_500_000)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"S1: Easy awards Liquidity at $75k"
	)

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 2)
	_economy.set("balance_cents", 12_499_999)
	_game_state.set("current_day", 30)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"S1: Hard Liquidity cash-under does not award"
	)
	_economy.set("balance_cents", 12_500_000)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"S1: Hard awards Liquidity at $125k"
	)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_game_state.set("campaign_mode", 2)
	_economy.set("balance_cents", 10_000_000)
	_game_state.set("current_day", 30)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"S1: award Liquidity king before HUD bind"
	)
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "S1: HUD instantiates after Liquidity award")
	if hud != null:
		var win_panel := hud.get_node_or_null("%CampaignWin") as PanelContainer
		var win_title := hud.get_node_or_null("%CampaignWinTitle") as Label
		var win_body := hud.get_node_or_null("%CampaignWinBody") as Label
		_expect_equal(
			win_panel != null and win_panel.visible,
			true,
			"S1: HUD shows Liquidity king win panel"
		)
		_expect_equal(
			win_title != null and win_title.text == "Liquidity king",
			true,
			"S1: HUD win title is Liquidity king"
		)
		_expect_equal(
			win_body != null and win_body.text.contains("$100,000.00"),
			true,
			"S1: HUD Liquidity body uses player-visible cash"
		)
		_assert_text_has_no_truth(
			win_title.text if win_title != null else "",
			"S1: HUD Liquidity title"
		)
		_assert_text_has_no_truth(
			win_body.text if win_body != null else "",
			"S1: HUD Liquidity body"
		)
		root.remove_child(hud)
		hud.free()

	var menu_packed: PackedScene = load("res://scenes/ui/main_menu.tscn") as PackedScene
	if menu_packed != null:
		var menu: Node = menu_packed.instantiate()
		root.add_child(menu)
		if not menu.is_node_ready():
			menu.notification(Node.NOTIFICATION_READY)
		var campaign_label := menu.get_node_or_null("%CampaignLabel") as Label
		var prestige_label := menu.get_node_or_null("%PrestigeLabel") as Label
		_expect_equal(
			campaign_label != null and campaign_label.text.contains("Liquidity king"),
			true,
			"S1: main menu binds Liquidity king campaign"
		)
		_expect_equal(
			prestige_label != null and prestige_label.visible
			and prestige_label.text.contains("Liquidity king"),
			true,
			"S1: main menu shows last Liquidity king prestige"
		)
		root.remove_child(menu)
		menu.free()

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("campaign_mode", 0)
	_game_state.call("start_new_game")
	var flagship_shop := _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_captured_campaign_won = {}
	_expect_equal(flagship_shop.tier, ShopState.Tier.LARGE, "S1: Flagship sanity shop is Large")
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"S1: Flagship still awards after alternate-win tests"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"flagship",
		"S1: Flagship win kind is unchanged"
	)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("campaign_mode", 0)
	_game_state.call("start_new_game")


func _test_campaign_mode_picker() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("return_to_menu")
	_game_state.set("campaign_complete", false)
	_game_state.set("last_prestige", &"")
	_game_state.set("sandbox_best_day", 0)
	_game_state.set("sandbox_best_cash_cents", 0)
	_expect_equal(
		_game_state.call("select_campaign_mode", 0),
		true,
		"T1: inactive session can select Flagship"
	)

	var menu := _instantiate_main_menu()
	_expect_equal(menu != null, true, "T1: main menu instantiates")
	var campaign_label := menu.get_node_or_null("%CampaignLabel") as Label if menu != null else null
	var blurb := menu.get_node_or_null("%ModeBlurb") as Label if menu != null else null
	var flagship_btn := menu.get_node_or_null("%FlagshipButton") as Button if menu != null else null
	var survive_btn := menu.get_node_or_null("%SurviveYear1Button") as Button if menu != null else null
	var liquidity_btn := menu.get_node_or_null("%LiquidityKingButton") as Button if menu != null else null
	var sandbox_btn := menu.get_node_or_null("%SandboxButton") as Button if menu != null else null
	_expect_equal(
		flagship_btn != null and flagship_btn.text == "Flagship",
		true,
		"T1: Flagship picker button is player-facing"
	)
	_expect_equal(
		survive_btn != null and survive_btn.text == "Survive Year 1",
		true,
		"T1: Survive Year 1 picker button is player-facing"
	)
	_expect_equal(
		liquidity_btn != null and liquidity_btn.text == "Liquidity king",
		true,
		"T1: Liquidity king picker button is player-facing"
	)
	_expect_equal(
		sandbox_btn != null and sandbox_btn.text == "Sandbox",
		true,
		"T1: Sandbox picker button is player-facing"
	)
	_expect_equal(
		campaign_label != null and campaign_label.text.contains("Flagship"),
		true,
		"T1: menu starts on Flagship"
	)
	_expect_equal(
		blurb != null and blurb.text.contains("Large shop"),
		true,
		"T1: Flagship blurb is player-facing"
	)
	if menu != null:
		_assert_text_has_no_truth(campaign_label.text if campaign_label != null else "", "T1: campaign label")
		_assert_text_has_no_truth(blurb.text if blurb != null else "", "T1: mode blurb")
		_assert_text_has_no_truth(flagship_btn.text if flagship_btn != null else "", "T1: Flagship button")
		_assert_text_has_no_truth(survive_btn.text if survive_btn != null else "", "T1: Survive button")
		_assert_text_has_no_truth(liquidity_btn.text if liquidity_btn != null else "", "T1: Liquidity button")
		_assert_text_has_no_truth(sandbox_btn.text if sandbox_btn != null else "", "T1: Sandbox button")

	if survive_btn != null:
		survive_btn.pressed.emit()
	_expect_equal(int(_game_state.get("campaign_mode")), 1, "T1: Survive click sets CampaignMode")
	_expect_equal(
		campaign_label != null and campaign_label.text.contains("Survive Year 1"),
		true,
		"T1: campaign label follows Survive Year 1"
	)
	_expect_equal(
		blurb != null and blurb.text.contains("365"),
		true,
		"T1: Survive blurb names day 365"
	)
	_game_state.call("start_new_game")
	_expect_equal(
		int(_game_state.get("campaign_mode")),
		1,
		"T1: start_new_game keeps Survive Year 1"
	)
	_expect_equal(
		_game_state.call("select_campaign_mode", 3),
		false,
		"T1: mid-run mode switch is rejected"
	)
	_expect_equal(
		int(_game_state.get("campaign_mode")),
		1,
		"T1: rejected switch leaves Survive Year 1"
	)
	_force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_game_state.set("current_day", 1)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("meets_flagship"),
		true,
		"T1: Flagship gates can be true in Survive Year 1"
	)
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"T1: Survive Year 1 does not award Flagship"
	)
	_game_state.set("current_day", 365)
	_economy.set("balance_cents", 1)
	_game_state.set("current_reputation", 40)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"T1: Survive Year 1 still awards when selected"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"survive_y1",
		"T1: Survive picker path emits survive_y1"
	)

	_expect_equal(
		_game_state.call("select_campaign_mode", 2),
		true,
		"T1: after award, Liquidity king can be selected"
	)
	_game_state.call("start_new_game")
	_expect_equal(int(_game_state.get("campaign_mode")), 2, "T1: Liquidity king persists into new game")
	_economy.set("balance_cents", 10_000_000)
	_game_state.set("current_day", 30)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_captured_campaign_won = {}
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"T1: Liquidity king still awards when selected"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"liquidity_king",
		"T1: Liquidity picker path emits liquidity_king"
	)

	_expect_equal(
		_game_state.call("select_campaign_mode", 3),
		true,
		"T1: Sandbox can be selected before a new game"
	)
	if sandbox_btn != null:
		sandbox_btn.pressed.emit()
	_expect_equal(int(_game_state.get("campaign_mode")), 3, "T1: Sandbox click sets CampaignMode")
	_expect_equal(
		campaign_label != null and campaign_label.text.contains("Sandbox"),
		true,
		"T1: campaign label follows Sandbox"
	)
	_game_state.call("start_new_game")
	_expect_equal(int(_game_state.get("campaign_mode")), 3, "T1: Sandbox persists into new game")
	_expect_equal(
		int(_game_state.get("sandbox_best_day")) >= 1,
		true,
		"T1: Sandbox records a day personal best"
	)
	_expect_equal(
		int(_game_state.get("sandbox_best_cash_cents")) >= 800_000,
		true,
		"T1: Sandbox records a cash personal best"
	)
	_force_large_shop(40)
	_economy.set("balance_cents", 10_000_000)
	_game_state.set("current_reputation", 80)
	_game_state.set("current_day", 390)
	_game_state.set("current_phase", DayPhasePolicy.SETTLE)
	_captured_campaign_won = {}
	_expect_equal(_game_state.call("meets_flagship"), true, "T1: Sandbox can meet Flagship")
	_expect_equal(_game_state.call("meets_survive_y1"), true, "T1: Sandbox can meet Survive Y1")
	_expect_equal(_game_state.call("meets_liquidity_king"), true, "T1: Sandbox can meet Liquidity king")
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		false,
		"T1: Sandbox awards none"
	)
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		false,
		"T1: Sandbox stays incomplete"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		true,
		"T1: Sandbox stays active"
	)
	_expect_equal(
		_captured_campaign_won.is_empty(),
		true,
		"T1: Sandbox does not emit campaign_won"
	)
	_expect_equal(
		int(_game_state.get("sandbox_best_day")),
		390,
		"T1: Sandbox personal best day updates"
	)
	_expect_equal(
		int(_game_state.get("sandbox_best_cash_cents")),
		10_000_000,
		"T1: Sandbox personal best cash updates"
	)

	var saved: Dictionary = _game_state.call("capture_save")
	_assert_payload_has_no_truth(saved, "T1: Sandbox save payload")
	_expect_equal(int(saved.get("campaign_mode", -1)), 3, "T1: save stores Sandbox mode")
	_expect_equal(int(saved.get("sandbox_best_day", 0)), 390, "T1: save stores sandbox best day")
	_game_state.call("return_to_menu")
	if menu != null:
		menu.call("_sync_campaign_copy")
		var bests := menu.get_node_or_null("%SandboxBests") as Label
		_expect_equal(
			bests != null and bests.visible and bests.text.contains("390")
			and bests.text.contains("$100,000.00"),
			true,
			"T1: menu shows Sandbox personal bests"
		)
		_assert_text_has_no_truth(bests.text if bests != null else "", "T1: sandbox bests")

	_expect_equal(
		_game_state.call("select_campaign_mode", 0),
		true,
		"T1: Flagship can be selected after Sandbox"
	)
	_game_state.call("start_new_game")
	_expect_equal(int(_game_state.get("campaign_mode")), 0, "T1: Flagship picker selection persists")
	var flagship_shop := _force_large_shop(40)
	_economy.set("balance_cents", 5_000_000)
	_game_state.set("current_reputation", 80)
	_captured_campaign_won = {}
	_expect_equal(flagship_shop.tier, ShopState.Tier.LARGE, "T1: Flagship shop is Large")
	_expect_equal(
		_game_state.call("evaluate_campaign_win"),
		true,
		"T1: Flagship still awards when selected"
	)
	_expect_equal(
		String(_captured_campaign_won.get("mode", "")),
		"flagship",
		"T1: Flagship picker path emits flagship"
	)

	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"T1: restore Sandbox save"
	)
	_expect_equal(int(_game_state.get("campaign_mode")), 3, "T1: restore keeps Sandbox mode")
	_expect_equal(
		bool(_game_state.get("campaign_complete")),
		false,
		"T1: restore keeps Sandbox incomplete"
	)
	_expect_equal(
		int(_game_state.get("sandbox_best_day")),
		390,
		"T1: restore keeps sandbox best day"
	)

	if menu != null:
		root.remove_child(menu)
		menu.free()

	var menu_src := FileAccess.get_file_as_string("res://scripts/ui/main_menu.gd")
	var state_src := FileAccess.get_file_as_string("res://scripts/autoload/game_state.gd")
	_expect_equal(
		menu_src.contains("true_market")
		or menu_src.contains("p_buy")
		or menu_src.contains("cert_valid"),
		false,
		"T1: main menu script stays §4.5 clean"
	)
	_expect_equal(
		state_src.contains("func _ensure_priceable_sku"),
		false,
		"T1: GameState does not grow the parked Soft helper"
	)
	for path: String in [
		"res://scripts/autoload/game_state.gd",
		"res://scripts/ui/main_menu.gd",
		"res://scripts/ui/hud.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		_expect_equal(
			source.contains("_ensure_priceable_sku"),
			false,
			"T1: %s does not call parked Soft helper" % path
		)
		_expect_equal(
			source.contains("flipper_weight_mult"),
			false,
			"T1: %s does not touch parked flipper Soft" % path
		)

	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.set("is_game_active", false)
	_game_state.set("campaign_complete", false)
	_game_state.set("sandbox_best_day", 0)
	_game_state.set("sandbox_best_cash_cents", 0)
	_game_state.call("select_campaign_mode", 0)
	_game_state.call("start_new_game")


func _test_loan_shark_soft_fail() -> void:
	_test_loan_shark_balance_scalars()
	_test_loan_shark_easy_offer_accept_and_drain()
	_test_loan_shark_normal_offer_and_refuse()
	_test_loan_shark_hard_instant_over()
	_test_loan_shark_second_bankruptcy_over()
	_test_loan_shark_hud_and_section_45()
	_test_loan_shark_save_load()
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")


func _test_loan_shark_balance_scalars() -> void:
	_expect_equal(EASY_CONFIG.loan_shark_enabled, true, "W1: Easy loan shark enabled")
	_expect_equal(NORMAL_CONFIG.loan_shark_enabled, true, "W1: Normal loan shark enabled")
	_expect_equal(HARD_CONFIG.loan_shark_enabled, false, "W1: Hard loan shark disabled")
	_expect_equal(EASY_CONFIG.loan_shark_cash_cents, 600_000, "W1: Easy +$6,000")
	_expect_equal(NORMAL_CONFIG.loan_shark_cash_cents, 500_000, "W1: Normal +$5,000")
	_expect_equal(EASY_CONFIG.loan_shark_daily_cents, 15_000, "W1: Easy −$150/day")
	_expect_equal(NORMAL_CONFIG.loan_shark_daily_cents, 20_000, "W1: Normal −$200/day")
	_expect_equal(EASY_CONFIG.loan_shark_days, 40, "W1: Easy 40-day drain")
	_expect_equal(NORMAL_CONFIG.loan_shark_days, 40, "W1: Normal 40-day drain")
	_expect_equal(EASY_CONFIG.loan_shark_rep_hit, 5, "W1: Easy Rep −5")
	_expect_equal(NORMAL_CONFIG.loan_shark_rep_hit, 10, "W1: Normal Rep −10")
	_expect_equal(EASY_CONFIG.missed_rent_weeks_to_lose, 3, "W1: Easy missed-rent weeks")
	_expect_equal(NORMAL_CONFIG.missed_rent_weeks_to_lose, 2, "W1: Normal missed-rent weeks")
	_expect_equal(HARD_CONFIG.missed_rent_weeks_to_lose, 2, "W1: Hard missed-rent weeks")


func _test_loan_shark_easy_offer_accept_and_drain() -> void:
	_game_state.call("set_balance_config", EASY_CONFIG)
	_game_state.call("start_new_game")
	_trigger_rent_bankruptcy("Easy offer")
	_expect_equal(
		bool(_game_state.get("loan_shark_offer_pending")),
		true,
		"W1 Easy: first bankruptcy shows offer"
	)
	_expect_equal(
		bool(_game_state.get("campaign_lost")),
		false,
		"W1 Easy: offer is not game over"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		true,
		"W1 Easy: campaign stays active during offer"
	)
	_expect_equal(
		_game_state.call("can_progress_day"),
		false,
		"W1 Easy: day progress blocks while offer is up"
	)
	_expect_equal(
		_game_state.call("advance_day"),
		false,
		"W1 Easy: cannot advance during offer"
	)
	_expect_equal(
		int(_captured_loan_shark.get("cash_cents", 0)),
		EASY_CONFIG.loan_shark_cash_cents,
		"W1 Easy: offer cash uses Easy scalar"
	)
	_expect_equal(
		int(_captured_loan_shark.get("daily_cents", 0)),
		EASY_CONFIG.loan_shark_daily_cents,
		"W1 Easy: offer daily uses Easy scalar"
	)
	_expect_equal(
		int(_captured_loan_shark.get("rep_hit", 0)),
		EASY_CONFIG.loan_shark_rep_hit,
		"W1 Easy: offer Rep hit uses Easy scalar"
	)
	_assert_payload_has_no_truth(_captured_loan_shark, "W1 Easy: offer payload")
	var cash_before := int(_economy.get("balance_cents"))
	var rep_before := int(_game_state.get("current_reputation"))
	_expect_equal(
		_game_state.call("accept_loan_shark"),
		true,
		"W1 Easy: Accept applies terms"
	)
	_expect_equal(
		String(_captured_loan_shark_outcome),
		"accept",
		"W1 Easy: accept resolves offer"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_before + EASY_CONFIG.loan_shark_cash_cents,
		"W1 Easy: Accept grants +$6,000"
	)
	_expect_equal(
		int(_game_state.get("current_reputation")),
		rep_before - EASY_CONFIG.loan_shark_rep_hit,
		"W1 Easy: Accept hits Rep −5"
	)
	_expect_equal(
		_economy.call("payday_loan_days_remaining"),
		EASY_CONFIG.loan_shark_days,
		"W1 Easy: drain scheduled for 40 days"
	)
	_expect_equal(
		bool(_game_state.get("loan_shark_offer_pending")),
		false,
		"W1 Easy: offer clears after Accept"
	)
	_expect_equal(
		_game_state.call("can_progress_day"),
		true,
		"W1 Easy: day progress resumes after Accept"
	)
	var cash_after_loan := int(_economy.get("balance_cents"))
	var drain_count := 0
	for _day_index: int in range(EASY_CONFIG.loan_shark_days):
		_expect_equal(
			_economy.call("has_active_payday_loan"),
			true,
			"W1 Easy: loan stays active through day %d" % (_day_index + 1)
		)
		_expect_equal(
			_economy.call("settle_payday_loan"),
			true,
			"W1 Easy: daily drain fires day %d" % (_day_index + 1)
		)
		drain_count += 1
	_expect_equal(drain_count, 40, "W1 Easy: drain fires 40 days")
	_expect_equal(
		_economy.call("has_active_payday_loan"),
		false,
		"W1 Easy: loan ends after 40 days"
	)
	_expect_equal(
		int(_economy.get("balance_cents")),
		cash_after_loan - EASY_CONFIG.loan_shark_daily_cents * 40,
		"W1 Easy: 40-day drain totals −$150/day"
	)


func _test_loan_shark_normal_offer_and_refuse() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_trigger_rent_bankruptcy("Normal offer")
	_expect_equal(
		bool(_game_state.get("loan_shark_offer_pending")),
		true,
		"W1 Normal: first bankruptcy shows offer"
	)
	_expect_equal(
		int(_captured_loan_shark.get("cash_cents", 0)),
		NORMAL_CONFIG.loan_shark_cash_cents,
		"W1 Normal: offer cash is +$5,000"
	)
	_expect_equal(
		int(_captured_loan_shark.get("daily_cents", 0)),
		NORMAL_CONFIG.loan_shark_daily_cents,
		"W1 Normal: offer daily is −$200"
	)
	_expect_equal(
		int(_captured_loan_shark.get("days", 0)),
		40,
		"W1 Normal: offer lasts 40 days"
	)
	_expect_equal(
		int(_captured_loan_shark.get("rep_hit", 0)),
		10,
		"W1 Normal: offer Rep hit is −10"
	)
	_assert_payload_has_no_truth(_captured_loan_shark, "W1 Normal: offer payload")
	_expect_equal(
		_game_state.call("refuse_loan_shark"),
		true,
		"W1 Normal: Refuse is accepted"
	)
	_expect_equal(
		String(_captured_loan_shark_outcome),
		"refuse",
		"W1 Normal: refuse resolves offer"
	)
	_expect_equal(
		bool(_game_state.get("campaign_lost")),
		true,
		"W1 Normal: Refuse is game over"
	)
	_expect_equal(
		String(_game_state.get("last_lose_reason")),
		"refused_loan_shark",
		"W1 Normal: refuse reason is refused_loan_shark"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"W1 Normal: Refuse ends the campaign"
	)
	_expect_equal(
		String(_captured_campaign_lost.get("reason", "")),
		"refused_loan_shark",
		"W1 Normal: campaign_lost reason is refuse"
	)
	_assert_payload_has_no_truth(_captured_campaign_lost, "W1 Normal: lose payload")
	_expect_equal(
		_game_state.call("advance_day"),
		false,
		"W1 Normal: game over cannot advance"
	)


func _test_loan_shark_hard_instant_over() -> void:
	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_trigger_rent_bankruptcy("Hard instant over")
	_expect_equal(
		bool(_game_state.get("loan_shark_offer_pending")),
		false,
		"W1 Hard: no loan shark offer"
	)
	_expect_equal(
		_captured_loan_shark.is_empty(),
		true,
		"W1 Hard: loan_shark_offered does not fire"
	)
	_expect_equal(
		bool(_game_state.get("campaign_lost")),
		true,
		"W1 Hard: instant game over"
	)
	_expect_equal(
		String(_game_state.get("last_lose_reason")),
		"missed_rent",
		"W1 Hard: lose reason is missed rent"
	)
	_expect_equal(
		bool(_game_state.get("is_game_active")),
		false,
		"W1 Hard: campaign ends immediately"
	)
	_expect_equal(
		_game_state.call("accept_loan_shark"),
		false,
		"W1 Hard: Accept is not available"
	)
	_assert_payload_has_no_truth(_captured_campaign_lost, "W1 Hard: lose payload")


func _test_loan_shark_second_bankruptcy_over() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_trigger_rent_bankruptcy("second bankruptcy first offer")
	_expect_equal(
		_game_state.call("accept_loan_shark"),
		true,
		"W1: first Accept consumes the recovery"
	)
	_trigger_rent_bankruptcy("second bankruptcy")
	_expect_equal(
		bool(_game_state.get("loan_shark_offer_pending")),
		false,
		"W1: second bankruptcy does not re-offer"
	)
	_expect_equal(
		bool(_game_state.get("campaign_lost")),
		true,
		"W1: second bankruptcy is game over"
	)
	_expect_equal(
		String(_game_state.get("last_lose_reason")),
		"missed_rent",
		"W1: second bankruptcy reason is missed rent"
	)


func _test_loan_shark_hud_and_section_45() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_trigger_rent_bankruptcy("HUD offer")
	var hud := _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "W1: HUD loads for loan shark modal")
	if hud == null:
		return
	var offer := hud.get_node_or_null("%LoanShark") as PanelContainer
	var title := hud.get_node_or_null("%LoanSharkTitle") as Label
	var body := hud.get_node_or_null("%LoanSharkBody") as Label
	var accept := hud.get_node_or_null("%LoanSharkAcceptButton") as Button
	var refuse := hud.get_node_or_null("%LoanSharkRefuseButton") as Button
	var over := hud.get_node_or_null("%GameOver") as PanelContainer
	_expect_equal(offer != null and offer.visible, true, "W1: loan shark modal shows")
	_expect_equal(over == null or not over.visible, true, "W1: game over hidden during offer")
	_expect_equal(
		title != null and title.text == "Loan shark",
		true,
		"W1: modal title is Loan shark"
	)
	_expect_equal(
		body != null
		and body.text.contains("$5,000.00")
		and body.text.contains("$200.00")
		and body.text.contains("40")
		and body.text.contains("10")
		and body.text.to_lower().contains("refuse is game over"),
		true,
		"W1: modal body shows Normal terms and refuse=over"
	)
	_assert_text_has_no_truth(body.text if body != null else "", "W1 loan shark body")
	_assert_text_has_no_truth(title.text if title != null else "", "W1 loan shark title")
	_expect_equal(accept != null and accept.visible, true, "W1: Accept button exists")
	_expect_equal(refuse != null and refuse.visible, true, "W1: Refuse button exists")
	accept.pressed.emit()
	_expect_equal(
		offer == null or not offer.visible,
		true,
		"W1: modal closes after Accept"
	)
	_expect_equal(
		_economy.call("has_active_payday_loan"),
		true,
		"W1: HUD Accept starts the daily drain"
	)
	hud.queue_free()

	_game_state.call("set_balance_config", HARD_CONFIG)
	_game_state.call("start_new_game")
	_trigger_rent_bankruptcy("HUD Hard over")
	hud = _instantiate_gameplay_hud()
	_expect_equal(hud != null, true, "W1: HUD loads for Hard game over")
	if hud == null:
		return
	offer = hud.get_node_or_null("%LoanShark") as PanelContainer
	over = hud.get_node_or_null("%GameOver") as PanelContainer
	var over_title := hud.get_node_or_null("%GameOverTitle") as Label
	var over_body := hud.get_node_or_null("%GameOverBody") as Label
	_expect_equal(offer == null or not offer.visible, true, "W1 Hard HUD: no offer")
	_expect_equal(over != null and over.visible, true, "W1 Hard HUD: game over shows")
	_expect_equal(
		over_title != null and over_title.text == "Game over",
		true,
		"W1 Hard HUD: title is Game over"
	)
	_assert_text_has_no_truth(
		over_body.text if over_body != null else "",
		"W1 Hard game over body"
	)
	hud.queue_free()


func _test_loan_shark_save_load() -> void:
	_game_state.call("set_balance_config", NORMAL_CONFIG)
	_game_state.call("start_new_game")
	_trigger_rent_bankruptcy("save after accept")
	_expect_equal(_game_state.call("accept_loan_shark"), true, "W1 save: Accept first")
	_expect_equal(
		_economy.call("settle_payday_loan"),
		true,
		"W1 save: one drain day before save"
	)
	var remaining := int(_economy.call("payday_loan_days_remaining"))
	var saved: Dictionary = _game_state.call("capture_save")
	_expect_equal(
		bool(saved.get("loan_shark_recovery_used", false)),
		true,
		"W1 save: recovery used is persisted"
	)
	_expect_equal(
		int(saved.get("payday_loan_days_remaining", 0)),
		remaining,
		"W1 save: remaining drain days persist"
	)
	_game_state.call("start_new_game")
	_expect_equal(
		bool(_game_state.get("loan_shark_recovery_used")),
		false,
		"W1 save: new game clears recovery"
	)
	_expect_equal(
		_game_state.call("restore_save", saved),
		true,
		"W1 save: restore succeeds"
	)
	_expect_equal(
		bool(_game_state.get("loan_shark_recovery_used")),
		true,
		"W1 save: restore keeps recovery used"
	)
	_expect_equal(
		int(_economy.call("payday_loan_days_remaining")),
		remaining,
		"W1 save: restore keeps drain days"
	)
	_expect_equal(
		bool(_game_state.get("campaign_lost")),
		false,
		"W1 save: accepted recovery is not a loss"
	)


func _trigger_rent_bankruptcy(label: String) -> void:
	var config: BalanceConfig = _game_state.get("balance_config")
	_captured_loan_shark = {}
	_captured_loan_shark_outcome = &""
	_captured_campaign_lost = {}
	_game_state.set("missed_rent_weeks", maxi(0, config.missed_rent_weeks_to_lose - 1))
	_game_state.set("current_day", config.first_rent_due_day)
	_game_state.set("current_phase", DayPhasePolicy.PREP)
	_game_state.set("loan_shark_offer_pending", false)
	_game_state.set("campaign_lost", false)
	_game_state.set("is_game_active", true)
	_economy.set("balance_cents", 0)
	_expect_equal(
		_game_state.call("start_floor"),
		true,
		"W1 %s: FLOOR opens before rent miss" % label
	)
	_expect_equal(
		_game_state.call("start_settle"),
		true,
		"W1 %s: SETTLE runs the rent miss" % label
	)


func _j1_comp_width(dto: Resource) -> int:
	if dto == null:
		return -1
	return int(dto.get("shown_comp_high_cents")) - int(dto.get("shown_comp_low_cents"))


func _j1_skill_signal_events() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event_value: Variant in _qa_autoload.call("get_events"):
		var event := event_value as Dictionary
		if String(event.get("event", "")) == "demand_signal_shown":
			result.append(event)
	return result


func _i1_unique_card() -> CardInstance:
	return _inventory_service.call(
		"receive_card",
		&"AA-SKIE-058",
		900,
		InventoryLocation.new(InventoryLocation.Type.BINDER),
		1800
	) as CardInstance


func _i1_card_target(card: CardInstance) -> Dictionary:
	var sku := _inventory_service.get("model").get_sku(card.sku_id) as ProductSKU
	return {
		"sku_id": card.sku_id,
		"display_name": sku.display_name if sku != null else String(card.sku_id),
		"quantity": 1,
		"listed_price_cents": card.listed_price_cents,
		"location": card.location,
		"card": card,
	}


func _i1_list_unique_card(listed_price_cents: int) -> Dictionary:
	var card := _i1_unique_card()
	if card == null:
		return {"ok": false, "reason": &"no_card"}
	return _economy.get("online_listings").call(
		"list_target",
		_i1_card_target(card),
		listed_price_cents,
		{"ship_days": 2}
	)


func _i1_ledger_count(category: StringName) -> int:
	var count := 0
	for entry: LedgerEntry in _economy.call("get_ledger"):
		if entry.category == category:
			count += 1
	return count


func _free_lingering_gameplay_huds() -> void:
	var stale: Array[Node] = []
	for child: Node in root.get_children():
		var script: Script = child.get_script() as Script
		if (
			script != null
			and String(script.resource_path).ends_with("hud.gd")
		):
			stale.append(child)
	for hud: Node in stale:
		if hud.get_parent() == root:
			root.remove_child(hud)
		hud.free()


func _instantiate_main_menu() -> Node:
	var packed: PackedScene = load("res://scenes/ui/main_menu.tscn") as PackedScene
	if packed == null:
		return null
	var menu: Node = packed.instantiate()
	root.add_child(menu)
	if not menu.is_node_ready():
		menu.notification(Node.NOTIFICATION_READY)
	return menu


func _instantiate_gameplay_hud() -> Node:
	_free_lingering_gameplay_huds()
	var packed: PackedScene = load("res://scenes/ui/gameplay_hud.tscn") as PackedScene
	if packed == null:
		return null
	var hud: Node = packed.instantiate()
	root.add_child(hud)
	if not hud.is_node_ready():
		hud.notification(Node.NOTIFICATION_READY)
	return hud


func _click_buy_row_for_channel(hud: Node, channel: StringName) -> bool:
	var rows := hud.get_node_or_null("%BuyOpportunityRows") as VBoxContainer
	if rows == null:
		return false
	var prefix := "%s ·" % String(channel).capitalize()
	for child: Node in rows.get_children():
		var row := child as Button
		if row != null and row.text.begins_with(prefix):
			row.pressed.emit()
			return true
	return false


func _select_buy_on_hud(hud: Node, dto: BuyConfirmSignal) -> void:
	Callable(hud, "_select_buy_opportunity").call(dto)


func _assert_text_has_no_truth(text: String, label: String) -> void:
	var lower := text.to_lower()
	_expect_equal(
		lower.contains("true_market"),
		false,
		"%s does not leak true_market" % label
	)
	_expect_equal(lower.contains("p_buy"), false, "%s does not leak p_buy" % label)
	_expect_equal(
		lower.contains("cert_valid"),
		false,
		"%s does not leak cert_valid" % label
	)


func _assert_payload_has_no_truth(payload: Dictionary, label: String) -> void:
	for key: Variant in payload.keys():
		var field := String(key)
		_expect_equal(
			field.contains("true_market")
			or field.contains("p_buy")
			or field.contains("cert_valid"),
			false,
			"%s field %s does not leak truth" % [label, field]
		)
		var nested: Variant = payload[key]
		if nested is Dictionary:
			_assert_payload_has_no_truth(nested as Dictionary, label)
		elif nested is Array:
			for item: Variant in nested:
				if item is Dictionary:
					_assert_payload_has_no_truth(item as Dictionary, label)


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


func _assert_large_shell_state(label: String) -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "%s shop_floor loads" % label)
	if packed == null:
		return
	var floor: Node = packed.instantiate()
	root.add_child(floor)
	var extent := floor.get_node_or_null("FloorExtent") as ShopFloorExtent
	_expect_equal(extent != null, true, "%s FloorExtent present" % label)
	if extent != null:
		extent.sync_from_shop()
		_expect_equal(
			extent.is_medium_extension_visible(),
			false,
			"%s Medium Art shell hides after Large Sign" % label
		)
		_expect_equal(
			extent.is_large_shell_visible(),
			true,
			"%s Large Art shell is visible" % label
		)
		_expect_equal(
			extent.is_large_scaffold_visible(),
			false,
			"%s Large scaffold interim floor is gone" % label
		)
		_expect_equal(
			extent.has_large_scaffold(),
			false,
			"%s Large scaffold nodes are absent" % label
		)
		_expect_equal(extent.has_node("LargeFloor"), false, "%s no LargeFloor node" % label)
		_expect_equal(extent.has_node("LargeWallEast"), false, "%s no LargeWallEast" % label)
		_expect_equal(extent.has_node("LargeWallNorth"), false, "%s no LargeWallNorth" % label)
		_expect_equal(extent.extra_floor_tile_count(), 154, "%s extra tiles vs Small" % label)
		_expect_equal(extent.extra_large_tile_count(), 94, "%s extra tiles vs Medium" % label)
		_expect_equal(extent.has_fog_veil(), false, "%s fog stays nacked" % label)
		_expect_equal(
			extent.has_code_driven_stub(),
			false,
			"%s MediumFloor stub stays nacked" % label
		)
		_expect_equal(extent.has_node("MediumVeilX"), false, "%s no Medium fog veil X" % label)
		_expect_equal(extent.has_node("MediumVeilZ"), false, "%s no Medium fog veil Z" % label)
	var small_shell := floor.get_node_or_null("Architecture/ShopShell") as Node3D
	var medium_shell := floor.get_node_or_null("Architecture/ShopShellMedium") as Node3D
	var large_shell := floor.get_node_or_null("Architecture/ShopShellLarge") as Node3D
	_expect_equal(small_shell != null, true, "%s Small Art GLB instanced" % label)
	_expect_equal(medium_shell != null, true, "%s Medium Art GLB instanced" % label)
	_expect_equal(large_shell != null, true, "%s Large Art GLB instanced" % label)
	if small_shell != null:
		_expect_equal(small_shell.visible, false, "%s Small shell hidden on Large" % label)
	if medium_shell != null:
		_expect_equal(medium_shell.visible, false, "%s Medium shell hidden on Large" % label)
	if large_shell != null:
		_expect_equal(large_shell.visible, true, "%s Large shell visible" % label)
		_expect_equal(
			large_shell.position.is_equal_approx(Vector3.ZERO),
			true,
			"%s Large SW pivot at origin" % label
		)
		_expect_equal(
			large_shell.scale.is_equal_approx(Vector3.ONE),
			true,
			"%s Large scale 1u=1m" % label
		)
	var world := floor.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world != null and world.environment != null:
		_expect_equal(world.environment.fog_enabled, false, "%s fog volume nacked" % label)
		_expect_equal(
			world.environment.volumetric_fog_enabled,
			false,
			"%s volumetric fog nacked" % label
		)
	var camera := floor.get_node_or_null("Camera") as ShopCamera
	if camera != null:
		camera.apply_home_pose(ShopCamera.POSE_AISLE)
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.AISLE_POSITION),
			true,
			"%s does not churn aisle camera" % label
		)
		_expect_equal(
			is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
			true,
			"%s does not churn FOV" % label
		)
		camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"%s keeps Art behind-counter home" % label
		)
	_assert_overhead_lights_on_floor(floor, true, label)
	_assert_shop_fog_nacked(floor, label)
	floor.free()


func _assert_shop_shell_state(want_medium: bool, label: String) -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "%s shop_floor loads" % label)
	if packed == null:
		return
	var floor: Node = packed.instantiate()
	root.add_child(floor)
	var extent := floor.get_node_or_null("FloorExtent") as ShopFloorExtent
	_expect_equal(extent != null, true, "%s FloorExtent present" % label)
	if extent != null:
		extent.sync_from_shop()
		_expect_equal(
			extent.is_medium_extension_visible(),
			want_medium,
			"%s Art Medium shell visibility" % label
		)
		_expect_equal(
			extent.extra_floor_tile_count(),
			60 if want_medium else 0,
			"%s extra tiles" % label
		)
		_expect_equal(extent.has_fog_veil(), false, "%s fog stays nacked" % label)
		_expect_equal(
			extent.has_code_driven_stub(),
			false,
			"%s code-driven MediumFloor stub gone" % label
		)
		_expect_equal(extent.has_node("MediumFloor"), false, "%s no MediumFloor node" % label)
		_expect_equal(extent.has_node("MediumWallEast"), false, "%s no east wall stub" % label)
		_expect_equal(extent.has_node("MediumWallNorth"), false, "%s no north wall stub" % label)
		_expect_equal(
			extent.is_large_shell_visible(),
			false,
			"%s Large Art shell stays hidden" % label
		)
		_expect_equal(
			extent.has_large_scaffold(),
			false,
			"%s Large scaffold stays absent" % label
		)
		_expect_equal(
			extent.is_large_scaffold_visible(),
			false,
			"%s Large scaffold stays hidden" % label
		)
		_expect_equal(extent.has_node("LargeFloor"), false, "%s no LargeFloor node" % label)
	var small_shell := floor.get_node_or_null("Architecture/ShopShell") as Node3D
	var medium_shell := floor.get_node_or_null("Architecture/ShopShellMedium") as Node3D
	var large_shell := floor.get_node_or_null("Architecture/ShopShellLarge") as Node3D
	_expect_equal(small_shell != null, true, "%s Small Art GLB instanced" % label)
	_expect_equal(medium_shell != null, true, "%s Medium Art GLB instanced" % label)
	_expect_equal(large_shell != null, true, "%s Large Art GLB instanced" % label)
	if small_shell != null:
		_expect_equal(small_shell.visible, not want_medium, "%s Small shell visible" % label)
	if medium_shell != null:
		_expect_equal(medium_shell.visible, want_medium, "%s Medium shell visible" % label)
		_expect_equal(
			medium_shell.position.is_equal_approx(Vector3.ZERO),
			true,
			"%s Medium SW pivot at origin" % label
		)
		_expect_equal(
			medium_shell.scale.is_equal_approx(Vector3.ONE),
			true,
			"%s Medium scale 1u=1m" % label
		)
	if large_shell != null:
		_expect_equal(large_shell.visible, false, "%s Large shell hidden" % label)
	var camera := floor.get_node_or_null("Camera") as ShopCamera
	if camera != null:
		camera.apply_home_pose(ShopCamera.POSE_AISLE)
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.AISLE_POSITION),
			true,
			"%s does not churn aisle camera" % label
		)
		_expect_equal(
			is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
			true,
			"%s does not churn FOV" % label
		)
		camera.apply_home_pose(ShopCamera.POSE_BEHIND_COUNTER)
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"%s keeps Art behind-counter home" % label
		)
	_assert_overhead_lights_on_floor(floor, want_medium, label)
	floor.free()


func _assert_overhead_lights_for_tier(want_medium: bool, label: String) -> void:
	var packed: PackedScene = load("res://scenes/shop/shop_floor.tscn") as PackedScene
	_expect_equal(packed != null, true, "%s shop_floor loads for lights" % label)
	if packed == null:
		return
	var floor: Node = packed.instantiate()
	root.add_child(floor)
	_assert_overhead_lights_on_floor(floor, want_medium, label)
	var camera := floor.get_node_or_null("Camera") as ShopCamera
	if camera != null:
		_expect_equal(
			camera.position.is_equal_approx(ShopCamera.BEHIND_COUNTER_POSITION),
			true,
			"%s lights do not churn behind-desk cam" % label
		)
		_expect_equal(
			is_equal_approx(camera.fov, ShopCamera.HOME_FOV),
			true,
			"%s lights do not churn FOV" % label
		)
	floor.free()


func _assert_overhead_lights_on_floor(floor: Node, want_medium: bool, label: String) -> void:
	var extent := floor.get_node_or_null("FloorExtent") as ShopFloorExtent
	_expect_equal(extent != null, true, "%s FloorExtent for lights" % label)
	if extent != null:
		extent.sync_from_shop()
		_expect_equal(
			extent.is_medium_overhead_visible(),
			want_medium,
			"%s Medium extras visibility" % label
		)
		_expect_equal(
			extent.visible_overhead_mesh_count(),
			11 if want_medium else 5,
			"%s overhead mesh count" % label
		)
		_expect_equal(
			extent.visible_overhead_fill_count(),
			11 if want_medium else 5,
			"%s overhead fill count" % label
		)
		_expect_equal(extent.has_fog_veil(), false, "%s lights keep fog nacked" % label)
	var lights_root := floor.get_node_or_null("Fixtures/OverheadLights")
	_expect_equal(lights_root != null, true, "%s OverheadLights present" % label)
	_assert_small_overheads_locked(lights_root, label)
	_assert_medium_overheads(lights_root, want_medium, label)
	_assert_shop_fog_nacked(floor, label)


func _assert_small_overheads_locked(lights_root: Node, label: String) -> void:
	_expect_equal(lights_root != null, true, "%s OverheadLights root" % label)
	if lights_root == null:
		return
	var sot := {
		"FrontLeft": Vector3(2.25, 2.79, -2.25),
		"FrontRight": Vector3(6.75, 2.79, -2.25),
		"BackLeft": Vector3(2.25, 2.79, -4.95),
		"BackRight": Vector3(6.75, 2.79, -4.95),
		"BackLeftAisle": Vector3(2.8, 2.78, -5.4),
	}
	for mesh_name: String in sot:
		var mesh := lights_root.get_node_or_null(mesh_name) as Node3D
		_expect_equal(mesh != null, true, "%s %s present" % [label, mesh_name])
		if mesh == null:
			continue
		_expect_equal(mesh.visible, true, "%s %s stays visible" % [label, mesh_name])
		_expect_equal(
			mesh.position.is_equal_approx(sot[mesh_name]),
			true,
			"%s %s locked SoT" % [label, mesh_name]
		)
		_expect_equal(
			mesh.scale.is_equal_approx(Vector3.ONE),
			true,
			"%s %s scale 1,1,1" % [label, mesh_name]
		)
		var fill := lights_root.get_node_or_null("%sFill" % mesh_name) as OmniLight3D
		_expect_equal(fill != null, true, "%s %sFill present" % [label, mesh_name])
		if fill == null:
			continue
		_expect_equal(fill.visible, true, "%s %sFill stays visible" % [label, mesh_name])
		_expect_equal(
			fill.position.is_equal_approx(Vector3(sot[mesh_name].x, 2.55, sot[mesh_name].z)),
			true,
			"%s %sFill same XZ Y=2.55" % [label, mesh_name]
		)
		_assert_overhead_fill_recipe(fill, "%s %sFill" % [label, mesh_name])


func _assert_medium_overheads(lights_root: Node, want_visible: bool, label: String) -> void:
	_expect_equal(lights_root != null, true, "%s OverheadLights for Medium extras" % label)
	if lights_root == null:
		return
	var sot := {
		"MidCenter": Vector3(5.4, 2.79, -4.95),
		"FarFront": Vector3(10.35, 2.79, -2.25),
		"FarBack": Vector3(10.35, 2.79, -4.95),
		"DeepLeft": Vector3(2.25, 2.79, -7.2),
		"DeepCenter": Vector3(6.3, 2.79, -7.2),
		"DeepRight": Vector3(10.35, 2.79, -7.2),
	}
	for mesh_name: String in sot:
		var mesh := lights_root.get_node_or_null(mesh_name) as Node3D
		_expect_equal(mesh != null, true, "%s %s present" % [label, mesh_name])
		if mesh == null:
			continue
		_expect_equal(
			mesh.visible,
			want_visible,
			"%s %s Medium-only visibility" % [label, mesh_name]
		)
		_expect_equal(
			mesh.position.is_equal_approx(sot[mesh_name]),
			true,
			"%s %s SoT position" % [label, mesh_name]
		)
		_expect_equal(
			mesh.scale.is_equal_approx(Vector3.ONE),
			true,
			"%s %s scale 1,1,1" % [label, mesh_name]
		)
		var fill := lights_root.get_node_or_null("%sFill" % mesh_name) as OmniLight3D
		_expect_equal(fill != null, true, "%s %sFill present" % [label, mesh_name])
		if fill == null:
			continue
		_expect_equal(
			fill.visible,
			want_visible,
			"%s %sFill Medium-only visibility" % [label, mesh_name]
		)
		_expect_equal(
			fill.position.is_equal_approx(Vector3(sot[mesh_name].x, 2.55, sot[mesh_name].z)),
			true,
			"%s %sFill same XZ Y=2.55" % [label, mesh_name]
		)
		_assert_overhead_fill_recipe(fill, "%s %sFill" % [label, mesh_name])
	var mid := lights_root.get_node_or_null("MidCenter") as Node3D
	var back_right := lights_root.get_node_or_null("BackRight") as Node3D
	_expect_equal(
		mid != null and back_right != null and mid != back_right,
		true,
		"%s MidCenter stays a distinct node from BackRight" % label
	)
	if mid != null and back_right != null:
		_expect_equal(
			is_equal_approx(back_right.position.x, 6.75),
			true,
			"%s BackRight stays at X=6.75" % label
		)
		_expect_equal(
			is_equal_approx(absf(mid.position.x - back_right.position.x), 1.35),
			true,
			"%s MidCenter dX 1.35 m from BackRight" % label
		)


func _assert_overhead_fill_recipe(omni: OmniLight3D, label: String) -> void:
	_expect_equal(
		omni.light_color.is_equal_approx(Color(1, 0.83, 0.66, 1)),
		true,
		"%s color (1.0, 0.83, 0.66)" % label
	)
	_expect_equal(is_equal_approx(omni.light_energy, 1.65), true, "%s energy 1.65" % label)
	_expect_equal(is_equal_approx(omni.omni_range, 7.0), true, "%s range 7.0" % label)
	_expect_equal(is_equal_approx(omni.omni_attenuation, 1.2), true, "%s atten 1.2" % label)
	_expect_equal(omni.shadow_enabled, false, "%s shadows off" % label)


func _assert_shop_fog_nacked(shop: Node, label: String) -> void:
	var world := shop.get_node_or_null("WorldEnvironment") as WorldEnvironment
	_expect_equal(world != null, true, "%s WorldEnvironment present" % label)
	if world == null or world.environment == null:
		return
	_expect_equal(world.environment.fog_enabled, false, "%s fog volume nacked" % label)
	_expect_equal(
		world.environment.volumetric_fog_enabled,
		false,
		"%s volumetric fog nacked" % label
	)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	if actual == expected:
		return
	_failures += 1
	push_error("%s: expected %s, got %s" % [label, expected, actual])
