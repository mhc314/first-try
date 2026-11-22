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

func _run() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	_assert(game.preview.texture != null, "starting the game renders a preview")
	game.aperture_index = 0
	game.focus_index = 0
	_assert(not _all_pass(game._evaluate()), "the first assignment rejects a visibly out-of-focus vase")
	game.focus_index = 1
	game.aperture_index = 2
	_assert(_all_pass(game._evaluate()), "the first assignment accepts a focused and exposed vase")
	game._capture()
	_assert(game.completed[0] and game.result_image.texture != null, "taking a photo completes the assignment and displays the result")
	game._next_task()
	game.aperture_index = 0
	_assert(not _all_pass(game._evaluate()), "the depth-of-field assignment rejects a shallow focused range")
	game.aperture_index = 3
	game.shutter_index = 3
	_assert(_all_pass(game._evaluate()), "the depth-of-field assignment can be completed")
	game._capture()
	game._next_task()
	game.focus_index = 2
	game.aperture_index = 0
	game.shutter_index = 1
	game.iso_index = 3
	_assert(_all_pass(game._evaluate()), "the moving subject can be frozen with a correctly exposed photo")
	game._capture()
	game._next_task()
	game.focus_index = 1
	game.aperture_index = 0
	game.shutter_index = 2
	game.iso_index = 2
	_assert(_all_pass(game._evaluate()), "the low-light assignment has a viable solution")
	game._capture()
	_assert(game.completed[3], "the final assignment can be completed")
	print("Failures: ", failures)
	quit(0 if failures == 0 else 1)
