extends Control

const W = 512
const H = 288
const DRAW_SCALE = 2
const BASE_W = 256
const STUDIO_ART = preload("res://assets/scenes/studio.png")
const GARDEN_ART = preload("res://assets/scenes/garden.png")
const PIXEL_FONT = preload("res://assets/fonts/fusion-pixel-12px-proportional-zh_hans.otf")
const SCENE_SIZE = Vector2i(512, 288)
const STUDIO_VASE = Rect2i(240, 142, 26, 32)
const STUDIO_FRONT_CARD = Rect2i(115, 184, 29, 38)
const STUDIO_BACK_CARD = Rect2i(335, 75, 30, 38)
const STUDIO_FAN = Rect2i(421, 107, 38, 38)
const LENS_GROUPS = [
	{"name": "广角—标准 25–70mm", "min": 25, "max": 70},
	{"name": "中长焦 70–200mm", "min": 70, "max": 200},
	{"name": "超长焦 200–1000mm", "min": 200, "max": 1000}
]
const SCENE_NAMES = ["摄影棚", "窗边花园", "窗边近景"]
const SCENE_LINKS = [
	{"right": 1},
	{"left": 0, "up": 2},
	{"down": 1}
]
const APERTURES = [2.8, 4.0, 5.6, 8.0, 11.0]
const SHUTTERS = [1.0 / 1000.0, 1.0 / 250.0, 1.0 / 60.0, 1.0 / 15.0]
const ISOS = [100, 200, 400, 800, 1600]
const LEVELS = [
	{"title": "教学关 / 摄影入门", "first_task": 0, "last_task": 4, "first_scene": 0, "scenes": [0, 1, 2], "lens_groups": [0, 1, 2]}
]
const TASKS = [
	{"title": "01 / 找到焦点", "text": "拍清中间的花瓶，并保持照片亮度适中。试试改变对焦位置。", "hint": "花瓶在中景。调整对焦位置，观察前后的变化。"},
	{"title": "02 / 观察景深", "text": "同时拍清前景和背景的数字卡片，并保持亮度适中。", "hint": "试试对焦中景并缩小光圈；画面变暗时可以调整其他参数。"},
	{"title": "03 / 定格运动", "text": "拍清正在转动的转盘，让叶片形状清楚，并保持亮度适中。", "hint": "试试更快的快门，并对焦背景。"},
	{"title": "04 / 暗处拍摄", "text": "在暗光下拍清花瓶，让照片足够明亮，且噪点不过度影响细节。", "hint": "静物允许使用较慢的快门；也可以比较不同 ISO 的结果。"},
	{"title": "05 / 寻找窗边的花", "text": "到窗边花园拍一张花的照片，让花大部分入画并保持亮度适中。", "hint": "点击画面右侧箭头前往花园，在花附近右键拍摄。花在中景。", "resume_scene": 1}
]
const MANUAL_TOPICS = [
	{"title": "基本操作", "text": "点击画面边缘的箭头，切换到相邻场景或靠近目标。\n\n在场景中右键，再点击“拍摄此处”打开相机。拖动取景画面可调整构图；拖动窗口标题栏可移动相机。\n\n拍照后查看任务反馈；照片需要手动点击保存。按 Esc 可暂停、查看照片或查阅手册。"},
	{"title": "曝光", "text": "曝光与拍摄时传感器接收的光有关。光圈、快门速度和现场光线共同影响曝光；调整 ISO 也会影响照片的最终亮度。\n\n画面过暗或过亮时，可以试着搭配调整这些参数。本游戏使用便于观察的简化亮度模拟。"},
	{"title": "光圈与景深", "text": "光圈控制镜头的进光开口。f 值越小，光圈开口越大，通常进光越多；f 值越大，开口越小，进光越少。\n\n景深是画面中看起来足够清晰的距离范围。其他条件相同时，缩小光圈（增大 f 值）通常会让景深变深。\n\n对焦决定清晰的位置；光圈影响其前后清晰范围。游戏中的景深是简化模拟。"},
	{"title": "快门速度", "text": "快门速度决定曝光持续的时间。1/1000 秒比 1/60 秒更短，更有助于定格运动，但其他条件相同时进光较少。\n\n较慢的快门能记录更多光，也更容易出现运动模糊。试着拍摄摄影棚里的转盘，比较叶片的变化。"},
	{"title": "ISO 与噪点", "text": "ISO 影响相机输出画面的亮度；提高 ISO 通常能让照片更亮，但噪点也可能更明显。\n\n提高 ISO 不会让镜头接收到更多光。暗光下可以结合快门与光圈调整，再观察亮度和细节之间的取舍。游戏里的噪点效果经过简化。"},
	{"title": "对焦", "text": "对焦决定相机在哪个距离附近成像最清晰。移动对焦环或滑块时，清晰的位置会随之改变。\n\n本游戏用 0 至 2 表示相对位置：0 靠近前景，1 为中景，2 靠近背景；它们不是以米计算的真实距离。场景目前分层模拟模糊。"},
	{"title": "焦距与镜头", "text": "在相同画幅下，较短焦距提供较宽视角；较长焦距提供较窄视角，让画面中的目标看起来更大。\n\n先选择镜头组，再拖动滑块调整焦距。当前 2D 原型使用裁切模拟视角，不模拟真实的空间透视；长焦会放大现有像素。"},
	{"title": "构图与任务", "text": "构图是决定把什么放进画面，以及如何安排它们的位置。右键选择拍摄中心后，仍可以拖动取景画面微调。\n\n任务可能要求目标大部分入画、对焦清晰或亮度合适。拍照结果会分别列出通过与未通过的条件。"},
	{"title": "照片与进度", "text": "拍照后点击“保存照片”，才会保存 PNG 文件；按 Esc 后选择“查看已保存的照片”可以浏览。\n\n照片位于游戏程序旁的 Photos 文件夹；关卡和任务进度保存在程序旁的 GameProgress 文件夹。移动游戏时可一同复制这两个文件夹。"}
]

var aperture_index = 2
var shutter_index = 2
var iso_index = 2
var focus_position = 1.0
var task_index = 0
var level_index = 0
var scene_index = 0
var lens_group_index = 0
var focal_length = 35
var view_center = Vector2(256, 144)
var camera_active = false
var dragging_view = false
var dragging_camera_window = false
var dragging_result_window = false
var pending_camera_center = Vector2.ZERO
var scene_view: TextureRect
var camera_menu: Button
var camera_panel: PanelContainer
var camera_header: HBoxContainer
var result_header: HBoxContainer
var focus_slider: HSlider
var focus_label: Label
var focal_slider: HSlider
var lens_choice: OptionButton
var task_panel: PanelContainer
var result_panel: PanelContainer
var task_button: Button
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
var completed: Array = []
var result_count = 0
var last_photo: Image
var photo_directory_override = "" # Used only by automated tests.
var progress_directory_override = "" # Used only by automated tests.
var progress_error = ""
var progress_read_blocked = false
var has_saved_progress = false
var _next_fan_angle = 0.0
var preview_clock = 0.0
var scene_label: Label
var left_arrow: Button
var right_arrow: Button
var up_arrow: Button
var down_arrow: Button
var title_screen: Control
var title_menu: VBoxContainer
var level_menu: VBoxContainer
var level_buttons: Array[Button] = []
var save_button: Button
var save_status: Label
var title_start_button: Button
var title_footer: Label
var pause_overlay: Control
var pause_menu: VBoxContainer
var album_menu: VBoxContainer
var album_image: TextureRect
var album_status: Label
var album_prev: Button
var album_next: Button
var album_back: Button
var album_files: PackedStringArray = []
var album_index = 0
var resume_button: Button
var pause_title_button: Button
var manual_overlay: Control
var manual_title: Label
var manual_body: Label
var manual_back: Button
var manual_from_title = false
var manual_buttons: Array[Button] = []
var title_manual_button: Button
var pause_manual_button: Button


func _ready() -> void:
	completed.resize(TASKS.size())
	completed.fill(false)
	_setup_theme()
	_build_ui()
	_load_progress()
	_refresh_task()
	_update_scene()
	_update_preview()
	_show_title()


func _process(delta: float) -> void:
	if pause_overlay.visible or manual_overlay.visible:
		return
	preview_clock += delta
	if preview_clock >= 0.75:
		preview_clock = 0.0
		_next_fan_angle += 0.65
		_update_scene()
		_update_preview()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if manual_overlay.visible:
			_close_manual()
			get_viewport().set_input_as_handled()
			return
		if title_screen.visible:
			return
		if pause_overlay.visible:
			if album_menu.visible:
				_show_pause_menu()
			else:
				_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()


func _setup_theme() -> void:
	var app_theme = Theme.new()
	var font: FontFile = PIXEL_FONT
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	font.disable_embedded_bitmaps = false
	app_theme.default_font = font
	app_theme.default_font_size = 16
	app_theme.set_color("font_color", "Label", Color("f2e5c6"))
	app_theme.set_color("font_color", "Button", Color("f2e5c6"))
	app_theme.set_color("font_hover_color", "Button", Color("fff4d7"))
	app_theme.set_color("font_pressed_color", "Button", Color("fff4d7"))
	app_theme.set_color("font_disabled_color", "Button", Color("879385"))
	app_theme.set_stylebox("normal", "Button", _style(Color("344c45"), Color("a9b59a")))
	app_theme.set_stylebox("hover", "Button", _style(Color("577163"), Color("e8c589")))
	app_theme.set_stylebox("pressed", "Button", _style(Color("253d38"), Color("f0cb8f")))
	app_theme.set_stylebox("disabled", "Button", _style(Color("293b36"), Color("56685c")))
	app_theme.set_stylebox("panel", "PopupMenu", _style(Color("243c36"), Color("b5be9e")))
	app_theme.set_stylebox("hover", "PopupMenu", _style(Color("577163"), Color("e8c589")))
	app_theme.set_color("font_color", "PopupMenu", Color("f2e5c6"))
	app_theme.set_color("font_hover_color", "PopupMenu", Color("fff4d7"))
	var track = StyleBoxFlat.new()
	track.bg_color = Color("344c45")
	track.border_color = Color("a9b59a")
	track.set_border_width_all(1)
	track.content_margin_top = 3
	track.content_margin_bottom = 3
	app_theme.set_stylebox("slider", "HSlider", track)
	var slider_handle = Image.create(12, 20, false, Image.FORMAT_RGBA8)
	slider_handle.fill(Color("304c43"))
	slider_handle.fill_rect(Rect2i(2, 2, 8, 16), Color("e4c28a"))
	var handle_texture = ImageTexture.create_from_image(slider_handle)
	app_theme.set_icon("grabber", "HSlider", handle_texture)
	app_theme.set_icon("grabber_highlight", "HSlider", handle_texture)
	theme = app_theme


func _style(bg: Color, border: Color, _radius: int = 0) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(2)
	box.set_corner_radius_all(0)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box


func _label(text: String, size: int = 16, color: String = "f2e5c6") -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(color))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _panel(parent: Node, bg: String = "243c36") -> VBoxContainer:
	var panel = PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _style(Color(bg), Color("b5be9e")))
	parent.add_child(panel)
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	panel.add_child(content)
	return content


func _build_ui() -> void:
	# The scene is the backdrop; every interface panel floats above it.
	scene_view = TextureRect.new()
	add_child(scene_view)
	scene_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene_view.stretch_mode = TextureRect.STRETCH_SCALE
	scene_view.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	scene_view.mouse_filter = Control.MOUSE_FILTER_STOP
	scene_view.gui_input.connect(_scene_input)

	left_arrow = _scene_arrow("◀", "left", Control.PRESET_CENTER_LEFT, Vector2(18, -30), Vector2(78, 30))
	right_arrow = _scene_arrow("▶", "right", Control.PRESET_CENTER_RIGHT, Vector2(-78, -30), Vector2(-18, 30))
	up_arrow = _scene_arrow("↑ 走近", "up", Control.PRESET_CENTER_TOP, Vector2(-55, 18), Vector2(55, 64))
	down_arrow = _scene_arrow("↓ 后退", "down", Control.PRESET_CENTER_BOTTOM, Vector2(-55, -64), Vector2(55, -18))
	# Kept for the existing scene navigation state, without covering the backdrop.
	scene_label = _label("", 14)
	scene_label.visible = false
	add_child(scene_label)

	task_button = Button.new()
	task_button.text = "任务 ▾"
	task_button.position = Vector2(18, 18)
	task_button.custom_minimum_size = Vector2(112, 46)
	task_button.pressed.connect(_toggle_tasks)
	add_child(task_button)

	var task_content = _panel(self)
	task_panel = task_content.get_parent()
	task_panel.position = Vector2(18, 70)
	task_panel.size = Vector2(370, 240)
	var task_header = HBoxContainer.new()
	task_content.add_child(task_header)
	task_title = _label("", 20, "f3e5bf")
	task_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	task_header.add_child(task_title)
	var close_task = Button.new()
	close_task.text = "关闭"
	close_task.pressed.connect(_close_tasks)
	task_header.add_child(close_task)
	task_text = _label("", 15)
	task_content.add_child(task_text)
	hint_label = _label("", 13, "b7c9a7")
	task_content.add_child(hint_label)
	task_content.add_child(_label("在场景中右键选择拍摄；取景器内可拖动构图。", 12, "b7c9a7"))
	var task_controls = HBoxContainer.new()
	task_content.add_child(task_controls)
	var prev_button = Button.new()
	prev_button.text = "上一项"
	prev_button.pressed.connect(_previous_task)
	task_controls.add_child(prev_button)
	next_button = Button.new()
	next_button.text = "下一项"
	next_button.pressed.connect(_next_task)
	task_controls.add_child(next_button)
	task_panel.hide()

	var camera = _panel(self)
	camera_panel = camera.get_parent()
	camera_panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	camera_panel.offset_left = -478
	camera_panel.offset_right = -18
	camera_panel.offset_top = -325
	camera_panel.offset_bottom = 325
	camera_header = HBoxContainer.new()
	camera.add_child(camera_header)
	camera_header.mouse_filter = Control.MOUSE_FILTER_STOP
	camera_header.mouse_default_cursor_shape = Control.CURSOR_MOVE
	camera_header.gui_input.connect(_camera_header_input)
	var camera_title = _label("取景器  ·  拖动此处移动窗口", 18, "f3e5bf")
	camera_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	camera_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	camera_header.add_child(camera_title)
	var close_camera_button = Button.new()
	close_camera_button.text = "关闭"
	close_camera_button.pressed.connect(_close_camera)
	camera_header.add_child(close_camera_button)
	var frame = AspectRatioContainer.new()
	frame.ratio = float(W) / H
	frame.custom_minimum_size = Vector2(390, 210)
	camera.add_child(frame)
	var screen = ColorRect.new()
	screen.color = Color.BLACK
	frame.add_child(screen)
	preview = TextureRect.new()
	screen.add_child(preview)
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview.mouse_filter = Control.MOUSE_FILTER_STOP
	preview.gui_input.connect(_viewfinder_input)
	camera.add_child(_label("相机参数（仅影响取景器）", 14, "c5d0ae"))
	var camera_row = HBoxContainer.new()
	camera_row.add_theme_constant_override("separation", 8)
	camera.add_child(camera_row)
	_add_choice(camera_row, "光圈", "aperture", ["f/2.8", "f/4", "f/5.6", "f/8", "f/11"], aperture_index)
	_add_choice(camera_row, "快门", "shutter", ["1/1000 秒", "1/250 秒", "1/60 秒", "1/15 秒"], shutter_index)
	_add_choice(camera_row, "ISO", "iso", ["100", "200", "400", "800", "1600"], iso_index)
	focus_label = _label("", 14, "c5d0ae")
	camera.add_child(focus_label)
	focus_slider = HSlider.new()
	focus_slider.min_value = 0.0
	focus_slider.max_value = 2.0
	focus_slider.step = 0.01
	focus_slider.value = focus_position
	focus_slider.custom_minimum_size.y = 20
	focus_slider.value_changed.connect(_focus_changed)
	camera.add_child(focus_slider)
	var lens_row = HBoxContainer.new()
	camera.add_child(lens_row)
	lens_choice = OptionButton.new()
	lens_choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lens_choice.fit_to_longest_item = false
	lens_choice.clip_text = true
	lens_choice.item_selected.connect(_lens_group_changed)
	lens_row.add_child(lens_choice)
	focal_slider = HSlider.new()
	focal_slider.step = 1
	focal_slider.custom_minimum_size.y = 20
	focal_slider.value_changed.connect(_focal_changed)
	camera.add_child(focal_slider)
	_configure_lenses()
	var camera_buttons = HBoxContainer.new()
	camera.add_child(camera_buttons)
	capture_button = Button.new()
	capture_button.text = "拍照并检查任务"
	capture_button.custom_minimum_size = Vector2(160, 40)
	capture_button.disabled = true
	capture_button.pressed.connect(_capture)
	camera_buttons.add_child(capture_button)
	var reset_button = Button.new()
	reset_button.text = "重置参数"
	reset_button.pressed.connect(_reset_settings)
	camera_buttons.add_child(reset_button)
	camera_panel.hide()

	var result = _panel(self)
	result_panel = result.get_parent()
	result_panel.set_anchors_preset(Control.PRESET_CENTER)
	result_panel.offset_left = -245
	result_panel.offset_right = 245
	result_panel.offset_top = -265
	result_panel.offset_bottom = 265
	result_header = HBoxContainer.new()
	result.add_child(result_header)
	result_header.mouse_filter = Control.MOUSE_FILTER_STOP
	result_header.mouse_default_cursor_shape = Control.CURSOR_MOVE
	result_header.gui_input.connect(_result_header_input)
	var result_title = _label("拍摄结果 · 拖动此处移动", 20, "f3e5bf")
	result_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_header.add_child(result_title)
	var close_result = Button.new()
	close_result.text = "关闭"
	close_result.pressed.connect(_close_result)
	result_header.add_child(close_result)
	result_image = TextureRect.new()
	result_image.custom_minimum_size = Vector2(270, 150)
	result_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	result.add_child(result_image)
	shot_label = _label("", 13, "c5d0ae")
	result.add_child(shot_label)
	result_label = _label("", 15)
	result.add_child(result_label)
	var save_row = HBoxContainer.new()
	result.add_child(save_row)
	save_button = Button.new()
	save_button.text = "保存照片"
	save_button.pressed.connect(_save_photo)
	save_row.add_child(save_button)
	save_status = _label("仅点击保存才会写入文件。", 13, "c7d0ae")
	save_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_row.add_child(save_status)
	result_panel.hide()

	camera_menu = Button.new()
	camera_menu.text = "拍摄此处"
	camera_menu.custom_minimum_size = Vector2(120, 42)
	camera_menu.pressed.connect(_on_camera_menu_selected)
	add_child(camera_menu)
	camera_menu.hide()
	_build_title_screen()
	_build_pause_menu()
	_build_manual()


func _build_title_screen() -> void:
	title_screen = Control.new()
	add_child(title_screen)
	title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop = TextureRect.new()
	title_screen.add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.texture = STUDIO_ART
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shade = ColorRect.new()
	shade.color = Color(0.07, 0.15, 0.13, 0.78)
	title_screen.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var accent = ColorRect.new()
	accent.color = Color("dbb47b")
	accent.position = Vector2(94, 164)
	accent.size = Vector2(8, 160)
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_screen.add_child(accent)
	var overline = _label("A PHOTOGRAPHY PUZZLE", 17, "b7c9a7")
	overline.name = "TitleOverline"
	overline.position = Vector2(122, 165)
	overline.autowrap_mode = TextServer.AUTOWRAP_OFF
	overline.size = Vector2(620, 30)
	title_screen.add_child(overline)
	var heading = _label("How to\nphotograph", 62, "f3e5bf")
	heading.name = "TitleHeading"
	heading.position = Vector2(120, 202)
	heading.size = Vector2(620, 160)
	title_screen.add_child(heading)
	var subtitle = _label("观察光线 · 调整镜头 · 留下瞬间", 18, "c5d0ae")
	subtitle.name = "TitleSubtitle"
	subtitle.position = Vector2(125, 390)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_OFF
	subtitle.size = Vector2(620, 30)
	title_screen.add_child(subtitle)
	title_footer = _label("游戏进度自动保存在游戏文件夹中", 14, "b0bfaa")
	title_footer.position = Vector2(125, 630)
	title_footer.size = Vector2(650, 50)
	title_screen.add_child(title_footer)
	var menu = _panel(title_screen, "1e3731")
	var menu_frame: PanelContainer = menu.get_parent()
	menu_frame.position = Vector2(805, 170)
	menu_frame.size = Vector2(330, 370)
	menu.add_child(_label("摄影委托", 22, "f3e5bf"))
	menu.add_child(_label("选择开始方式", 14, "b7c9a7"))
	title_menu = VBoxContainer.new()
	title_menu.add_theme_constant_override("separation", 12)
	menu.add_child(title_menu)
	title_start_button = Button.new()
	title_start_button.text = "开始游戏"
	title_start_button.custom_minimum_size.y = 48
	title_start_button.pressed.connect(_continue_game)
	title_menu.add_child(title_start_button)
	var choose = Button.new()
	choose.text = "选择关卡"
	choose.custom_minimum_size.y = 48
	choose.pressed.connect(_show_level_menu)
	title_menu.add_child(choose)
	title_manual_button = Button.new()
	title_manual_button.text = "游戏手册"
	title_manual_button.custom_minimum_size.y = 48
	title_manual_button.pressed.connect(_open_manual)
	title_menu.add_child(title_manual_button)
	var exit_button = Button.new()
	exit_button.text = "退出游戏"
	exit_button.custom_minimum_size.y = 48
	exit_button.pressed.connect(get_tree().quit)
	title_menu.add_child(exit_button)
	level_menu = VBoxContainer.new()
	level_menu.add_theme_constant_override("separation", 12)
	menu.add_child(level_menu)
	var level_scroll = ScrollContainer.new()
	level_scroll.custom_minimum_size.y = 200
	level_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	level_menu.add_child(level_scroll)
	var level_list = VBoxContainer.new()
	level_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_scroll.add_child(level_list)
	for level in range(LEVELS.size()):
		var level_button = Button.new()
		level_button.custom_minimum_size.y = 48
		level_button.pressed.connect(_start_level.bind(level))
		level_list.add_child(level_button)
		level_buttons.append(level_button)
	var back = Button.new()
	back.text = "返回"
	back.custom_minimum_size.y = 48
	back.pressed.connect(_show_main_menu)
	level_menu.add_child(back)
	level_menu.hide()


func _build_pause_menu() -> void:
	pause_overlay = Control.new()
	add_child(pause_overlay)
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var shade = ColorRect.new()
	shade.color = Color(0.03, 0.08, 0.07, 0.82)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var content = _panel(center, "1e3731")
	var panel: PanelContainer = content.get_parent()
	panel.custom_minimum_size = Vector2(650, 550)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu = VBoxContainer.new()
	pause_menu.add_theme_constant_override("separation", 14)
	content.add_child(pause_menu)
	pause_menu.add_child(_label("游戏暂停", 24, "f3e5bf"))
	pause_menu.add_child(_label("按 Esc 继续游戏", 15, "b7c9a7"))
	resume_button = Button.new()
	resume_button.text = "继续游戏"
	resume_button.custom_minimum_size.y = 50
	resume_button.pressed.connect(_resume_game)
	pause_menu.add_child(resume_button)
	var photos_button = Button.new()
	photos_button.text = "查看已保存的照片"
	photos_button.custom_minimum_size.y = 50
	photos_button.pressed.connect(_show_album)
	pause_menu.add_child(photos_button)
	pause_manual_button = Button.new()
	pause_manual_button.text = "游戏手册"
	pause_manual_button.custom_minimum_size.y = 50
	pause_manual_button.pressed.connect(_open_manual)
	pause_menu.add_child(pause_manual_button)
	pause_title_button = Button.new()
	pause_title_button.text = "返回标题"
	pause_title_button.custom_minimum_size.y = 50
	pause_title_button.pressed.connect(_show_title)
	pause_menu.add_child(pause_title_button)
	album_menu = VBoxContainer.new()
	album_menu.add_theme_constant_override("separation", 10)
	content.add_child(album_menu)
	album_menu.add_child(_label("已保存的照片", 22, "f3e5bf"))
	album_image = TextureRect.new()
	album_image.custom_minimum_size = Vector2(590, 330)
	album_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	album_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	album_image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	album_menu.add_child(album_image)
	album_status = _label("", 14, "c5d0ae")
	album_menu.add_child(album_status)
	var navigation = HBoxContainer.new()
	navigation.add_theme_constant_override("separation", 10)
	album_menu.add_child(navigation)
	album_prev = Button.new()
	album_prev.text = "上一张"
	album_prev.pressed.connect(_album_move.bind(-1))
	navigation.add_child(album_prev)
	album_next = Button.new()
	album_next.text = "下一张"
	album_next.pressed.connect(_album_move.bind(1))
	navigation.add_child(album_next)
	album_back = Button.new()
	album_back.text = "返回暂停菜单"
	album_back.pressed.connect(_show_pause_menu)
	navigation.add_child(album_back)
	album_menu.hide()
	pause_overlay.hide()


func _build_manual() -> void:
	manual_overlay = Control.new()
	add_child(manual_overlay)
	manual_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	manual_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var shade = ColorRect.new()
	shade.color = Color(0.03, 0.08, 0.07, 0.88)
	manual_overlay.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center = CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	manual_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var content = _panel(center, "1e3731")
	var panel: PanelContainer = content.get_parent()
	panel.custom_minimum_size = Vector2(980, 600)
	var header = HBoxContainer.new()
	content.add_child(header)
	var title = _label("游戏手册", 23, "f3e5bf")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	manual_back = Button.new()
	manual_back.text = "返回  Esc"
	manual_back.pressed.connect(_close_manual)
	header.add_child(manual_back)
	var columns = HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 18)
	content.add_child(columns)
	var topics_scroll = ScrollContainer.new()
	topics_scroll.custom_minimum_size.x = 190
	topics_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(topics_scroll)
	var topics = VBoxContainer.new()
	topics.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	topics_scroll.add_child(topics)
	for index in range(MANUAL_TOPICS.size()):
		var button = Button.new()
		button.text = MANUAL_TOPICS[index]["title"]
		button.toggle_mode = true
		button.custom_minimum_size.y = 42
		button.pressed.connect(_select_manual_topic.bind(index))
		topics.add_child(button)
		manual_buttons.append(button)
	var page = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 14)
	columns.add_child(page)
	manual_title = _label("", 22, "f3e5bf")
	page.add_child(manual_title)
	var page_scroll = ScrollContainer.new()
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(page_scroll)
	manual_body = _label("", 17, "dce1c6")
	manual_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.add_child(manual_body)
	manual_overlay.hide()


func _open_manual() -> void:
	manual_from_title = title_screen.visible
	manual_overlay.show()
	manual_overlay.move_to_front()
	_select_manual_topic(0)
	manual_back.grab_focus()


func _select_manual_topic(index: int) -> void:
	manual_title.text = MANUAL_TOPICS[index]["title"]
	manual_body.text = MANUAL_TOPICS[index]["text"]
	for i in manual_buttons.size():
		manual_buttons[i].button_pressed = i == index


func _close_manual() -> void:
	manual_overlay.hide()
	if manual_from_title:
		title_start_button.grab_focus()
	else:
		resume_button.grab_focus()


func _pause_game() -> void:
	dragging_view = false
	dragging_camera_window = false
	dragging_result_window = false
	pause_overlay.show()
	pause_overlay.move_to_front()
	_show_pause_menu()


func _resume_game() -> void:
	pause_overlay.hide()


func _show_pause_menu() -> void:
	album_menu.hide()
	pause_menu.show()
	resume_button.grab_focus()


func _show_album() -> void:
	pause_menu.hide()
	album_menu.show()
	album_back.grab_focus()
	album_files.clear()
	album_index = 0
	var folder = _photo_directory()
	if DirAccess.dir_exists_absolute(folder):
		var directory = DirAccess.open(folder)
		if directory == null:
			album_image.texture = null
			album_status.text = "无法读取 Photos 文件夹，请检查访问权限。"
			album_prev.disabled = true
			album_next.disabled = true
			return
		for filename in directory.get_files():
			if filename.get_extension().to_lower() == "png":
				album_files.append(filename)
		album_files.sort()
		album_files.reverse()
	_show_album_photo()


func _album_move(direction: int) -> void:
	if album_files.is_empty():
		return
	album_index = clampi(album_index + direction, 0, album_files.size() - 1)
	_show_album_photo()


func _show_album_photo() -> void:
	album_image.texture = null
	album_prev.disabled = album_index <= 0
	album_next.disabled = album_files.is_empty() or album_index >= album_files.size() - 1
	if album_files.is_empty():
		album_status.text = "还没有保存的照片。拍照后可在结果窗口选择保存。"
		return
	var filename = album_files[album_index]
	var photo = Image.new()
	if photo.load(_photo_directory().path_join(filename)) != OK:
		album_status.text = "无法打开照片：" + filename
		return
	album_image.texture = ImageTexture.create_from_image(photo)
	album_status.text = "%d / %d  ·  %s" % [album_index + 1, album_files.size(), filename]


func _show_title() -> void:
	if pause_overlay != null:
		pause_overlay.hide()
	camera_menu.hide()
	_close_camera()
	_close_result()
	task_panel.hide()
	title_start_button.text = "继续游戏" if has_saved_progress else "开始游戏"
	title_footer.text = progress_error if not progress_error.is_empty() else "游戏进度自动保存在游戏文件夹中"
	_show_main_menu()
	title_screen.show()
	title_screen.move_to_front()


func _show_main_menu() -> void:
	title_menu.show()
	level_menu.hide()


func _show_level_menu() -> void:
	for level in range(LEVELS.size()):
		var unlocked = _level_unlocked(level)
		level_buttons[level].disabled = not unlocked
		level_buttons[level].text = LEVELS[level]["title"] if unlocked else LEVELS[level]["title"] + "  /  尚未解锁"
	title_menu.hide()
	level_menu.show()


func _level_complete(level: int) -> bool:
	for index in range(LEVELS[level]["first_task"], LEVELS[level]["last_task"] + 1):
		if not completed[index]:
			return false
	return true


func _level_unlocked(level: int) -> bool:
	if level < 0 or level >= LEVELS.size():
		return false
	for previous in range(level):
		if not _level_complete(previous):
			return false
	return true


func _continue_game() -> void:
	_start_level(level_index, task_index)


func _start_level(level: int, resume_task: int = -1) -> void:
	if not _level_unlocked(level):
		return
	level_index = level
	task_index = resume_task if resume_task >= LEVELS[level]["first_task"] and resume_task <= LEVELS[level]["last_task"] else LEVELS[level]["first_task"]
	scene_index = LEVELS[level]["first_scene"]
	if resume_task >= 0:
		var resume_scene: int = TASKS[task_index].get("resume_scene", scene_index)
		if resume_scene in LEVELS[level]["scenes"]:
			scene_index = resume_scene
	view_center = Vector2(256, 144)
	camera_menu.hide()
	_close_camera()
	_close_result()
	task_panel.hide()
	last_photo = null
	_reset_settings()
	_save_progress()
	_refresh_task()
	_update_scene()
	title_screen.hide()


func _scene_arrow(text: String, direction: String, preset: Control.LayoutPreset, start_offset: Vector2, end_offset: Vector2) -> Button:
	var button = Button.new()
	button.text = text
	button.pressed.connect(_change_scene.bind(direction))
	add_child(button)
	button.set_anchors_preset(preset)
	button.offset_left = start_offset.x
	button.offset_top = start_offset.y
	button.offset_right = end_offset.x
	button.offset_bottom = end_offset.y
	return button


func _toggle_tasks() -> void:
	task_panel.visible = not task_panel.visible


func _close_tasks() -> void:
	task_panel.hide()


func _close_result() -> void:
	dragging_result_window = false
	result_panel.hide()

func _add_choice(parent: Node, title: String, key: String, values: Array, selected: int) -> void:
	var column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(column)
	column.add_child(_label(title, 14, "c5d0ae"))
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
	_update_preview()


func _configure_lenses() -> void:
	lens_choice.clear()
	for group_index in LEVELS[level_index]["lens_groups"]:
		lens_choice.add_item(LENS_GROUPS[group_index]["name"], group_index)
	lens_choice.select(0)
	_lens_group_changed(0)


func _lens_group_changed(index: int) -> void:
	lens_group_index = lens_choice.get_item_id(index)
	var group = LENS_GROUPS[lens_group_index]
	focal_slider.min_value = group["min"]
	focal_slider.max_value = group["max"]
	focal_slider.set_value_no_signal(clampi(focal_length, group["min"], group["max"]))
	_focal_changed(focal_slider.value)


func _focal_changed(value: float) -> void:
	focal_length = int(value)
	for index in lens_choice.item_count:
		var group_name: String = LENS_GROUPS[lens_choice.get_item_id(index)]["name"]
		lens_choice.set_item_text(index, group_name + ("  ·  %dmm" % focal_length if index == lens_choice.selected else ""))
	_clamp_view_center()
	if camera_active:
		_update_preview()


func _focus_changed(value: float) -> void:
	focus_position = value
	focus_label.text = "对焦位置：%.2f   前景 0 · 中景 1 · 背景 2" % value
	if camera_active:
		_update_preview()


func _reset_settings() -> void:
	aperture_index = 2
	shutter_index = 2
	iso_index = 2
	focus_slider.set_value_no_signal(1.0)
	_focus_changed(1.0)
	focal_length = 35
	_configure_lenses()
	_clamp_view_center()
	choices["aperture"].select(aperture_index)
	choices["shutter"].select(shutter_index)
	choices["iso"].select(iso_index)
	_update_preview()


func _previous_task() -> void:
	task_index = maxi(LEVELS[level_index]["first_task"], task_index - 1)
	_save_progress()
	_close_result()
	_refresh_task()
	result_label.text = "任务已切换。调整参数后拍照，查看本次结果。"
	_update_scene()
	_update_preview()


func _next_task() -> void:
	if completed[task_index] and task_index < LEVELS[level_index]["last_task"]:
		task_index += 1
		_save_progress()
		_close_result()
		_refresh_task()
		result_label.text = "任务已切换。调整参数后拍照，查看本次结果。"
		_update_scene()
		_update_preview()
	elif completed[task_index] and level_index < LEVELS.size() - 1 and _level_complete(level_index):
		_start_level(level_index + 1)


func _refresh_task() -> void:
	var task = TASKS[task_index]
	task_title.text = LEVELS[level_index]["title"] + "\n" + task["title"]
	task_text.text = task["text"]
	hint_label.text = "提示：" + task["hint"]
	if task_index == 3:
		hint_label.text += "\n本任务的摄影棚灯光已调暗。"
	if not progress_error.is_empty():
		hint_label.text += "\n" + progress_error
	var last_in_level = task_index == LEVELS[level_index]["last_task"]
	next_button.disabled = not completed[task_index] or (last_in_level and (level_index == LEVELS.size() - 1 or not _level_complete(level_index)))
	if last_in_level and level_index < LEVELS.size() - 1:
		next_button.text = "下一关"
	elif last_in_level and completed[task_index]:
		next_button.text = "关卡已完成"
	else:
		next_button.text = "下一项"
	_refresh_scene_controls()


func _refresh_scene_controls() -> void:
	scene_label.text = "场景：" + SCENE_NAMES[scene_index]
	left_arrow.disabled = not _can_change_scene("left")
	right_arrow.disabled = not _can_change_scene("right")
	up_arrow.disabled = not _can_change_scene("up")
	down_arrow.disabled = not _can_change_scene("down")
	left_arrow.visible = not left_arrow.disabled
	right_arrow.visible = not right_arrow.disabled
	up_arrow.visible = not up_arrow.disabled
	down_arrow.visible = not down_arrow.disabled


func _can_change_scene(direction: String) -> bool:
	return SCENE_LINKS[scene_index].has(direction) and SCENE_LINKS[scene_index][direction] in LEVELS[level_index]["scenes"]


func _change_scene(direction: String) -> void:
	if not _can_change_scene(direction):
		return
	scene_index = SCENE_LINKS[scene_index][direction]
	camera_menu.hide()
	_close_camera()
	_close_result()
	_refresh_scene_controls()
	_update_scene()


func _view_rect() -> Rect2i:
	var width: int = clampi(roundi(float(W) * 25.0 / focal_length), 1, W)
	var height: int = clampi(roundi(float(width) * H / W), 1, H)
	return Rect2i(Vector2i(view_center - Vector2(width, height) / 2.0), Vector2i(width, height))


func _clamp_view_center() -> void:
	var half_size = Vector2(_view_rect().size) / 2.0
	view_center.x = clampf(view_center.x, half_size.x, float(SCENE_SIZE.x) - half_size.x)
	view_center.y = clampf(view_center.y, half_size.y, float(SCENE_SIZE.y) - half_size.y)


func _scene_position_at(local_position: Vector2) -> Vector2:
	if scene_view.size.x <= 0.0 or scene_view.size.y <= 0.0:
		return Vector2(-1, -1)
	if not Rect2(Vector2.ZERO, scene_view.size).has_point(local_position):
		return Vector2(-1, -1)
	return local_position / scene_view.size * Vector2(SCENE_SIZE)


func _scene_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		camera_menu.hide()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var point = _scene_position_at(event.position)
		if point.x < 0.0:
			return
		pending_camera_center = point
		var click_position = get_global_transform_with_canvas().affine_inverse() * (scene_view.get_global_transform_with_canvas() * event.position)
		var button_size = camera_menu.get_combined_minimum_size()
		camera_menu.size = button_size
		var offset = Vector2(12, 12)
		var position = click_position + offset
		if position.x + button_size.x > size.x:
			position.x = click_position.x - button_size.x - offset.x
		if position.y + button_size.y > size.y:
			position.y = click_position.y - button_size.y - offset.y
		camera_menu.position = Vector2(clampf(position.x, 0, maxf(0, size.x - button_size.x)), clampf(position.y, 0, maxf(0, size.y - button_size.y)))
		camera_menu.show()
		camera_menu.move_to_front()


func _on_camera_menu_selected() -> void:
	camera_menu.hide()
	view_center = pending_camera_center
	_clamp_view_center()
	camera_active = true
	dragging_view = false
	capture_button.disabled = false
	camera_panel.show()
	_update_preview()


func _viewfinder_input(event: InputEvent) -> void:
	if not camera_active:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging_view = event.pressed
	elif event is InputEventMouseMotion and dragging_view:
		var scale_factor = minf(preview.size.x / W, preview.size.y / H)
		if scale_factor <= 0.0:
			return
		var display_size = Vector2(W, H) * scale_factor
		view_center -= event.relative * Vector2(_view_rect().size) / display_size
		_clamp_view_center()
		_update_preview()


func _camera_header_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging_camera_window = event.pressed
		if event.pressed:
			# Switch to top-left anchoring without moving the window.
			var old_position = camera_panel.position
			camera_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
			camera_panel.position = old_position
	elif event is InputEventMouseMotion and dragging_camera_window:
		var desired = camera_panel.position + event.relative
		var limit = (size - camera_panel.size).max(Vector2.ZERO)
		camera_panel.position = Vector2(clampf(desired.x, 0.0, limit.x), clampf(desired.y, 0.0, limit.y))


func _result_header_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging_result_window = event.pressed
		if event.pressed:
			var old_position = result_panel.position
			result_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
			result_panel.position = old_position
	elif event is InputEventMouseMotion and dragging_result_window:
		var desired = result_panel.position + event.relative
		var limit = (size - result_panel.size).max(Vector2.ZERO)
		result_panel.position = Vector2(clampf(desired.x, 0.0, limit.x), clampf(desired.y, 0.0, limit.y))


func _close_camera() -> void:
	camera_active = false
	dragging_view = false
	dragging_camera_window = false
	capture_button.disabled = true
	camera_panel.hide()
	_update_preview()


func _subject_visible(subject: Rect2i, required_scene: int) -> bool:
	if scene_index != required_scene:
		return false
	var view = _view_rect()
	var overlap = view.intersection(subject)
	var subject_area = float(subject.size.x * subject.size.y)
	var view_area = float(view.size.x * view.size.y)
	var visible_area = float(overlap.size.x * overlap.size.y)
	return visible_area >= subject_area * 0.8 and visible_area / view_area >= 0.004


func _exposure() -> float:
	var light = 0.18 if task_index == 3 else 1.0
	return light * pow(2.8 / float(APERTURES[aperture_index]), 2.0) * (float(SHUTTERS[shutter_index]) / (1.0 / 60.0)) * (float(ISOS[iso_index]) / 100.0)


func _blur_amount(object_depth: int) -> float:
	var aperture = float(APERTURES[aperture_index])
	return absf(float(object_depth) - focus_position) * 3.0 / aperture


func _noise_strength() -> float:
	var iso_factor = float(ISOS[iso_index]) / 100.0
	var low_light_factor = 1.7 if task_index == 3 else 0.65
	return clampf((sqrt(iso_factor) - 1.0) * 0.035 * low_light_factor, 0.0, 0.23)


func _update_preview() -> void:
	if not camera_active:
		preview.texture = null
		return
	preview.texture = ImageTexture.create_from_image(_render_photo(false))


func _update_scene() -> void:
	scene_view.texture = ImageTexture.create_from_image(_render_scene(false, true))


func _capture() -> void:
	if not camera_active:
		return
	_next_fan_angle += 1.3
	var image = _render_photo(true)
	last_photo = image
	save_button.disabled = false
	save_status.text = "仅点击保存才会写入文件。"
	result_image.texture = ImageTexture.create_from_image(image)
	result_count += 1
	shot_label.text = "第 %d 张  ·  %s  ·  %dmm\nf/%s  ·  %s  ·  ISO %d  ·  对焦：%.2f" % [result_count, SCENE_NAMES[scene_index], focal_length, str(APERTURES[aperture_index]), choices["shutter"].get_item_text(shutter_index), ISOS[iso_index], focus_position]
	var checks = _evaluate()
	var all_ok = true
	var lines = PackedStringArray()
	for check in checks:
		var ok = check[0]
		all_ok = all_ok and ok
		lines.append(("[通过] " if ok else "[未通过] ") + check[1])
	if all_ok:
		completed[task_index] = true
		_save_progress()
		result_label.text = "拍摄成功！\n" + "\n".join(lines)
		if task_index < LEVELS[level_index]["last_task"]:
			result_label.text += "\n可以继续下一项。"
		elif level_index < LEVELS.size() - 1 and _level_complete(level_index):
			result_label.text += "\n本关完成！打开任务面板进入下一关。"
		else:
			result_label.text += "\n本关挑战已完成！"
	else:
		result_label.text = "再试一次\n" + "\n".join(lines)
	if not progress_error.is_empty():
		result_label.text += "\n" + progress_error
	_refresh_task()
	_update_preview()
	result_panel.show()
	result_panel.move_to_front()


func _game_directory() -> String:
	return ProjectSettings.globalize_path("res://") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()


func _progress_directory() -> String:
	return progress_directory_override if not progress_directory_override.is_empty() else _game_directory().path_join("GameProgress")


func _load_progress() -> void:
	var path = _progress_directory().path_join("progress.json")
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		progress_read_blocked = true
		progress_error = "无法读取进度文件，原文件未被覆盖。"
		return
	var parser = JSON.new()
	var parse_error = parser.parse(file.get_as_text())
	file.close()
	var data = _normalize_progress(parser.data) if parse_error == OK else {}
	if data.is_empty():
		progress_read_blocked = true
		progress_error = "进度文件无法识别，原文件未被覆盖。"
		return
	completed.assign(data["completed"])
	level_index = int(data["level"])
	task_index = int(data["task"])
	scene_index = LEVELS[level_index]["first_scene"]
	has_saved_progress = true


func _normalize_progress(data: Variant) -> Dictionary:
	if not data is Dictionary or (data.get("version") != 1 and data.get("version") != 2):
		return {}
	var entries: Variant = data.get("completed")
	if not entries is Array or entries.is_empty() or entries.size() > TASKS.size():
		return {}
	if data.get("version") == 1 and entries.size() != 5:
		return {}
	for entry in entries:
		if typeof(entry) != TYPE_BOOL:
			return {}
	var saved_level: Variant = data.get("level")
	var saved_task: Variant = data.get("task")
	if typeof(saved_level) not in [TYPE_INT, TYPE_FLOAT] or typeof(saved_task) not in [TYPE_INT, TYPE_FLOAT]:
		return {}
	if not is_finite(float(saved_level)) or not is_finite(float(saved_task)):
		return {}
	if float(saved_level) != floorf(float(saved_level)) or float(saved_task) != floorf(float(saved_task)):
		return {}
	var level = int(saved_level)
	var task = int(saved_task)
	if data.get("version") == 1:
		if level == 0 and (task < 0 or task > 3):
			return {}
		if level == 1:
			if task != 4 or not (entries[0] and entries[1] and entries[2] and entries[3]):
				return {}
		elif level != 0:
			return {}
		level = 0
	if level < 0 or level >= LEVELS.size():
		return {}
	if task < LEVELS[level]["first_task"] or task > LEVELS[level]["last_task"] or task >= entries.size():
		return {}
	for previous in range(level):
		for index in range(LEVELS[previous]["first_task"], LEVELS[previous]["last_task"] + 1):
			if index >= entries.size() or not entries[index]:
				return {}
	var normalized: Array = entries.duplicate()
	while normalized.size() < TASKS.size():
		normalized.append(false)
	return {"completed": normalized, "level": level, "task": task}


func _save_progress() -> bool:
	if progress_read_blocked:
		return false
	var folder = _progress_directory()
	var error = DirAccess.make_dir_recursive_absolute(folder)
	if error != OK or not DirAccess.dir_exists_absolute(folder):
		progress_error = "进度保存失败，请检查游戏文件夹的写入权限。"
		return false
	var path = folder.path_join("progress.json")
	var temp_path = folder.path_join("progress.json.tmp")
	var file = FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		progress_error = "进度保存失败，请检查游戏文件夹的写入权限。"
		return false
	file.store_string(JSON.stringify({"version": 2, "completed": completed, "level": level_index, "task": task_index}))
	file.flush()
	error = file.get_error()
	file.close()
	if error == OK:
		error = DirAccess.rename_absolute(temp_path, path)
	if error != OK:
		progress_error = "进度保存失败，请检查游戏文件夹的写入权限。"
		return false
	progress_error = ""
	has_saved_progress = true
	return true


func _photo_directory() -> String:
	if not photo_directory_override.is_empty():
		return photo_directory_override
	return _game_directory().path_join("Photos")


func _save_photo() -> void:
	if last_photo == null:
		return
	var folder = _photo_directory()
	var error = DirAccess.make_dir_recursive_absolute(folder)
	if error != OK or not DirAccess.dir_exists_absolute(folder):
		save_status.text = "无法创建 Photos 文件夹，请检查写入权限。"
		return
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	var suffix = 1
	var path = folder.path_join("photo_%s_%03d.png" % [timestamp, suffix])
	while FileAccess.file_exists(path):
		suffix += 1
		path = folder.path_join("photo_%s_%03d.png" % [timestamp, suffix])
	error = last_photo.save_png(path)
	if error == OK:
		save_status.text = "已保存到 Photos 文件夹。"
		save_button.disabled = true
	else:
		save_status.text = "保存失败，请检查文件夹写入权限。"


func _evaluate() -> Array:
	var exposure = _exposure()
	var bright_enough = exposure >= 0.18
	var not_blown = exposure <= 2.5
	var checks = []
	match task_index:
		0:
			checks.append([_subject_visible(STUDIO_VASE, 0), "花瓶大部分入画" if _subject_visible(STUDIO_VASE, 0) else "请到摄影棚，让花瓶大部分入画"])
			checks.append([_blur_amount(1) <= 0.7, "花瓶清晰" if _blur_amount(1) <= 0.7 else "花瓶有些模糊：试试对焦中景"])
		1:
			var cards_visible = _subject_visible(STUDIO_FRONT_CARD, 0) and _subject_visible(STUDIO_BACK_CARD, 0)
			checks.append([cards_visible, "前后卡片都在画面中" if cards_visible else "请让两张数字卡片大部分入画；可以换广角镜头"])
			var both_clear = _blur_amount(0) <= 0.7 and _blur_amount(2) <= 0.7
			checks.append([both_clear, "前后卡片都清晰" if both_clear else "前后卡片尚未同时清晰：试试缩小光圈"])
		2:
			checks.append([_subject_visible(STUDIO_FAN, 0), "转盘大部分入画" if _subject_visible(STUDIO_FAN, 0) else "请到摄影棚，让转盘大部分入画"])
			checks.append([_blur_amount(2) <= 0.7, "转盘对焦清晰" if _blur_amount(2) <= 0.7 else "转盘失焦：试试对焦背景"])
			checks.append([float(SHUTTERS[shutter_index]) <= 1.0 / 250.0, "转盘叶片已定格" if float(SHUTTERS[shutter_index]) <= 1.0 / 250.0 else "叶片有运动模糊：试试更快的快门"])
		3:
			checks.append([_subject_visible(STUDIO_VASE, 0), "花瓶大部分入画" if _subject_visible(STUDIO_VASE, 0) else "请到摄影棚，让花瓶大部分入画"])
			checks.append([_blur_amount(1) <= 0.7, "花瓶清晰" if _blur_amount(1) <= 0.7 else "花瓶有些模糊：试试对焦中景"])
			checks.append([_noise_strength() <= 0.13, "噪点没有严重影响细节" if _noise_strength() <= 0.13 else "噪点过多：试试降低 ISO"])
		4:
			var flower_visible = _subject_visible(Rect2i(348, 104, 88, 130), 1) or _subject_visible(Rect2i(184, 0, 176, 252), 2)
			checks.append([flower_visible, "花大部分入画" if flower_visible else "请前往窗边花园，让花大部分入画"])
			checks.append([_blur_amount(1) <= 0.7, "花对焦清晰" if _blur_amount(1) <= 0.7 else "花有些模糊：试试对焦中景"])
	checks.append([bright_enough, "亮度足够" if bright_enough else "照片过暗：试试增加曝光"])
	checks.append([not_blown, "没有明显过曝" if not_blown else "照片过曝：试试减少曝光"])
	return checks


func _render_photo(is_capture: bool) -> Image:
	var scene_image = _render_scene(is_capture, false)
	scene_image.resize(SCENE_SIZE.x, SCENE_SIZE.y, Image.INTERPOLATE_NEAREST)
	var view = _view_rect()
	var photo = Image.create(view.size.x, view.size.y, false, Image.FORMAT_RGBA8)
	photo.fill(Color.BLACK)
	var visible = view.intersection(Rect2i(Vector2i.ZERO, SCENE_SIZE))
	if visible.size.x > 0 and visible.size.y > 0:
		photo.blit_rect(scene_image, visible, visible.position - view.position)
	photo.resize(W, H, Image.INTERPOLATE_NEAREST)
	return photo


func _render_scene(is_capture: bool, reality: bool) -> Image:
	var scene_image = _render_studio(is_capture, reality) if scene_index == 0 else _render_garden(is_capture, reality)
	if scene_index == 2:
		scene_image = scene_image.get_region(Rect2i(256, 108, 256, 144))
	return scene_image


func _render_studio(is_capture: bool, reality: bool = false) -> Image:
	var img: Image = STUDIO_ART.get_image().duplicate()
	img.convert(Image.FORMAT_RGBA8)
	_draw_fan(img, _next_fan_angle, reality)
	if not reality:
		_blur_region(img, STUDIO_FRONT_CARD, _blur_amount(0))
		_blur_region(img, STUDIO_VASE, _blur_amount(1))
		_blur_region(img, STUDIO_BACK_CARD, _blur_amount(2))
		_blur_region(img, STUDIO_FAN, _blur_amount(2))
		_apply_exposure(img, _exposure(), _noise_strength(), is_capture)
	elif task_index == 3:
		_apply_exposure(img, 0.35, 0.0, false)
	return img


func _render_garden(is_capture: bool, reality: bool = false) -> Image:
	var img: Image = GARDEN_ART.get_image().duplicate()
	img.convert(Image.FORMAT_RGBA8)
	if not reality:
		_blur_region(img, Rect2i(348, 104, 88, 130), _blur_amount(1))
		_apply_exposure(img, _exposure(), _noise_strength(), is_capture)
	elif task_index == 3:
		_apply_exposure(img, 0.35, 0.0, false)
	return img


func _rect(img: Image, x: int, y: int, width: int, height: int, hex: String) -> void:
	img.fill_rect(Rect2i(x * DRAW_SCALE, y * DRAW_SCALE, width * DRAW_SCALE, height * DRAW_SCALE), Color(hex))


func _draw_fan(img: Image, angle: float, reality: bool = false) -> void:
	img.fill_rect(Rect2i(438, 139, 4, 9), Color("384c54"))
	img.fill_rect(Rect2i(433, 147, 14, 3), Color("344249"))
	var shutter = 1.0 / 1000.0 if reality else float(SHUTTERS[shutter_index])
	var motion = minf(shutter * 18.0, 1.6)
	for y in range(108, 143):
		for x in range(422, 457):
			var dx = float(x) - 439.0
			var dy = float(y) - 125.0
			var distance = sqrt(dx * dx + dy * dy)
			if distance > 16.0:
				continue
			if distance > 14.5:
				img.set_pixel(x, y, Color("334b56"))
				continue
			var blade = 0.0
			var sample_count = 5
			for s in range(sample_count):
				var a = atan2(dy, dx) - angle - motion * (float(s) / float(sample_count - 1) - 0.5)
				if distance < 13.5 and cos(a * 3.0) > 0.52:
					blade += 1.0 / float(sample_count)
			var c = Color("c4c6a6").lerp(Color("587879"), blade)
			if distance < 2.5:
				c = Color("d9ab70")
			img.set_pixel(x, y, c)


func _blur_region(img: Image, area: Rect2i, amount: float) -> void:
	if amount <= 0.35:
		return
	var source = Image.create_from_data(W, H, false, Image.FORMAT_RGBA8, img.get_data())
	var radius = clampi(int(ceil(amount * 2.0)) * DRAW_SCALE, 1, 8)
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
