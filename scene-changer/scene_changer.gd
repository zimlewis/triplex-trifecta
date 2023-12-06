extends CanvasLayer

@onready var animator = $AnimationPlayer

signal started_loading_scene
signal finished_loading_scene

var progress = []
var loading_status = 0
var scene_to_load
var tween

func _ready():
	set_process(false)
	$progress_count.visible = false
	$loading.visible = false	
	$logo.visible = false
	started_loading_scene.connect(on_started_loading_scene)
	finished_loading_scene.connect(on_finished_loading_scene)
	pass

func on_started_loading_scene():
	set_process(true)
	pass

func on_finished_loading_scene():
	set_process(false)
	progress = []
	loading_status = 0
	$progress_count.visible = false
	$loading.visible = false
	$logo.visible = false
	tween.kill()
	$dissolved_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass

func _process(delta):
	loading_status = ResourceLoader.load_threaded_get_status(scene_to_load , progress)
	
	$loading/bar.material.set_shader_parameter("crop_right" , 1 - progress[0])
	
	if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
		finished_loading_scene.emit()

func change_scene(target : String , in_animation : String , out_animation : String , set_value_lambda = null):
	$dissolved_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	$loading/bar.material.set_shader_parameter("crop_right" , 1)
	$loading.visible = true
	$logo.visible = true
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
	tween.tween_property($logo , "rotation" , deg_to_rad(180) , 0.5).as_relative()
	
	
	scene_to_load = target
	

	var current_scene = get_tree().current_scene
	
	animator.play(in_animation)
	
	await animator.animation_finished
	
	
	
	ResourceLoader.load_threaded_request(scene_to_load)
	started_loading_scene.emit()
	
	await finished_loading_scene
	
	var loaded_scene = ResourceLoader.load_threaded_get(scene_to_load).instantiate()
	if !set_value_lambda == null:
		set_value_lambda.call(loaded_scene)
		
	current_scene.queue_free()
	get_tree().get_root().add_child(loaded_scene)
	animator.play_backwards(in_animation)
	get_tree().current_scene = loaded_scene
	
	scene_to_load = null
	return loaded_scene
