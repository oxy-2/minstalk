extends CanvasLayer

# start menu + death screen. plain buttons now, swap for png hit-areas later.

var menu: Control
var death: Control
var hpbar: Control
var hpfill: ColorRect
var hplabel: Label
static var _skip_menu := false
var _maxhp := 10

func _ready() -> void:
	add_to_group("gameui")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_menu()
	_build_death()
	_build_hp()
	print("gameui ready, skip=", _skip_menu)
	if _skip_menu:
		_skip_menu = false
		start_game()
	else:
		show_menu()

func _process(_delta: float) -> void:
	_update_hp()

func _build_hp() -> void:
	hpbar = Control.new()
	hpbar.name = "HPBar"
	hpbar.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	hpbar.offset_left = 16
	hpbar.offset_top = 16
	hpbar.offset_right = 236
	hpbar.offset_bottom = 52
	hpbar.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.08, 0.8)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hpbar.add_child(bg)

	hpfill = ColorRect.new()
	hpfill.color = Color(0.2, 0.85, 0.25, 0.95)
	hpfill.offset_left = 3
	hpfill.offset_top = 3
	hpfill.offset_right = 217
	hpfill.offset_bottom = 33
	hpfill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(hpfill)

	hplabel = Label.new()
	hplabel.text = "10 / 10"
	hplabel.add_theme_font_size_override("font_size", 16)
	hplabel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hplabel.offset_left = 8
	hplabel.offset_top = 6
	hplabel.offset_right = -8
	hplabel.offset_bottom = -4
	hplabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hplabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hplabel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(hplabel)

	add_child(hpbar)

func _update_hp() -> void:
	var hp := 0
	var p = get_tree().get_first_node_in_group("player")
	if p != null and is_instance_valid(p) and "health" in p:
		hp = max(int(p.health), 0)
		_maxhp = max(_maxhp, hp)
	var ratio = float(hp) / float(max(_maxhp, 1))
	hpfill.offset_right = 3 + (214.0 * ratio)
	hpfill.color = Color(0.85, 0.15, 0.15).lerp(Color(0.2, 0.85, 0.25), ratio)
	hplabel.text = "%d / %d" % [hp, _maxhp]

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
