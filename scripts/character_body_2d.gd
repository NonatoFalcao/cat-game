extends CharacterBody2D

const SPEED = 300.0        # Velocidade horizontal do gato
const JUMP_VELOCITY = -400.0  # Força do pulo (negativo = para cima)
var is_rolling = false     # Controla se está girando (animação de morte)
var roll_timer = 0.0       # Temporizador da animação de morte
var morreu = false         # Controla se o gato morreu

func _physics_process(delta: float) -> void:
	# Aplica gravidade sempre, mesmo quando morreu
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Se morreu, executa animação de giro e espera para perder vida
	if morreu:
		rotation_degrees += 15       # Gira o gato
		roll_timer -= delta          # Conta o tempo da animação
		if roll_timer <= 0:
			perder_vida()            # Após 1.5s, chama perder vida
		move_and_slide()
		return                       # Para aqui, não processa mais nada

	# Diminui o tempo restante da fase
	Global.tempo -= delta
	if Global.tempo <= 0:
		game_over()                  # Acabou o tempo = game over
		return

	# Pulo — verifica se está encolhido para pular mais alto
	if Input.is_action_just_pressed("pular") and is_on_floor():
		if scale == Vector2(0.5, 0.5):
			velocity.y = JUMP_VELOCITY * 1.5  # Pulo alto quando encolhido
		else:
			velocity.y = JUMP_VELOCITY        # Pulo normal

	# Movimento horizontal
	var direction := Input.get_axis("esquerda", "direita")
	if direction:
		velocity.x = direction * SPEED
		$anim.flip_h = direction > 0  # Espelha o sprite (reflexão)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)  # Desacelera suavemente

	# Encolher — escala o gato para metade do tamanho
	if Input.is_action_just_pressed("ui_down"):
		scale = Vector2(0.5, 0.5)   # Escala: encolhe
	if Input.is_action_just_released("ui_down"):
		scale = Vector2(1.5, 1.5)   # Escala: volta ao tamanho normal

	# Animações baseadas no estado do gato
	if not is_on_floor():
		$anim.play("jump")   # No ar = animação de pulo
	elif direction:
		$anim.play("run")    # Movendo = animação de corrida
	else:
		$anim.play("idle")   # Parado = animação idle

	# Troca de fase ao chegar no final (posição X > 1400)
	if position.x > 1400:
		var cena_atual = get_tree().current_scene.scene_file_path
		if cena_atual == "res://levels/world_01.tscn":
			get_tree().change_scene_to_file("res://levels/world_02.tscn")  # Vai para fase 2
		elif cena_atual == "res://levels/world_02.tscn":
			get_tree().change_scene_to_file("res://levels/victory.tscn")   # Vai para tela de vitória

	# Detecta queda fora da fase (posição Y muito baixa)
	if position.y > 350 and not morreu:
		is_rolling = true    # Inicia animação de giro
		roll_timer = 1.5     # Duração da animação em segundos
		morreu = true        # Marca que morreu

	# Atualiza HUD com vidas e tempo (só se os labels existirem)
	var label_vidas = get_node_or_null("../CanvasLayer/label_vidas")
	var label_tempo = get_node_or_null("../CanvasLayer/label_tempo")
	if label_vidas:
		label_vidas.text = "Vidas: " + str(Global.vidas)
	if label_tempo:
		label_tempo.text = "Tempo: " + str(int(Global.tempo))

	move_and_slide()
	apply_push_force()  # Aplica força de empurrar objetos

# Empurra objetos do tipo Pushables ao colidir
func apply_push_force():
	for objects in get_slide_collision_count():
		var collision = get_slide_collision(objects)
		if collision.get_collider() is Pushables:
			collision.get_collider().empurrar(-collision.get_normal())  # Empurra na direção oposta à colisão

# Perde uma vida e reinicia a fase ou vai para game over
func perder_vida():
	Global.vidas -= 1
	is_rolling = false
	rotation_degrees = 0
	morreu = false
	if Global.vidas <= 0:
		game_over()                        # Sem vidas = game over
	else:
		get_tree().reload_current_scene()  # Ainda tem vidas = reinicia fase

# Game over: reseta vidas e tempo e vai para a tela de game over
func game_over():
	Global.vidas = 3
	Global.tempo = 60.0
	get_tree().change_scene_to_file("res://game_over.tscn")
