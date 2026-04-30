extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_rolling = false
var roll_timer = 0.0
var morreu = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if morreu:
		rotation_degrees += 15
		roll_timer -= delta
		if roll_timer <= 0:
			perder_vida()
		move_and_slide()
		return

	Global.tempo -= delta
	if Global.tempo <= 0:
		game_over()
		return

	if Input.is_action_just_pressed("pular") and is_on_floor():
		if scale == Vector2(0.5, 0.5):
			velocity.y = JUMP_VELOCITY * 1.5
		else:
			velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("esquerda", "direita")
	if direction:
		velocity.x = direction * SPEED
		$anim.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("ui_down"):
		scale = Vector2(0.5, 0.5)
	if Input.is_action_just_released("ui_down"):
		scale = Vector2(1.5, 1.5)

	if not is_on_floor():
		$anim.play("jump")
	elif direction:
		$anim.play("run")
	else:
		$anim.play("idle")

	if position.x > 1400:
		get_tree().change_scene_to_file("res://levels/world_02.tscn")

	if position.y > 350 and not morreu:
		is_rolling = true
		roll_timer = 1.5
		morreu = true

	var label_vidas = get_node_or_null("../CanvasLayer/label_vidas")
	var label_tempo = get_node_or_null("../CanvasLayer/label_tempo")

	if label_vidas:
		label_vidas.text = "Vidas: " + str(Global.vidas)
	if label_tempo:
		label_tempo.text = "Tempo: " + str(int(Global.tempo))

	move_and_slide()

func perder_vida():
	Global.vidas -= 1
	is_rolling = false
	rotation_degrees = 0
	morreu = false
	if Global.vidas <= 0:
		game_over()
	else:
		get_tree().reload_current_scene()

func game_over():
	Global.vidas = 3
	Global.tempo = 60.0
	get_tree().change_scene_to_file("res://game_over.tscn")
	
