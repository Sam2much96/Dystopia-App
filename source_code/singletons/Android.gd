# Contains Android Specific Configurations of Mobiles in a single separate script


# Features 
# (1) Should CHeck Screen Orientation Every 30 Seconds
# (2) SHould Implement Android Specific Perfoormance OPtimization for different Mobiles
# (3) Should Contain All Mobile Optimizations In a single script
# (4) Should COntain Admob implementation when possible
# (5) SHould Map to Debug Signleton for Web Browser Debug


extends Node

class_name android, "res://resources/misc/Android 32x32.png"

signal player_ready # Emitted When Player Enters Scene Tree

# Lifetime OPtimizations for CPU Particle FX
const Long_lifetime : int = 6
const Short_lifetime : int = 3
const MINUMUM_FPS : int = 25


onready var TouchInterface : TouchScreenHUD  setget set_TouchInterface, get_TouchInterface #= GlobalInput.gameHUD.TouchInterface
onready var GameHUD_ : GameHUD 


var ingameMenu : Game_Menu

export (bool) var _is_android = false

# To reduce memory over write of Global scerenn orientation integer unless necessary
# and reduce memory calls between singletons unless necessary
var local_screen_orientation : int 
onready var initial_screen_orientation : int = Utils.Screen.Orientation() # for comparison

# Get Debug Singleton for Debugging
onready var _debug = get_node("/root/Debug")

# SImulation SIngleton Pointer
onready var _simulation = get_node("/root/Simulation")

onready var _globals = get_node("/root/Globals")

#*********** Android Plugins *************#

# Godot Chrome
var Chrome = null
#export (bool) var WebBrowserOpen : bool = false 

# Ad Mob Ads Node
onready var _ads : AdMob = self.get_child(0)



func _ready():
	
	"""
	Enable & Disable
	"""
	# Features
	# (1) Disable if not on android
	# (2) Enable on Native ANdroid
	# (3) Enable on Mobile Browser
	
	if _globals.os == "Android": # Android Native
		_is_android = true
		
		# load Godot Chrome Browser
		# To do : write separate godotchrome class 
		Chrome = Engine.get_singleton("GodotChrome")
		
		
		
		
		# Connect Signals 
		connect("player_ready",self, "_on_player_ready")
		
		
		
		ads() # Enable ads here
		
		#initial_screen_orientation = Utils.Screen.Orientation()
	if _globals.os == "HTML5" && initial_screen_orientation == 1: # Mobile Browser
		# Check Screen Dimensions to estimate if it is a mobile browser
		#initial_screen_orientation = Utils.Screen.Orientation()
		#if initial_screen_orientation == 0: # Vertical Screen is 1, it's set to 0 for local testing
		print_debug("Device Is Mobile Browser")
		_debug.misc_debug += "Device is Mobile Browser"
		_is_android = true
	
	if _globals.os == "HTML5" && initial_screen_orientation == 0: # PC Browser
		# Check Screen Dimensions to estimate if it is a mobile browser
		#initial_screen_orientation = Utils.Screen.Orientation()
		#if initial_screen_orientation == 0: # Vertical Screen is 1, it's set to 0 for local testing
		print_debug("Device Is PC Browser")
		_debug.misc_debug += "Device is PC Browser"
		_is_android = false
	
	if _globals.os != "Android":
		_is_android = false
		push_warning("Device Is Not Android!")
		self.set_process(false)
		self.set_physics_process(false)
	
	print_debug("Android :", _is_android, "/", _globals.os)
	

func is_android() -> bool:
	# Returns script state as boolean if is android or isnt safely
	# checks if game is running on mobile browser or native android
	
	return _is_android


func ads() -> void:
	# create ads parameters
	
	# Config and Inititalise Ads Programmatically
	
	# config ads
	_ads.banner_id = "ca-app-pub-3900377589557710/5127703243"
	_ads.rewarded_id = "ca-app-pub-3900377589557710/4046256488"
	_ads.is_real_set(false) # Test Ads & Ads Initialisation
	_ads.is_real = false
	#_ads.initialize_on_background_thread()
	_ads.load_banner()
	_ads.load_rewarded_video()
	
	_ads.show_banner()
	_ads.move_banner(false)


func _no_ads() -> void:
	print_stack() # debug the stack
	
	if is_instance_valid(_ads):
		print_debug("Hiding Adds Banner")
		_ads.hide_banner()


func hide_touch_interface():
	
	# Hide Game HUD
	# TO DO: Port TO Touch HUD Inspector Tab
	TouchInterface.reset()



func show_only_menu():
	TouchInterface.__menu()

func show_all_buttons():
	print_stack()
	TouchInterface.show_action_buttons()
	TouchInterface.show_direction_buttons()



func _process(_delta):
	
	
	" Rain Fx Optimizations "
	
	
	"Performance Saver"
	"Performance Optimizations"
	# Particle Optimization for Differing Screen Orientations
	
	# Bug : 
	# (1) CPU Fx SHould contain platform asychronic Optimizations
	# (2) CPU optimization is buggy
	#
	# Functions :
	# (1) Turns off CPU fx is framerate is too low
	
	"""
	Touch HUD Visibility
	"""
	
	if is_instance_valid(TouchInterface) && _is_android == false : # PC Browser
		TouchInterface.hide()
	
	"""
	RAIN FX OPTIMIZATION
	"""
	
	if _simulation.frame_counter % 200 == 0 && is_instance_valid(_simulation.rainFX): 

		# Rain Logic In A Single Function
		if _debug.fps_debug_() > MINUMUM_FPS:
			_simulation.rainFX.emitting = true
			#print ('Emitting Rain Particles') #-introducees a bug
			
		#if !enable:
		#	rain_particles.emitting = false
		
		if  _debug.fps_debug_() < MINUMUM_FPS:
			_simulation.rainFX.emitting = false

		
		# Attempt to Update GLobal screen orientation
		if _globals.screenOrientation != local_screen_orientation:
			_globals.screenOrientation  = local_screen_orientation
	
		if local_screen_orientation == 0: #.SCREEN_HORIZONTAL:
			Simulation.rainFX.lifetime = Short_lifetime
			#TouchInterface.Horizontal() # doesn't work yet
		
		if local_screen_orientation == 1: #SCREEN_VERTICAL:
			Simulation.rainFX.lifetime = Long_lifetime
			
			# Touch Interface downscaling
			# TOuch Interface Format and Scaling should be exported functionis
			# doesn't work yet
			#TouchInterface.Vertical()

	# Functions:
	#toggles touch interface visibility depending on the os and screen orientation (Pc or Mobiles)
	#
	# (1) Moved to ANdroid singleton for more polling
	# what???
		#TouchInterface._Hide_touch_interface = false
		#TouchInterface.show()
		#print_debug('Hiding touch interface for ', Globals.os)


	
	
	# Update Global Screen Orientation every 100th frame

	"""
	SCREEN ORIENTATION ALGORITHM
	"""
	# Mobile Native Implemnentation
	#
	# (1) Checks Device  Screen orentation
	# (2) Sets the Global Script for Screen Orientation
	#(3) This ALgorithm should be run periodically on a separate device like mobile every 100th frame
	if _simulation.frame_counter % 250 == 0:
		# update local screen orientation 
		local_screen_orientation = Utils.Screen.Orientation()
	
	# Sets Screen Orientation 
	if _simulation.frame_counter % 120 == 0 && is_instance_valid(GameHUD_):
		
		# compare previous orientation and adjust hud
		#if local_screen_orientation != initial_screen_orientation:
			
		Utils.Screen._adjust_touchHUD_length(GameHUD_.Anim) # sets touch interface layout
		
		# for debugging console Logs
		#print_debug("Debug 2:", Android.Chrome.consoleLog())
		
		
			# update initial screen orientation
		#	initial_screen_orientation = local_screen_orientation

		#elif local_screen_orientation == initial_screen_orientation:
		#	pass
	if _simulation.frame_counter % 130 == 00 && is_instance_valid(ingameMenu):
		"""
		
		UPSCALING && DOWNSCALING MENU
		
		"""
		
		#UI Upscaing
		
		if local_screen_orientation == 1: #SCREEN_VERTICAL is 1
			
			#var newPosition = Vector2(-650,250)
			Utils.UI.upscale_ui(ingameMenu, ingameMenu.newScale, ingameMenu.get_position())
		if local_screen_orientation == 0:
			Utils.UI.upscale_ui(ingameMenu, ingameMenu.initialScale, ingameMenu.get_position())
		

func _on_player_ready():
	if _is_android == true:
			# Move To android Singleton
	#if Globals.os == "Android":
		GlobalInput.TouchInterface.enabled = true
		Android.show_all_buttons() # Show Touch HUD UI


func set_TouchInterface(hud : TouchScreenHUD):
	TouchInterface = hud

func get_TouchInterface() -> TouchScreenHUD:
	return TouchInterface

# OPtimise android ads
func _on_AdMob_banner_loaded():
	print_debug("Banner Ads Loaded")
	
	# Ad some sud to this account
	Globals.suds += 1000
	



func _on_AdMob_banner_failed_to_load(error_code):
	# stop the ads timer, log the error codes
	
	# pass the error code to ingame debug
	_debug.Ads_debug += "Banner Ads failed err" + str(error_code)

	print_debug(_debug.Ads_debug)

	


func _on_AdMob_rewarded_video_loaded():
	# offer the player a random item spin for 1 video
	print_debug("rewarded video loaded")
	

func show_rewarded_video_ads():
	_ads.show_rewarded_video() # Show the rewarded video ad



func _on_AdMob_rewarded_video_opened():
	print_debug("rewarded video opened")
	Globals.suds += 10_000

func _on_AdMob_rewarded_video_failed_to_load(error_code):
	print_debug("rewarded video failed loading: ", error_code)


func _on_AdMob_rewarded(currency, amount):
	print_debug(currency, amount)
