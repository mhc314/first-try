extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args = OS.get_cmdline_user_args()
	if args.size() != 2:
		printerr("Expected a phase and a test directory")
		quit(1)
		return
	var game = load("res://main.tscn").instantiate()
	game.progress_directory_override = args[1]
	root.add_child(game)
	await process_frame
	game.set_process(false)
	if not OS.has_feature("editor") and game._game_directory() != OS.get_executable_path().get_base_dir():
		printerr("Exported game did not use the executable directory")
		quit(1)
		return
	if args[0] == "write":
		game.completed = [true, true, true, true, false]
		game.level_index = 0
		game.task_index = 4
		if not game._save_progress():
			printerr("Failed to write progress: ", game.progress_error)
			quit(1)
			return
	elif args[0] == "read":
		game._show_level_menu()
		if not game.has_saved_progress or game.level_buttons[0].disabled or game.level_index != 0 or game.task_index != 4:
			printerr("Saved tutorial or task was not restored")
			quit(1)
			return
	else:
		printerr("Unknown phase")
		quit(1)
		return
	print("PASS: progress ", args[0], " in a separate process")
	quit(0)
