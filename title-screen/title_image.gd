extends Control

var menu_max_travel = 30
var center_of_screen

@onready var background = $background
@onready var frontground = $frontground
@onready var middleground = $middleground

var background_initial_position
var frontground_initial_position
var middleground_initial_position

func _ready():
	background_initial_position = background.global_position
	frontground_initial_position = frontground.global_position
	middleground_initial_position = middleground.global_position

func _process(delta):
	
	var dict_to_mouse = (get_global_mouse_position() - GameManager.center_of_screen).limit_length(menu_max_travel)
	dict_to_mouse.y *= 0.2
	
	background.global_position.x = lerp(background.global_position , background_initial_position + dict_to_mouse * -1.5 , delta * 2).x
	frontground.global_position.x = lerp(frontground.global_position , frontground_initial_position + dict_to_mouse * 1.5 , delta * 2).x


	background.global_position.y = lerp(background.global_position , background_initial_position + dict_to_mouse * -1 , delta * 2).y
	middleground.global_position.y = lerp(middleground.global_position , middleground_initial_position + dict_to_mouse * -1 , delta * 2).y
	frontground.global_position.y = lerp(frontground.global_position , frontground_initial_position + dict_to_mouse * 1 , delta * 2).y
