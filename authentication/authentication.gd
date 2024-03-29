extends Control

#Login form
@onready var login_button = $form/login/btn_login
@onready var login_email = $form/login/email
@onready var login_password = $form/login/password
@onready var remember_me = $form/login/rememeber_me
@onready var error_login_label = $form/login/error

#Register form
@onready var register_button = $form/register/btn_register
@onready var register_email = $form/register/email
@onready var register_username = $form/register/username
@onready var register_password = $form/register/password
@onready var register_password_confirm = $form/register/password_confirm
@onready var error_register_label = $form/register/error


func disable_form():
	login_button.disabled = true
	login_email.editable = false
	login_password.editable = false
	remember_me.disabled = true
	
	register_button.disabled = true
	register_email.editable = false
	register_username.editable = false
	register_password.editable = false
	register_password_confirm.editable = false


func enable_form():
	login_button.disabled = false
	login_email.editable = true
	login_password.editable = true
	remember_me.disabled = false
	
	register_button.disabled = false
	register_email.editable = true
	register_username.editable = true
	register_password.editable = true
	register_password_confirm.editable = true


func _ready():
	Firebase.Auth.signup_succeeded.connect(signup_succeeded)
	Firebase.Auth.signup_failed.connect(signup_failed)
	Firebase.Auth.login_succeeded.connect(login_succeeded)
	Firebase.Auth.login_failed.connect(login_failed)
	
	if (FileAccess.file_exists("user://user.auth")):
		disable_form()
		await Firebase.Auth.load_auth()
		var firestore_user_collection : FirestoreCollection = Firebase.Firestore.collection("users")
		firestore_user_collection.get_doc(Firebase.Auth.auth.localid)
		GameData.user_data = await firestore_user_collection.get_document
		
		SceneChanger.change_scene("res://title-screen/title_screen.tscn" , "texture_fade" , "texture_fade")

		
	login_button.connect("pressed" , login_pressed)
	register_button.connect("pressed" , register_pressed)
	pass
	
func login_pressed():
	disable_form()
	await Firebase.Auth.login_with_email_and_password(login_email.text , login_password.text)



func register_pressed():
	if register_password.text != register_password_confirm.text:
		error_register_label.text = "password does not match"
		return
	
	disable_form()
	Firebase.Auth.signup_with_email_and_password(register_email.text , register_password.text)



func signup_succeeded(auth_info : Dictionary):
	Firebase.Auth.update_account(auth_info.idtoken , register_username.text , "" , [] , true)
	var firestore_user_collection : FirestoreCollection = Firebase.Firestore.collection("users")
	var add_task : FirestoreTask = firestore_user_collection.add(auth_info.localid , {
		"lv" : 0, 
		"rank" : 0, 
		"elo" : 0,
		"exp" : 0, 
		"in_game_name" : register_username.text, 
		"email" : auth_info.email, 
		"decks":{
		}
	})
	await add_task.task_finished
	register_username.text = ""
	register_email.text = ""
	register_password.text = ""
	register_password_confirm.text = ""
	enable_form()
	pass

func signup_failed(code, message):
	error_register_label.text = str(code) + ": " + message
	enable_form()
	pass



func login_succeeded(auth_info : Dictionary):
	var saved
	
	if remember_me.button_pressed:
		saved = await Firebase.Auth.save_auth(Firebase.Auth.auth)
	if !saved:
		print("can't save")
	var firestore_user_collection : FirestoreCollection = Firebase.Firestore.collection("users")
	firestore_user_collection.get_doc(auth_info.localid)
	GameData.user_data = await firestore_user_collection.get_document

	
	SceneChanger.change_scene("res://title-screen/title_screen.tscn" , "texture_fade" , "texture_fade")
  
func login_failed(code , message : String):
	error_login_label.text = str(code) + ": " + message
	enable_form()

	
#func userdata_received(auth_info : FirebaseUserData):
#	pass
#
#func logged_out():
#	pass





func _on_rg_pressed():
	for i in [$form/login/email, $form/login/password]:
		i.editable = false
	for i in [%btn_login, $form/login/rg]:
		i.disabled = true
	
	for i in [$form/register/username, $form/register/email, $form/register/password, $form/register/password_confirm]:
		i.editable = true
	for i in [%btn_register, $form/register/lg]:
		i.disabled = false
	$form/login.visible = false
	$form/register.visible = true


func _on_lg_pressed():
	for i in [$form/login/email, $form/login/password]:
		i.editable = true
	for i in [%btn_login, $form/login/rg]:
		i.disabled = false
	
	for i in [$form/register/username, $form/register/email, $form/register/password, $form/register/password_confirm]:
		i.editable = false
	for i in [%btn_register, $form/register/lg]:
		i.disabled = true
	$form/login.visible = true
	$form/register.visible = false
