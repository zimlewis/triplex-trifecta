extends Control

var tween
var queue_time = 0
var chosen_deck

# Called when the node enters the scene tree for the first time.
func _ready():
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_loops()
	tween.tween_property($logo , "rotation" , deg_to_rad(180) , 1).as_relative()
	
	var queue_request_message = {
		"message" : Client.Message.JOIN_QUEUE,
		"client_id" : Client.peer_id,
		"rp" : GameData.user_data.doc_fields.rank,
		"deck" : JSON.stringify(chosen_deck),
		"player_id" : GameData.user_data.doc_name
	}
	
	Client.send_to_server(queue_request_message)


func _on_timer_timeout():
	queue_time += 1
	
	var minute = queue_time / 60
	var second = queue_time - minute * 60
	
	$queue_time.text = ("0" if minute < 10 else "") + str(minute) + ":" + ("0" if second < 10 else "") + str(second)


func _on_cancel_pressed():
	var queue_cancel_message = {
		"message" : Client.Message.CANCEL_QUEUE,
		"client_id" : Client.peer_id
	}
	
	Client.send_to_server(queue_cancel_message)
	
	SceneChanger.change_scene("res://title-screen/title_screen.tscn" , "texture_fade" , "texture_fade")
