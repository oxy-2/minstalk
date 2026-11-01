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
