# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Comics Extension script
#
#A Menu for Holding and Displaying Comic book chapters 
#
# Features:
#(1) shows and hides comic page buttons
#(2) Connects to signal from Comics node

# To Do:
#(1) Implement grid panels for mobile screens (done)
# (2) Implement better connects to Comics node, not Signals
# (3) Convert to ads spot emulating webtoons landing page
# *************************************************


extends GridContainer

onready var Grid_Container = self
onready var Scroll_Container = Grid_Container.get_parent()


onready var loaded_comics 

# Size Vectors For Stretching THe scroll Container
# Bug Fix for Broken Comics UI on Mobile Screen Orientations

var size_A : Vector2 = Vector2(1772,1871)
var size_B : Vector2 = Vector2(2490, 6289)

# UI buttons
#onready var _back : Button = get_parent().get_parent().get_parent().get_node("back")
onready var chap_1 : TextureButton = $chap_1
onready var chap_2 : TextureButton = $chap_2
onready var chap_3 : TextureButton = $chap_3
onready var chap_4 : TextureButton = $chap_4
onready var chap_5 : TextureButton = $chap_5
onready var chap_6 : TextureButton = $chap_6
onready var chap_7 : TextureButton = $chap_7

# Header Labels
onready var Comics__2_UI : Array = [] # SHould contail label files

onready var Comics_Grid_UI : Array = [chap_1, chap_2, chap_3, chap_4, chap_5, chap_6, chap_7]

func _ready():
	Globals.update_curr_scene()
	#manually_translate() # Temporarily Disabling
	# Only Connect buttons in Comics 2 Scene 
	if Globals.curr_scene == "Comics UI":
	
		print_debug("Comics Buttons COnnected: ",connect_signals())
	
	
	get_node("chap_1").grab_focus()
	
	#**********Buggy*****************#
	
	# Changes UI Orientation Based on Globals screen Orientation
	if Globals.screenOrientation == 1: #mobile UI 
		Grid_Container.set_columns(2)
		Scroll_Container.set_enable_h_scroll(false)
		Scroll_Container.set_enable_v_scroll(true)
		
		
		return Scroll_Container.set_size(size_B)
		
		
		
	elif Globals.screenOrientation == 0: #PC UI
		Grid_Container.set_columns(7)
		Scroll_Container.set_enable_h_scroll(true)
		Scroll_Container.set_enable_v_scroll(false)
		#get_node("chap_3").grab_focus()

		
		return Scroll_Container.set_size(size_A)
		


func connect_signals()-> bool:
	chap_1.connect("pressed", self, "_on_chap_1_pressed")
	chap_2.connect("pressed", self, "_on_chap_2_pressed")
	chap_3.connect("pressed", self, "_on_chap_3_pressed")
	chap_4.connect("pressed", self, "_on_chap_4_pressed")
	chap_5.connect("pressed", self, "_on_chap_5_pressed")
	chap_6.connect("pressed", self, "_on_chap_6_pressed")
	chap_7.connect("pressed", self, "_on_chap_7_pressed")
	return (
		chap_1.is_connected("pressed",self,"_on_chap_1_pressed") &&
		chap_2.connect("pressed", self, "_on_chap_2_pressed") &&
		chap_3.connect("pressed", self, "_on_chap_3_pressed") &&
		chap_4.connect("pressed", self, "_on_chap_4_pressed") &&
		chap_5.connect("pressed", self, "_on_chap_5_pressed") &&
		chap_6.connect("pressed", self, "_on_chap_6_pressed") &&
		chap_7.connect("pressed", self, "_on_chap_7_pressed")
		)


"Hides Comics Chapters Buttons"
func _on_Comics_loaded_comics():
	#Comloaded_comics = true
	for child in get_children(): # works
		child.hide()


'Shows Comics Chapter Buttons'
#connected from COomics signal 
func _on_Comics_freed_comics():
	#loaded_comics = false
	for child in get_children(): 
		child.show()

"Button controls back"
# Hacky Close COmics fix for Comics refactor

func _on_Back_button_pressed():
	if loaded_comics == false or Globals.comics != null: #&& Globals.comics.enabled == false :
		Globals._go_to_title()
	#if loaded_comics == true:
		#$"/root/Dialogs".show_dialog('Finish Comics First ', 'Admin')
		
		#$"/root/Dialogs".dialog_box.hide()
		Comics_v6.close_comic()
		






func _on_chap_1_pressed():
	_on_Comics_loaded_comics()
	return Comics_v6._on_chap_1_pressed()


func _on_chap_2_pressed():
	_on_Comics_loaded_comics()
	return Comics_v6._on_chap_2_pressed()


func _on_chap_3_pressed():
	_on_Comics_loaded_comics()
	return Comics_v6._on_chap_3_pressed()


func _on_chap_4_pressed():
	_on_Comics_loaded_comics()
	return Comics_v6._on_chap_4_pressed()


func _on_chap_5_pressed():
	_on_Comics_loaded_comics()
	return Comics_v6._on_chap_5_pressed()


func _on_chap_6_pressed():
	_on_Comics_loaded_comics()
	return Comics_v6._on_chap_6_pressed()


func _on_chap_7_pressed():
	_on_Comics_loaded_comics()
	return Comics_v6._on_chap_7_pressed()

func manually_translate():
	# Should Be Implemented In Header Names
	if Dialogs.language != "" or null:
		#jggugu
		Dialogs.set_font(Comics__2_UI, 44, "",0)
		
		for i in Comics__2_UI:
			# Note: If it breaks with a null object error, it means that the scene layout has been changed
			# Update the button links then
			i.set_text(Dialogs.translate_to(i.name, Dialogs.language))
