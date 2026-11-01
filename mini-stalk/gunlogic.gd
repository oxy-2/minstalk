extends Node2D

@export var bulletscene: PackedScene = preload("res://bullet.tscn")
@export var shootcooldown := 0.25
@export var enemyinterval := 0.9
@export var turnspeed := 3.0
@export var swayamount := 0.08
@export var swayspeed := 1.1
@export var shoot_audio : AudioStreamMP3

@onready var muzzle = $Muzzle
@onready var ginsprite = $Sprite2D
@onready var shooter = get_parent()


var _cooldown := 0.0
var _enemytimer := 0.0
var _swaytime := 0.0
var _aimangle := 0.0

func _ready() -> void:
	_enemytimer = enemyinterval
	_aimangle = rotation

func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)

	if shooter.is_in_group("player"):
		look_at(get_global_mouse_position())
		_aimangle = rotation
		_keepgunupright()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _cooldown <= 0.0:
			_shoot(0.0)
		return

	# enemy gun: line up first (slow turn + sway), then pop one every 1.5s
	var player = get_tree().get_first_node_in_group("player")
	if player == null or not _can_enemy_fire():
		return

	_swaytime += delta
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var target = to_player.angle()
	var angdiff = wrapf(target - _aimangle, -PI, PI)
	_aimangle += clampf(angdiff, -turnspeed * delta, turnspeed * delta)
	rotation = _aimangle + sin(_swaytime * swayspeed) * swayamount
	_keepgunupright()

	# lined up = barrel near the player (or already in their face)
	var aimed = absf(angdiff) < 0.45 or dist < 90.0
	if not aimed:
		_enemytimer = enemyinterval
		return

	_enemytimer -= delta
	if _enemytimer <= 0.0:
		_enemytimer = enemyinterval
		print(shooter.name, " shoots")
		_shoot(0.0)

func _can_enemy_fire() -> bool:
	if shooter.has_method("is_gun_ready"):
		return shooter.is_gun_ready()
	if "activated" in shooter:
		return shooter.activated
	return true

func _shoot(angle_error: float) -> void:
	if bulletscene == null:
		return
	var packed = bulletscene.instantiate()
	var bullet = packed if packed is Area2D else packed.get_node("Area2D")
	bullet.shooter = shooter
	# fire along where the barrel actually points (includes sway)
	bullet.direction = Vector2.from_angle(rotation + angle_error)
	get_tree().current_scene.add_child(packed)
	packed.global_position = muzzle.global_position
	_cooldown = shootcooldown
	
	

# never let the gun art go upside down
func _keepgunupright() -> void:
	if ginsprite == null:
		return
	var ang = wrapf(rotation, -PI, PI)
	ginsprite.flip_v = absf(ang) > PI / 2.0
