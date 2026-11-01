extends CanvasLayer

# start menu + death screen. plain buttons now, swap for png hit-areas later.

var menu: Control
var death: Control
static var _skip_menu := false

func _ready() -> void:
	add_to_group("gameui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_menu()
	_build_death()
	print("gameui ready, skip=", _skip_menu)
	if _skip_menu:
		_skip_menu = false
		start_game()
	else:
		show_menu()

func _build_menu() -> void:
	menu = Control.new()
	menu.name = "Menu"
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.process_mode = Node.PROCESS_MODE_ALWAYS

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(center)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)

	var title = Label.new()
	title.text = "MiniStalk"
	title.add_theme_font_size_override("font_size", 52)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var startbtn = Button.new()
	startbtn.text = "Start"
	startbtn.custom_minimum_size = Vector2(220, 52)
	startbtn.pressed.connect(start_game)
	box.add_child(startbtn)

	var quitbtn = Button.new()
	quitbtn.text = "Quit"
	quitbtn.custom_minimum_size = Vector2(220, 52)
	quitbtn.pressed.connect(quit_game)
	box.add_child(quitbtn)

	add_child(menu)

func _build_death() -> void:
	death = Control.new()
	death.name = "DeathScreen"
	death.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death.process_mode = Node.PROCESS_MODE_ALWAYS

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death.add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death.add_child(center)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)

	var title = Label.new()
	title.text = "You Died"
	title.add_theme_font_size_override("font_size", 52)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var restartbtn = Button.new()
	restartbtn.text = "Restart"
	restartbtn.custom_minimum_size = Vector2(220, 52)
	restartbtn.pressed.connect(restart)
	box.add_child(restartbtn)

	var menubtn = Button.new()
	menubtn.text = "Menu"
	menubtn.custom_minimum_size = Vector2(220, 52)
	menubtn.pressed.connect(show_menu)
	box.add_child(menubtn)

	var quitbtn = Button.new()
	quitbtn.text = "Quit"
	quitbtn.custom_minimum_size = Vector2(220, 52)
	quitbtn.pressed.connect(quit_game)
	box.add_child(quitbtn)

	add_child(death)

func show_menu() -> void:
	get_tree().paused = true
	menu.visible = true
	death.visible = false
	print("menu shown, paused=", get_tree().paused)

func start_game() -> void:
	menu.visible = false
	death.visible = false
	get_tree().paused = false

func show_death() -> void:
	get_tree().paused = true
	menu.visible = false
	death.visible = true

func restart() -> void:
	_skip_menu = true
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_game() -> void:
	get_tree().quit()
