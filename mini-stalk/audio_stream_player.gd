extends "res://gunlogic.gd"
@onready var audio = $AudioStreamPlayer


func _process(delta: float) -> void:
	if _shoot():
		audio.stream = shoot_audio
		audio.play()
