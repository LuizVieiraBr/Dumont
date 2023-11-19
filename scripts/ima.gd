extends Area2D

var vel_projetil = 700

@onready var animIma = $anim as AnimatedSprite2D

func _physics_process(delta):
	position += transform.x * vel_projetil * delta
	
