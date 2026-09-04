class_name CustomerCast
extends RefCounted

enum Slot {
	C1,
	C2,
	C3,
}

const SCENE_C1 := (
	"res://assets/chars/customers/char_customer_casual_a_01/"
	+ "char_customer_casual_a_01.glb"
)
const SCENE_C2 := (
	"res://assets/chars/customers/char_customer_casual_b_01/"
	+ "char_customer_casual_b_01.glb"
)
const SCENE_C3 := (
	"res://assets/chars/customers/char_customer_casual_c_01/"
	+ "char_customer_casual_c_01.glb"
)


static func slot_for(archetype_id: StringName) -> Slot:
	match archetype_id:
		&"flipper":
			return Slot.C2
		&"kid_parent", &"spike":
			return Slot.C3
		_:
			return Slot.C1


static func slot_name(slot: Slot) -> StringName:
	match slot:
		Slot.C2:
			return &"C2"
		Slot.C3:
			return &"C3"
		_:
			return &"C1"


static func visual_for(archetype_id: StringName) -> Dictionary:
	var slot := slot_for(archetype_id)
	match slot:
		Slot.C2:
			return {
				"slot": slot_name(slot),
				"height": 1.70,
				"radius": 0.23,
				"color": Color(0.28, 0.27, 0.26),
				"scene": SCENE_C2,
			}
		Slot.C3:
			return {
				"slot": slot_name(slot),
				"height": 1.66,
				"radius": 0.22,
				"color": Color(0.62, 0.46, 0.28),
				"scene": SCENE_C3,
			}
		_:
			return {
				"slot": slot_name(slot),
				"height": 1.74,
				"radius": 0.22,
				"color": Color(0.34, 0.52, 0.56),
				"scene": SCENE_C1,
			}
