extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -350.0


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
		
	if not is_on_floor():
		$anim.play("jump")
	elif direction:
		$anim.play("run")
	else:
		$anim.play("idle")

	move_and_slide()
	apply_push_force()
func apply_push_force():
	for objects in get_slide_collision_count():
		var collision = get_slide_collision(objects)
		if collision.get_collider() is Pushables:
			collision.get_collider().empurrar(-collision.get_normal())	
			
