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

export (bool) var _is_android  

# To reduce memory over write of Global scerenn orientation integer unless necessary
# and reduce memory calls between singletons unless necessary
var local_screen_orientation : int 
onready var initial_screen_orientation : int = Utils.Screen.Orientation() # for comparison

# Get Debug Singleton for Debugging
onready var _debug : Debug = get_node("/root/Debug")

func _ready():
	
	"""
	Enable & Disable
	"""
	# Features
	# (1) Disable if not on android
	# (2) Enable on Native ANdroid
	#(3) Enable on Mobile Browser
	
	if Globals.os == "Android": # Android Native
		_is_android = true
		#initial_screen_orientation = Utils.Screen.Orientation()
	if Globals.os == "HTML5" && initial_screen_orientation == 1: # Mobile Browser
		# Check Screen Dimensions to estimate if it is a mobile browser
		#initial_screen_orientation = Utils.Screen.Orientation()
		#if initial_screen_orientation == 0: # Vertical Screen is 1, it's set to 0 for local testing
		print_debug("Device Is Mobile Browser")
		_debug.misc_debug += "Device is Mobile Browser"
		_is_android = true
	else:
		_is_android = false
		self.set_process(false)
		self.set_physics_process(false)
	
	print_debug("Android :", _is_android)
	

func is_android() -> bool:
	# Returns script state as boolean if is android or isnt safely
	# checks if game is running on mobile browser or native android
	
	return _is_android

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
	RAIN FX OPTIMIZATION
	"""
	
	if Simulation.frame_counter % 200 == 0 && is_instance_valid(Simulation.rainFX): 

		# Rain Logic In A Single Function
		if Debug.fps_debug_() > MINUMUM_FPS:
			Simulation.rainFX.emitting = true
			#print ('Emitting Rain Particles') #-introducees a bug
			
		#if !enable:
		#	rain_particles.emitting = false
		
		if  Debug.fps_debug_() < MINUMUM_FPS:
			Simulation.rainFX.emitting = false

		
		# Attempt to Update GLobal screen orientation
		if Globals.screenOrientation != local_screen_orientation:
			Globals.screenOrientation  = local_screen_orientation
	
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
	if Simulation.frame_counter % 250 == 0:
		# update local screen orientation 
		local_screen_orientation = Utils.Screen.Orientation()
	
	# Sets Screen Orientation 
	if Simulation.frame_counter % 120 == 0 && is_instance_valid(TouchInterface):
		
		# compare previous orientation and adjust hud
		#if local_screen_orientation != initial_screen_orientation:
			
		Utils.Screen._adjust_touchHUD_length(TouchInterface.Anim) # sets touch interface layout
			
			# update initial screen orientation
		#	initial_screen_orientation = local_screen_orientation

		#elif local_screen_orientation == initial_screen_orientation:
		#	pass
	if Simulation.frame_counter % 130 == 00 && is_instance_valid(ingameMenu):
		"""
		
		UPSCALING && DOWNSCALING MENU
		
		"""
		
		#UI Upscaing
		
		if local_screen_orientation == 1: #SCREEN_VERTICAL is 1
			
			#var newPosition = Vector2(-650,250)
			Utils.UI.upscale_ui(ingameMenu, ingameMenu.newScale, ingameMenu.get_position())
		if local_screen_orientation == 0:
			Utils.UI.upscale_ui(ingameMenu, ingameMenu.initialScale, ingameMenu.get_position())
		
