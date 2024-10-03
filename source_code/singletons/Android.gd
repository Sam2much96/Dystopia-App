# Contains Android Specific Configurations of Mobiles in a single separate script


# Features 
# (1) Should CHeck Screen Orientation Every 30 Seconds
# (2) SHould Implement Android Specific Perfoormance OPtimization for different Mobiles
# (3) Should Contain All Mobile Optimizations In a single script
# (4) Should COntain Admob implementation when possible
# (5) SHould Map to Debug Signleton for Web Browser Debug


extends Node

class_name android, "res://resources/misc/Android 32x32.png"

# Lifetime OPtimizations for CPU Particle FX
const Long_lifetime : int = 6
const Short_lifetime : int = 3
const MINUMUM_FPS : int = 25


var TouchInterface : TouchScreenHUD

var ingameMenu : Game_Menu

export (bool) var _is_android = true

# To reduce memory over write of Global scerenn orientation integer unless necessary
# and reduce memory calls between singletons unless necessary
var local_screen_orientation : int 
onready var initial_screen_orientation : int = Utils.Screen.Orientation() # for comparison

# Get Debug Singleton for Debugging
onready var _debug = get_node("/root/Debug")

# SImulation SIngleton Pointer
onready var _simulation = get_node("/root/Simulation")

onready var _globals = get_node("/root/Globals")

# Godot Chrome
var Chrome = null


func _ready():
	
	"""
	Enable & Disable
	"""
	# Features
	# (1) Disable if not on android
	# (2) Enable on Native ANdroid
	#(3) Enable on Mobile Browser
	
	if _globals.os == "Android": # Android Native
		_is_android = true
		
		# load Godot Chrome Browser
		  
		Chrome = Engine.get_singleton("GodotChrome")#load("res://New game code and features/GodotChrome.gd")
		
		
		#initial_screen_orientation = Utils.Screen.Orientation()
	if _globals.os == "HTML5" && initial_screen_orientation == 1: # Mobile Browser
		# Check Screen Dimensions to estimate if it is a mobile browser
		#initial_screen_orientation = Utils.Screen.Orientation()
		#if initial_screen_orientation == 0: # Vertical Screen is 1, it's set to 0 for local testing
		print_debug("Device Is Mobile Browser")
		_debug.misc_debug += "Device is Mobile Browser"
		_is_android = true
		
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


static func ads(_ads : AdMob, tree : SceneTree, state : bool) -> void:
	# Should Config and Inititalise Ads Programmatically
	# Ads Experience SHould Be Cached ANd Timed To SHow & Disappear uppon Player Death
	# Only Implement Banner Ads For This Game`
	#var _ads #= AdMob.new()
	
	if state == true:
		# config ads
		_ads.banner_id = "ca-app-pub-3900377589557710/5127703243"
		_ads.is_real_set(false) # Test Ads & Ads Initialisation
		#_ads._init()
		_ads.load_banner()
		_ads.show_banner()
		_ads.move_banner(false)
	if state == false:
		_ads.hide_banner()
	


func _process(delta):
	
	
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
	if _simulation.frame_counter % 120 == 0 && is_instance_valid(TouchInterface):
		
		# compare previous orientation and adjust hud
		#if local_screen_orientation != initial_screen_orientation:
			
		Utils.Screen._adjust_touchHUD_length(TouchInterface.Anim) # sets touch interface layout
			
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
		
