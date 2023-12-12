extends Control


var hand = []
var hand_focus = false : set = set_hand_focus



func _ready():
	self.hand_focus = false


func set_hand_focus(value):
	hand_focus = value
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	
	if hand_focus:
		tween.tween_property(self , "position:y" , 280 , 1)
	else:
		tween.tween_property(self , "position:y" , 535 , 1)

func add_to_hand(card):
	add_child(card)
	
	card.position.x = size.x / 2
	card.position.y = 104
	
	card.scale =  GameManager.card_size/GameManager.card_texture_size * 2
	card.state = Card.card_state.IN_HAND
	
	card.press_play.connect(
		func():
			if get_tree().current_scene.turn_owner == multiplayer.get_unique_id():
				remove_from_hand(card)
				get_tree().current_scene.get_node("dragging_canvas").add_child(card)
				card.state = Card.card_state.IS_DRAGGING
				card.scale = GameManager.card_size/GameManager.card_texture_size
			pass
	)
	
	card.return_to_hand.connect(
		func():
			card.get_parent().remove_child(card)
			add_to_hand(card)
	)
	
	card.place.connect(
		func(slot):
			get_tree().current_scene.play_card.rpc(card , card.card_id , slot.row , slot.column)
	)
	
	
	hand_update()
	
	
	
func hand_update():
	print(hand.size())
	var whole_hand_size = ((hand.size() - 1) * (GameManager.card_size.x + 10) * 2) + GameManager.card_size.x * 2
	var middle_of_hand = size.x / 2
	
	var start_pos = middle_of_hand - (whole_hand_size / 2)
	
	
	
	for card in hand:
		var tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.set_parallel(true)
		tween.tween_property(card , "position:x" , start_pos + hand.find(card) * (GameManager.card_size.x + 10) * 2 , 1)
#		position.x = start_pos + hand.find(card) * (GameManager.card_size.x + 10) * 2
		
		
func remove_from_hand(card):
	card.get_parent().remove_child(card)
	
	
	hand_update()

func _process(delta):
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		if hand_focus == true:
			self.hand_focus = false
	else:
		if hand_focus == false:
			self.hand_focus = true

	hand = get_children()
	pass




func _on_child_entered_tree(node):
	hand = get_children()


func _on_child_exiting_tree(node):
		hand = get_children()


func _on_child_order_changed():
	hand = get_children()
