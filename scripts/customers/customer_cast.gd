class_name CustomerCast
extends RefCounted

enum Slot {
	C1,
	C2,
	C3,
}


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
				"height": 1.76,
				"radius": 0.23,
				"color": Color(0.62, 0.42, 0.28),
			}
		Slot.C3:
			var kid := archetype_id == &"kid_parent"
			return {
				"slot": slot_name(slot),
				"height": 1.48 if kid else 1.64,
				"radius": 0.20 if kid else 0.21,
				"color": Color(0.46, 0.40, 0.56),
			}
		_:
			return {
				"slot": slot_name(slot),
				"height": 1.70,
				"radius": 0.22,
				"color": Color(0.34, 0.52, 0.56),
			}
