extends Node2D

var player_name
var enemy_name

var player_leader
var enemy_leader

var player_deck

var enemy_peer_id

var data

var turn_owner : set = set_turn



signal game_start
signal game_end

signal turn_start
signal turn_end

@onready var turn_display = $hud/turn_display
@onready var turn_display_text = $hud/turn_display/Label
@onready var pass_button = $hud/pass_button
@onready var player_hand = $hud/player/player_hand



# Called when the node enters the scene tree for the first time.
func _ready():
	for i in JSON.parse_string(data.players):
		if i != str(Client.peer_id):
			enemy_peer_id = i
			continue
	
	player_deck = JSON.parse_string(JSON.parse_string(data.players)[str(Client.peer_id)].deck)
	
	for i in player_deck:
		if "leader" in i:
			player_leader = i
			player_deck.pop_at(player_deck.find(i))
	for i in JSON.parse_string(JSON.parse_string(data.players)[enemy_peer_id].deck):
		if "leader" in i:
			enemy_leader = i
	
	$hud/enemy/enemy_banner/enemy_leader.card_id = enemy_leader
	$hud/player/player_banner/player_leader.card_id = player_leader
	
	$hud/enemy/enemy_banner/enemy_leader.init_card()
	$hud/player/player_banner/player_leader.init_card()
	

	
	player_name = JSON.parse_string(data.players)[str(Client.peer_id)].player_name
	enemy_name = JSON.parse_string(data.players)[enemy_peer_id].player_name
	
	
	$hud/enemy/enemy_banner/enemy_name.text = enemy_name
	$hud/player/player_banner/player_name.text = player_name
	
	self.turn_owner = int(data.host)
	
	
	game_start.connect(on_game_start)
	game_end.connect(on_game_end)
	turn_start.connect(on_turn_start)
	turn_end.connect(on_turn_end)
	
	game_start.emit()
	

func on_game_start():
	if multiplayer.get_unique_id() == int(turn_owner):
		print(multiplayer.get_unique_id())
		turn_start.emit()
	
	for i in range(3):
		var card_id = player_deck[randi() % player_deck.size()]
		var card = load("res://game-components/card/card.tscn").instantiate()
		
		card.name = card_id + "_" + str(player_hand.hand.size())
		card.card_id = card_id
		
		card.is_ally = true
		
		player_hand.add_to_hand(card)
	

func on_game_end():
	pass

func on_turn_start():
	pass

func on_turn_end():
	pass

func set_turn(t):
	turn_owner = t
	
	turn_display_text.text = (player_name if int(t) == multiplayer.get_unique_id() else enemy_name) + "'s turn"
	
	turn_display.texture = load("res://fight-screen/hud/turnSignal_p1.png" if int(t) == int(multiplayer.get_unique_id()) else "res://fight-screen/hud/turnSignal_p2.png")
	
	pass_button.disabled = !(int(t) == multiplayer.get_unique_id())
	
	if int(t) == multiplayer.get_unique_id(): turn_start.emit()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#
#@rpc("any_peer")
#func ping():
#	print(str(multiplayer.get_remote_sender_id()))

@rpc("any_peer" , "call_local")
func end_turn():
	if !(multiplayer.get_peers().size() > 0): return
	if turn_owner == int(multiplayer.get_unique_id()):
		turn_end.emit()
		self.turn_owner = int(multiplayer.get_peers()[0])
		return
	if turn_owner == int(multiplayer.get_peers()[0]):
		self.turn_owner = multiplayer.get_unique_id()
		return

func _on_pass_button_pressed():
	end_turn.rpc()


func _on_debug_pressed():
	print(multiplayer.get_peers())
	pass

@rpc("any_peer" , "call_local")
func play_card(card , card_id , row , column):
	var slot = get_node("board").get_child(row).get_child(column)
	if multiplayer.get_remote_sender_id() != multiplayer.get_unique_id():
		var new_card = load("res://game-components/card/card.tscn").instantiate()
		new_card.is_ally = false
		new_card.card_id = card_id
		get_node("cards").add_child(new_card)

		new_card.state = Card.card_state.IN_PLAY
		new_card.global_position = slot.global_position
	if multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		card.is_ally = true
		card.state = Card.card_state.IN_PLAY
		get_node("dragging_canvas").remove_child(card)
		get_node("cards").add_child(card)
		card.global_position = slot.global_position
		pass
	
	slot.remove_from_group("dropable_areas")
		
	pass

