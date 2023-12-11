extends Node2D

var player_name
var enemy_name

var player_leader
var enemy_leader

var player_deck
var enemy_deck

var enemy_peer_id

var data

var turn_owner : set = set_turn

@onready var turn_display = $hud/player/turn_display
@onready var turn_display_text = $hud/player/turn_display/Label
@onready var pass_button = $hud/player/pass_button

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in JSON.parse_string(data.players):
		if i != str(Client.peer_id):
			enemy_peer_id = i
			continue
	
	for i in JSON.parse_string(JSON.parse_string(data.players)[str(Client.peer_id)].deck):
		if "leader" in i:
			player_leader = i
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
	


func set_turn(t):
	turn_owner = t
	
	turn_display_text.text = (player_name if int(t) == multiplayer.get_unique_id() else enemy_name) + "'s turn"
	
	turn_display.texture = load("res://fight-screen/hud/turnSignal_p1.png" if int(t) == int(multiplayer.get_unique_id()) else "res://fight-screen/hud/turnSignal_p2.png")
	
	pass_button.disabled = !(int(t) == multiplayer.get_unique_id())
	
	
	

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
		self.turn_owner = int(multiplayer.get_peers()[0])
		return
	if turn_owner == int(multiplayer.get_peers()[0]):
		self.turn_owner = multiplayer.get_unique_id()
		return
#	print(multiplayer.get_unique_id() , ": " , turn_owner , "\nis current turn: " , int(turn_owner) == multiplayer.get_unique_id())
	pass

func _on_pass_button_pressed():
	end_turn.rpc()


func _on_debug_pressed():
	print(multiplayer.get_peers())
	pass
