extends CharacterBody2D

@export var outlawspeed := 60.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $outlawsprite
@onready var notifier = $VisibleOnScreenNotifier2D

var activated := false

func _ready() -> void:
	notifier.screen_entered.connect(_on_screen_entered)
	
func _on_screen_entered() -> void:
	activated = true
	
func _physics_process(delta: float) -> void:
	if not activated or player == null:
		velocity = Vector2.ZERO
		anim.stop()
		return
	
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * outlawspeed
	anim.play("walk")
	anim.flip_h = dir.x < 0
	move_and_slide()
