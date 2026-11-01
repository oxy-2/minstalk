extends CharacterBody2D

@export var SPEED : float = 200.00
@export var SPRINT_SPEED : float = 300.00
@export var health := 10
@export var max_health := 10
@export var stim_multiplier := 2.0

@onready var animated_sprite = $AnimatedSprite2D

var _stim_timer := 0.0

var blood = load("res://bloodFIXED.tscn")

func apply_stim(duration: float) -> void:
	_stim_timer = duration

func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	print("player hp: ", health)

func _physics_process(delta: float) -> void:
	_stim_timer = maxf(_stim_timer - delta, 0.0)
	var boost = stim_multiplier if _stim_timer > 0.0 else 1.0
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") #wasd
	
	var currentspeed = SPEED * boost
	if Input.is_key_pressed(KEY_SHIFT): #sprint stuff
		currentspeed = SPRINT_SPEED * boost
		
	if direction != Vector2.ZERO: #moves
		velocity = direction * currentspeed
		animated_sprite.play("walk") #animation #bhoppingaura
		if direction.x < 0:
			animated_sprite.flip_h = true #sleide to the left
		elif direction.x > 0:
			animated_sprite.flip_h = false # sllide to the right
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		animated_sprite.stop() # criss corss
		
	move_and_slide() # cha cha real smooth

func take_damage(amount: int) -> void:
	health -= amount
	print("player hp: ", health)
	var blood_instance = blood.instantiate()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.global_position = global_position
	if health <= 0:
		print("player died")
		var ui = get_tree().get_first_node_in_group("gameui")
		if ui:
			ui.show_death()
		queue_free()
