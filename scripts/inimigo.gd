extends CharacterBody2D
class_name Inimigo

var player_ref = null

var speed := 110
var recebendo_dano := false
var força_knockback := 200  # Intensidade do knockback
@export var vida_inimigo := 3

@export_category("Objects")
@export var texture: AnimatedSprite2D = null
@onready var anim := $AnimatedSprite2D as AnimatedSprite2D
@onready var area_detectação := $"area_de_detecção/collision_detec_area" as CollisionShape2D

# Função que detecta o player para dar o trigger de perseguição
func _on_area_de_detecção_body_entered(body):
	if(body.is_in_group("personagem")):
		player_ref = body
		area_detectação.scale *= 2

# Função que detecta um corpo saindo da área, caso seja o player, atribui um valor nulo para "perder" de vista
func _on_area_de_detecção_body_exited(body):
	if(body.is_in_group("personagem")):
		player_ref = null
		velocity = Vector2.ZERO

func _physics_process(delta):
	# Verifica a vida do inimigo para executar o código
	if(vida_inimigo > 0):
		# Chama a função de animação constantemente para atualizar as animações
		animate()
		# Verifica se o body que entrou é o player, para assim começar a segui-lo
		if(player_ref != null):
			# If que para o inimigo quando o personagem morre
			if(player_ref.is_dead):
				velocity = Vector2.ZERO
				return
			
			# Olha para o inimigo, segue a direção dele e calcula a distância para dar dano melee
			look_at(player_ref.global_position)
			var direction: Vector2 = global_position.direction_to(player_ref.global_position)
			var distance := global_position.distance_to(player_ref.global_position)
			
			if(recebendo_dano):
				apply_knockback(global_position.direction_to(player_ref.global_position))
				
			if(distance < 50):
				player_ref.receber_dano($".")
			
			velocity = direction * speed
			move_and_slide()
	elif(vida_inimigo == 0):
		morto()

# Função que dá play nas animações dele andando ou parado
func animate() -> void:
	if(recebendo_dano):
		velocity = Vector2.ZERO
		anim.play("recebendo dano")
		await anim.animation_finished
		# Define o recebendo_dano de volta para falso após a reprodução da animação
		recebendo_dano = false
	elif(velocity != Vector2.ZERO):
		anim.play("andando")
	else:
		anim.play("parado")

# Função que recebe uma área 2D, caso ela esteja no grupo "ima" (arma do Dummont),
# ela diminui 1 ponto na vida dele e aplica knockback
func receber_dano_do_ima(area):
	if(area.is_in_group("ima")):
		vida_inimigo -= 1
		recebendo_dano = true
		# Chama a função de animação recebendo_dano
		anim.play("recebendo dano")
		# Aplica knockback
		apply_knockback(global_position.direction_to(area.global_position))

# Função que aplica knockback ao inimigo
func apply_knockback(direction: Vector2) -> void:
	velocity = -direction * força_knockback
	move_and_slide()

#Define quando o inimigo morreu
func morto():
	anim.play("morto")
	await get_tree().create_timer(2).timeout
	queue_free()
