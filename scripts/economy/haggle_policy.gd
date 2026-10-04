class_name HagglePolicy
extends RefCounted

## systems §3 one-counter haggle. Cash buy offers that already show
## an ask get one shot to name a lower price. They take it, or the
## deal is gone. Out: auction snipes, player trades, Report, Walk.
const REP_BASE := 0.40
const REP_PER_POINT := 0.006
const CHANNEL_WEIGHT_DISTRIBUTOR := 1.10
const CHANNEL_WEIGHT_MARKETPLACE := 1.00
const CHANNEL_WEIGHT_SHADY := 0.80
const CHANNEL_WEIGHT_FALLBACK := 1.00
const MIN_OFFER_CENTS := 1
const RESULT_REFUSED := &"refused"
const RESULT_ACCEPTED := &"accepted"
const RESULT_MISSED := &"missed"


static func can_haggle(channel: Variant) -> bool:
	match _named_channel(channel):
		DemandSignalService.Channel.DISTRIBUTOR:
			return true
		DemandSignalService.Channel.MARKETPLACE:
			return true
		DemandSignalService.Channel.SHADY:
			return true
		_:
			return false


static func channel_weight(channel: Variant, configured: float = -1.0) -> float:
	if configured > 0.0:
		return configured
	match _named_channel(channel):
		DemandSignalService.Channel.DISTRIBUTOR:
			return CHANNEL_WEIGHT_DISTRIBUTOR
		DemandSignalService.Channel.MARKETPLACE:
			return CHANNEL_WEIGHT_MARKETPLACE
		DemandSignalService.Channel.SHADY:
			return CHANNEL_WEIGHT_SHADY
		_:
			return CHANNEL_WEIGHT_FALLBACK


static func rep_term(reputation: int, configured: float = -1.0) -> float:
	if configured < 0.0:
		return REP_BASE + float(reputation) * REP_PER_POINT
	return configured


static func accept_chance(
	offer_cents: int,
	ask_cents: int,
	reputation: int,
	channel: Variant,
	configured_weight: float = -1.0,
	configured_rep_term: float = -1.0
) -> float:
	if offer_cents <= 0 or ask_cents <= 0:
		return 0.0
	var ratio := float(offer_cents) / float(ask_cents)
	var term := rep_term(reputation, configured_rep_term)
	var weight := channel_weight(channel, configured_weight)
	return clampf(ratio * term * weight, 0.0, 1.0)


static func is_valid_counter(offer_cents: int, ask_cents: int) -> bool:
	return offer_cents >= MIN_OFFER_CENTS and offer_cents < ask_cents


static func roll_seed(opportunity_id: StringName, day: int) -> int:
	return _mix(String(opportunity_id).hash(), day, 4)


static func roll_accept(
	seed: int,
	offer_cents: int,
	ask_cents: int,
	reputation: int,
	channel: Variant,
	configured_weight: float = -1.0,
	configured_rep_term: float = -1.0
) -> bool:
	var chance := accept_chance(
		offer_cents,
		ask_cents,
		reputation,
		channel,
		configured_weight,
		configured_rep_term
	)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed & 0x7fffffff
	return rng.randf() < chance


static func _named_channel(channel: Variant) -> DemandSignalService.Channel:
	if typeof(channel) == TYPE_INT:
		return channel as DemandSignalService.Channel
	match String(channel).to_lower():
		"distributor":
			return DemandSignalService.Channel.DISTRIBUTOR
		"buylist":
			return DemandSignalService.Channel.BUYLIST
		"auction":
			return DemandSignalService.Channel.AUCTION
		"shady":
			return DemandSignalService.Channel.SHADY
		"marketplace":
			return DemandSignalService.Channel.MARKETPLACE
		"":
			return DemandSignalService.Channel.BUYLIST
		_:
			return DemandSignalService.Channel.BUYLIST


static func _mix(seed: int, day: int, lane: int) -> int:
	var mixed := (
		(int(seed) * 1664525)
		^ (int(day) * 22695477)
		^ (int(lane) * 1013904223)
	)
	return mixed & 0x7fffffff
