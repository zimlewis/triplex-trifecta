extends Node2D


var thyena_cards = []
var tikkers_cards = []
var aouni_cards = []
var mysticle_cards = []
var wildcardz_cards = []
var kahn_cards = []
var reinalia_cards = []

var grid_size = Vector2(92 * 2.25 , 128 * 2.25)

var max_lad = 15
var max_leader = 1

var deck = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in GameData.card_database:
		var grid = Control.new()
		grid.name = i
		grid.custom_minimum_size = grid_size
		grid.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var card = preload("res://game-components/card/card.tscn").instantiate()
		card.name = i
		card.card_id = i
		grid.add_child(card)
		get_node("card/deck_selection/" + GameData.card_database[i].region + "/GridContainer").add_child(grid)
		if card.card_information.type == "Leader":
			get_node("card/deck_selection/" + GameData.card_database[i].region + "/GridContainer").move_child(grid , 0)
		card.scale *= grid_size / GameManager.card_size
		card.mouse_event.connect(card_inputed)

func card_inputed(card , event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			add_to_deck(card)

func add_to_deck(card):
	if card.card_information.type == "Leader":
		var leader_count = 0
		for i in deck:
			if GameData.card_database[i].type == "Leader":
				leader_count += 1
		if leader_count + 1 > max_leader:return
	
	if card.card_information.type == "Lad":
		var lad_count = 0
		for i in deck:
			if GameData.card_database[i].type == "Lad":
				lad_count += 1
		if lad_count + 1 > max_lad:return
		
	deck.append(card.card_id)
	var card_label = Label.new()
	card_label.text = " " + card.card_information.name
	card_label.theme = load("res://deck-builder/deck.tres")
	card_label.name = card.card_id + "_" + str(deck.size())
	card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	%cards.add_child(card_label)
	if card.card_information.type == "Leader":
		%cards.move_child(card_label , 0)
		card_label.modulate = Color.YELLOW
	card_label.mouse_filter = Control.MOUSE_FILTER_STOP
	card_label.gui_input.connect(
		func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					remove_from_deck(card)
			pass
	)

func remove_from_deck(card):
	var index = deck.find(card.card_id , 0)
	if index != -1:
		deck.pop_at(index)
	var card_label = null
	
	for i in %cards.get_children():
		if card.card_id in i.name:
			card_label = i
	
	card_label.queue_free()


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

	had_decks[deck_name] = deck
	var up_task: FirestoreTask = firestore_collection.update(GameData.user_data.doc_name , {'decks' : had_decks})


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
	
