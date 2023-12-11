extends Node2D


var all_cards = []

var grid_size = Vector2(92 * 2.25 , 128 * 2.25)

var max_lad = 15
var max_leader = 1

var deck = []
var chosen_deck = []
var chosen_deck_name

enum {
	EDIT,
	CREATE
}

var mode = EDIT

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in GameData.card_database:
		var grid = Control.new()
		grid.name = i
		grid.custom_minimum_size = grid_size
		grid.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var card = load("res://game-components/card/card.tscn").instantiate()
		card.name = i
		card.card_id = i
		grid.add_child(card)
		get_node("card/deck_selection/" + GameData.card_database[i].region + "/GridContainer").add_child(grid)
		if card.card_information.type == "Leader":
			get_node("card/deck_selection/" + GameData.card_database[i].region + "/GridContainer").move_child(grid , 0)
		card.scale *= grid_size / GameManager.card_size
		card.mouse_event.connect(card_inputed)
		card.state = Card.card_state.IN_PREVIEW
		
	if mode == EDIT:
		for i in chosen_deck:
			add_to_deck(i)
			pass
		$selected_card/LineEdit.text = chosen_deck_name
	pass

func card_inputed(card , event):
	var result = add_to_deck(card.card_id)
	if result == 1: GameManager.play_sound_effect("res://sound-effect/gui_db_addcard.wav")


func add_to_deck(card):
	if GameData.card_database[card].type == "Leader":
		var leader_count = 0
		for i in deck:
			if GameData.card_database[i].type == "Leader":
				leader_count += 1
		if leader_count + 1 > max_leader:return 0
	
	if GameData.card_database[card].type == "Lad":
		var lad_count = 0
		for i in deck:
			if GameData.card_database[i].type == "Lad":
				lad_count += 1
		if lad_count + 1 > max_lad:return 0
	
	
	deck.append(card)
	var card_label = get_node("selected_card/ScrollContainer/cards").get_node(card)
	if card_label == null:
		card_label = Control.new()
		card_label.custom_minimum_size = Vector2(250 , 64)
		card_label.name = card
		card_label.gui_input.connect(
			func(event):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
					if event.pressed:
						
						remove_from_deck(card)
				pass
		)
		
		var amount_of_added_card = get_amount_of_added_card(card)
		
		var card_frame = TextureRect.new()
		card_frame.texture = load("res://gui/dbCard_" + GameData.card_database[card].type.to_lower() + ".png")
		card_frame.size = Vector2(250 , 64)
		card_frame.position = Vector2(0 , 0)
		card_frame.stretch_mode = TextureRect.STRETCH_KEEP
		
		var card_name = Label.new()
		card_name.name = "card_name"
		card_name.size = Vector2(174 , 64)
		card_name.position = Vector2(20 , 0)
		card_name.text = GameData.card_database[card].name
		card_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		card_name.theme = load("res://deck-builder/deck.tres")
		card_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		var card_amount = Label.new()
		card_amount.name = "card_amount"
		card_amount.size = Vector2(64 , 64)
		card_amount.position = Vector2(174 , 0)
		card_amount.text = "x" + str(amount_of_added_card)
		card_amount.theme = load("res://deck-builder/deck.tres")
		card_amount.vertical_alignment = VERTICAL_ALIGNMENT_CENTER		
		card_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		
		card_label.add_child(card_frame)
		card_label.add_child(card_name)
		card_label.add_child(card_amount)
		
		%cards.add_child(card_label)
		if GameData.card_database[card].type == "Leader":
			%cards.move_child(card_label , 0)
			card_name.modulate = Color.YELLOW
			card_amount.modulate = Color.YELLOW
			
			
		pass
	else:
		var amount_of_added_card = get_amount_of_added_card(card)
		
		var card_amount = card_label.get_node("card_amount")
		card_amount.name = "card_amount"
		card_amount.text = "x" + str(amount_of_added_card)
	
	return 1


func get_amount_of_added_card(card_id):
	var amount_of_added_card = 0
	
	for i in deck:
		if i == card_id:
			amount_of_added_card += 1
	
	return amount_of_added_card

func remove_from_deck(card):
	GameManager.play_sound_effect("res://sound-effect/gui_db_delcard.wav")
	var index = deck.find(card , 0)
	if index != -1:
		deck.pop_at(index)
	
	var card_label = get_node("selected_card/ScrollContainer/cards").get_node(card)
	
	var amount_of_added_card = get_amount_of_added_card(card)
	
	if amount_of_added_card <= 0:
		card_label.queue_free()
		return
	
	card_label.get_node("card_amount").text = "x" + str(amount_of_added_card)
	GameManager.play_sound_effect("res://sound-effect/gui_db_delcard.wav")

func _on_button_pressed():
	$selected_card/Button.disabled = true
	var deck_name = $selected_card/LineEdit.text.strip_edges(true , true)
	var leader_count = 0
	var lad_count = 0
	for i in deck:
		if GameData.card_database[i].type == "Leader":
			leader_count += 1
		if GameData.card_database[i].type == "Lad":
			lad_count += 1

	if !leader_count == max_leader: return
	if !lad_count == max_lad: return
	
	if deck_name == "": return
	
	GameManager.play_sound_effect("res://sound-effect/gui_click.wav")
	var firestore_collection = Firebase.Firestore.collection("users")
	var had_decks = GameData.user_data.doc_fields.decks


	if mode == EDIT:
		if had_decks.has(deck_name) and deck_name != chosen_deck_name:return
		if deck_name != chosen_deck_name:
			had_decks.erase(chosen_deck_name)
	if mode == CREATE:
		if had_decks.has(deck_name): return
		
	had_decks[deck_name] = deck
	
	
	var up_task: FirestoreTask = firestore_collection.update(GameData.user_data.doc_name , {'decks' : had_decks})
	await up_task.task_finished
	firestore_collection.get_doc(Firebase.Auth.auth.localid)
	GameData.user_data = await firestore_collection.get_document
	
	
	turn_off_deck_builder()

func turn_off_deck_builder():
	SceneChanger.change_scene("res://title-screen/title_screen.tscn" , "texture_fade" , "texture_fade")

func _on_back_pressed():
	GameManager.play_sound_effect("res://sound-effect/gui_click.wav")
	turn_off_deck_builder()
	


func _on_deck_selection_tab_button_pressed(tab):
	GameManager.play_sound_effect("res://sound-effect/gui_click.wav")


func _on_deck_selection_tab_clicked(tab):
	GameManager.play_sound_effect("res://sound-effect/gui_click.wav")
