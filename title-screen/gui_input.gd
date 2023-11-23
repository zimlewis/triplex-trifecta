extends Label

signal menu_inputed(event , node)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	connect("gui_input" , on_gui_input)

func on_gui_input(event):
	emit_signal("menu_inputed" , event , self)


