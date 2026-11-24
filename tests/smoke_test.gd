extends SceneTree

var game
var failures = 0

func _initialize() -> void:
	call_deferred("_run")

func _assert(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		printerr("FAIL: ", description)

func _all_pass(checks: Array) -> bool:
	for check in checks:
		if not check[0]:
			return false
	return true

func _right_click_at(point: Vector2) -> void:
	var size: Vector2 = game.scene_view.size
	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = true
	event.position = point / Vector2(game.SCENE_SIZE) * size
	game._scene_input(event)

func _select_at(point: Vector2) -> void:
	_right_click_at(point)
	game.camera_menu.pressed.emit()

func _drag_preview(relative: Vector2) -> void:
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	game._viewfinder_input(press)
	var motion = InputEventMouseMotion.new()
	motion.relative = relative
	game._viewfinder_input(motion)
	press.pressed = false
	game._viewfinder_input(press)

func _drag_camera_window(relative: Vector2) -> void:
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	game.camera_header.gui_input.emit(press)
	var motion = InputEventMouseMotion.new()
	motion.relative = relative
	game.camera_header.gui_input.emit(motion)
	press.pressed = false
	game.camera_header.gui_input.emit(press)

func _drag_result_window(relative: Vector2) -> void:
	var press = InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	game.result_header.gui_input.emit(press)
	var motion = InputEventMouseMotion.new()
	motion.relative = relative
	game.result_header.gui_input.emit(motion)
	press.pressed = false
	game.result_header.gui_input.emit(press)

func _press_escape() -> void:
	var event = InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.pressed = true
	root.push_input(event)
	var release = InputEventKey.new()
	release.keycode = KEY_ESCAPE
	release.pressed = false
	root.push_input(release)

func _run() -> void:
	var test_progress_dir = ProjectSettings.globalize_path("res://.godot/progress_test_%d" % Time.get_ticks_usec())
	game = load("res://main.tscn").instantiate()
	game.progress_directory_override = test_progress_dir
	root.add_child(game)
	await process_frame
	game.set_process(false)
	var legacy = {"version": 1, "completed": [true, true, true, true, false], "level": 1, "task": 4}
	var migrated: Dictionary = game._normalize_progress(legacy)
	_assert(migrated.get("level", -1) == 0 and migrated.get("task", -1) == 4 and migrated.get("completed", []) == legacy["completed"], "old garden progress migrates to the merged tutorial")
	_assert(game._normalize_progress({"version": 1, "completed": [false, false, false, false, false], "level": 1, "task": 4}).is_empty(), "invalid old unlocks are rejected")
	var legacy_dir: String = test_progress_dir.path_join("legacy")
	DirAccess.make_dir_recursive_absolute(legacy_dir)
	var legacy_path: String = legacy_dir.path_join("progress.json")
	var legacy_file = FileAccess.open(legacy_path, FileAccess.WRITE)
	var legacy_text = JSON.stringify(legacy)
	legacy_file.store_string(legacy_text)
	legacy_file.close()
	var legacy_game = load("res://main.tscn").instantiate()
	legacy_game.progress_directory_override = legacy_dir
	root.add_child(legacy_game)
	await process_frame
	legacy_game.set_process(false)
	_assert(legacy_game.has_saved_progress and legacy_game.level_index == 0 and legacy_game.task_index == 4 and FileAccess.get_file_as_string(legacy_path) == legacy_text, "old save is loaded without overwriting it during migration")
	legacy_game._continue_game()
	_assert(legacy_game.scene_index == 1 and JSON.parse_string(FileAccess.get_file_as_string(legacy_path)).get("version") == 2, "continuing an old garden save keeps its task and writes the new version")
	legacy_game.queue_free()
	DirAccess.remove_absolute(legacy_path)
	DirAccess.remove_absolute(legacy_dir)
	_assert(game.title_screen.visible and game.title_menu.visible, "the title screen appears when the game starts")
	var overline: Label = game.title_screen.get_node("TitleOverline")
	var heading: Label = game.title_screen.get_node("TitleHeading")
	var subtitle: Label = game.title_screen.get_node("TitleSubtitle")
	for label in [overline, subtitle]:
		_assert(label.get_line_count() == 1 and label.size.x >= label.get_minimum_size().x, "title caption stays on one line without clipping: %s" % label.name)
		_assert(not label.get_rect().intersects(heading.get_rect()), "title caption does not overlap the heading: %s" % label.name)
	_assert(Rect2(Vector2.ZERO, game.size).encloses(game.title_menu.get_global_rect()), "the title menu fits inside the window")
	_assert(game.theme.default_font.has_char("拍".unicode_at(0)) and game.theme.default_font.has_char("H".unicode_at(0)), "the bundled pixel font supports Chinese and English")
	game.title_manual_button.pressed.emit()
	await process_frame
	_assert(game.manual_overlay.visible and game.manual_title.text == "基本操作", "the title screen opens the manual")
	game.manual_buttons[2].pressed.emit()
	await process_frame
	_assert(game.manual_title.text == "光圈与景深" and game.manual_body.text.contains("对焦"), "manual topics show their explanations")
	_assert(game.manual_body.size.x >= 400 and game.manual_body.get_line_count() > 2, "manual text has a wide, wrapped reading area")
	_assert(Rect2(Vector2.ZERO, game.size).encloses(game.manual_back.get_global_rect()) and Rect2(Vector2.ZERO, game.size).encloses(game.manual_body.get_global_rect()), "manual controls fit in the window")
	_press_escape()
	_assert(not game.manual_overlay.visible and game.title_screen.visible, "Escape returns from the manual to the title")
	game._show_level_menu()
	_assert(game.level_menu.visible and game.level_buttons.size() == 1 and not game.level_buttons[0].disabled, "the merged tutorial is available in the level menu")
	game._start_level(1)
	_assert(game.title_screen.visible, "a nonexistent level cannot be entered")
	game._continue_game()
	await process_frame
	_assert(not game.title_screen.visible and game.level_index == 0 and game.scene_index == 0, "a new game starts in the tutorial studio")
	_assert(game.right_arrow.visible, "the garden is accessible from the studio immediately")
	for button in game.task_panel.find_children("*", "Button", true, false):
		_assert(button.text != "返回标题", "the task panel does not contain a return-to-title button")
	game._change_scene("right")
	_assert(game.scene_index == 1 and game.left_arrow.visible, "the right arrow enters the garden within the tutorial")
	game._change_scene("left")
	_assert(game.scene_index == 0, "the left arrow returns to the studio")
	var test_photo_dir = ProjectSettings.globalize_path("res://.godot/photo_test_%d" % Time.get_ticks_usec())
	game.photo_directory_override = test_photo_dir
	_press_escape()
	_assert(game.pause_overlay.visible and game.pause_menu.visible, "Escape opens the pause menu")
	game.pause_manual_button.pressed.emit()
	_assert(game.manual_overlay.visible and game.pause_overlay.visible, "the pause menu opens the manual")
	game.manual_buttons[4].pressed.emit()
	_assert(game.manual_title.text == "ISO 与噪点", "the manual explains ISO")
	_press_escape()
	_assert(not game.manual_overlay.visible and game.pause_menu.visible, "Escape returns from the manual to the pause menu")
	var clock_before: float = game.preview_clock
	game._process(2.0)
	_assert(game.preview_clock == clock_before, "scene animation stops while paused")
	game._show_album()
	_assert(game.album_menu.visible and game.album_files.is_empty() and game.album_status.text.contains("没有"), "the album explains when there are no saved photos")
	_press_escape()
	_assert(game.pause_overlay.visible and game.pause_menu.visible and not game.album_menu.visible, "Escape returns from the album to the pause menu")
	_press_escape()
	_assert(not game.pause_overlay.visible, "Escape resumes the game")
	_assert(game.scene_view.texture != null, "the reality scene is visible at startup")
	var detailed_scene: Image = game.scene_view.texture.get_image()
	_assert(detailed_scene.get_size() == Vector2i(512, 288), "the scene uses a 512 by 288 drawing grid")
	_assert(detailed_scene.get_pixel(245, 153) == detailed_scene.get_pixel(247, 153) and detailed_scene.get_pixel(245, 153) != detailed_scene.get_pixel(246, 153), "the vase contains a one-pixel highlight")
	_assert(game.scene_view.position == Vector2.ZERO and game.scene_view.size == game.size, "the scene fills the game window")
	_assert(not game.task_panel.visible and not game.camera_panel.visible and not game.result_panel.visible, "all panels are closed at startup")
	game.task_button.pressed.emit()
	_assert(game.task_panel.visible, "the task button opens the task panel")
	game.task_button.pressed.emit()
	_assert(not game.task_panel.visible, "the task button closes the task panel")
	game.task_button.pressed.emit()
	game._close_tasks()
	_assert(not game.task_panel.visible, "the task panel can also be closed explicitly")
	_assert(not game.camera_active and game.preview.texture == null and game.capture_button.disabled, "the viewfinder starts black and cannot capture")
	var closed_center: Vector2 = game.view_center
	_drag_preview(Vector2(40, 20))
	_assert(game.view_center == closed_center and not game.dragging_view, "dragging a closed viewfinder has no effect")
	game._capture()
	_assert(game.result_count == 0, "capture is ignored when the camera is closed")
	_right_click_at(Vector2(256, 144))
	_assert(not game.camera_active and game.preview.texture == null, "right-click alone does not activate the camera")
	_assert(game.camera_menu.visible and game.camera_menu.position.distance_to(game.scene_view.size / 2.0 + Vector2(12, 12)) < 1.0, "the camera button appears beside the selected point in window coordinates")
	for point in [Vector2(1, 1), Vector2(511, 1), Vector2(1, 287), Vector2(511, 287)]:
		_right_click_at(point)
		var button_rect: Rect2 = game.camera_menu.get_rect()
		var click: Vector2 = point / Vector2(game.SCENE_SIZE) * game.scene_view.size
		_assert(Rect2(Vector2.ZERO, game.size).encloses(button_rect) and button_rect.get_center().distance_to(click) < 180, "the camera button stays near the click and inside the window at %s" % point)
	_right_click_at(Vector2(256, 144))
	game.camera_menu.pressed.emit()
	await process_frame
	_assert(game.camera_active and game.camera_panel.visible and game.preview.texture != null and not game.capture_button.disabled, "selecting the menu item opens the camera")
	_assert(not game.camera_menu.visible and game.preview.texture.get_image().get_size() == Vector2i(512, 288), "the button closes and the photograph retains the finer resolution")
	var camera_rect: Rect2 = game.camera_panel.get_rect()
	_assert(camera_rect.position.x >= 0 and camera_rect.position.y >= 0 and camera_rect.end.x <= game.size.x and camera_rect.end.y <= game.size.y, "camera panel fits inside the game window")
	_assert(absf(game.preview.size.x / game.preview.size.y - float(game.W) / game.H) < 0.02, "the viewfinder keeps the photograph's aspect ratio")
	_assert(game.view_center.distance_to(Vector2(256, 144)) < 1.0, "the selected scene point becomes the viewfinder center")
	var center_before_window_drag: Vector2 = game.view_center
	var camera_position_before: Vector2 = game.camera_panel.position
	_drag_camera_window(Vector2(-100, -50))
	var expected_camera_position = (camera_position_before + Vector2(-100, -50)).max(Vector2.ZERO)
	_assert(game.camera_panel.position.distance_to(expected_camera_position) < 1.0 and game.view_center == center_before_window_drag, "dragging the title bar moves the window without changing the camera framing")
	_assert(game.camera_panel.get_global_rect().encloses(game.focal_slider.get_global_rect()) and game.camera_panel.get_global_rect().encloses(game.focus_slider.get_global_rect()), "both sliders fit inside the camera window")
	_press_escape()
	_press_escape()
	_assert(game.camera_panel.visible and game.camera_active and game.view_center == center_before_window_drag, "pausing preserves the current camera and framing")
	_drag_camera_window(Vector2(-10000, -10000))
	_assert(game.camera_panel.position == Vector2.ZERO, "the camera window stops at the upper-left edge")
	_drag_camera_window(Vector2(10000, 10000))
	_assert(game.camera_panel.position.distance_to(game.size - game.camera_panel.size) < 1.0 and not game.dragging_camera_window, "the camera window stops at the lower-right edge and releases cleanly")
	var reality_before: PackedByteArray = game._render_scene(false, true).get_data()
	var view_before: PackedByteArray = game.preview.texture.get_image().get_data()
	_drag_preview(Vector2(40, 20))
	_assert(game.view_center.x < 256 and game.view_center.y < 144 and not game.dragging_view, "dragging the viewfinder moves its center and releases cleanly")
	_assert(game.preview.texture.get_image().get_data() != view_before and game._render_scene(false, true).get_data() == reality_before, "dragging changes the viewfinder without changing reality")
	_select_at(Vector2(256, 144))
	view_before = game.preview.texture.get_image().get_data()
	game._choice_changed(4, "iso")
	game._choice_changed(0, "aperture")
	game._choice_changed(3, "shutter")
	game.focus_slider.value = 0.25
	_assert(game._render_scene(false, true).get_data() == reality_before, "camera parameters do not alter the reality scene")
	_assert(game.preview.texture.get_image().get_data() != view_before, "camera parameters change the viewfinder")
	var scene_bounds = Rect2i(Vector2i.ZERO, game.SCENE_SIZE)
	_assert(game.focus_slider.step == 0.01 and is_equal_approx(game.focus_position, 0.25), "focus slider supports positions between the scene layers")
	var previous_width = 10000
	for setting in [[0, 25], [0, 35], [0, 70], [1, 200], [2, 1000]]:
		game.lens_choice.select(setting[0])
		game._lens_group_changed(setting[0])
		game.focal_slider.value = setting[1]
		var caption: String = game.lens_choice.get_item_text(game.lens_choice.selected)
		var caption_width: float = game.lens_choice.get_theme_font("font").get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, game.lens_choice.get_theme_font_size("font_size")).x
		_assert(caption.contains("%dmm" % setting[1]) and caption_width + 36 <= game.lens_choice.size.x, "lens selection displays %dmm horizontally without clipping" % setting[1])
		_select_at(Vector2(1, 1))
		var frame: Rect2i = game._view_rect()
		_assert(game.focal_length == setting[1] and frame.size.x <= previous_width, "focal length %d mm changes the view width" % setting[1])
		_assert(scene_bounds.encloses(frame) and frame.position == Vector2i.ZERO, "lens %d mm stays inside the upper-left scene edge" % setting[1])
		_drag_preview(Vector2(-100000, -100000))
		_assert(scene_bounds.encloses(game._view_rect()) and game._view_rect().end.distance_to(scene_bounds.end) <= 2, "lens %d mm stays inside the lower-right scene edge" % setting[1])
		previous_width = frame.size.x
	game._reset_settings()
	_assert(scene_bounds.encloses(game._view_rect()), "resetting the lens keeps the frame inside the scene")
	game._close_camera()
	_assert(not game.camera_active and not game.camera_panel.visible and game.preview.texture == null and game.capture_button.disabled, "closing the camera hides the viewfinder")
	game._reset_settings()
	_select_at(Vector2(256, 144))
	game.aperture_index = 0
	game.focus_slider.value = 0
	var blurred_vase: PackedByteArray = game._render_studio(false, false).get_region(game.STUDIO_VASE).get_data()
	_assert(not _all_pass(game._evaluate()), "the first assignment rejects an out-of-focus vase")
	game.focus_slider.value = 1
	var focused_vase: PackedByteArray = game._render_studio(false, false).get_region(game.STUDIO_VASE).get_data()
	_assert(blurred_vase != focused_vase, "focus changes the appearance of the vase at its new location")
	game.aperture_index = 2
	_assert(_all_pass(game._evaluate()), "the first assignment accepts a focused and exposed vase")
	game._capture()
	await process_frame
	await process_frame
	_assert(not DirAccess.dir_exists_absolute(test_photo_dir), "taking a photo does not save it automatically")
	_assert(game.completed[0] and game.result_image.texture != null, "capturing completes the first assignment")
	_assert(FileAccess.file_exists(test_progress_dir.path_join("progress.json")), "finishing a task saves progress beside the game")
	_assert(game.result_panel.visible, "capturing opens the result panel")
	var result_rect: Rect2 = game.result_panel.get_rect()
	_assert(result_rect.position.x >= 0 and result_rect.position.y >= 0 and result_rect.end.x <= game.size.x and result_rect.end.y <= game.size.y, "result panel fits inside the game window")
	_assert(result_rect.encloses(game.save_button.get_global_rect()), "the photo save button fits inside the result panel")
	_drag_result_window(Vector2(-10000, -10000))
	_assert(game.result_panel.position == Vector2.ZERO and not game.dragging_result_window, "result window can be dragged to the upper-left edge")
	_drag_result_window(Vector2(10000, 10000))
	_assert(game.result_panel.position.distance_to(game.size - game.result_panel.size) < 1.0, "result window stops at the lower-right edge")
	game.save_button.pressed.emit()
	var files = DirAccess.get_files_at(test_photo_dir)
	_assert(files.size() == 1 and game.save_button.disabled, "the player can explicitly save the photo once")
	var saved_path = test_photo_dir.path_join(files[0]) if files.size() == 1 else ""
	var saved = Image.load_from_file(saved_path) if not saved_path.is_empty() else null
	_assert(saved != null and saved.get_data() == game.last_photo.get_data(), "the saved PNG matches the captured photo")
	game._capture()
	game.save_button.pressed.emit()
	files = DirAccess.get_files_at(test_photo_dir)
	_assert(files.size() == 2 and files[0] != files[1], "saving another photo does not overwrite the first")
	_press_escape()
	game._show_album()
	await process_frame
	_assert(game.album_files.size() == 2 and game.album_image.texture != null and game.album_status.text.contains("1 / 2"), "the album loads saved photos")
	_assert(Rect2(Vector2.ZERO, game.size).encloses(game.album_image.get_global_rect()), "the saved-photo preview fits inside the window")
	game._album_move(1)
	_assert(game.album_status.text.contains("2 / 2") and game.album_next.disabled and not game.album_prev.disabled, "the album navigates between saved photos")
	var invalid_photo_path: String = test_photo_dir.path_join("zzz_invalid.png")
	var invalid_photo = FileAccess.open(invalid_photo_path, FileAccess.WRITE)
	invalid_photo.store_string("not a png")
	invalid_photo.close()
	game._show_album()
	_assert(game.album_status.text.contains("无法打开") and game.album_image.texture == null, "the album reports an unreadable photo")
	game._album_move(1)
	_assert(game.album_image.texture != null, "other photos remain accessible after an unreadable photo")
	DirAccess.remove_absolute(invalid_photo_path)
	_press_escape()
	_press_escape()
	_assert(not game.pause_overlay.visible and game.result_panel.visible, "resuming restores the open photo result")
	game.photo_directory_override = saved_path
	game._capture()
	game.save_button.pressed.emit()
	_assert(not game.save_button.disabled and game.save_status.text.contains("无法"), "a write failure is visible and can be retried")
	game.photo_directory_override = test_photo_dir
	game._close_result()
	_assert(not game.result_panel.visible and game.camera_panel.visible, "closing the result returns to the camera")
	game._next_task()
	game.lens_choice.select(0)
	game._lens_group_changed(0)
	game.focal_slider.value = 25
	game.aperture_index = 0
	_assert(not _all_pass(game._evaluate()), "the depth-of-field assignment rejects a shallow focused range")
	game.aperture_index = 3
	game.shutter_index = 3
	_assert(_all_pass(game._evaluate()), "the depth-of-field assignment can be completed")
	game._capture()
	game._next_task()
	game.lens_choice.select(0)
	game._lens_group_changed(0)
	game.focal_slider.value = 35
	_select_at(Vector2(400, 144))
	game.focus_slider.value = 2
	game.aperture_index = 0
	game.shutter_index = 1
	game.iso_index = 3
	_assert(_all_pass(game._evaluate()), "the moving subject can be frozen")
	game._capture()
	game._next_task()
	_select_at(Vector2(256, 144))
	game.focus_slider.value = 1
	game.aperture_index = 0
	game.shutter_index = 2
	game.iso_index = 2
	_assert(_all_pass(game._evaluate()), "the low-light assignment has a viable solution")
	game._capture()
	game._next_task()
	_assert(game.level_index == 0 and game.task_index == 4 and game.scene_index == 0, "the garden task follows the studio tasks in the same tutorial")
	game._change_scene("right")
	_assert(game.scene_index == 1 and not game.camera_active, "the player uses the arrow to reach the garden")
	var restarted = load("res://main.tscn").instantiate()
	restarted.progress_directory_override = test_progress_dir
	root.add_child(restarted)
	await process_frame
	restarted.set_process(false)
	_assert(restarted.has_saved_progress and restarted.level_index == 0 and restarted.task_index == 4, "the tutorial task survives restarting the game")
	restarted._continue_game()
	_assert(restarted.level_index == 0 and restarted.scene_index == 1, "continuing the garden task opens the garden")
	restarted.queue_free()
	_assert(game.left_arrow.visible, "the studio remains accessible from the garden")
	game.aperture_index = 2
	game.shutter_index = 2
	game.iso_index = 2
	game.focus_slider.value = 1
	_select_at(Vector2(392, 170))
	_assert(_all_pass(game._evaluate()), "the garden flower can be photographed")
	game._capture()
	_assert(game.completed[4], "the exploration assignment can be completed")
	game._change_scene("up")
	_assert(game.scene_index == 2 and not game.camera_active, "the forward arrow reaches the close-up and closes the camera")
	_select_at(Vector2(256, 144))
	_assert(_all_pass(game._evaluate()), "the close-up flower can be photographed")
	game._change_scene("down")
	_assert(game.scene_index == 1, "the back arrow returns from the close-up")
	_press_escape()
	game.pause_title_button.pressed.emit()
	_assert(game.title_screen.visible and not game.pause_overlay.visible, "the pause menu returns to the title")
	game._show_level_menu()
	_assert(game.level_buttons.size() == 1 and not game.level_buttons[0].disabled, "the completed tutorial remains available")
	game._start_level(0)
	game._show_title()
	game._show_level_menu()
	_assert(game._level_complete(0) and not game.level_buttons[0].disabled, "replaying the tutorial keeps completed tasks")
	game.progress_directory_override = saved_path
	_assert(not game._save_progress() and not game.progress_error.is_empty(), "a progress write failure is reported")
	game.progress_directory_override = test_progress_dir
	_assert(game._save_progress() and game.progress_error.is_empty(), "progress saving can recover after a write failure")
	var broken_dir = test_progress_dir.path_join("broken")
	DirAccess.make_dir_recursive_absolute(broken_dir)
	var broken_file = FileAccess.open(broken_dir.path_join("progress.json"), FileAccess.WRITE)
	broken_file.store_string("invalid progress")
	broken_file.close()
	var broken = load("res://main.tscn").instantiate()
	broken.progress_directory_override = broken_dir
	root.add_child(broken)
	await process_frame
	broken.set_process(false)
	_assert(broken.progress_read_blocked and not broken._save_progress(), "unrecognized progress cannot be overwritten automatically")
	_assert(FileAccess.get_file_as_string(broken_dir.path_join("progress.json")) == "invalid progress", "unrecognized progress remains intact")
	broken.queue_free()
	DirAccess.remove_absolute(broken_dir.path_join("progress.json"))
	DirAccess.remove_absolute(broken_dir)
	DirAccess.remove_absolute(test_progress_dir.path_join("progress.json"))
	DirAccess.remove_absolute(test_progress_dir.path_join("progress.json.tmp"))
	DirAccess.remove_absolute(test_progress_dir)
	for file in files:
		DirAccess.remove_absolute(test_photo_dir.path_join(file))
	DirAccess.remove_absolute(test_photo_dir)
	print("Failures: ", failures)
	quit(0 if failures == 0 else 1)
