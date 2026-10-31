extends CharacterBody2D

@export var SPEED : float = 250.0

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") #wasd
	if direction != Vector2.ZERO: #moves
		velocity = direction * SPEED
		animated_sprite.play("walk") #animation #bhoppingaura
		if direction.x < 0:
			animated_sprite.flip_h = true #sleide to the left
		elif direction.x > 0:
			animated_sprite.flip_h = false # sllide to the right
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		animated_sprite.stop() # criss corss
		
	move_and_slide() # cha cha real smooth
