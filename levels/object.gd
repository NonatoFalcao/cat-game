extends CharacterBody2D
class_name Pushables

const PUSH_SPEED = 300.0

func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	move_and_slide()
	velocity.x = 0
		
func empurrar(direcao):
	velocity.x = direcao.x * PUSH_SPEED
