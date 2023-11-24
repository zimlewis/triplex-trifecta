extends NinePatchRect

@onready var game_option_button = $gamemode/HBoxContainer.get_children()
var chosen_mode : String : set = set_chosen_mode
var decks : set = set_decks
var grid_size = Vector2(147.2 , 204.8)

func _ready():
	chosen_mode = "unrated"
	for i in game_option_button:
		i.connect("menu_inputed" , _on_menu_inputed)

func set_decks(value):
	decks = value
	for i in decks.duplicate():
		var grid = Control.new()
		grid.custom_minimum_size = grid_size
		var deck_name = Label.new()
		var leader = load("res://game-components/card/card.tscn").instantiate()
		var leader_id
		for ii in decks[i]:
			if "leader" in ii:
				leader_id = ii

		leader.card_id = leader_id
		deck_name.size = Vector2(147.2 , 34)
		deck_name.position = Vector2(0 , 170.8)
		deck_name.text = i
		deck_name.theme = load("res://deck-builder/deck.tres")
		deck_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		deck_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		grid.add_child(deck_name)
		grid.add_child(leader)
		$deck_choser/GridContainer.add_child(grid)
		leader.scale *= grid_size * 0.85 / GameManager.card_size
		leader.position.x = (grid_size.x - GameManager.card_texture_size.x * leader.scale.x) / 2







func _on_menu_inputed(event , sender):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			self.chosen_mode = sender.get_meta("gamemode")

func set_chosen_mode(value):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_parallel(true)
	
	chosen_mode = value
	
	for i in game_option_button:
		tween.tween_property(i , "modulate" , Color.YELLOW if i.get_meta("gamemode") == chosen_mode else Color.WHITE , .2).set_ease(Tween.EASE_OUT_IN)
	

	match chosen_mode:
		"unrated":
			tween.tween_property($deck_choser , "size" , Vector2(666 , 442) , 1)
			tween.tween_property($deck_choser , "position" , Vector2(27 , 80) , 1)
			$deck_choser/GridContainer.columns = 4
			tween.tween_property($play_info , "size" , Vector2(287 , 442) , 1)
			tween.tween_property($play_info , "position" , Vector2(726 , 80) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "position" , Vector2(50 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "position" , Vector2(50 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "modulate:a" , 0 , 1)
			pass
		"competitive":
			tween.tween_property($deck_choser , "size" , Vector2(666 , 442) , 1)
			tween.tween_property($deck_choser , "position" , Vector2(27 , 80) , 1)
			$deck_choser/GridContainer.columns = 4
			tween.tween_property($play_info , "size" , Vector2(287 , 442) , 1)
			tween.tween_property($play_info , "position" , Vector2(726 , 80) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "position" , Vector2(50 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "position" , Vector2(50 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "modulate:a" , 0 , 1)
			pass
		"local":
			tween.tween_property($deck_choser , "size" , Vector2(470 , 442) , 1)
			tween.tween_property($deck_choser , "position" , Vector2(27 , 80) , 1)
			$deck_choser/GridContainer.columns = 3
			tween.tween_property($play_info , "size" , Vector2(517 , 442) , 1)
			tween.tween_property($play_info , "position" , Vector2(496 , 80) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "position" , Vector2(46 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "position" , Vector2(287 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "modulate:a" , 1 , 1)
			pass


