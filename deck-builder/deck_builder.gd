extends Node2D


var all_cards = []

var grid_size = Vector2(92 * 2.25 , 128 * 2.25)

var max_lad = 15
var max_leader = 1

var deck = []
var chosen_deck = []
var chosen_deck_name
var deck_panel
var play_panel

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
		
	if mode == EDIT:
		for i in chosen_deck:
			add_to_deck(i)
			pass
		$selected_card/LineEdit.text = chosen_deck_name
	pass

func card_inputed(card , event):
	add_to_deck(card.card_id)


func add_to_deck(card):
	if GameData.card_database[card].type == "Leader":
		var leader_count = 0
		for i in deck:
			if GameData.card_database[i].type == "Leader":
				leader_count += 1
		if leader_count + 1 > max_leader:return
	
	if GameData.card_database[card].type == "Lad":
		var lad_count = 0
		for i in deck:
			if GameData.card_database[i].type == "Lad":
				lad_count += 1
		if lad_count + 1 > max_lad:return
		
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
		
		
		var card_name = Label.new()
		card_name.name = "card_name"
		card_name.size = Vector2(174 , 64)
		card_name.position = Vector2(0 , 0)
		card_name.text = GameData.card_database[card].name
		card_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		card_name.theme = load("res://deck-builder/deck.tres")
		
		var card_amount = Label.new()
		card_amount.name = "card_amount"
		card_amount.size = Vector2(74 , 64)
		card_amount.position = Vector2(174 , 0)
		card_amount.text = "x" + str(amount_of_added_card)
		card_amount.theme = load("res://deck-builder/deck.tres")
		
		card_label.add_child(card_name)
		card_label.add_child(card_amount)
		
		%cards.add_child(card_label)
		if GameData.card_database[card].type == "Leader":
			%cards.move_child(card_label , 0)
			card_label.modulate = Color.YELLOW
			
		pass
	else:
		var amount_of_added_card = get_amount_of_added_card(card)
		
		var card_amount = card_label.get_node("card_amount")
		card_amount.name = "card_amount"
		card_amount.text = "x" + str(amount_of_added_card)
		pass

func get_amount_of_added_card(card_id):
	var amount_of_added_card = 0
	
	for i in deck:
		if i == card_id:
			amount_of_added_card += 1
	
	return amount_of_added_card

func remove_from_deck(card):
	var index = deck.find(card , 0)
	if index != -1:
		deck.pop_at(index)
	
	var card_label = get_node("selected_card/ScrollContainer/cards").get_node(card)
	
	var amount_of_added_card = get_amount_of_added_card(card)
	
	if amount_of_added_card <= 0:
		card_label.queue_free()
		return
	
	card_label.get_node("card_amount").text = "x" + str(amount_of_added_card)


func _on_button_pressed():
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
	deck_panel.decks = GameData.user_data.doc_fields.decks
	play_panel.decks = GameData.user_data.doc_fields.decks
	


func _on_back_pressed():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT).set_parallel(false)
	var cover = ColorRect.new()
	get_tree().get_root().add_child(cover)
	cover.position = Vector2(0 , 0)
	cover.size = Vector2(1280 , 720)
	cover.modulate = Color.BLACK
	cover.modulate.a = 0
	tween.tween_property(cover , "modulate:a" , 1 , 1)
	tween.tween_callback(queue_free)
	tween.tween_property(cover , "modulate:a" , 0 , 1)
	tween.tween_callback(cover.queue_free)
	
