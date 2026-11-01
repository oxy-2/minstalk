extends Sprite2D

signal option_selected(index: int)

# 0 = top, 1 = bottom-right, 2 = bottom-left
@export var wheel_radius := 0.0        # 0 = auto from the texture size
@export var arc_steps := 10
@export var show_debug := false
@export var medkit_uses := 2
@export var stim_uses := 2
@export var stim_duration := 15.0
@export var label_offset := Vector2(-60, -150)  # more negative Y = higher

var _zones: Array[Polygon2D] = []
var _label: Label

func _ready() -> void:
	visible = false

	var r := wheel_radius
	if r <= 0.0 and texture != null:
		r = texture.get_width() * 0.5

	for i in 3:
		var centre_angle := deg_to_rad(-90.0 + i * 120.0)
		var from_angle := centre_angle - deg_to_rad(60.0)
		var to_angle := centre_angle + deg_to_rad(60.0)

		var pts := PackedVector2Array([Vector2.ZERO])
		for s in arc_steps + 1:
			var a := lerpf(from_angle, to_angle, float(s) / arc_steps)
			pts.append(Vector2.from_angle(a) * r)

		var zone := Polygon2D.new()
		zone.polygon = pts
		zone.color = Color(1, 1, 1, 0.25)
		zone.visible = show_debug
		add_child(zone)
		_zones.append(zone)

	# one label, created once, shows both counters
	_label = Label.new()
	_label.position = label_offset
	_label.add_theme_font_size_override("font_size", 20)
	add_child(_label)
	_update_label()

func _process(_delta: float) -> void:
	visible = Input.is_key_pressed(KEY_E)
	if show_debug and visible:
		var hovered := _get_hovered()
		for i in _zones.size():
			_zones[i].color = Color(1, 0.8, 0.2, 0.4) if i == hovered else Color(1, 1, 1, 0.2)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hovered := _get_hovered()
		if hovered != -1:
			option_selected.emit(hovered)
			var player = get_tree().get_first_node_in_group("player")
			match hovered:
				0:
					if medkit_uses > 0 and player != null and player.has_method("heal"):
						if player.health < player.max_health:
							player.heal(5)
							medkit_uses -= 1
							_update_label()
				1:
					if stim_uses > 0 and player != null and player.has_method("apply_stim"):
						player.apply_stim(stim_duration)
						stim_uses -= 1
						_update_label()
				2:
					pass
			get_viewport().set_input_as_handled()

func _update_label() -> void:
	if _label == null:
		return
	_label.text = "Medkits: " + str(medkit_uses) + "\nStims: " + str(stim_uses)
	_label.modulate = Color.WHITE if (medkit_uses > 0 or stim_uses > 0) else Color(1, 0.3, 0.3)

# index of the sector under the mouse, or -1
func _get_hovered() -> int:
	var mouse := get_global_mouse_position()
	for i in _zones.size():
		var local := _zones[i].to_local(mouse)
		if Geometry2D.is_point_in_polygon(local, _zones[i].polygon):
			return i
	return -1
