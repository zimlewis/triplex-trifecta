extends Camera2D


class_name PanningCamera2D

const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 4.0
const ZOOM_RATE: float = 8.0
const ZOOM_INCREMENT: float = 0.1

var _target_zoom: float = zoom.x

var _tween: Tween

func _ready():
	_target_zoom = zoom.x

func _physics_process(delta: float) -> void:
	_tween = create_tween()
	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, _target_zoom))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_in()
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_out()
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			position = get_screen_center_position() - event.relative / zoom
			
			
			


func zoom_in() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)


func zoom_out() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)

#extends Camera2D
#
#
#class_name PanningCamera2D
#
#const MIN_ZOOM: float = 0.4
#const MAX_ZOOM: float = 2.0
#const ZOOM_RATE: float = 8.0
#const ZOOM_INCREMENT: float = 0.1
#
#var _target_zoom: float = 1.0
#var _target_position: Vector2 = get_global_mouse_position()
#
#var _tween: Tween
#
#
#func _physics_process(delta: float) -> void:
#	_tween = create_tween()
#	zoom = lerp(zoom, _target_zoom * Vector2.ONE, ZOOM_RATE * delta)
#	global_position = lerp(global_position , _target_position , ZOOM_RATE * delta)
#	if is_equal_approx(zoom.x, _target_zoom): zoom = _target_zoom * Vector2.ONE
#	if is_equal_approx(global_position.x , _target_position.x): global_position = _target_position
#
#
#func _unhandled_input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		if event.is_pressed():
#			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
#				zoom_in()
#			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
#				zoom_out()
#	if event is InputEventMouseMotion:
#		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
#			_target_position = get_screen_center_position() - event.relative / zoom
#
#
#func zoom_in() -> void:
#	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
#	var screen_center = get_screen_center_position()
#	var mouse_position = get_global_mouse_position()
#	var tan_a = tan((mouse_position.y - screen_center.y) / (mouse_position.x - screen_center.x))
#	var cos_a = sqrt(1 / (1 + tan_a * tan_a))
#	var sin_a = sqrt((tan_a * tan_a) / (1 + tan_a * tan_a))
#
#	_target_position = screen_center - Vector2(cos_a * (_target_zoom - zoom.x) * -screen_center.distance_to(mouse_position) , sin_a * (_target_zoom - zoom.y) * screen_center.distance_to(mouse_position))
#	set_physics_process(true)
#
#
#func zoom_out() -> void:
#	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
#	var screen_center = get_screen_center_position()
#	var mouse_position = get_global_mouse_position()
#	var tan_a = tan((mouse_position.y - screen_center.y) / (mouse_position.x - screen_center.x))
#	var cos_a = sqrt(1 / (1 + tan_a * tan_a))
#	var sin_a = sqrt((tan_a * tan_a) / (1 + tan_a * tan_a))
#
#	_target_position = screen_center - Vector2(cos_a * (_target_zoom - zoom.x) * -screen_center.distance_to(mouse_position) , sin_a * (_target_zoom - zoom.y) * screen_center.distance_to(mouse_position))
##	print("position: {0} \ntarget_position: {1}".format([global_position , _target_position]))
#	set_physics_process(true)
