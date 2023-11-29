extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for i in GameData.card_database:
		var card = preload("res://game-components/card/card.tscn").instantiate()
		card.card_id = i
		card.position = Vector2(index * GameManager.card_size.x + 50 , 0)
		index += 1
		
		add_child(card)


func _on_data_test_pressed():
	var message = {
		"message" : Client.Message.USER_CONNECTED,
		"data" : "test"
	}
	
	Client.send_to_server(message)
	
