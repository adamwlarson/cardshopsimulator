class_name BuylistPctSettings
extends RefCounted

## Player buylist % of market per category, as AW1 stores them.
## Defaults match BuylistPolicy.PCT_SEALED / PCT_SINGLES_NM / PCT_GRADED.
## Missing / unknown categories fall back to BuylistPolicy.buylist_pct.
const SAVE_SEALED_KEY := "sealed"
const SAVE_SINGLES_NM_KEY := "singles_nm"
const SAVE_GRADED_KEY := "graded"

var _pct_by_category: Dictionary = {}


func _init() -> void:
	reset()


func reset() -> void:
	_pct_by_category = {
		BuylistPolicy.CATEGORY_SEALED: BuylistPolicy.PCT_SEALED,
		BuylistPolicy.CATEGORY_SINGLES_NM: BuylistPolicy.PCT_SINGLES_NM,
		BuylistPolicy.CATEGORY_GRADED: BuylistPolicy.PCT_GRADED,
	}


func pct_for(category: Variant) -> float:
	var named := BuylistDripPolicy.named_category(category)
	if _pct_by_category.has(named):
		return float(_pct_by_category[named])
	return BuylistPolicy.buylist_pct(category)


func set_pct(category: Variant, pct: float) -> void:
	var named := BuylistDripPolicy.named_category(category)
	if not BuylistDripPolicy.is_category(named):
		return
	_pct_by_category[named] = pct


func snapshot() -> Dictionary:
	return {
		SAVE_SEALED_KEY: pct_for(BuylistPolicy.CATEGORY_SEALED),
		SAVE_SINGLES_NM_KEY: pct_for(BuylistPolicy.CATEGORY_SINGLES_NM),
		SAVE_GRADED_KEY: pct_for(BuylistPolicy.CATEGORY_GRADED),
	}


func apply_save(data: Dictionary) -> void:
	reset()
	if data.is_empty():
		return
	if data.has(SAVE_SEALED_KEY):
		set_pct(BuylistPolicy.CATEGORY_SEALED, float(data[SAVE_SEALED_KEY]))
	if data.has(SAVE_SINGLES_NM_KEY):
		set_pct(BuylistPolicy.CATEGORY_SINGLES_NM, float(data[SAVE_SINGLES_NM_KEY]))
	if data.has(SAVE_GRADED_KEY):
		set_pct(BuylistPolicy.CATEGORY_GRADED, float(data[SAVE_GRADED_KEY]))
