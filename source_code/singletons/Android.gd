# Contains Android Specific Configurations of Mobiles in a single separate script


# Features 
# (1) Should CHeck Screen Orientation Every 30 Seconds
# (2) SHould Implement Android Specific Perfoormance OPtimization for different Mobiles
# (3) Should Contain All Mobile Optimizations In a single script
# (4) Should COntain Admob implementation when possible
# (5) SHould Map to Debug Signleton for Web Browser Debug
# (6) Ads Logic SHould Add banner ads as backup for failed video ads


extends Node

class_name android, "res://resources/misc/Android 32x32.png"

signal player_ready # Emitted When Player Enters Scene Tree

# Lifetime OPtimizations for CPU Particle FX
const Long_lifetime : int = 6
const Short_lifetime : int = 3
const MINUMUM_FPS : int = 25


var TouchInterface : TouchScreenHUD  setget set_TouchInterface, get_TouchInterface 
var GameHUD_ #: GameHUD 


var ingameMenu : Game_Menu setget set_GameMenu, get_GameMenu

export (bool) var _is_android = false




"Safe Pointers To Global Singletons"

onready var _debug = get_node("/root/Debug")
onready var safe_Utils = get_node("/root/Utils")
onready var _simulation = get_node("/root/Simulation")
onready var screen = get_node("/root/GameHud/TouchInterface")
onready var _globals = get_node("/root/Globals")
onready var safe_GameHUD = get_node("/root/GameHud")
onready var safe_Dialogs = get_node("/root/Dialogs")
onready var safe_TouchInterface = safe_GameHUD.TouchInterface

"Screen Extension"
# Extends screen logic calculations from touch interface, a child of gamehud
# To reduce memory over write of Global scerenn orientation integer unless necessary
# and reduce memory calls between singletons unless necessary
var local_screen_orientation : int 
onready var initial_screen_orientation : int = screen.Screen.Orientation() # for comparison

#*********** Android Plugins *************#

# Godot Chrome
var Chrome = null
#export (bool) var WebBrowserOpen : bool = false 

# Ad Mob Ads Node
onready var _ads : AdMob = self.get_child(0)
onready var ADS_TRIGGERED : bool = false
onready var TRIGGER_ADS : bool = false

var VIDEO_READY : bool = false
var BANNER_READY : bool = false

# Particle FX Trigger
var TRIGGER_RAINS : bool = false

# screen triggers
var CHECK_ORIENTATION : bool = false
var TRIGGER_SCREEN : bool = false

onready var adsTimer = $AdsTimer
onready var rainTimer = $RainsTimer
onready var screenTimer = $ScreenTimer
onready var OtTimer = $OrientationTimer

onready var scene_nodes = [adsTimer, rainTimer,screenTimer, OtTimer]

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
		if (Engine.get_singleton("GodotChrome")):
			Chrome = Engine.get_singleton("GodotChrome")
		
		
		safe_Utils.UI.check_for_broken_links(scene_nodes)
		
		# Connect Signals 
		connect("player_ready",self, "_on_player_ready")
		
		
		# Enable forced ads here
		# and reward players with coins
		ads() 
		
		#initial_screen_orientation = Utils.Screen.Orientation()
	
	# Temporarily disabled for testing/debugging Touchinterface UI on PC
	if _globals.os != "Android":
		_is_android = false
		push_warning("Device Is Not Android!")
		self.set_process(false)
	#	self.set_physics_process(false)
	
	
	#print_debug("Android :", _is_android, "/", _globals.os)


func is_android() -> bool:
	# Returns script state as boolean if is android or isnt safely
	# checks if game is running on mobile browser or native android
	
	return _is_android


func ads() -> void:
	print_debug("Running Mobile Ads")
	# create ads parameters for rewarded video and banner ads
	
	# Config and Inititalise Ads Programmatically
	
	# config ads
	_ads.banner_id = "ca-app-pub-3900377589557710/5127703243"
	_ads.rewarded_id = "ca-app-pub-3900377589557710/4046256488"
	_ads.is_real_set(true) # Test Ads & Ads Initialisation
	_ads.is_real = true
	#_ads.initialize_on_background_thread()
	_ads.load_banner()
	
	# temporarily disabling for refactor Jun 19.2025
	#_ads.load_rewarded_video()
	_ads.move_banner(false)
	_ads.show_banner()
	# Ad some sud to this account
	_globals.suds += 1000
	
	ADS_TRIGGERED = true
	
func ads_video()-> void:
	
	

	
	pass



func _no_ads() -> void:
	#print_stack() # debug the stack
	
	if is_instance_valid(_ads):
		#print_debug("Hiding Adds Banner")
		_ads.hide_banner()



func _process(_delta):
	
	
	" Rain Fx Optimizations "
	
	
	"Performance Saver"
	"Performance Optimizations"
	# Particle Optimization for Differing Screen Orientations
	
	"ADS OPTIMIZATION"
	
	if TRIGGER_ADS && !ADS_TRIGGERED: # trigger ads after 3 minutes
		# Enable ads here
		ads()
	
	"""
	RAIN FX OPTIMIZATION
	
	to do:
		(1) decouple nested if statements
		(2) Create separate timer objects with instance checking and programatic object signal connections for simulation triggers
	"""
	
	if TRIGGER_RAINS && is_instance_valid(_simulation.rainFX): 

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
			_simulation.rainFX.lifetime = Short_lifetime
			#TouchInterface.Horizontal() # doesn't work yet
		
		if local_screen_orientation == 1: #SCREEN_VERTICAL:
			_simulation.rainFX.lifetime = Long_lifetime
			



	# Update Global Screen Orientation every 100th frame
	"""
	SCREEN ORIENTATION ALGORITHM
	"""
	# Mobile Native Implemnentation
	#
	# (1) Checks Device  Screen orentation
	# (2) Sets the Global Script for Screen Orientation
	#(3) This ALgorithm should be run periodically on a separate device like mobile every 100th frame
	# (4) Should ideally be a low level signal connected to the core engine
	# (5) Should emit signals if orientation changes
	if CHECK_ORIENTATION && is_instance_valid(GameHUD_):
		# update local screen orientation 
		local_screen_orientation = GameHUD_.TouchInterface.Screen.Orientation()
		#_globals.screenOrientation = local_screen_orientation # make the new orientation more available
		CHECK_ORIENTATION = false # reset timer

		
		"""
		
		UPSCALING && DOWNSCALING MENU
		
		"""
		
		#UI Upscaing
		
		if local_screen_orientation == 1: #SCREEN_VERTICAL is 1
			
			#var newPosition = Vector2(-650,250)
			safe_Utils.UI.upscale_ui(ingameMenu, ingameMenu.newScale, ingameMenu.get_position())
		if local_screen_orientation == 0:
			safe_Utils.UI.upscale_ui(ingameMenu, ingameMenu.initialScale, ingameMenu.get_position())
		
		TRIGGER_SCREEN = false # turn off screen adjustments

func _on_player_ready():
	#if _is_android == true:
	#	print_stack()
	#	safe_TouchInterface.enabled = true
	#Android.show_all_buttons() # Show Touch HUD UI
	pass

func set_TouchInterface(hud : TouchScreenHUD):
	#print_stack()
	TouchInterface = hud
	#print_debug("Touch Interface debug: ", TouchInterface, "/", hud, "/", is_instance_valid(hud))

func get_TouchInterface() -> TouchScreenHUD:
	return TouchInterface

func set_GameMenu(hud : Game_Menu):
	ingameMenu = hud 

func get_GameMenu() -> Game_Menu:
	return ingameMenu


# Optimise android ads
func _on_AdMob_banner_loaded():
	print_debug("Banner Ads Loaded")
	BANNER_READY = true
	
	safe_Dialogs.show_dialog("Here's Your Reward! $SUD 1,000", "Admin")
	_globals.suds += 1000


func _on_AdMob_banner_failed_to_load(error_code):
	# stop the ads timer, log the error codes
	
	# pass the error code to ingame debug
	_debug.Ads_debug += "Banner Ads failed err" + str(error_code)

	print_debug(_debug.Ads_debug)
	BANNER_READY = false
	


func _on_AdMob_rewarded_video_loaded():
	# offer the player a random item spin for 1 video
	print_debug("rewarded video loaded")
	VIDEO_READY = true

func show_rewarded_video_ads():
	# Rewarded Ads Logic accounts for 
	# failure to load video ads
	#
	
	print_debug("Showing Ads VIdeos / Banner Logic")
	if VIDEO_READY && BANNER_READY:
		_ads.show_rewarded_video() # Show the rewarded video ad

	if !VIDEO_READY && BANNER_READY:
		_ads.show_banner()
		_globals.suds += 5_000
		safe_Dialogs.show_dialog("Here's Your Reward! $SUD 5,000", "A.T.M")
	if !VIDEO_READY && !BANNER_READY:
		print_debug("Ads was unable to load")
		safe_Dialogs.show_dialog("Wasn't Able to connect to the net, try again later", "A.T.M")



func _on_AdMob_rewarded_video_opened():
	print_debug("rewarded video opened")
	_globals.suds += 10_000
	#		Globals.suds += 10_000
	safe_Dialogs.show_dialog("Here's Your Reward! $SUD 10,000", "Admin")

func _on_AdMob_rewarded_video_failed_to_load(error_code):
	print_debug("rewarded video failed loading: ", error_code)


func _on_AdMob_rewarded(currency, amount):
	print_debug(currency, amount)


class Advertising:
	"""
	An Advertising Class for optimising and controlling the ads / ads data for each player
	"""
	# To DO :
	# (1) Implement in Android Singleton
	var t = 0
	
	
	static func start_ads_timer(_timer : Timer):
		_timer.start()
	
	func hash_ads_data():
		pass
		
	func stop_ads_timer(_timer : Timer):
		_timer.stop()
		
		# log the data



func _on_Timer_timeout():
	pass # Replace with function body.


func _on_AdsTimer_timeout():
	# Trigger Ads
	TRIGGER_ADS = true


func _on_RainsTimer_timeout():
	TRIGGER_RAINS = true


func _on_OrientationTimer_timeout():
	CHECK_ORIENTATION = true
	#print_debug("Screen Orientation Triggered")


func _on_ScreenTimer_timeout():
	TRIGGER_SCREEN = true
	#print_debug("Screen Resizing Triggered")


func _exit_tree(): # Delete all TImer noews
	Utils.MemoryManagement.queue_free_array(scene_nodes)
