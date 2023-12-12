extends Node2D
class_name Card

enum card_state{
	IN_PLAY,
	IN_HAND,
	IN_INSPECT,
	IN_PREVIEW,
	IS_DECK_LEADER,
	IS_DRAGGING
}

@onready var image = $image
@onready var frame = $frame

@onready var bar = $bar

@onready var stat_left = $bar/left/stat
@onready var stat_middle = $bar/middle/stat
@onready var stat_right = $bar/right/stat

@onready var stat_leader_left = $bar/left/leader_stat
@onready var stat_leader_right = $bar/right/leader_stat
@onready var stat_leader_middle = $bar/middle/leader_stat

@onready var effect_all = $bar_effect
@onready var effect_left = $bar_effect/left
@onready var effect_top = $bar_effect/top
@onready var effect_bottom = $bar_effect/bottom
@onready var effect_right = $bar_effect/right

@onready var card_name = $name
@onready var card_tittle = $title

@onready var ability_description = $card_description_frame

@onready var type_icon = $card_description_frame/detailed_information/type
@onready var region_icon = $card_description_frame/detailed_information/region

@onready var action_panel = $action_panel
@onready var drop_area = $drop_area

var mouse_in_card = false;
var is_ally = false

var body_ref : set = set_body_ref

signal press_play
signal press_ability

signal return_to_hand
signal place(area)

@export var card_id = "leader_thyena_citrious"
var card_information

var state : card_state = card_state.IN_HAND : set = set_state 



signal mouse_event(card , event)
signal delete_inspect
signal inspect_deck

func _init():
	scale = GameManager.card_size/GameManager.card_texture_size
	pass

func set_body_ref(value):
	if body_ref != null:
		body_ref.get_parent().modulate.a = 1
	if value == null:
		body_ref = null
		return
	value.get_parent().modulate.a = 0.8
	body_ref = value

func _ready():
	init_card()
	self.state = card_state.IN_HAND
	
func set_state(value):
	state = value
	frame.get_node("NinePatchRect").modulate.a = 0
	drop_area.get_node("CollisionShape2D").shape = null
	match state:
		card_state.IN_PLAY:
			frame.size = Vector2(920 , 920)
			ability_description.visible = false
			effect_all.visible = false
			bar.visible = false if card_information.type == "Leader" else true
			card_name.visible = false if card_information.type == "Leader" else true
			card_tittle.visible = false if card_information.type == "Leader" else true
			frame.get_node("NinePatchRect").modulate = Color.GREEN if is_ally else Color.RED
		card_state.IN_HAND:
			frame.size = Vector2(920 , 1280)
			ability_description.visible = true
			effect_all.visible = true
			bar.visible = true
			card_name.visible = true
			card_tittle.visible = true
		card_state.IN_PREVIEW:
			frame.size = Vector2(920 , 1280)
			ability_description.visible = true
			effect_all.visible = true
			bar.visible = true
			card_name.visible = true
			card_tittle.visible = true
		card_state.IS_DRAGGING:
			scale = GameManager.card_size/GameManager.card_texture_size
			frame.size = Vector2(920 , 920)
			ability_description.visible = false
			effect_all.visible = false
			bar.visible = false if card_information.type == "Leader" else true
			card_name.visible = false if card_information.type == "Leader" else true
			card_tittle.visible = false if card_information.type == "Leader" else true
			
			var area_shape = RectangleShape2D.new()
			area_shape.size = Vector2(920 , 920)
			drop_area.get_node("CollisionShape2D").shape = area_shape
			
			action_panel.visible = false
			
			drop_area.get_node("CollisionShape2D").position = Vector2(460 , 460)



func _process(delta):
	if state == card_state.IS_DRAGGING:
		var offset = (frame.size * scale) / 2
		global_position = get_global_mouse_position() - offset
		
#		for area in drop_area.get_overlapping_areas():
#			area.get_node("CollisionShape2D").shape.intersection(drop_area.get_node("CollisionShape2D"))


func init_card():
	card_information = GameData.card_database[card_id]
	card_name.text = card_information.name
	card_tittle.text = "\"" + card_information.title + "\""

	if card_information.type == "Lad":
		stat_left.text = str(card_information.left)
		stat_right.text = str(card_information.right)
		stat_middle.text = str(card_information.middle)
		
		effect_bottom.get_node("icon").texture = load("res://game-components/card/bar_icon/%s.png" % card_information.effect_bottom.side)
		effect_top.get_node("icon").texture = load("res://game-components/card/bar_icon/%s.png" % card_information.effect_top.side)
		effect_left.get_node("icon").texture = load("res://game-components/card/bar_icon/%s.png" % card_information.effect_left.side)
		effect_right.get_node("icon").texture = load("res://game-components/card/bar_icon/%s.png" % card_information.effect_right.side)
	
		effect_bottom.get_node("stat").text = ("+" if card_information.effect_bottom.stat > 0 else "") + str(card_information.effect_bottom.stat)
		effect_top.get_node("stat").text = ("+" if card_information.effect_top.stat > 0 else "") + str(card_information.effect_top.stat)
		effect_left.get_node("stat").text = ("+" if card_information.effect_left.stat > 0 else "") + str(card_information.effect_left.stat)
		effect_right.get_node("stat").text = ("+" if card_information.effect_right.stat > 0 else "") + str(card_information.effect_right.stat)
		
		effect_bottom.visible = false if card_information.effect_bottom.stat == 0 else true
		effect_top.visible = false if card_information.effect_top.stat == 0 else true
		effect_right.visible = false if card_information.effect_right.stat == 0 else true
		effect_left.visible = false if card_information.effect_left.stat == 0 else true
		
		stat_left.visible = true
		stat_middle.visible = true
		stat_right.visible = true
		
		stat_right.get_parent().get_node("icon").visible = true
		stat_middle.get_parent().get_node("icon").visible = true
		stat_left.get_parent().get_node("icon").visible = true
		
		stat_leader_left.visible = false
		stat_leader_middle.visible = false
		stat_leader_right.visible = false
		
		image.texture = load("res://game-components/card/lads/%s/img.png" % card_information.name)
	else:
		stat_left.visible = false
		stat_middle.visible = false
		stat_right.visible = false
		
		stat_right.get_parent().get_node("icon").visible = false
		stat_middle.get_parent().get_node("icon").visible = false
		stat_left.get_parent().get_node("icon").visible = false
		
		stat_leader_left.visible = true
		stat_leader_middle.visible = true
		stat_leader_right.visible = true
		
		effect_bottom.visible = false
		effect_top.visible = false
		effect_right.visible = false
		effect_left.visible = false
		
		stat_leader_left.text = card_information.left
		stat_leader_right.text = card_information.right
		stat_leader_middle.text = card_information.middle
		
		stat_leader_left.self_modulate = GameData.leader_stat_color[card_information.left]
		stat_leader_right.self_modulate = GameData.leader_stat_color[card_information.right]
		stat_leader_middle.self_modulate = GameData.leader_stat_color[card_information.middle]
		
		image.texture = load("res://game-components/card/leaders/%s/img.png" % card_information.name)
		
		
	ability_description.get_node("center/description").text = "[center]" + card_information.ability + "[/center]"
	ability_description.get_node("detailed_information/region").texture = load("res://game-components/card/icons/%s.png" % card_information.region)
	ability_description.get_node("detailed_information/type").texture = load("res://game-components/card/icons/%s.png" % card_information.type)
	ability_description.get_node("detailed_information/region_text").text = card_information.region
	ability_description.get_node("detailed_information/type_text").text = card_information.type
	
	
	
	frame.texture = load("res://game-components/card/frames/frame_" + card_information.region.to_lower() + ".png")
	ability_description.texture = load("res://game-components/card/boxes/box_" + card_information.region.to_lower() + ".png")
	ability_description.get_node("detailed_information").texture = load("res://game-components/card/balls/slot_" + card_information.region.to_lower() + ".png")
	


func _on_frame_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if !state == card_state.IN_INSPECT:
				mouse_event.emit(self , event)
			match state:
				card_state.IN_HAND:
					if is_ally:
						action_panel.position = Vector2(0 , -387)
						action_panel.visible = !action_panel.visible
				card_state.IN_PLAY:
					if is_ally:
						action_panel.position = Vector2(0 , 991)
						action_panel.visible = !action_panel.visible
				card_state.IS_DRAGGING:
					if body_ref == null:
						return_to_hand.emit()
					else:
						place.emit(body_ref.get_parent())
					
			
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			match state:
				card_state.IN_HAND , card_state.IN_PLAY , card_state.IN_PREVIEW:
					GameManager.inspect(card_id)
				card_state.IS_DECK_LEADER:
					inspect_deck.emit()
				Card.card_state.IN_INSPECT:
					delete_inspect.emit()

func inspect(id):
	if id is String:
		var inspect_layer = CanvasLayer.new()
		var inspect_background = ColorRect.new()
		var inspect_card = load("res://game-components/card/card.tscn").instantiate()
		
		var inspect_card_scale = Vector2((get_tree().current_scene.get_viewport_rect().size.y - 100) / GameManager.card_size.y , (get_tree().current_scene.get_viewport_rect().size.y - 100) / GameManager.card_size.y)
		
		inspect_card.card_id = card_id
		
		
		inspect_background.color = Color.BLACK
		inspect_background.color.a = 0.5
		inspect_background.size = get_tree().current_scene.get_viewport_rect().size
		inspect_background.mouse_filter = Control.MOUSE_FILTER_PASS
		
		inspect_layer.add_child(inspect_background)
		inspect_layer.add_child(inspect_card)
		
		
		get_tree().get_root().add_child(inspect_layer)
		
		inspect_card.scale *= inspect_card_scale
		inspect_card.state = inspect_card.card_state.IN_INSPECT
		inspect_card.position = GameManager.center_of_screen - GameManager.card_texture_size * inspect_card.scale / 2
		inspect_card.delete_inspect.connect(inspect_layer.queue_free)
		


func _on_play_pressed():
	press_play.emit()


func _on_ability_pressed():
	press_ability.emit()


func _on_drop_area_area_entered(area):
	if area in get_tree().get_nodes_in_group("dropable_areas"):
		self.body_ref = area


func _on_drop_area_area_exited(area):
	if body_ref == area:
		self.body_ref = null
