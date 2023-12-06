extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$setting_panel/close.pressed.connect(queue_free)
	$setting_panel/logout.pressed.connect(func():
		queue_free()
		Firebase.Auth.logout()
		await SceneChanger.change_scene("res://authentication/authentication.tscn" , "texture_fade" , "texture_fade")
	)
