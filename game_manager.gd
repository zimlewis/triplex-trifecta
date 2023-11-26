extends Node


var center_of_screen
var card_size = Vector2(110 , 153)
var card_texture_size = Vector2(920 , 1280)

func _process(delta):
	
	center_of_screen = get_tree().current_scene.get_viewport_rect().size / 2


func inspect(id):
	var inspect_layer = CanvasLayer.new()
	var inspect_background = ColorRect.new()

	var inspect_card_scale = Vector2((get_tree().current_scene.get_viewport_rect().size.y - 100) / GameManager.card_size.y , (get_tree().current_scene.get_viewport_rect().size.y - 100) / GameManager.card_size.y)
	
	
	inspect_background.color = Color.BLACK
	inspect_background.color.a = 0.5
	inspect_background.size = get_tree().current_scene.get_viewport_rect().size
	inspect_background.mouse_filter = Control.MOUSE_FILTER_PASS
	
	get_tree().get_root().add_child(inspect_layer)
	
	if id is String:
		var inspect_card = load("res://game-components/card/card.tscn").instantiate()
		
		inspect_card.card_id = id
		
		
		inspect_layer.add_child(inspect_card)
		
		
		inspect_layer.add_child(inspect_background)
		
		inspect_card.scale *= inspect_card_scale
		inspect_card.state = inspect_card.card_state.IN_INSPECT
		inspect_card.position = center_of_screen - card_texture_size * inspect_card.scale / 2
		inspect_card.delete_inspect.connect(inspect_layer.queue_free)
		
	if id is Array:
		var scroll_container = ScrollContainer.new()
		var hbox_container = HBoxContainer.new()
		
		
		scroll_container.add_child(hbox_container)
		inspect_layer.add_child(scroll_container)
		
		for i in id:
			var grid = Control.new()
			
			
			var inspect_card = load("res://game-components/card/card.tscn").instantiate()
			
			inspect_card.card_id = i
			
			
			
			grid.add_child(inspect_card)
			hbox_container.add_child(grid)
			
			
			inspect_card.scale *= inspect_card_scale
			inspect_card.state = inspect_card.card_state.IN_INSPECT
			inspect_card.delete_inspect.connect(inspect_layer.queue_free)
			grid.custom_minimum_size = inspect_card.scale * card_texture_size
			
			if inspect_card.card_information.type == "Leader":
				hbox_container.move_child(grid , 0)
			
		scroll_container.size = Vector2(1280 , 630)
		scroll_container.position = Vector2(0 , 40)
		

	
	
	
