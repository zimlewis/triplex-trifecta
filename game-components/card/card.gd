extends Node2D
class_name Card


@onready var image = $image
@onready var frame = $frame

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

var mouse_in_card = false;

var card_id = "leader_thyena_citrious"
var card_information;

var placed : bool = true : set = set_placed

signal mouse_event(card , event)

func _init():
	scale = GameManager.card_size/GameManager.card_texture_size

func _ready():
	card_information = GameData.card_database[card_id]
	init_card()
	


func set_placed(value):
	placed = value
	if placed:
		frame.size = Vector2(920 , 920)
		ability_description.visible = false
		effect_all.visible = false
		
	else:
		frame.size = Vector2(920 , 1280)
		ability_description.visible = true
		effect_all.visible = true



func init_card():
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
		
		effect_bottom.visible = false
		effect_top.visible = false
		effect_right.visible = false
		effect_left.visible = false
		
		stat_leader_left.visible = true
		stat_leader_middle.visible = true
		stat_leader_right.visible = true
		
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

func _input(event):
	if event is InputEventMouseButton:
		if mouse_in_card:
			mouse_event.emit(self , event)

func _on_area_2d_mouse_entered():
	mouse_in_card = true


func _on_area_2d_mouse_exited():
	mouse_in_card = false
