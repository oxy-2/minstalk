extends CharacterBody2D

@export var obeliskspeed := 280.0
@export var ohealth := 5
@export var okeepdistance := 180.0
@export var oreloadkeepdistance := 240.0
@export var ostrafespeed := 120.0
@export var obulletaggro := 480.0

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
	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		anim.stop()
		return

	if not activated and _player_bullet_nearby():
		activated = true
		print(name, " return fire")

	if not activated:
		velocity = Vector2.ZERO
		anim.stop()
		return

	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir = to_player.normalized() if dist > 0.001 else Vector2.RIGHT

	_strafetime += delta
	var strafeamt = sin(_strafetime * 1.8)
	var keep = oreloadkeepdistance if _is_reloading() else okeepdistance

	var motion := Vector2.ZERO
	if dist > keep + 28.0:
		motion = _steer(dir) * obeliskspeed
	elif dist < keep - 28.0:
		motion = _steer(-dir) * obeliskspeed
	motion += dir.orthogonal() * strafeamt * ostrafespeed

	velocity = motion
	anim.play("walk")
	anim.flip_h = dir.x < 0
	move_and_slide()

# slide along walls instead of sticking: if the way ahead is blocked, try a few angles
func _steer(dir: Vector2) -> Vector2:
	if _ray_free(dir):
		return dir
	for ang in [0.55, -0.55, 1.1, -1.1, 1.7, -1.7]:
		var alt = dir.rotated(ang)
		if _ray_free(alt):
			return alt
	return Vector2.ZERO

func _ray_free(dir: Vector2) -> bool:
	var q = PhysicsRayQueryParameters2D.create(global_position, global_position + dir * 52.0)
	q.exclude = [get_rid()]
	q.collide_with_areas = false
	var hit = get_world_2d().direct_space_state.intersect_ray(q)
	if hit.is_empty():
		return true
	var col = hit.get("collider")
	return col is CharacterBody2D

func _player_bullet_nearby() -> bool:
	for b in get_tree().get_nodes_in_group("bullet"):
		if not is_instance_valid(b):
			continue
		if b.shooter != null and b.shooter.is_in_group("player"):
			if global_position.distance_to(b.global_position) <= obulletaggro:
				return true
	return false

func take_damage(amount: int) -> void:
	ohealth -= amount
	print(name, " hp: ", ohealth)
	if ohealth <= 0:
		print(name, " died")
		queue_free()
