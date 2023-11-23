extends Node


var center_of_screen
var card_size = Vector2(110 , 153)
var card_texture_size = Vector2(920 , 1280)
func _process(delta):
	
	center_of_screen = get_tree().current_scene.get_viewport_rect().size / 2


