extends CharacterBody2D

@export var outlawspeed := 100.0
@export var health := 3
@export var keepdistance := 160.0
@export var strafespeed := 55.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $outlawsprite
@onready var notifier = $VisibleOnScreenNotifier2D

var activated := false
var _strafedir := 1.0
var _strafetimer := 0.0
var _path: PackedVector2Array = []
var _pathindex := 0
var _repathtimer := 0.0
var _stucktimer := 0.0
var _lastpos := Vector2.ZERO

func _ready() -> void:
	add_to_group("enemy")
	notifier.screen_entered.connect(_on_screen_entered)

func _on_screen_entered() -> void:
	if not activated:
		activated = true
		print(name, " woke up")

func is_gun_ready() -> bool:
	return activated

func _physics_process(delta: float) -> void:
	if not activated or not is_instance_valid(player):
		velocity = Vector2.ZERO
		anim.stop()
		return

	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir = to_player.normalized() if dist > 0.001 else Vector2.RIGHT

	# stuck on map collision -> kick sideways and repath
	if global_position.distance_to(_lastpos) < 0.8 and velocity.length() > 20.0:
		_stucktimer += delta
		if _stucktimer > 0.45:
			_stucktimer = 0.0
			_repathtimer = 0.0
			velocity += dir.orthogonal() * outlawspeed * (1.0 if randf() > 0.5 else -1.0)
	else:
		_stucktimer = 0.0
	_lastpos = global_position

	var losblocked = navgrid.is_los_blocked(global_position, player.global_position, [get_rid()], self)

	if losblocked:
		_repathtimer -= delta
		if _repathtimer <= 0.0:
			_repathtimer = 0.28
			_path = navgrid.find_path(global_position, player.global_position, self)
			_pathindex = 0
		if _path.size() > 0:
			if _pathindex < _path.size() - 1 and global_position.distance_to(_path[_pathindex]) < 18.0:
				_pathindex += 1
			var target = _path[_pathindex]
			var to_target = target - global_position
			if to_target.length() > 0.001:
				velocity = to_target.normalized() * outlawspeed
				dir = to_target.normalized()
			else:
				velocity = Vector2.ZERO
		else:
			velocity = dir * outlawspeed
	else:
		_path = PackedVector2Array()
		_pathindex = 0
		_repathtimer = 0.0

		# flip strafe side every few seconds so they arent predictable
		_strafetimer -= delta
		if _strafetimer <= 0.0:
			_strafetimer = randf_range(1.6, 3.2)
			_strafedir = -_strafedir

		var motion := Vector2.ZERO
		if dist > keepdistance + 28.0:
			motion = dir
		elif dist < keepdistance - 28.0:
			motion = -dir
		motion += dir.orthogonal() * _strafedir * (strafespeed / maxf(outlawspeed, 1.0))

		if motion.length() > 0.0:
			velocity = motion.normalized() * outlawspeed
		else:
			velocity = Vector2.ZERO

	anim.play("walk")
	anim.flip_h = dir.x < 0
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	print(name, " hp: ", health)
	if health <= 0:
		print(name, " died")
		queue_free()
