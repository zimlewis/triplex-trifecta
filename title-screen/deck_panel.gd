extends NinePatchRect

var grid_size = Vector2(147.2 , 204.8)
var initialized = false

var decks : set = set_decks

func set_decks(value):
	decks = value
	for i in decks.duplicate():
		var grid = Control.new()
		grid.custom_minimum_size = grid_size
		
		
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
		deck_name.theme = load("res://deck-builder/deck.tres")
		deck_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		deck_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		
		grid.add_child(deck_name)
		grid.add_child(leader)
		$deck_choser/GridContainer.add_child(grid)
		
		
		
		

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	pass


func _on_create_button_pressed():
	var tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	var deck_builder = load("res://deck-builder/deck_builder.tscn").instantiate()
	get_tree().get_root().add_child(deck_builder)
	deck_builder.modulate.a = 0
	tween.tween_property(deck_builder , "modulate:a" , 1 , 1)
	

func _on_edit_button_pressed():
	var tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	var deck_builder = load("res://deck-builder/deck_builder.tscn").instantiate()
	get_tree().get_root().add_child(deck_builder)
	deck_builder.modulate.a = 0
	tween.tween_property(deck_builder , "modulate:a" , 1 , 1)
