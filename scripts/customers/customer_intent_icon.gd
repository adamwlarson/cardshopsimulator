class_name CustomerIntentIcon
extends Sprite3D

enum Intent {
	BROWSE,
	BUY,
	SELL,
}

const COLOR_BROWSE := Color(0.74, 0.76, 0.78)
const COLOR_BUY := Color(0.30, 0.64, 0.62)
const COLOR_SELL := Color(0.84, 0.58, 0.26)

var intent: Intent = Intent.BROWSE


func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pixel_size = 0.012
	centered = true
	position = Vector3(0.0, 2.05, 0.0)
	apply_intent(Intent.BROWSE)


func apply_intent(next: Intent) -> void:
	intent = next
	texture = _make_texture(next)
	modulate = Color.WHITE


func intent_name() -> StringName:
	match intent:
		Intent.BUY:
			return &"buy"
		Intent.SELL:
			return &"sell"
		_:
			return &"browse"


func presentation() -> Dictionary:
	return {"intent": intent_name()}


func has_truth_fields() -> bool:
	for key: Variant in presentation().keys():
		var field := String(key)
		if (
			field.contains("sku")
			or field.contains("price")
			or field.contains("comp")
			or field.contains("true_market")
			or field.contains("cert_valid")
		):
			return true
	return false


func _make_texture(next: Intent) -> Texture2D:
	var image := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color := COLOR_BROWSE
	match next:
		Intent.BUY:
			color = COLOR_BUY
			_draw_bag(image, color)
		Intent.SELL:
			color = COLOR_SELL
			_draw_tag(image, color)
		_:
			_draw_magnifier(image, color)
	return ImageTexture.create_from_image(image)


func _draw_magnifier(image: Image, color: Color) -> void:
	_fill_circle(image, 20, 20, 11, color)
	_fill_circle(image, 20, 20, 6, Color(0.12, 0.13, 0.15, 0.92))
	_fill_rect(image, 28, 28, 8, 4, color)


func _draw_bag(image: Image, color: Color) -> void:
	_fill_rect(image, 12, 18, 24, 22, color)
	_fill_rect(image, 16, 10, 4, 10, color)
	_fill_rect(image, 28, 10, 4, 10, color)


func _draw_tag(image: Image, color: Color) -> void:
	_fill_rect(image, 14, 12, 20, 24, color)
	_fill_circle(image, 24, 18, 3, Color(0.12, 0.13, 0.15, 0.92))
	_fill_rect(image, 20, 26, 8, 3, Color(0.12, 0.13, 0.15, 0.55))


func _fill_circle(image: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	var r2 := radius * radius
	for y: int in range(cy - radius, cy + radius + 1):
		for x: int in range(cx - radius, cx + radius + 1):
			if x < 0 or y < 0 or x >= 48 or y >= 48:
				continue
			var dx := x - cx
			var dy := y - cy
			if dx * dx + dy * dy <= r2:
				image.set_pixel(x, y, color)


func _fill_rect(
	image: Image,
	left: int,
	top: int,
	width: int,
	height: int,
	color: Color
) -> void:
	for y: int in range(top, top + height):
		for x: int in range(left, left + width):
			if x < 0 or y < 0 or x >= 48 or y >= 48:
				continue
			image.set_pixel(x, y, color)
