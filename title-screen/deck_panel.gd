extends NinePatchRect

var grid_size = Vector2(147.2 , 204.8)
var initialized = false

var decks : set = set_decks

var chosen_deck

func set_decks(value):
	if $play_info/deck_hover.get_child(0) != null:
		$play_info/deck_hover.get_child(0).queue_free()
	chosen_deck = ""
	$play_info/edit_button.disabled = true
	$play_info/remove_button.disabled = true
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
		
		
		

# Called when the node enters the scene tree for the first time.
func _ready():
	
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
	deck_leader.state = Card.card_state.IS_DECK_LEADER
	$play_info/chosen_deck_name.text = deck
	chosen_deck = deck
	$play_info/edit_button.disabled = false
	$play_info/remove_button.disabled = false
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_create_button_pressed():
	GameManager.play_sound_effect("res://sound-effect/gui_click.wav")
	var set_deck_builder_value = func(deck_builder):
		deck_builder.mode = deck_builder.CREATE
	var deck_builder = await SceneChanger.change_scene("res://deck-builder/deck_builder.tscn" , "texture_fade" , "texture_fade" , set_deck_builder_value)


func _on_edit_button_pressed():
	GameManager.play_sound_effect("res://sound-effect/gui_click.wav")
	var set_deck_builder_value = func(deck_builder):
		deck_builder.mode = deck_builder.EDIT
		deck_builder.chosen_deck = self.decks[self.chosen_deck]
		deck_builder.chosen_deck_name = self.chosen_deck
	var deck_builder = await SceneChanger.change_scene("res://deck-builder/deck_builder.tscn" , "texture_fade" , "texture_fade" , set_deck_builder_value)



func _on_remove_button_pressed():
	GameManager.play_sound_effect("res://sound-effect/gui_click.wav")
	var firestore_collection = Firebase.Firestore.collection("users")
	var had_decks = GameData.user_data.doc_fields.decks
	
	had_decks.erase(chosen_deck)
	var up_task: FirestoreTask = firestore_collection.update(GameData.user_data.doc_name , {'decks' : had_decks})
	
	
	chosen_deck = ""
	$play_info/edit_button.disabled = true
	$play_info/remove_button.disabled = true
	$play_info/chosen_deck_name.text = ""
	if $play_info/deck_hover.get_child(0) != null:
		$play_info/deck_hover.get_child(0).queue_free()
	
	await up_task.task_finished
	firestore_collection.get_doc(Firebase.Auth.auth.localid)
	GameData.user_data = await firestore_collection.get_document
	decks = GameData.user_data.doc_fields.decks
	$"../play_panel".decks = GameData.user_data.doc_fields.decks
