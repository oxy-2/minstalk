extends CharacterBody2D

@export var obeliskspeed := 80.0
@export var ohealth := 5
@export var okeepdistance := 180.0
@export var ostrafespeed := 65.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $obelisksprite
@onready var notifier = $VisibleOnScreenNotifier2D

var activated := false
var _strafedir := 1.0
var _strafetimer := 0.0

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

	# flip strafe side every few seconds so they arent predictable
	_strafetimer -= delta
	if _strafetimer <= 0.0:
		_strafetimer = randf_range(1.6, 3.2)
		_strafedir = -_strafedir

	var motion := Vector2.ZERO
	if dist > okeepdistance + 28.0:
		motion = dir
	elif dist < okeepdistance - 28.0:
		motion = -dir
	motion += dir.orthogonal() * _strafedir * (ostrafespeed / maxf(obeliskspeed, 1.0))

	if motion.length() > 0.0:
		velocity = motion.normalized() * obeliskspeed
	else:
		velocity = Vector2.ZERO

	anim.play("walk")
	anim.flip_h = dir.x < 0
	move_and_slide()

func take_damage(amount: int) -> void:
	ohealth -= amount
	print(name, " hp: ", ohealth)
	if ohealth <= 0:
		print(name, " died")
		queue_free()
