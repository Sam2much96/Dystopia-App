# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# The Debug singleton 
#(1) It processes and Debugs the Player  and Enemy AI states, as well as the other singletons
# (2) reate State Machine
#
# Bugs 
# (1) it is hard coded and requires both a looser code and a general update
#  (2) Version 2 of the Debug codes have yet to be implemented
# (6) Use return to end functions instead of Pass, pass breaks the code
# (7) It's Now a Huge performance hog. Lmfao
	# use is_instance_valid(debug) with set-get functions as a runtime parameter
#(8) Implement font size increase
# *************************************************
# To DO:
# (1) Refactor to use one RichText Label for all debug parameters
#
# *************************************************



extends Node 

class_name debug

export (bool) var enabled 


var error_splash_page : PackedScene = load ('res://New game code and features/Error splash page for crashes.tscn')


var logging = false
#var user_font_size = 80
var __label  

#lists of labels being used by the debug panel
var music_label : Label
var player_label : Label 
var ram_label : Label
var fps_label : Label
var enemy_label : Label
var network_label : Label
var comics_label : Label
var autosave_label : Label
var misc_label : Label
var globals_label : Label
var ads_label : Label
var avail_thread_label : Label
#

var Autosave_debug : String ='' 
var Music_debug : String
var Player_debug : String
var Ram_debug : String
export (float) var FPS_debug : float 
var Enemy_debug : String
var debug_panel  : Node
var Comics_debug : String = ''
var misc_debug : String = ''
var kill_count : int = 0
var enemy : String = ''
var Network_debug : String = ''
var Globals_debug : String
var Ads_debug : String = ''
var avail_thread : String = "0"

# State Machine Variables
enum {START_DEBUG, STOP_DEBUG}
var _state_ = START_DEBUG

# Debug panel cannot be more than 1
var debug_panels_cr8ted : Array = [] # append the debug pannel to this array to stop double instance bug


"""
THE DEBUG SINGLETON
"""



#func _ready():
	#if enabled == true : #and debug_panel != null: #breaks the code, diabling for debug purposes
	#start_debug_v1()
	#return

var frame_counter : int = 0


func _input(event): 
	"""
	functions that control the debug process
	"""
	if event.is_action_pressed("Debug") and debug_panel != null: #stops the debug code #catch the error that occurs
		stop_debug() #Disabling to Debug
		return
	elif event.is_action_pressed("Debug") and debug_panel == null:
		start_debug_v1() #Disabling to Debug
		return


func _process(_delta):

	if enabled:
		
		frame_counter += 1
		
		if frame_counter >= 1000:
			
			#Reset Counter
			frame_counter = 0

		if frame_counter % 5 == 0:
			FPS_debug = fps_debug_() #fps_debug_() # update fps counter for other scenes
			

			" DEBUG STATE MACHINE " #Disabling to Debug
			match _state_:
				START_DEBUG: # works
					#start_debug_v1() # creates multiple instances bug
					Music_debug ='Music debug:' + str(Music.music_debug)
					Player_debug ='Player debug:'+ str(Globals.player) + 'Spawn point:' + str(Globals.spawnpoint) + 'Current level: ' + str(Globals.current_level) 
				
					#it uses the ram_mb funtion to convert bytes to mb
					Ram_debug= ('Ram Used :'+ ((_ram_debug())) + 'mb') 
					#'FPS: '+ str(Engine.get_frames_per_second())
					Enemy_debug = 'Enemy debug:' + str('Killcount:' , Globals.kill_count)
					Autosave_debug = Autosave_debug

					Network_debug =  str(Networking.debug )
					misc_debug = str(misc_debug) #+ str("/")  + _new_debug('new debugs are run in this function: ')
					Globals_debug='Direction type' + '/'+ str(Globals.direction_control)
					avail_thread = str('Available threads: ',int (OS.get_processor_count())) 

					
					
					return show_debug_v1() #causes the double instance bug
				STOP_DEBUG:
					if not debug_panel == null:
						if is_instance_valid(debug_panel): debug_panel.queue_free()
						
						debug_panel = null # Null instance bug from the debug panel
						enabled = false
						Music_debug = ""
						Player_debug = ""
						Ram_debug= ""
						FPS_debug = 0.0
						Enemy_debug= ""
						Network_debug = ""
						misc_debug = ""
						avail_thread = ""
						
						return
					if debug_panel == null:
						return
	


	"""
	Error catcher
	"""
	# Turns off debuging if the debug panel isn't created
	if enabled == true and debug_panel == null:
		push_error("Error getting Debug panel, turning off debug.")
		enabled = false
	
	# Prevents double instance bug
		#(1) create an array and add new debug panels to it when instanced
		#(2) Delete the previous array entry once they are == 2
	if debug_panels_cr8ted.size() >= 2:
		debug_panel = debug_panels_cr8ted.pop_front()

" Globally Accessible Framerate"
func fps_debug_()-> float:
	return Engine.get_frames_per_second()

func _ram_debug() -> String:
	#This code gets the current ram being used as bytes 
	#and converts it to MB and rounds up the final figure
	var ram_mb = String(round(float(OS.get_static_memory_usage()) / 1_048_576))
	
	return ram_mb


func stop_debug():
	_state_ = STOP_DEBUG

"""
VERSION 1 CODE CREATES THE DEBUG PANEL TO SHOW THE DEBUG VALUES
"""
"Uses THe Input Function to control it"
func start_debug_v1():  #Creates multiple instances bug
	enabled = true # write to create only single insances of children 


	#creates and loads dynamic fonts
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load('res://fonts/adamwarrenpro.ttf')
	
	"Changes Font Size for Mobile Ui"
	if Globals.screenOrientation == 1:
		dynamic_font.size = 50
	else : dynamic_font.size = 26
	
	#dynamic_font.size = 26
	dynamic_font.outline_size = 2
	dynamic_font.outline_color= Color(0,0,0,1)
	dynamic_font.use_filter = true
	debug_panel =CanvasLayer.new() 
	#add debug layer as child of debug singleton #fixes touch input bug
	get_tree().get_root().get_node("/root/Debug").call_deferred('add_child',debug_panel) 
	debug_panel.add_to_group('debug') #adds to a group, dont know if it works
	
	debug_panels_cr8ted.append(debug_panel) # Appends to an array
	#set draw order
	debug_panel.set_layer(1) 

	var vbox = VBoxContainer.new()
	debug_panel.add_child(vbox) #draws vbox on screen
	#sets mouse filter to ignore' fixes startup bug
	#print(vbox.get_mouse_filter())
	vbox.set_mouse_filter(2)
	
	music_label = Label.new()
	player_label = Label.new()
	ram_label= Label.new()
	fps_label= Label.new()
	enemy_label= Label.new()
	network_label= Label.new()
	comics_label= Label.new()
	autosave_label= Label.new()
	misc_label =Label.new()
	globals_label = Label.new()
	ads_label = Label.new()
	avail_thread_label = Label.new()
	vbox.add_child(music_label) #update code to use for loop
	vbox.add_child(player_label)
	vbox.add_child(ram_label)
	vbox.add_child(fps_label)
	vbox.add_child(enemy_label)
	vbox.add_child(network_label)
	vbox.add_child(comics_label)
	vbox.add_child(autosave_label)
	vbox.add_child(misc_label)
	vbox.add_child(globals_label)
	vbox.add_child(ads_label)
	vbox.add_child(avail_thread_label)
	
	#add font data #use label.rect_size.x and .y= 100 to manually increase label size
	#vbox.ALIGN_CENTER #aligns vbox to center #fix code
	music_label.add_font_override('font', dynamic_font) #adds dynamc font data
	player_label.add_font_override('font', dynamic_font) #use a forloop for this
	ram_label.add_font_override('font', dynamic_font)
	fps_label.add_font_override('font', dynamic_font)
	enemy_label.add_font_override('font', dynamic_font)
	network_label.add_font_override('font', dynamic_font)
	comics_label.add_font_override('font', dynamic_font)
	autosave_label.add_font_override('font', dynamic_font)
	misc_label.add_font_override('font', dynamic_font)
	globals_label.add_font_override('font', dynamic_font)
	ads_label.add_font_override('font', dynamic_font)
	avail_thread_label.add_font_override('font', dynamic_font)
	
	_state_ = START_DEBUG

func start_debug_2():  #Works with some bugs
	enabled = true
	debug_panel =CanvasLayer.new() 
	__label =  RichTextLabel.new()
	debug_panel.add_to_group('debug') 
	debug_panel.set_layer(1) 
	debug_panel.add_child(__label) #draws vbox on screen
	__label.set_mouse_filter(2)
	'Error Catcher 1- Makes script a child of globals if debug singleton goes down'
	if get_tree().get_root().get_node("/root/Debug") == null:
		#add debug layer as child of debug singleton 
		get_tree().get_root().get_node("/root/Globals").call_deferred('add_child',debug_panel)
		return false
	elif get_tree().get_root().get_node("/root/Debug") != null:
		get_tree().get_root().get_node("/root/Debug").call_deferred('add_child',debug_panel)
		return true


"""
VERSION 1 CODE SETS THE DEBUG LABELS TO THEIR CALCULATED VALUES
"""
func show_debug_v1():
	if debug_panel != null :
		if Music_debug!= null && music_label != null:
			music_label.set_text (Music_debug) 
		if Player_debug != null && player_label != null:
			player_label.set_text (Player_debug)
		if Ram_debug != null && ram_label != null:
			ram_label.set_text (Ram_debug) 
		if FPS_debug != null && fps_label != null:
			fps_label.set_text (str(FPS_debug))
		if Enemy_debug != null && enemy_label != null:
			enemy_label.set_text (Enemy_debug)
		if Network_debug != null && network_label != null:
			network_label.set_text (Network_debug)
		if Comics_debug != null && comics_label != null:
			comics_label.set_text  (Comics_debug)
		if Autosave_debug != null && autosave_label != null:
			autosave_label.set_text (Autosave_debug)
		if misc_debug != null && misc_label != null:
			misc_label.set_text( misc_debug)
		if Globals_debug != null && globals_label != null:
			globals_label.set_text(Globals_debug)
		if Ads_debug != null && ads_label != null:
			ads_label.set_text(Ads_debug)
		if avail_thread != null && avail_thread_label != null:
			avail_thread_label.set_text(str(avail_thread))
	if debug_panel != null and enabled: 
		return
	if debug_panel == null and !enabled :
		push_error('error getting debug panel')
		return
	

func show_debug_2(): #works, but the label spawn point breaks
	if debug_panel != null && __label != null:
		__label.add_text (str(Music_debug) + str ( Player_debug ) )
		__label.append_bbcode("[center]" + str(__label.text) + "[/center]\n")
		__label.set_use_bbcode(true)
		__label.set_modulate(Color( 0.86, 0.08, 0.24, 1)) 
		__label.update()
	if debug_panel != null and enabled: 
		return
	if debug_panel == null and !enabled :
		push_error('error getting debug panel')



func log_debug(): #improvve logging code run at exit tree  #Copy log files to documents
	if ProjectSettings.get_setting('logging/file_logging/enable_file_logging'):
		var _doc = OS.get_system_dir(2) 
		var _dir = Utils.dir
		var _log = Utils.file
		_log.open('user://logs/godot.log', File.READ_WRITE)
		_log.store_string ( 'dystopia_app_log'+ str(OS.get_time(true)) +
			Music_debug + Player_debug + Ram_debug + str(FPS_debug) + Enemy_debug + Network_debug + Comics_debug +
			Autosave_debug + misc_debug + Globals_debug + Ads_debug + avail_thread
			) 
		
		
		#('user://logs/godot.log' from, _doc to)
		print ('Doc:',_doc,'  log: ', _log) #works
		print ('logging debug, saved to  ', _doc, ', user://logs/godot.log')
		_log.close()
		_dir.copy('user://logs/godot.log',str(_doc)) #buggy ## Low Priority Program. Does not execute

# Low Priority Program. Does not execute
func _exit_tree():
	print (get_tree().get_node_count())  # a new commit
	if logging == true:
		log_debug() #Attempts to save this run's log file
	
	
	pass
