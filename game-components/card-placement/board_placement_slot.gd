extends Node2D


var column
var row

func _ready():
	row = get_parent().get_parent().get_children().find(get_parent())
	column = get_parent().get_children().find(self)
