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
var webrtc_peer = WebRTCMultiplayerPeer.new()
var peer_id

var connected_peers = []

signal receive_data(data)

func _ready():
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	receive_data.connect(on_receive_data)
	connect_to_server("")
	pass

func connected_to_server():
	pass

func peer_connected(id):
	connected_peers.append(id)
	

func peer_disconnected(id):
	connected_peers.pop_at(connected_peers.find(id))

func _process(delta):
	peer.poll()
	if !(peer.get_available_packet_count() > 0): return
	
	var packet = peer.get_packet()
	
	if packet == null: return
		
	var data_string = packet.get_string_from_utf8()
	var data = JSON.parse_string(data_string)
	
	receive_data.emit(data)


func connect_to_server(ip):
	var error = peer.create_client("ws://127.0.0.1:8915")
	print(error)
	if error != OK:
		connect_to_server("")
	
	

func on_receive_data(data):
	if data.message == Message.ID:
		peer_id = data.id
		connected(data.id)
	if data.message == Message.USER_CONNECTED:
		create_peer(data.id)
	
	if data.message == Message.LOBBY:
		if data.state == "start":
			var players = JSON.parse_string(data.players)
	
	if data.message == Message.CANDIDATE:
		if webrtc_peer.has_peer(int(data.original_peer)):
			webrtc_peer.get_peer(int(data.original_peer)).connection.add_ice_candidate(data.media , int(data.index) , data.sdp)
	
	if data.message == Message.ANSWER:
		if webrtc_peer.has_peer(int(data.original_peer)):
			webrtc_peer.get_peer(int(data.original_peer)).connection.set_remote_description("answer" , data.data)
	
	if data.message == Message.OFFER:
		if webrtc_peer.has_peer(int(data.original_peer)):
			webrtc_peer.get_peer(int(data.original_peer)).connection.set_remote_description("offer" , data.data)
		

func create_peer(id):
	if int(id) != int(peer_id):
		var peer : WebRTCPeerConnection = WebRTCPeerConnection.new()
		peer.initialize({
			"iceServers" : [{"urls" : ["stun:stun1.l.google.com:19302"]}]
		})
		
		
		peer.session_description_created.connect(offer_created.bind(int(id)))
		peer.ice_candidate_created.connect(ice_candidate_created.bind(int(id)))
		
		var err = webrtc_peer.add_peer(peer , int(id))
		
		print("rtc add peer: " , err)
		
		if int(id) < webrtc_peer.get_unique_id():
			peer.create_offer()
			
		pass
	pass

func offer_created(type , sdp , id):
	
	if !webrtc_peer.has_peer(id): return
	
	webrtc_peer.get_peer(id).connection.set_local_description(type , sdp)
	
	
	if type == "offer":
		send_offer(id , sdp)
	else:
		send_answer(id , sdp)
	pass

func send_offer(id , data):
	var message = {
		"peer" : id,
		"original_peer" : peer_id,
		"message" : Message.OFFER,
		"data" : data
	}
	
	send_to_server(message)
	pass

func send_answer(id , data):
	var message = {
		"peer" : id,
		"original_peer" : peer_id,
		"message" : Message.ANSWER,
		"data" : data
	}
	
	send_to_server(message)
	pass

func ice_candidate_created(media , index , sdp_name , id):
	
	var message = {
		"peer" : id,
		"original_peer" : peer_id,
		"message" : Message.CANDIDATE,
		"media" : media,
		"index" : index,
		"sdp" : sdp_name
	}
	
	send_to_server(message)
	pass

func send_to_server(data):
	var message_bytes = JSON.stringify(data).to_utf8_buffer()
	
	peer.put_packet(message_bytes)
	
func connected(id):
	webrtc_peer.create_mesh(int(id))
	multiplayer.multiplayer_peer = webrtc_peer
	pass
