class_name CustomerIntentIcon
extends Sprite3D

enum Intent {
	BROWSE,
	BUY,
	SELL,
}

const COLOR_BROWSE := Color(0.82, 0.84, 0.86)
const COLOR_BUY := Color(0.22, 0.72, 0.68)
const COLOR_SELL := Color(0.92, 0.62, 0.22)
const SIZE_PX := 64

var intent: Intent = Intent.BROWSE


func _ready() -> void:
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	shaded = false
	double_sided = true
	pixel_size = 0.022
	centered = true
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	render_priority = 8
	apply_intent(intent)


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
	var image := Image.create(SIZE_PX, SIZE_PX, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var color := COLOR_BROWSE
	match next:
		Intent.BUY:
			color = COLOR_BUY
		Intent.SELL:
			color = COLOR_SELL
	_fill_circle(image, 32, 32, 30, Color(0.08, 0.08, 0.09, 0.92))
	_fill_circle(image, 32, 32, 26, color)
	match next:
		Intent.BUY:
			_draw_bag(image)
		Intent.SELL:
			_draw_tag(image)
		_:
			_draw_magnifier(image)
	return ImageTexture.create_from_image(image)


func _draw_magnifier(image: Image) -> void:
	var ink := Color(0.10, 0.11, 0.12, 1.0)
	_fill_circle(image, 28, 26, 12, ink)
	_fill_circle(image, 28, 26, 7, COLOR_BROWSE)
	_fill_rect(image, 36, 36, 12, 5, ink)


func _draw_bag(image: Image) -> void:
	var ink := Color(0.08, 0.14, 0.14, 1.0)
	_fill_rect(image, 20, 28, 24, 20, ink)
	_fill_rect(image, 24, 18, 5, 12, ink)
	_fill_rect(image, 35, 18, 5, 12, ink)


func _draw_tag(image: Image) -> void:
	var ink := Color(0.18, 0.10, 0.04, 1.0)
	_fill_rect(image, 22, 18, 20, 28, ink)
	_fill_circle(image, 32, 26, 4, COLOR_SELL)
	_fill_rect(image, 28, 34, 8, 4, COLOR_SELL)


func _fill_circle(image: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	var r2 := radius * radius
	for y: int in range(cy - radius, cy + radius + 1):
		for x: int in range(cx - radius, cx + radius + 1):
			if x < 0 or y < 0 or x >= SIZE_PX or y >= SIZE_PX:
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
			if x < 0 or y < 0 or x >= SIZE_PX or y >= SIZE_PX:
				continue
			image.set_pixel(x, y, color)
