extends Control

const W = 256
const H = 144
const APERTURES = [2.8, 4.0, 5.6, 8.0, 11.0]
const SHUTTERS = [1.0 / 1000.0, 1.0 / 250.0, 1.0 / 60.0, 1.0 / 15.0]
const ISOS = [100, 200, 400, 800, 1600]
const FOCUSES = ["前景卡片", "中景花瓶", "背景转盘"]
const TASKS = [
	{"title": "01 / 找到焦点", "text": "拍清中间的花瓶，并保持照片亮度适中。试试改变对焦位置。", "hint": "花瓶在中景。调整对焦位置，观察前后的变化。"},
	{"title": "02 / 观察景深", "text": "同时拍清前景和背景的数字卡片，并保持亮度适中。", "hint": "试试对焦中景并缩小光圈；画面变暗时可以调整其他参数。"},
	{"title": "03 / 定格运动", "text": "拍清正在转动的转盘，让叶片形状清楚，并保持亮度适中。", "hint": "试试更快的快门，并对焦背景。"},
	{"title": "04 / 暗处拍摄", "text": "在暗光下拍清花瓶，让照片足够明亮，且噪点不过度影响细节。", "hint": "静物允许使用较慢的快门；也可以比较不同 ISO 的结果。"}
]

var aperture_index = 2
var shutter_index = 2
var iso_index = 2
var focus_index = 1
var task_index = 0
var preview: TextureRect
var result_image: TextureRect
var task_title: Label
var task_text: Label
var result_label: Label
var shot_label: Label
var hint_label: Label
var capture_button: Button
var next_button: Button
var choices = {}
var completed = [false, false, false, false]
var result_count = 0
var _next_fan_angle = 0.0
var preview_clock = 0.0


func _ready() -> void:
	_setup_theme()
	_build_ui()
	_refresh_task()
	_update_preview()


func _process(delta: float) -> void:
	preview_clock += delta
	if preview_clock >= 0.75:
		preview_clock = 0.0
		_next_fan_angle += 0.65
		_update_preview()


func _setup_theme() -> void:
	var app_theme = Theme.new()
	var font = SystemFont.new()
	font.font_names = PackedStringArray(["Microsoft YaHei", "Microsoft YaHei UI", "Noto Sans CJK SC", "Arial"])
	app_theme.default_font = font
	app_theme.default_font_size = 16
	app_theme.set_color("font_color", "Label", Color("e8edf3"))
	app_theme.set_color("font_color", "Button", Color("e8edf3"))
	app_theme.set_color("font_hover_color", "Button", Color("ffffff"))
	app_theme.set_color("font_pressed_color", "Button", Color("ffffff"))
	app_theme.set_color("font_disabled_color", "Button", Color("75808e"))
	app_theme.set_stylebox("normal", "Button", _style(Color("303c4c"), Color("536176"), 5))
	app_theme.set_stylebox("hover", "Button", _style(Color("42526a"), Color("87a2c4"), 5))
	app_theme.set_stylebox("pressed", "Button", _style(Color("1f2936"), Color("91b7df"), 5))
	app_theme.set_stylebox("disabled", "Button", _style(Color("252d38"), Color("35404e"), 5))
	theme = app_theme


func _style(bg: Color, border: Color, radius: int = 0) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box


func _label(text: String, size: int = 16, color: String = "e8edf3") -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(color))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _panel(parent: Node, bg: String = "202936") -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(Color(bg), Color("354354"), 7))
	parent.add_child(panel)
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	panel.add_child(content)
	return content


func _build_ui() -> void:
	var background = ColorRect.new()
	background.color = Color("111821")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)
	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)
	var top = HBoxContainer.new()
	root.add_child(top)
	var title = _label("摄影实验室", 28, "f3e3ba")
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var subtitle = _label("摄影棚原型  /  用照片探索相机参数", 14, "9eafc0")
	subtitle.autowrap_mode = TextServer.AUTOWRAP_OFF
	top.add_child(subtitle)

	var body = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 14)
	root.add_child(body)
	var left = VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.9
	left.add_theme_constant_override("separation", 10)
	body.add_child(left)
	var right = VBoxContainer.new()
	right.custom_minimum_size.x = 350
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0
	right.add_theme_constant_override("separation", 10)
	body.add_child(right)

	var view_panel = _panel(left, "19232d")
	view_panel.add_child(_label("取景器  /  拍照时画面会固定", 16, "e6c98a"))
	preview = TextureRect.new()
	preview.custom_minimum_size = Vector2(640, 360)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	view_panel.add_child(preview)
	view_panel.add_child(_label("前景：数字 2   ·   中景：花瓶   ·   背景：数字 8 和旋转转盘", 13, "9eafc0"))

	var camera = _panel(left)
	camera.add_child(_label("相机设置", 18, "f3e3ba"))
	var camera_row = HBoxContainer.new()
	camera_row.add_theme_constant_override("separation", 8)
	camera.add_child(camera_row)
	_add_choice(camera_row, "光圈", "aperture", ["f/2.8", "f/4", "f/5.6", "f/8", "f/11"], aperture_index)
	_add_choice(camera_row, "快门", "shutter", ["1/1000 秒", "1/250 秒", "1/60 秒", "1/15 秒"], shutter_index)
	_add_choice(camera_row, "ISO", "iso", ["100", "200", "400", "800", "1600"], iso_index)
	_add_choice(camera_row, "对焦位置", "focus", FOCUSES, focus_index)
	var buttons = HBoxContainer.new()
	camera.add_child(buttons)
	capture_button = Button.new()
	capture_button.text = "拍照并检查任务"
	capture_button.custom_minimum_size = Vector2(200, 45)
	capture_button.pressed.connect(_capture)
	buttons.add_child(capture_button)
	var reset_button = Button.new()
	reset_button.text = "重置参数"
	reset_button.pressed.connect(_reset_settings)
	buttons.add_child(reset_button)

	var task_panel = _panel(right)
	task_title = _label("", 20, "f3e3ba")
	task_panel.add_child(task_title)
	task_text = _label("", 15)
	task_panel.add_child(task_text)
	hint_label = _label("", 13, "9eafc0")
	task_panel.add_child(hint_label)
	var task_controls = HBoxContainer.new()
	task_panel.add_child(task_controls)
	var prev_button = Button.new()
	prev_button.text = "上一项"
	prev_button.pressed.connect(_previous_task)
	task_controls.add_child(prev_button)
	next_button = Button.new()
	next_button.text = "下一项"
	next_button.pressed.connect(_next_task)
	task_controls.add_child(next_button)

	var result_panel = _panel(right)
	result_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result_panel.add_child(_label("拍摄结果", 18, "f3e3ba"))
	result_image = TextureRect.new()
	result_image.custom_minimum_size = Vector2(300, 170)
	result_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	result_panel.add_child(result_image)
	shot_label = _label("按下拍照后，照片和参数会保留在这里。", 13, "aab8c8")
	result_panel.add_child(shot_label)
	result_label = _label("提示：调整参数后，先观察左侧取景器，再拍照。", 15)
	result_panel.add_child(result_label)
	result_panel.add_child(_label("说明：这是教学用的简化模拟，不代表真实相机的精确测量。", 12, "889aaa"))


func _add_choice(parent: Node, title: String, key: String, values: Array, selected: int) -> void:
	var column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(column)
	column.add_child(_label(title, 14, "aab8c8"))
	var choice = OptionButton.new()
	choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for value in values:
		choice.add_item(str(value))
	choice.select(selected)
	choice.item_selected.connect(_choice_changed.bind(key))
	choices[key] = choice
	column.add_child(choice)


func _choice_changed(index: int, key: String) -> void:
	match key:
		"aperture": aperture_index = index
		"shutter": shutter_index = index
		"iso": iso_index = index
		"focus": focus_index = index
	_update_preview()


func _reset_settings() -> void:
	aperture_index = 2
	shutter_index = 2
	iso_index = 2
	focus_index = 1
	choices["aperture"].select(aperture_index)
	choices["shutter"].select(shutter_index)
	choices["iso"].select(iso_index)
	choices["focus"].select(focus_index)
	_update_preview()


func _previous_task() -> void:
	task_index = maxi(0, task_index - 1)
	_refresh_task()
	result_label.text = "任务已切换。调整参数后拍照，查看本次结果。"
	_update_preview()


func _next_task() -> void:
	if completed[task_index] and task_index < TASKS.size() - 1:
		task_index += 1
		_refresh_task()
		result_label.text = "任务已切换。调整参数后拍照，查看本次结果。"
		_update_preview()


func _refresh_task() -> void:
	var task = TASKS[task_index]
	task_title.text = task["title"]
	task_text.text = task["text"]
	hint_label.text = "提示：" + task["hint"]
	if task_index == 3:
		hint_label.text += "\n本任务的摄影棚灯光已调暗。"
	next_button.disabled = not completed[task_index] or task_index == TASKS.size() - 1
	if task_index == TASKS.size() - 1 and completed[task_index]:
		next_button.text = "教程已完成"
	else:
		next_button.text = "下一项"


func _exposure() -> float:
	var light = 0.18 if task_index == 3 else 1.0
	return light * pow(2.8 / float(APERTURES[aperture_index]), 2.0) * (float(SHUTTERS[shutter_index]) / (1.0 / 60.0)) * (float(ISOS[iso_index]) / 100.0)


func _blur_amount(object_depth: int) -> float:
	var aperture = float(APERTURES[aperture_index])
	return absf(float(object_depth - focus_index)) * 3.0 / aperture


func _noise_strength() -> float:
	var iso_factor = float(ISOS[iso_index]) / 100.0
	var low_light_factor = 1.7 if task_index == 3 else 0.65
	return clampf((sqrt(iso_factor) - 1.0) * 0.035 * low_light_factor, 0.0, 0.23)


func _update_preview() -> void:
	var image = _render_photo(false)
	preview.texture = ImageTexture.create_from_image(image)


func _capture() -> void:
	_next_fan_angle += 1.3
	var image = _render_photo(true)
	result_image.texture = ImageTexture.create_from_image(image)
	result_count += 1
	shot_label.text = "第 %d 张  ·  f/%s  ·  %s  ·  ISO %d\n对焦：%s" % [result_count, str(APERTURES[aperture_index]), choices["shutter"].get_item_text(shutter_index), ISOS[iso_index], FOCUSES[focus_index]]
	var checks = _evaluate()
	var all_ok = true
	var lines = PackedStringArray()
	for check in checks:
		var ok = check[0]
		all_ok = all_ok and ok
		lines.append(("✓ " if ok else "✗ ") + check[1])
	if all_ok:
		completed[task_index] = true
		result_label.text = "拍摄成功！\n" + "\n".join(lines)
		if task_index < TASKS.size() - 1:
			result_label.text += "\n可以继续下一项。"
		else:
			result_label.text += "\n你完成了全部摄影棚挑战！"
	else:
		result_label.text = "再试一次\n" + "\n".join(lines)
	_refresh_task()
	_update_preview()


func _evaluate() -> Array:
	var exposure = _exposure()
	var bright_enough = exposure >= 0.18
	var not_blown = exposure <= 2.5
	var checks = []
	match task_index:
		0:
			checks.append([_blur_amount(1) <= 0.7, "花瓶清晰" if _blur_amount(1) <= 0.7 else "花瓶有些模糊：试试对焦中景"])
		1:
			var both_clear = _blur_amount(0) <= 0.7 and _blur_amount(2) <= 0.7
			checks.append([both_clear, "前后卡片都清晰" if both_clear else "前后卡片尚未同时清晰：试试缩小光圈"])
		2:
			checks.append([_blur_amount(2) <= 0.7, "转盘对焦清晰" if _blur_amount(2) <= 0.7 else "转盘失焦：试试对焦背景"])
			checks.append([float(SHUTTERS[shutter_index]) <= 1.0 / 250.0, "转盘叶片已定格" if float(SHUTTERS[shutter_index]) <= 1.0 / 250.0 else "叶片有运动模糊：试试更快的快门"])
		3:
			checks.append([_blur_amount(1) <= 0.7, "花瓶清晰" if _blur_amount(1) <= 0.7 else "花瓶有些模糊：试试对焦中景"])
			checks.append([_noise_strength() <= 0.13, "噪点没有严重影响细节" if _noise_strength() <= 0.13 else "噪点过多：试试降低 ISO"])
	checks.append([bright_enough, "亮度足够" if bright_enough else "照片过暗：试试增加曝光"])
	checks.append([not_blown, "没有明显过曝" if not_blown else "照片过曝：试试减少曝光"])
	return checks


func _render_photo(is_capture: bool) -> Image:
	var img = Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("526877"))
	_rect(img, 0, 0, W, 88, "607d85")
	_rect(img, 0, 15, W, 3, "9eb4aa")
	_rect(img, 0, 88, W, 56, "665449")
	_rect(img, 0, 88, W, 5, "94705a")
	_rect(img, 8, 22, 39, 57, "465e67")
	_rect(img, 11, 25, 33, 51, "b4c9c1")
	_rect(img, 25, 25, 4, 51, "789893")
	_rect(img, 11, 48, 33, 3, "789893")
	_rect(img, 158, 28, 29, 36, "8e6b4b")
	_rect(img, 161, 31, 23, 30, "e2ce9c")
	_digit(img, 168, 37, "8", Color("3c4e51"), 3)
	_draw_fan(img, _next_fan_angle)
	# The focused objects have simplified scene depths: near, middle and far.
	_rect(img, 102, 103, 46, 8, "3b3f42")
	_rect(img, 111, 77, 28, 26, "b88460")
	_rect(img, 115, 70, 20, 12, "d7a77c")
	_rect(img, 119, 67, 12, 4, "ecc5a0")
	_rect(img, 115, 84, 20, 3, "f0ca94")
	_rect(img, 118, 91, 14, 3, "f0ca94")
	_rect(img, 25, 86, 38, 44, "a67f52")
	_rect(img, 28, 89, 32, 38, "e8d6a5")
	_digit(img, 36, 95, "2", Color("3c4e51"), 4)
	_blur_region(img, Rect2i(24, 85, 40, 46), _blur_amount(0))
	_blur_region(img, Rect2i(101, 66, 48, 46), _blur_amount(1))
	_blur_region(img, Rect2i(157, 27, 31, 38), _blur_amount(2))
	_blur_region(img, Rect2i(189, 30, 55, 68), _blur_amount(2))
	_apply_exposure(img, _exposure(), _noise_strength(), is_capture)
	return img


func _rect(img: Image, x: int, y: int, width: int, height: int, hex: String) -> void:
	img.fill_rect(Rect2i(x, y, width, height), Color(hex))


func _digit(img: Image, x: int, y: int, digit: String, color: Color, scale: int) -> void:
	var pattern = ["111", "001", "111", "100", "111"] if digit == "2" else ["111", "101", "111", "101", "111"]
	for row in range(5):
		for col in range(3):
			if pattern[row][col] == "1":
				img.fill_rect(Rect2i(x + col * scale, y + row * scale, scale, scale), color)


func _draw_fan(img: Image, angle: float) -> void:
	_rect(img, 211, 80, 9, 23, "384c54")
	_rect(img, 202, 101, 28, 5, "344249")
	var shutter = float(SHUTTERS[shutter_index])
	var motion = minf(shutter * 18.0, 1.6)
	for y in range(34, 84):
		for x in range(190, 240):
			var dx = float(x - 215)
			var dy = float(y - 59)
			var distance = sqrt(dx * dx + dy * dy)
			if distance > 23.0:
				continue
			if distance > 21.0:
				img.set_pixel(x, y, Color("334b56"))
				continue
			var blade = 0.0
			var sample_count = 5
			for s in range(sample_count):
				var a = atan2(dy, dx) - angle - motion * (float(s) / float(sample_count - 1) - 0.5)
				if distance < 19.0 and cos(a * 3.0) > 0.52:
					blade += 1.0 / float(sample_count)
			var c = Color("c4c6a6").lerp(Color("587879"), blade)
			if distance < 4.0:
				c = Color("d9ab70")
			img.set_pixel(x, y, c)


func _blur_region(img: Image, area: Rect2i, amount: float) -> void:
	if amount <= 0.35:
		return
	var source = Image.create_from_data(W, H, false, Image.FORMAT_RGBA8, img.get_data())
	var radius = clampi(int(ceil(amount * 2.0)), 1, 4)
	var mix_amount = clampf((amount - 0.25) * 0.8, 0.0, 0.9)
	for y in range(area.position.y, area.end.y):
		for x in range(area.position.x, area.end.x):
			var center = source.get_pixel(x, y)
			var blur = (source.get_pixel(clampi(x - radius, 0, W - 1), y) + source.get_pixel(clampi(x + radius, 0, W - 1), y) + source.get_pixel(x, clampi(y - radius, 0, H - 1)) + source.get_pixel(x, clampi(y + radius, 0, H - 1))) / 4.0
			img.set_pixel(x, y, center.lerp(blur, mix_amount))


func _apply_exposure(img: Image, exposure: float, noise: float, is_capture: bool) -> void:
	var brightness = pow(maxf(exposure, 0.0), 0.65)
	var rng = RandomNumberGenerator.new()
	rng.seed = 73 + (result_count if is_capture else 0)
	for y in range(H):
		for x in range(W):
			var c = img.get_pixel(x, y)
			var grain = rng.randf_range(-noise, noise)
			img.set_pixel(x, y, Color(clampf(c.r * brightness + grain, 0.0, 1.0), clampf(c.g * brightness + grain, 0.0, 1.0), clampf(c.b * brightness + grain, 0.0, 1.0), 1.0))
