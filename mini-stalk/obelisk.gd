extends CharacterBody2D

@export var obeliskspeed := 280.0
@export var ohealth := 5
@export var okeepdistance := 180.0
@export var oreloadkeepdistance := 240.0
@export var ostrafespeed := 120.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $obelisksprite
@onready var notifier = $VisibleOnScreenNotifier2D

var activated := false
var _strafetime := 0.0

func _ready() -> void:
	add_to_group("enemy")
	notifier.screen_entered.connect(_on_screen_entered)

func _on_screen_entered() -> void:
	if not activated:
		activated = true
		print(name, " woke up")

func is_gun_ready() -> bool:
	return activated

func _is_reloading() -> bool:
	for child in get_children():
		if "reloading" in child:
			return child.reloading
	return false

func _physics_process(delta: float) -> void:
	if not activated or not is_instance_valid(player):
		velocity = Vector2.ZERO
		anim.stop()
		return

	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir = to_player.normalized() if dist > 0.001 else Vector2.RIGHT

	# smooth back-and-forth strafe
	_strafetime += delta
	var strafeamt = sin(_strafetime * 1.8)

	# step back while reloading
	var keep = oreloadkeepdistance if _is_reloading() else okeepdistance

	var motion := Vector2.ZERO
	if dist > keep + 28.0:
		motion = dir * obeliskspeed
	elif dist < keep - 28.0:
		motion = -dir * obeliskspeed
	motion += dir.orthogonal() * strafeamt * ostrafespeed

	velocity = motion
	anim.play("walk")
	anim.flip_h = dir.x < 0
	move_and_slide()

func take_damage(amount: int) -> void:
	ohealth -= amount
	print(name, " hp: ", ohealth)
	if ohealth <= 0:
		print(name, " died")
		queue_free()
