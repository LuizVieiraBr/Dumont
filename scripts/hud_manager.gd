extends Control

@onready var municao_counter = $container/municao_container/municao_counter as Label
@onready var animated_sprite_2d = $container/municao_container/AnimatedSprite2D

func _ready():
	pass

func _process(delta):
	if(Globals.player_municao > 0):
		animated_sprite_2d.play("idle")
	else:
		animated_sprite_2d.play("recarregando")
	
	municao_counter.text = str(Globals.player_municao)
