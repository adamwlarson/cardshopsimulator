class_name PlayerTradePolicy
extends RefCounted

## systems §3 player trades. Integer gate: Rep ≥ 50 can offer, Rep ≤ 49 cannot.
const UNLOCK_REP := 50
## Seeded in-kind pair: give one owned Dustway ETB, receive one Skiefall ETB.
const SEEDED_OFFER_ID := &"player-trade-seeded-dust-for-skie"
const SEEDED_GIVE_SKU := &"AA-DUST-ETB"
const SEEDED_RECEIVE_SKU := &"AA-SKIE-ETB"
const SEEDED_CONDITION := "Sealed · NM"
const SEEDED_COUNTERPARTY := "Another shop"
const SEEDED_GIVE_QTY := 1
const SEEDED_RECEIVE_QTY := 1


static func is_unlocked(reputation: int) -> bool:
	return reputation >= UNLOCK_REP


static func can_offer(reputation: int) -> bool:
	return is_unlocked(reputation)
