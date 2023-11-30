extends Node2D

var player_name
var enemy_name

var player_leader
var enemy_leader

var player_deck
var enemy_deck

var enemy_peer_id

var data

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
	
	var firestore_user_collection : FirestoreCollection = Firebase.Firestore.collection("users")
	firestore_user_collection.get_doc(JSON.parse_string(data.players)[str(Client.peer_id)].player_id)

	var player_data = await firestore_user_collection.get_document
	player_name = player_data.doc_fields.in_game_name

	
	firestore_user_collection.get_doc(JSON.parse_string(data.players)[enemy_peer_id].player_id)
	
	var enemy_data = await firestore_user_collection.get_document
	enemy_name = enemy_data.doc_fields.in_game_name
	
	$hud/enemy/enemy_banner/enemy_name.text = enemy_name
	$hud/player/player_banner/player_name.text = player_name
	


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
