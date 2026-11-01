extends CharacterBody2D

@export var SPEED : float = 200.00
@export var SPRINT_SPEED : float = 300.00
@export var health := 10

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") #wasd
	
	var currentspeed = SPEED
	if Input.is_key_pressed(KEY_SHIFT): #sprint stuff
		currentspeed = SPRINT_SPEED
		
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
	if health <= 0:
		print("player died")
		queue_free()
