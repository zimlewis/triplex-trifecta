extends NinePatchRect

@onready var game_option_button = $gamemode/HBoxContainer.get_children()
var chosen_mode : String : set = set_chosen_mode




func _ready():
	chosen_mode = "unrated"
	for i in game_option_button:
		i.connect("menu_inputed" , _on_menu_inputed)



func _on_menu_inputed(event , sender):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			self.chosen_mode = sender.get_meta("gamemode")

func set_chosen_mode(value):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART).set_parallel(true)
	
	chosen_mode = value
	
	for i in game_option_button:
		tween.tween_property(i , "modulate" , Color.YELLOW if i.get_meta("gamemode") == chosen_mode else Color.WHITE , .2).set_ease(Tween.EASE_OUT_IN)
	

	match chosen_mode:
		"unrated":
			tween.tween_property($deck_choser , "size" , Vector2(666 , 442) , 1)
			tween.tween_property($deck_choser , "position" , Vector2(27 , 80) , 1)
			$deck_choser/GridContainer.columns = 6
			tween.tween_property($play_info , "size" , Vector2(287 , 442) , 1)
			tween.tween_property($play_info , "position" , Vector2(726 , 80) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "position" , Vector2(50 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "position" , Vector2(50 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "modulate:a" , 0 , 1)
			pass
		"competitive":
			tween.tween_property($deck_choser , "size" , Vector2(666 , 442) , 1)
			tween.tween_property($deck_choser , "position" , Vector2(27 , 80) , 1)
			$deck_choser/GridContainer.columns = 6
			tween.tween_property($play_info , "size" , Vector2(287 , 442) , 1)
			tween.tween_property($play_info , "position" , Vector2(726 , 80) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "position" , Vector2(50 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "position" , Vector2(50 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "modulate:a" , 0 , 1)
			pass
		"local":
			tween.tween_property($deck_choser , "size" , Vector2(431 , 442) , 1)
			tween.tween_property($deck_choser , "position" , Vector2(27 , 80) , 1)
			var lambda = func():
				await get_tree().create_timer(.3).timeout
				$deck_choser/GridContainer.columns = 5
				await get_tree().create_timer(.2).timeout
				$deck_choser/GridContainer.columns = 4
			lambda.call()
			tween.tween_property($play_info , "size" , Vector2(517 , 442) , 1)
			tween.tween_property($play_info , "position" , Vector2(496 , 80) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "size" , Vector2(184 , 256) , 1)
			tween.tween_property($play_info/chosen_deck_1 , "position" , Vector2(46 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "position" , Vector2(287 , 84) , 1)
			tween.tween_property($play_info/chosen_deck_2 , "modulate:a" , 1 , 1)
			pass


