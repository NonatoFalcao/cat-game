extends Control

# Esta função é criada automaticamente quando você conecta o sinal
func _on_reiniciar_pressed() -> void:
	# Reseta os status globais
	Global.vidas = 3
	Global.tempo = 60.0
	
	# Volta para a fase inicial
	get_tree().change_scene_to_file("res://levels/world_01.tscn")
