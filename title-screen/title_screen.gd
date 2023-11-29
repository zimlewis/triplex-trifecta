extends Control

@onready var buttons_list = [
	get_node("%first_button"),
	get_node("%second_button"),
	get_node("%third_button")
]

var menu_list = [
	"Home",
	"Play",
	"Deck builder",
	"About us"
]

var menu_sprites = {
	"Home": {
		"icon" : preload("res://title-screen/sprites/home.png"),
		"title" : preload("res://title-screen/sprites/homeT.png")
	},
	"Play": {
		"icon" : preload("res://title-screen/sprites/play.png"),
		"title" : preload("res://title-screen/sprites/playT.png")
	},
	"Deck builder": {
		"icon" : preload("res://title-screen/sprites/deck.png"),
		"title" : preload("res://title-screen/sprites/deckT.png")
	},
	"About us": {
		"icon" : preload("res://title-screen/sprites/aboutUs.png"),
		"title" : preload("res://title-screen/sprites/aboutUsT.png")
	}
}

var index = 0 : set = set_index
@onready var input_buffer_timer = get_tree().create_timer(1.0)

func _ready():
	self.index = 1
	print(GameData.user_data)
	$account_bar/name.text = str(GameData.user_data.doc_fields.in_game_name)
	$account_bar/lv.text = "LV: " + str(GameData.user_data.doc_fields.lv)
	$account_bar/rank.text = "RP: " + str(GameData.user_data.doc_fields.rank)
	$deck_panel.decks = GameData.user_data.doc_fields.decks
	$play_panel.decks = GameData.user_data.doc_fields.decks
	pass


func set_index(value):
	var delta_value = index - value
	index = value
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	for i in len(buttons_list):
		if index == -2:
			index = 2
		
		tween.tween_property(buttons_list[i].get_node("text").get_material() , "shader_parameter/shake_rate" , 1 , 0.1)
		tween.tween_property(buttons_list[i].get_node("image").get_material() , "shader_parameter/shake_rate" , 1 , 0.1)
		
		var menu_index = i + index % 4 - 2
		buttons_list[i].get_node("text").texture = menu_sprites[menu_list[menu_index]]["title"]
		buttons_list[i].get_node("image").texture = menu_sprites[menu_list[menu_index]]["icon"]
		buttons_list[i].set_meta("action" , menu_list[menu_index])
		
		tween.tween_property(buttons_list[i].get_node("text").get_material() , "shader_parameter/shake_rate" , 0 , 0.1).set_delay(0.2)
		tween.tween_property(buttons_list[i].get_node("image").get_material() , "shader_parameter/shake_rate" , 0 , 0.1).set_delay(0.2)		
	
	
	for i in [$play_panel , $deck_panel , $about_us_panel]:
		if i.get_meta("showing") == true:
			tween.tween_property(i , "position:x" , -1174 if delta_value == -1 else 1486 , 1).from(116)
			pass
		pass
		
	match buttons_list[1].get_meta('action'):
		"Home":
			$play_panel.set_meta("showing" , false)
			$deck_panel.set_meta("showing" , false)
			$about_us_panel.set_meta("showing" , false)
			tween.tween_property($account_bar , "position:y" , 11 , 1)
			pass
		"Play":
			$play_panel.set_meta("showing" , true)
			$deck_panel.set_meta("showing" , false)
			$about_us_panel.set_meta("showing" , false)
			tween.tween_property($play_panel , "position:x" , 116 , 1).from(-1174 if delta_value == 1 else 1486)
			tween.tween_property($account_bar , "position:y" , -125 , 1)
			pass
		"Deck builder":
			$play_panel.set_meta("showing" , false)
			$deck_panel.set_meta("showing" , true)
			$about_us_panel.set_meta("showing" , false)
			tween.tween_property($deck_panel , "position:x" , 116 , 1).from(-1174 if delta_value == 1 else 1486)
			tween.tween_property($account_bar , "position:y" , -125 , 1)
			pass
		"About us":
			$play_panel.set_meta("showing" , false)
			$deck_panel.set_meta("showing" , false)
			$about_us_panel.set_meta("showing" , true)
			tween.tween_property($about_us_panel , "position:x" , 116 , 1).from(-1174 if delta_value == 1 else 1486)
			tween.tween_property($account_bar , "position:y" , -125 , 1)
			pass
	
	input_buffer_timer = get_tree().create_timer(0.5)

func _on_left_pressed():
	if is_equal_approx(input_buffer_timer.get_time_left() , 0.0):
		self.index -= 1


func _on_right_pressed():
	if is_equal_approx(input_buffer_timer.get_time_left() , 0.0):
		self.index += 1


func _on_first_button_gui_input(event):
#	print("input_buffer_timer.get_time_left(): {0}\nis_equal_approx(input_buffer_timer.get_time_left() , 0.0): {1}".format([input_buffer_timer.get_time_left() , is_equal_approx(input_buffer_timer.get_time_left() , 0.0)]))
	if event is InputEventMouseButton and is_equal_approx(input_buffer_timer.get_time_left() , 0.0):
		if event.button_mask == MOUSE_BUTTON_LEFT:
			self.index -= 1


func _on_second_button_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			pass


func _on_third_button_gui_input(event):
#	print("input_buffer_timer.get_time_left(): {0}\nis_equal_approx(input_buffer_timer.get_time_left() , 0.0): {1}".format([input_buffer_timer.get_time_left() , is_equal_approx(input_buffer_timer.get_time_left() , 0.0)]))
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT and is_equal_approx(input_buffer_timer.get_time_left() , 0.0):
			self.index += 1



func _on_log_out_btn_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_LEFT:
			await Firebase.Auth.logout()
			get_tree().change_scene_to_file("res://authentication/authentication.tscn")
			
