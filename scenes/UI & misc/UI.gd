# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is an Ingame UI (Separate from Ingame Menu) containing
# information used by the player's Dialogue, Inventory, Health bar,.
# Kill count, Directional, Comics.
# On the 16/04/22 , i started an update to the dialogue button.
# *************************************************


extends CanvasLayer


func _ready():
	return Dialogs.connect("dialog_started", self, "_on_dialog_started")
	return Dialogs.connect("dialog_ended", self, "_on_dialog_ended")
	
	return $Stats.connect("not_enabled",self, '_on_status_hidden')
	return $Stats.connect('enabled',self,'_on_status_showing')
	return $Comics.connect( 'freed_comics', self, '_on_comics_freed'  )

	
	return $"Menu ".connect("menu_hidden",self,'on_menu_hidden')
	return $"Menu ".connect("menu_showing",self,'on_menu_showing')
	
func _on_dialog_started():
	$TouchInterface.interract()

func _on_dialog_ended():
	$TouchInterface.reset()


func _input(_event):
	if Input.is_action_just_pressed("comics"):
		if $Comics.enabled == true:
			if $TouchInterface.state != 'comics' and $Comics.loaded_comics == true:
				$TouchInterface.comics()
		elif $Comics.enabled == false or $Comics.loaded_comics == false:
			$TouchInterface.reset()
	if Input.is_action_just_pressed("pause"):
		if $Stats.enabled == true :
			$TouchInterface.status() #calls a display function int the touch interface scene
			
	if Input.is_action_just_pressed('menu'):
		if $"Menu ".enabled == true:
			$TouchInterface.menu()
		elif $"Menu ".enabled == false:
			$TouchInterface.reset()
	if Input.is_action_just_pressed('attack'):
		if $TouchInterface.state != 'attack':
			$TouchInterface.attack()
			yield(get_tree().create_timer(3.0), "timeout")
			$TouchInterface.reset()

func _on_comics_freed():
	$TouchInterface.reset()

func _on_status_showing():
	$TouchInterface.reset()
	print('status hidden') #for debug purposes

func _on_status_hidden():
	#$Stats.enabled = false
	$TouchInterface.status()
	print('status showing')

func on_comics_showing():
	$TouchInterface.comics()

func on_menu_showing():
	$TouchInterface.menu()
func on_menu_hidden():
	$TouchInterface.reset()
