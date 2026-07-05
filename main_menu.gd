extends Node2D


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/test_level.tscn")


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file()


func _on_quit_pressed() -> void:
	get_tree().quit()
