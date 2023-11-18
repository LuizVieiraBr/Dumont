extends CharacterBody2D

#Variáveis do personagem
@export var speed = 300.0
@export var vida = 3
@onready var anim = $anim as AnimatedSprite2D
var is_dead := false
var força_knockback := 300
var recebendo_dano := false


#Variáveis do tiro
@onready var ima_scene := preload("res://scenes/ima.tscn")
@export var tempo_recarga := 1.0
@export var can_shoot := true
var tempo_recarga_anim := 0.2
var is_shooting := false
var carregando := false
var municao = Globals.player_municao

func _physics_process(delta):
	if(!is_dead):
		look_at(get_global_mouse_position())
		get_input()
		move_and_slide()
		
	
func get_input():
	if(recebendo_dano):
		anim.play("recebendo dano")
		await anim.animation_finished
		recebendo_dano = false
	elif(!carregando):
		var input_direction = Input.get_vector("left", "right", "up", "down")
		if(input_direction != Vector2.ZERO):
			if(!is_shooting):
				anim.play("walk")
			velocity = input_direction * speed
		elif(input_direction == Vector2.ZERO):
			velocity = Vector2.ZERO
			if(!is_shooting):
				anim.play("idle")
		
		if(Input.is_action_just_pressed("shoot") and can_shoot):
			anim.play("shoot")
			is_shooting = true
			spawn_bullet()
			await get_tree().create_timer(tempo_recarga_anim).timeout
			is_shooting = false

#função que cria a bala na tela
func spawn_bullet():
	var ima = ima_scene.instantiate()
	ima.position = position
	
	if(can_shoot and Globals.player_municao > 0):
		get_parent().add_child(ima)
		ima.transform = $spawner_imas.global_transform
		ima.animIma.play("tiro")
		can_shoot = false
		await get_tree().create_timer(tempo_recarga).timeout
		can_shoot = true
		Globals.player_municao -= 1
	else:
		carregando = true
		velocity = Vector2.ZERO
		anim.play("recarregar")
		await anim.animation_finished
		carregando = false
		Globals.player_municao = 4

func receber_dano(body):
	if(body.is_in_group("inimigos") and vida > 0):
		recebendo_dano = true
		vida -= 1
		apply_knockback(global_position.direction_to(body.global_position))
	else:
		morto()

# Função que aplica knockback ao player
func apply_knockback(direction: Vector2) -> void:
	velocity = -direction * força_knockback
	move_and_slide()

func morto():
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("morto")
	await get_tree().create_timer(2).timeout
	get_tree().reload_current_scene()
