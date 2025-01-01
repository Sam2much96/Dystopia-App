# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a touch interface consisting of Touch 2d buttons and a Touch screen Joystick
# information used by the ingame UI node.
# Created Using Godot UI Noes And Texture Buttons For Better UI functionality

# Features:
# (1) A State Machine for the touch interface to hint the player and not clutter the ui
# (2) Emits it's state as a signal
# (3) Touch OS enables or Disables the touch interface depending on if a touch screen is present and the Globals.os. _Hide_touch_interface boolean variable
# (4) uses Globals.screenOrientation to change the button arrangements for mobiles
# (5) Connects to signals from Dialogues and COmics SIngletons
# (6) Changes Menu Button Colour Depending on Scene
# (7) Touchscreen HUD does adjusts to phone orientation on android 
# (8) It features a different Touch Interface States exported as Functions, and A StateMachine for
#		Differentiating Between Different Touch Input Types i.e. Stylus, Dpad and joystick
#		And Mapping Different Inputs To UI Action
# (9) It Acts As A Hud FOr The Active Player Item via The Action Buttons e.g. Sword Item, Bow Items
#
#
#
# Bugs :
#(1) using animation player resets the Joystick/D-pad optionality
#(2) Doesnt run code cuz of low priority on thread, rewrite to use static fucnctions


# TO DO:
# (0) _on_comics_showing() is not working
# (1) Fix the joystick code  (1/2)
# (2) Update the interract state to be usable
# (3) Hidetouch interface / Touch interface reset bug (workaround) CLicking other buttons on the touch UI resets this bug on touch UI
#(4) Edit Documentation to be neater (Online documetation)
# (5) Joystick Colors?
# (6) Fix Brken Ingame Controller changer (fixed 1/2)
# (7) Should Resize to fit Screen Diameters using Global Scripts & Variables
# # (a) Write a Resize function using Global Screen Orientation Calculation and Screen Size
#	#	# (b) Variables available : Globals.os, Globals.screen Orientation, Globals.screenSize,Globals.viewport_size, GLobals.center_of_viewport
#		#(c) set grouped buttons positioning programmatically (Done)
# (8) ReWrite Logic Using Animation Player Nodes to fix Stuck Button Bug
# (9) State machine is not optimized at all (processor hog) (1/2)
# (10) TOuch Interface should be adjustible on mobile using drag and drop
# (11) TOuch Interface Format and Scaling should be exported function to android singleton (DOne)
# (12) Implement Drag and Drop Customization using state machines and postion registers
# (13) Vibration Bug when Rescaling
# (14) Touch HUD Scaling is buggy on Mobile Browsers (fixed)
# (15) Shoud Export An Inspector Item String List THat Triggers Different HUD States 
# (16) Implement Stylus and Swipe COntrolls for Mobile Devices like LOZ Phantom Hourglass
# (17) refactor To Use Texture Buttons for Better UI and Configuration. TOuchScreen Buttons Cannot Be moved as Ui Elements

 
# (18) Improve Touch HUD for mobile players (Done)
# (19) Add touch hud drag and drop using refactored comics script (1/2)
# (20) Fix hud auto orientation for mobile (Done)
# (21) Implement procedural animation for Touch Interface Via Functions to be called from Game HUD -> Android Setup
# *************************************************


extends Control


class_name TouchScreenHUD, "res://resources/misc/Android 32x32.png"

var _Hide_touch_interface : bool

#Debug
onready var _debug = get_tree().get_root().get_node("/root/Debug")

# Comics Singleton Pointer
onready var _comics = null#get_tree().get_root().get_node("/root/Comics_v6")

#Safe Global Input Ponter
onready var _Input = get_tree().get_root().get_node("/root/GlobalInput")

# Pointer to Parent
onready var parent = get_parent()

# Pointer to menu node from Parent
onready var menuObj : Game_Menu = parent.get_child(6)

# Pointer to Global Menu Pointer
onready var menu3 = _Input.menu

#State Machine
# Use A Match Conditional for differentiating Input Types
# Stylus Should Only Catch TOuch Screen Inputs
# add functions to state machine
enum { D_PAD_, JOYSTICK, STYLUS , CONFIG, DEBUG } # Config State for Drag ANd Drop Mode

export (int) var _state_controller = D_PAD_
export (String, 'modern', 'classic', "stylus") var _control # Dupli9cate of Globals._controller_type
export (String, 'menu', 'interract', "attack", "stats", "comics", "reset") var _state_inspector : String # State machine Debugger from inspector Tab
var _Debug_Run : bool = false

export (bool) var enabled # Local Variant for stroing if device is android from adnroid singleton

#signal menu
signal interract
signal attack
signal stats
signal comics
signal reset


var _menu : TextureButton 
var _interract : TextureButton 
var stats_ : TextureButton
var roll : TextureButton 
var slash  : TextureButton 

var comics_ : TextureButton 
var _joystick : TouchScreenButton
var joystick2 : TouchScreenButton 
var D_pad : Control 

var Anim : AnimationPlayer 

var _up : TextureButton
var _down : TextureButton
var _left : TextureButton
var _right : TextureButton



'UI control Parents'
var interract_buttons : Control
var action_interract_buttons : Control

"Dimensions Calculator"
var dimensions : Vector2  
var dimensional_diff : Vector2  

var buttons_positional_data : Array

var LineDebug : Line2D 

onready var joystick_parent: Control # = $Joystick

'UI button as arrays'
onready var all_UI_Nodes : Array
onready var action_buttons : Array 
onready var direction_buttons : Array 
onready var analogue_joystick : Array
onready var d_pad : Array

"Scene Tree"
onready var __scene_tree : SceneTree = get_tree()

# debug COunter counts how many times a mehtod has been called
var counter : int = 0
#func _enter_tree():
	#"Global Pointer" # DEepreciated in favor of GlobalInput Singleton
	#Globals._TouchScreenHUD = self

# Helper booleans for Stopping Loop Processing
var _action_button_showing : bool
var _direction_button_showing : bool


# Local Pointer TO Stats Node
onready var _Stats_ : Stats = get_parent().get_child(4)

onready var TouchInput = Input 

func _ready():
	
		# Make Global Pointer
	#
	GlobalInput.TouchInterface = self
	Android.TouchInterface = self
	
	
	# Bug: Android Intializer is buggy
	#print_debug("Connect Texture Button Signals Here")
	#print_debug("OS Debug: ",Globals.os)
	# COde Mutates ENabled
	if Android.is_android() == false:
		self.hide()
		enabled = false
	#if Android.is_android() == true: 
	#	self.show()
	##	print_debug("Showing Touch Interface")
	#if Globals.os == "Android":
	#	self.show()
	#	enabled = true
	#if Globals.os == "HTML5" && Utils.initial_screen_orientation == 0: # Mobile Browser
	#	self.show()
	#	enabled = true
	#if Globals.os == "HTML5" && Utils.initial_screen_orientation == 1: # PC Browser
	#	self.hide()
	#	enabled = false
	###self.hide() if not Android.is_android() else print_debug("Showing Touch Interface")
	#if Globals.os == "X11":
	#	self.hide()
	# VIsibility Is Handled In Singleton Process

	
	######## Begin Setting Nodes #
	_menu = $menu
	_interract = $Control/InterractButtons/interact
	stats_ = $Control/InterractButtons/stats
	roll = $Control/ActionButtons/Spacer/roll
	slash = $Control/ActionButtons/slash
	comics_ = $Control/InterractButtons/comics
	#_joystick = $Joystick/joystick_circle
	#joystick2 = $Joystick/joystick_circle2
	 
	#Anim = $AnimationPlayer
	D_pad = $"D-pad"
	LineDebug = $Line2D
	#touch_interface_debug() disabling for now
	
	_up = $"D-pad/up"
	_down = $"D-pad/down"
	_left = $"D-pad/left"
	_right = $"D-pad/right"
	

	action_interract_buttons = $Control/ActionButtons 
	interract_buttons = $Control/InterractButtons
	
	# Debug Broken Lins
	
	all_UI_Nodes = [_menu ,stats_, _interract, roll, slash,comics_,
	#_joystick, joystick2,
	D_pad, _up, _down, _left, _right ]
	
	# Error Catcher For Broken UI Links
	Utils.UI.check_for_broken_links(all_UI_Nodes)
	
	# Check For Broken signal connections
	
	
	
	"Set Button Arraqys for easy on/off"
	action_buttons = [
		_menu ,
		stats_,
		_interract,
		roll, 
		slash,
		comics_
		]
	
	#analogue_joystick  = [ _joystick, joystick2]
	d_pad = [D_pad, _up, _down, _left, _right]
	
	
		# Select Users Preferred Direction Controls 
		
	if str(Globals.direction_control )== "classic" :
		direction_buttons = d_pad
	elif str(Globals.direction_control) == "modern" :
		#direction_buttons = analogue_joystick
		print_debug("Joystick Inputs Require Refactoring")
	# Default Direction Button should be Analgue
	else: pass #direction_buttons = analogue_joystick

	#### Done Setting Nodes
	
	# Update scene Temporarily Disabled
	#Globals.update_curr_scene()
	
	#print_debug( " Global Touch HUD: ", GlobalInput.TouchInterface)
	# Auto Hides All UI Interfaces
		
	#__menu()
	reset()
	
	# Turn off this setup script if not running on Android
	if enabled:
		
		# Connect Button Signals
		print_debug("Connect Body Signals")
		
		
		#print_debug(direction_buttons, Globals.direction_control)

		"Touch UI Visibility"
		# moved to ANdroid singleton
		# Disabling for debugging
		#hide_self(Globals.os, Globals.screenOrientation, _Hide_touch_interface, self)
		
		
		
		
		
		
		"Touch Menu Button Customization"
		# Customizes 
		if Globals.curr_scene == "HouseInside":
			_menu.self_modulate = Color(255,255,255) # white
		else: _menu.self_modulate = Color(0,0,0) # black
		
		"Auto sets the controller button"
		
		
		
		
		# Depreciated for Refoactoring
		#Utils.Screen.calculate_button_positional_data(
		#	_menu, 
		#	_interract,
		#	stats_, 
		#	roll, 
		#	slash, 
		#	comics_, 
		#	_joystick, 
		#	D_pad
		#	)
		
		"Set Initial Touch HUD Layout"
		#Utils.Screen._adjust_touchHUD_length(Anim)
		
		
		
		"Display Screen Calculations"
		#Utils.Screen.display_calculations(get_tree().get_root(), Utils)
		
		# Calculates the Length and Breadth of All Touchscreen HUD buttons
		#dimensions = Utils.Functions.calculate_length_breadth(buttons_positional_data)
		
		# calculates a dimensional difference between the center of the vuewport aand the Button onscreen positions 
		#dimensional_diff = dimensions - Globals.center_of_viewport 
	
	#For debug purposes only
	#print_debug("HUD Dimensions:", dimensions) # Breath of the wild lmao
	#print_debug("Dimension difference: ",dimensional_diff )
	
	#print_debug("Global Direction COntrols : ",Globals.direction_control, "/",dimensions, "/",dimensional_diff)
	
	
	# Debug Required Pointers
	#print_debug(parent, menu2, menu3)
		
		"Mobile Specific Signals"
		print_debug("Stats Signals and Menu signals implementation are broken")
		# COnnect signals from dialogue
		# DIalogues to self
		Dialogs.connect("dialog_started", self, "interract")
		Dialogs.connect("dialog_ended", self, "show_all_buttons")

		# Comics to Touch Interface
		#if is_instance_valid(_comics): # Buggy Singleton Instance
		#	_comics.connect( 'comics_showing', self, '_on_comics_showing')
		#	_comics.connect( 'comics_showing', self, '_on_comics_hidden'  )

		# Menu to Touch Interface Connection
		# Quick Hacky Fiz
		# It Connects THe TOuch interface to self inplemented methods
		#if is_instance_valid(menu2): # Error Catcher 1
		#	menu2.connect("menu_showing", self, "menu") 
		#	menu2.connect("menu_hidden", self, "show_all_buttons")
		
		
		# connects menu from global pointer
		if is_instance_valid(menuObj):
			if not (menuObj.is_connected("menu_showing", self, "menu") &&
			menuObj.is_connected("menu_hidden", self, "menu")
			):
				menuObj.connect("menu_showing", self, "menu") 
				#menuObj.connect("menu_hidden", self, "menu") # temporarily disabled for ux refactoring
		## Networking TImer to Touch Interface
		# Resets Using Networking timer
		#Networking.timer.connect("timeout", self, "show_all_buttons") 

		# Connects Stats Ui Signals To Touchscreen HUD for Mobile
		_Stats_.connect("_enabled", self ,"status")
		_Stats_.connect("_not_enabled", self ,"show_all_buttons")
		
		if (
			_Stats_.is_connected("_enabled", self ,"status") &&
			_Stats_.is_connected("_not_enabled", self ,"show_all_buttons") != true 
		) :
			push_error("Stats x TouchHUD signal is broken")
		
		#if is_instance_valid(Inventory._stats_ui):
		#	Inventory._stats_ui.connect("status_showing",self,"status")
		#	Inventory._stats_ui.connect("status_hidden",self,"reset")
			
			# Debug Signals

		# Debug SIgnals
		# Convert to Unit Tests instead
		# TO DO:
		# (1) Debug Code
		# (2) Update Documentation
		if is_instance_valid(Dialogs && menu3 && Networking):
			if not (Dialogs.is_connected("dialog_started", self, "interract") &&
				Dialogs.is_connected("dialog_ended", self, "show_all_buttons") # &&
				#_comics.is_connected( 'comics_showing', self, '_on_comics_showing') &&
				#_comics.is_connected( 'comics_showing', self, '_on_comics_hidden'  ) &&
				#menu3.is_connected("menu_showing", self, "menu") &&
				#menu3.is_connected("menu_hidden", self, "reset") &&
				#Networking.timer.is_connected("timeout", self, "reset")
				
				) == true:

				# Debug Node Signal Connections
				print_debug(
					Dialogs.is_connected("dialog_started", self, "interract"),
					Dialogs.is_connected("dialog_ended", self, "show_all_buttons")
					#_comics.is_connected( 'comics_showing', self, '_on_comics_showing'),
					#_comics.is_connected( 'comics_showing', self, '_on_comics_hidden'  ),
					#menu3.is_connected("menu_showing", self, "menu"), 
					#menu3.is_connected("menu_hidden", self, "reset"),
					#Networking.timer.is_connected("timeout", self, "reset") 
					)

	if not enabled:
		__disappear()
		

# I wrote all the states within functions. I should'vve instead written them within a process fucntion
"""
THE STATE MACHINE CALLS WITH FUNCTIONS
"""
func reset():  #resets node visibility statuses
	
	#print_stack()
	#assert(Globals.os == "Android")
	hide_buttons()
	
	#_state_controller = _RESET
	#return _state_controller 
	#"shows all the UI options"
	#show_action_buttons()
	
	#show_direction_buttons()

#Enumerate each of the following states




func status():  #used by ui scene when status is clicked
	#print_debug("dkjasbfiajsdbfiadb")
	#print_stack()
	hide_buttons()
	stats_.show()


func comics():  #used by ui scene when comics is clicked
	#_state_controller = _COMICS
	#return _state_controller 
	hide_buttons()
	comics_.show()

func menu(): #used by ui scene when menu is clicked
	#_state_controller = _MENU
	#return _state_controller 
	hide_buttons()
	_menu.show()

func interract(): #used by ui scene when interract is clicked
	
	hide_buttons()
	_menu.show()
	_interract.show()
	#return _state_controller  


func attack(): #used by ui scene when attack is clicked 
	#_state_controller = _ATTACK
	#return _state_controller 

	emit_signal('attack')

	hide_buttons()

	_menu.show()
	slash.show()
	roll.show()
	if _control == Globals._controller_type[1]: # modern
		D_pad.hide()
		joystick_parent.show()

	if _control == Globals._controller_type[2]: # classic
		joystick_parent.hide()
		D_pad.show()




# Handles Debugging Variables from the touch interface system
# Should PNly run once
func touch_interface_debug(): #Debug singleton is broken
	if _Hide_touch_interface == false && _debug.debug_panel != null && _Debug_Run == false:

		_Debug_Run = true# Runs this Debug Loop Only Once
		
		#RepositionButtonsHUD()
		# *************************************************
		# Buttons Debug
		# (a) Plot a line2d with all Buttons Position (done)
		# (b) Use Line Point Dimensions to Compare Global Screen Size calculations  
		# *************************************************
		
		for i in buttons_positional_data:
			LineDebug.add_point(i)
			
			



func show_all_buttons():
	print_stack()
	#if enabled:
	print_debug("Showing All Buttons")
	show_action_buttons()
	show_direction_buttons()


func hide_buttons() :

	# Reset Helper Booleans
	_action_button_showing = false
	_direction_button_showing = false
	
	
	for i in direction_buttons :
		#if i.visible() :
		i.hide()
	for x in action_buttons:
		if x.visible:
			x.hide()
	# hackky bug fix for D-pad UI showing Bug
	D_pad.hide()
	
	
	# Release UI FOus


func show_action_buttons() :
	# SHows the Action buttons recursively
	#print_debug("Showing Action Buttons")
	if enabled:
		for j in action_buttons:
			j.show()


func show_direction_buttons() -> void:
	#print_debug("Showing Direction Buttons")
	if enabled:
		for j in direction_buttons:
			j.show()


func _on_comics_showing(): # Refactoring For Minimap UI
	print_debug("Comics SHowing")
	
	comics() 


func _on_comics_hidden():
	print_debug("Comics Hidden")
	reset()



##### External Method TO Be Called Form Other Scripts
func __menu():
	# Hudes All Button Except The Mebnu Button
	#print_stack()
	#assert(Globals.os == "Android")
	if enabled:
		#print_debug("Touch Interface External Menu")
		_menu.show()
		_interract.hide()
		stats_.hide()
		roll.hide()
		slash.hide()
		comics_.hide()
		#_joystick.hide()
		#joystick2.hide()
		_up.hide()
		_down.hide()
		_left.hide()
		_right.hide()
		# Debug Menu
		print_debug(_menu.visible, "/", _interract.visible)

func __disappear():
	_menu.hide()
	_interract.hide()
	stats_.hide()
	roll.hide()
	slash.hide()
	comics_.hide()
	#_joystick.hide()
	#joystick2.hide()
	_up.hide()
	_down.hide()
	_left.hide()
	_right.hide()

"""
PROCEDURAL ANIMATION FOR UI POSITIONING
"""
#
# (1) Methods Are TO Be called from GameHUD animation player Via ANdroid Singleton for Screen Orientation Positioning
func Horizontal():
	# Position UI Nodes For Horizontal Screens
	_left.rect_position =Vector2(83.482,453.99)
	_left.rect_size =Vector2(87,87)
	_left.rect_rotation =179.7
	_left.rect_scale = Vector2(1,1)
	
	_up.rect_position = Vector2(69.482,392.99)
	_up.rect_size = Vector2(87,87)
	_up.rect_rotation = -89.1
	_up.rect_scale =Vector2(1,1)
	
	_right.rect_position = Vector2(127.482,372.99)
	_right.rect_size = Vector2(87,87)
	_right.rect_rotation = 0.8
	_right.rect_scale = Vector2(1,1)
	
	_down.rect_position =Vector2(147.482,440.989)
	_down.rect_size = Vector2(87,87)
	_down.rect_rotation = 90.3
	_down.rect_scale = Vector2(1,1)
	
	
	_menu.rect_position = Vector2(32,48)
	_menu.rect_size = Vector2(166,143)
	_menu.rect_scale = Vector2(0.5,0.5)
	
	$Control/InterractButtons/Label_Spacer.hide()
	$Control/InterractButtons.rect_scale = Vector2(0.7,0.7)
	$Control/InterractButtons.rect_position = Vector2(840,-13)
	
	$Control/ActionButtons.rect_scale = Vector2(1,1)
	$Control/ActionButtons.rect_position = Vector2(704,296)
	$Control/ActionButtons.rect_size = Vector2(224,206)
	return 0


func Vertical():
	# Position UI Nodes HFor Horizontal Screens
	_left.rect_position =Vector2(133.964,1920.99)
	_left.rect_size =Vector2(87,87)
	_left.rect_rotation =179.7
	_left.rect_scale = Vector2(2,2)
	
	_up.rect_position = Vector2(95.446,1786.98)
	_up.rect_size = Vector2(87,87)
	_up.rect_rotation = -89.1
	_up.rect_scale =Vector2(2,2)
	
	_right.rect_position = Vector2(213.964,1742.99)
	_right.rect_size = Vector2(87,87)
	_right.rect_rotation = 0.8
	_right.rect_scale = Vector2(2,2)
	
	_down.rect_position =Vector2(254.964,1865.99)
	_down.rect_size = Vector2(87,87)
	_down.rect_rotation = 90.3
	_down.rect_scale = Vector2(2,2)
	
	
	_menu.rect_position = Vector2(32,48)
	_menu.rect_size = Vector2(166,143)
	_menu.rect_scale = Vector2(1,1)
	
	
	$Control/InterractButtons/Label_Spacer.show()
	$Control/InterractButtons.rect_scale = Vector2(1,1)
	$Control/InterractButtons.rect_position = Vector2(736.723,-21.035)
	
	$Control/ActionButtons.rect_scale = Vector2(1.5,1.5)
	$Control/ActionButtons.rect_position = Vector2(611.412,1723.547)
	$Control/ActionButtons.rect_size = Vector2(224,206)
	
	
	return 0

"""
UI Button Connections
"""
# via Global Input Singleton
# Buggy : Introduces Stuct Input Bug On Mobile Devices
func _on_menu_pressed():
	#print_debug("111111111111111111111111111") #Works
	return 0#_Input.parse_input(_Input.NodeInput,__scene_tree,"menu", true)



func _on_stats_pressed():
	#print_debug("Stats Button Pressed")
	return 0#_Input.parse_input(_Input.NodeInput,__scene_tree,"pause", true)


func _on_comics_pressed():
	print_debug("Comics Button Pressed")
	return _Input.parse_input(_Input.NodeInput,__scene_tree,"comics", true)


func _on_interact_pressed():
	#print_debug("Interract Button Pressed")
	return 0 #_Input.parse_input(_Input.NodeInput,__scene_tree,"interact", true)


func _on_roll_pressed():
	#print_debug("Roll Button Pressed")
	return 0#_Input.parse_input(_Input.NodeInput,__scene_tree,"roll", true)


func _on_slash_pressed():
	#print_debug("Attack Button Pressed")
	return 0#_Input.parse_input(_Input.NodeInput,__scene_tree,"attack", true)


func _on_right_pressed():
	
	return 0 #_Input.parse_input(_Input.NodeInput,__scene_tree,"move_right", true)


func _on_up_pressed():
	return 0#_Input.parse_input(_Input.NodeInput,__scene_tree,"move_up", true)


func _on_left_pressed():
	return 0#_Input.parse_input(_Input.NodeInput,__scene_tree,"move_left", true)



func _on_down_pressed():
	return 0


#func _on_menu_gui_input(event):
#	print_debug("22222222222222") # Doesnt'tWorks
#	_Input.parse_input("menu", true)


func _on_stats_gui_input(event):
	print_debug("Stats GUI Input")
	stats_.grab_focus()
	#print_debug("Stats Button Pressed")
	#_Input.parse_input("pause", true)


#func _on_stats_mouse_entered():
#	print("1111111111111")


func _on_down_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"move_down", true)


func _on_down_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"move_down", false)


func _on_left_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"move_left", true)


func _on_left_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"move_left", false)


func _on_up_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"move_up", false)


func _on_up_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"move_up", true)




func _on_right_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"move_right", false)


func _on_right_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"move_right", true)


func _on_stats_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"pause", false)


func _on_stats_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"pause", true)



func _on_interact_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"interact", false)



func _on_interact_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"interact", true)


func _on_roll_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"roll", false)

func _on_roll_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"roll", true)

func _on_slash_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"attack", false)


func _on_slash_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"attack", true)


func _on_menu_button_up():
	return _Input.parse_input(TouchInput,__scene_tree,"menu", false)


func _on_menu_button_down():
	return _Input.parse_input(TouchInput,__scene_tree,"menu", true)

"""
Unhandled Inputs
"""
# (1) For Debugging Stuck Input Bugs which are unhandled inputs with no node responsibility

#func _unhandled_input(event):
#	# Fixed Stuck Input Bug / Unhandled Input From This node can be debugged here
#	if event is InputEventScreenTouch:
#		return
#	if event is InputEventMouseButton:
#		return
#	
#	if _Input.reg_inputs.has(event.action):
	#
#		print_debug("Unhandled Input Debug: ",event.action, event.is_pressed())
#
