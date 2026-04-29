extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_rolling = false
var roll_timer = 0.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("esquerda", "direita")
	if direction:
		velocity.x = direction * SPEED
		$anim.flip_h = direction > 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	# ROLAGEM - aperta espaço para rolar
	if Input.is_action_just_pressed("rolar") and is_on_floor():
		is_rolling = true
		roll_timer = 1.5
		velocity.x = direction * SPEED * 8

	if is_rolling:
		rotation_degrees += 15
		roll_timer -= delta
		if roll_timer <= 0:
			is_rolling = false
			rotation_degrees = 0

# ENCOLHER - segura baixo para encolher
	if Input.is_action_just_pressed("ui_down"):
		scale = Vector2(0.5, 0.5)
	if Input.is_action_just_released("ui_down"):
		scale = Vector2(1.5, 1.5)

	# PULO - pula mais alto se estiver encolhido
	if Input.is_action_just_pressed("pular") and is_on_floor():
		if scale == Vector2(0.5, 0.5):
			velocity.y = JUMP_VELOCITY * 1.5
		else:
			velocity.y = JUMP_VELOCITY
		
	if not is_on_floor():
		$anim.play("jump")
	elif direction:
		$anim.play("run")
	else:
		$anim.play("idle")
		
	if position.x > 1400:
		get_tree().change_scene_to_file("res://levels/world_02.tscn")

	move_and_slide()
