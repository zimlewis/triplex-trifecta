extends NinePatchRect

@onready var game_option_button = $gamemode/HBoxContainer.get_children()
var chosen_mode : String : set = set_chosen_mode
var decks : set = set_decks
var grid_size = Vector2(147.2 , 204.8)
var chosen_deck

func _ready():
	chosen_mode = "unrated"
	for i in game_option_button:
		i.connect("menu_inputed" , _on_menu_inputed)

func set_decks(value):
	if $play_info/deck_hover.get_child(0) != null:
		$play_info/deck_hover.get_child(0).queue_free()
	$play_info/play.disabled = true
	$play_info/chosen_deck_name.text = ""
	decks = value
	for i in $deck_choser/GridContainer.get_children():
		i.queue_free()
	for i in decks.duplicate():
		var grid = Control.new()
		grid.custom_minimum_size = grid_size
		grid.name = i
		grid.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					choose_deck(i)
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
				if event.pressed:
					var deck_to_inspect = decks[i].duplicate()
					GameManager.inspect(deck_to_inspect)
					pass
		)
		
		
		var leader = load("res://game-components/card/card.tscn").instantiate()
		var leader_id
		for ii in decks[i]:
			if "leader" in ii:
				leader_id = ii

		leader.card_id = leader_id
		leader.scale *= grid_size * 0.85 / GameManager.card_size
		leader.position.x = (grid_size.x - GameManager.card_texture_size.x * leader.scale.x) / 2
		
		
		
		
		
		var deck_name = Label.new()
		deck_name.size = Vector2(147.2 , 34)
		deck_name.position = Vector2(0 , 170.8)
		deck_name.text = i
		deck_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		deck_name.theme = load("res://title-screen/deck.tres")
		deck_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		deck_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		
		grid.add_child(deck_name)
		grid.add_child(leader)
		$deck_choser/GridContainer.add_child(grid)
		
		leader.state = Card.card_state.IS_DECK_LEADER






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
			pass
		"competitive":
			pass
		"local":
			pass

func choose_deck(deck):
	if $play_info/deck_hover.get_child(0) != null:
		$play_info/deck_hover.get_child(0).queue_free()
	var deck_leader = load("res://game-components/card/card.tscn").instantiate()
	var leader_id
	for i in decks[deck]:
		if "leader" in i:
			leader_id = i

	deck_leader.card_id = leader_id
	deck_leader.scale *= $play_info/deck_hover.size / GameManager.card_size
	
	$play_info/deck_hover.add_child(deck_leader)
	$play_info/chosen_deck_name.text = deck
	$play_info/play.disabled = false
	deck_leader.state = Card.card_state.IS_DECK_LEADER
	
	chosen_deck = deck


func _on_play_pressed():
	var set_queue_scene_value = func(queue_scene):
		queue_scene.chosen_deck = self.decks[self.chosen_deck]
		queue_scene.gamemode = self.chosen_mode
	await SceneChanger.change_scene("res://match-queue/match_queue.tscn" , "texture_fade" , "texture_fade" , set_queue_scene_value)
