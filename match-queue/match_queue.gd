extends Control

var tween
var queue_time = 0
var chosen_deck
var gamemode

# Called when the node enters the scene tree for the first time.
func _ready():
	Client.receive_data.connect(on_receive_data)
	if gamemode != "challenge":
		$normal_mode.visible = true
		$challenge_mode.visible = false
		tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.set_loops()
		tween.tween_property($normal_mode/logo , "rotation" , deg_to_rad(180) , 1).as_relative()
		$normal_mode/Timer.start()
		
		var queue_request_message = {
			"message" : Client.Message.JOIN_QUEUE,
			"client_id" : Client.peer_id,
			"rp" : GameData.user_data.doc_fields.rank,
			"elo" : GameData.user_data.doc_fields.elo,
			"deck" : JSON.stringify(chosen_deck),
			"player_id" : GameData.user_data.doc_name,
			"gamemode" : gamemode
		}
		
		Client.send_to_server(queue_request_message)
	else:
		$normal_mode.visible = false
		$challenge_mode.visible = true


func _on_timer_timeout():
	queue_time += 1
	
	var minute = queue_time / 60
	var second = queue_time - minute * 60
	
	$normal_mode/queue_time.text = ("0" if minute < 10 else "") + str(minute) + ":" + ("0" if second < 10 else "") + str(second)


func _on_cancel_pressed():
	var queue_cancel_message = {
		"message" : Client.Message.CANCEL_QUEUE,
		"client_id" : Client.peer_id
	}
	
	Client.send_to_server(queue_cancel_message)
	
	SceneChanger.change_scene("res://title-screen/title_screen.tscn" , "texture_fade" , "texture_fade")


func _on_line_edit_text_changed(new_text):
	if $challenge_mode/LineEdit.text.strip_edges(true , true) == "":
		$challenge_mode/join.disabled = true
	else:
		$challenge_mode/join.disabled = false


func _on_create_pressed():
	$challenge_mode/create.disabled = true
	$challenge_mode/join.disabled = true
	var queue_request_message = {
		"message" : Client.Message.LOBBY,
		"client_id" : Client.peer_id,
		"deck" : JSON.stringify(chosen_deck),
		"player_id" : GameData.user_data.doc_name,
		"lobby" : "create new lobby"
	}
	
	Client.send_to_server(queue_request_message)

func on_receive_data(data):
	print(data)
	if data.message == Client.Message.LOBBY:
		if data.state == "create":
			$challenge_mode/LineEdit.editable = false
			$challenge_mode/LineEdit.text = data.lobby
		if data.state == "start":
			var set_play_value = func(fight_scene):
				fight_scene.data = data
			await SceneChanger.change_scene("res://fight-screen/fight_screen.tscn" , "texture_fade" , "texture_fade" , set_play_value)

			pass
	pass

func _on_join_pressed():
	$challenge_mode/create.disabled = true
	$challenge_mode/join.disabled = true
	if $challenge_mode/LineEdit.editable:
		var queue_request_message = {
			"message" : Client.Message.LOBBY,
			"client_id" : Client.peer_id,
			"deck" : JSON.stringify(chosen_deck),
			"player_id" : GameData.user_data.doc_name,
			"lobby" : $challenge_mode/LineEdit.text
		}
		
		Client.send_to_server(queue_request_message)
