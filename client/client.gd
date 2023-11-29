extends Node

enum Message {
	ID,
	JOIN,
	USER_CONNECTED,
	USER_DISCONNECTED,
	LOBBY,
	CANDIDATE,
	OFFER,
	ANSWER,
	CHECK_IN,
	JOIN_QUEUE,
	CANCEL_QUEUE
}

var peer = WebSocketMultiplayerPeer.new()
var peer_id

func _ready():
	connect_to_server("")
	pass

func _process(delta):
	peer.poll()
	if !(peer.get_available_packet_count() > 0): return
	
	var packet = peer.get_packet()
	
	if packet == null: return
		
	var data_string = packet.get_string_from_utf8()
	var data = JSON.parse_string(data_string)
	
	if data.message == Message.ID:
		peer_id = data.id
	pass

func connect_to_server(ip):
	var error = peer.create_client("ws://127.0.0.1:8915")
	

func send_to_server(data):
	var message_bytes = JSON.stringify(data).to_utf8_buffer()
	
	peer.put_packet(message_bytes)
	
