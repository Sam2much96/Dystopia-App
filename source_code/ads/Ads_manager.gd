extends CanvasLayer
# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is an ads manager used to activate
# and manage the ad mediator sdk's built with the project
# ************************************************* 
# Features
# (1) Codes for selecting and initializing an ads mediator for Android mobile phones 
# (2) Switches Between Ads Mediator Programmatically
# (3) Changes the Ad type Programmatically
# (4) Uses a Dictionary to manage ads initialization
# (5) Works only on Android Mobiles
# (6) Uses a 5 second timer to run an initialization loop
#To DO
# OS specific implementation calls to determine os differences
# DIfferent AD states to expand codes
# Unified debug for ell ad mediators
# Make Ads less invasive
# Bugs
# (2) Yodo1Mas implementation code might be broken (testing)
# (3) Compilong Appodeal SDK with yodo1mas creates a bug on the java side of the codes
# (4) Admob is banned. Attempt implementing yodo1mas



class_name ADsManager


"""
THIS CODE STARTED OUT AS A DEBUGGER FOR THE AD'S . IT IS EVOLVING TO AN AD MANAGER SYSTEM
"""
# Debug change_mediators function, especially the dictionary implementation

#var Ads_debug (
'Reference to the Ad Mediators'
onready var Admob = $AdMob
#onready var _Appodeal = $Appodeal
onready var _yodo1mas = $Yodo1Mas
onready var timer = $Timer


onready var java_singleton

export (int) var  _timeout_timer = 10

'Ads Mediators'
var mediators = {0:'GodotAppodeal',1: "GodotAdMob",2:"GodotYodo1Mas"}

'Ads Selector For Inspector Tab'
export (String, 'GodotAppodeal', "GodotAdMob", "GodotYodo1Mas") var singleton #It can't auto detect during runtimes

'Ads Type'
export (String, 'banner_ad', "video_ad", 'interstitial') var _ad_type #='GodotAppodeal' #It can't auto detect during runtimes
export var ads_debug:String
export (bool) var enabled
export (bool) var testing = true
export (int) var _how_many_times #used for an initialization Loop
var _are_the_ads_displaying_ 
export (bool) var Fast_debug # runs a fast debug loop (depreciated)

onready var _Debug = get_tree().get_root().get_node("/root/Debug")

"CHECKS FOR THE SINGLETON VARIABLES SO I'M NOT MAKING FREQUENT CALLS TO THE ENGINE"
var DoEngineCheck1 #Admob
var DoEngineCheck2 # Appodeal
var DoEngineCheck3 # Yodo1Mas

#export (bool) var _Has_singleton_compiled # Stores engine data if the ad singleton is compiled (depreciated)

func _enter_tree():
	fast_debug() # used in Ads logic, always leave on
	check_ads_mediators() # Checks and modifies the Mediators dictionary

func init(): #just counts an inititalization loop
	
	# A counting integer for an init loop
	_how_many_times = _how_many_times+1
	print ('Singleton: ',singleton)

func _ready():
	_connect_ads_signals()
	
	
	if enabled == true:
		"# Checks the available ad mediators and modifies a mediator dictionary from the result"
		#check_ads_mediators() #duplicate code
		
		"""
		ERROR CHECKER 1
		"""
		#sets the java singleton for initialization
		#if Engine.has_singleton(singleton)== true: #depreciated. Should use a function to initialize ads
		'Uses The Check Ads Mediators Function To Initialize ther Ads'
		
		if mediators.has(1) && singleton == str ('GodotAdMob'):
			
			java_singleton = Engine.get_singleton(singleton) #sets the Java singleton
			
			admob() # it returns a boolean if initialized successfully
			print ('Has Admob initialized: ', str(admob()))
			enabled = false # Deactivates the ads manager to avoid a stack overflow
			
		if mediators.has(0) && singleton == str('GodotAppodeal'):
				pass
		if mediators.has(2) &&  singleton == str ("GodotYodo1Mas"):
			 
			java_singleton = Engine.get_singleton(singleton) #sets the Java singleton
			yodo1mas() #rewrite
			
			enabled = false # Deactivates the ads manager to avoid a stack overflow


#"""
#APPODEAL AD LOADING FUNCTION
#"""


# Loads admob banner
func admob() ->   bool : 
	if singleton == null: #Error catcher
		print ('singleton is null, deactivating')
		return false
	if (Engine.has_singleton(singleton)) == true && enabled == true:
		Admob.init()
		
		print('initializing ', (singleton),' Debugging ', singleton,' : ', Admob._admob_singleton, _ad_type) #pass these variables to debug string
		if _ad_type == 'banner_ad':
			Admob.load_banner()
			Admob.show_banner()
			_are_the_ads_displaying_ = true
			return true
			print ( 'Banner Dimensions :', str(Admob.get_banner_dimension())) #pass these variables to debug string
		elif _ad_type == 'interstitial':
			Admob.load_interstitial()
			Admob.show_interstitial()
			_are_the_ads_displaying_ = true
			return true
			print ('Is interstitial initialised: ', str(Admob.is_interstitial_loaded())) #pass these variables to debug string
		elif _ad_type == "video_ad": # I have no rewards to give the users
			Admob.load_rewarded_video()
			Admob.show_rewarded_video()
			_are_the_ads_displaying_ = true
			print ('Is rewarded video loaded: ', str(Admob.is_rewarded_video_loaded())) #pass these variables to debug string
			return true
		else: return false
		
		
		# Error Handlers
		if Admob.is_rewarded_video_loaded() == false: # if rewarded video fails to load
			# resets ad type to banner ad
			_ad_type = 'banner_ad'
			#return _ad_type
		print ( 'Is',(singleton), 'Initialized ' , str(Admob.init())) # Checks if the singleton initializes

	if not bool(Engine.has_singleton(singleton)) == true && enabled == true: # AUTOMATICALLY FAST DEBUS IF THE ENGINE SINGLETON ISN'T THERE
		fast_debug()
		return false
	else: return false

" Breaking the code here. To Debug Later"
func yodo1mas()-> bool:
	if singleton == null: #Error catcher
		print ('singleton is null, deactivating')
		return false
	if (Engine.has_singleton(singleton)) == true && enabled == true:
		#var _y =Engine.get_singleton("GodotYodo1Mas")
		if _ad_type == str ('banner_ad'):
			_yodo1mas.show_banner_ad()
			return true
		if _ad_type == str ( "video_ad"):
			_yodo1mas.show_rewarded_ad()
			_are_the_ads_displaying_ = true
			return true
		if _ad_type == str (  'interstitial'):
			_yodo1mas.show_interstitial_ad() 
			_are_the_ads_displaying_ = true
			return true
	if not (Engine.has_singleton(singleton)) == true:
		_Debug.Ads_debug = str ('Singleton', singleton, 'is not present in the testing device') 
		return false
	if DoEngineCheck3 == true && enabled == false:
		_Debug.Ads_debug = str ('Ads manager is not enabled')
		return false # Retuns a boolean if the ads is implemented or not
	return true # Requires Testing


func check_ads_mediators():
	#check if engine has the singleton installed and erases them from the mediators dictionary if they aren't 
	if not Engine.has_singleton('GodotAdMob') :
		if mediators.has(1):
			mediators.erase(1)
	
	if not Engine.has_singleton('GodotAppodeal') : #not yet tested if it works
		if mediators.has(0):
			mediators.erase(0)
	
	if not Engine.has_singleton("GodotYodo1Mas"):
		if mediators.has(2):
			mediators.erase(2)
	
func change_ads_mediator(): #selects a random ads mediator ##temporarily disabling until i'm able to properly debug
	# Don't change ads mediator in process function
	# Not yet properly debugged
	# Kind of works?
	print ("//Ad mediators: ",mediators)
	singleton = ''
	if mediators.size() > 1: # Only activates when more than one mediator is installed
		var _no = int(rand_range(-1,mediators.size())) #selects a random mediator number
	
		print ("Selected Mediator: ", str(mediators[_no])) #for debug Purposes only
		singleton = mediators[_no]
		return singleton
	if mediators.size() == 1: #Use only 1 dictionary value if the app has only 1 mediator
		print ("//Mediator Installed://",mediators.values()) #for debug purposes only
		singleton = (mediators.values())
		return singleton
		
	if mediators.size() == 0: #if mediator sdk not compiled
		singleton = null #should throw up an error or break
		return 
	init() #initialises ads manager with new ads manager singleton

func change_ads_type(ads):
	if ads == null or '': # Random ad type selector
		var types_of_ads = {0:'banner_ad', 1:"video_ad", 2:'interstitial'}
		_ad_type = ''
		var _no = int(rand_range(-1,types_of_ads.size())) #selects a random ad type
		_ad_type = types_of_ads[_no]
		return _ad_type
		init() #initialises ads manager with new ads manager singleton
	if ads == 'banner_ad':
		_ad_type = 'banner_ad'
		return _ad_type
		init()
	if ads == "video_ad":
		_ad_type = "video_ad"
		return _ad_type
		init()
	if ads ==  'interstitial':
		_ad_type = 'interstitial'
		return _ad_type
		init()
	else:
		push_error('Ads can only be'+ 'banner_ad'+ "video_ad"+ 'interstitial')

func _connect_ads_signals(): # Documented
	"connects Ads signals"
	# Uses the Ads Dictionary to connect ads signals
	#Autochanges ads mediator
	#Yodo1Mas
	if mediators.has(2) :
		if _yodo1mas.connect('banner_ad_not_loaded', self, "change_ads_mediators") != OK:
			_yodo1mas.connect('banner_ad_not_loaded', self, "change_ads_mediators")
			_yodo1mas.connect("interstitial_ad_not_loaded", self, "change_ads_mediators")
			_yodo1mas.connect("rewarded_ad_not_loaded", self, "change_ads_mediators")
	if not mediators.has(2) : return

	#Appodeal
	if mediators.has(0) :
		pass
	if not mediators.has(0): return
	
	
	#Admob
	if mediators.has(1) :
		if Admob.connect("banner_failed_to_load", self, "change_ads_mediators") != OK:
			Admob.connect_signals()  #admob connects emitted signals within it's own function
			Admob.connect("banner_failed_to_load", self, "change_ads_mediators")
			Admob.connect("interstitial_failed_to_load", self, "change_ads_mediators")
			Admob.connect("rewarded_video_failed_to_load", self, "change_ads_mediators")
	if not mediators.has(1) : return
	

func _process(_delta):
	
	
	 #Debugs the Ad state to the Debug Panel
	if enabled == true :
		if mediators.size() == 0: #use mediators dictionary instead
			if _Debug != null:
				_Debug.Ads_debug = '//Engine does not have any Advertising  singleton' 
				
		if not mediators.size() == 0 : #engine has singleton funtion breaks 
			#Updates the Ads debug to the ads debug
			_Debug.Ads_debug = '//Engine has singleton'+ '//Ads debug//'+(ads_debug) + "//Are the Ads showning" + (_are_the_ads_displaying_)
			
			"""
			CHECKS IF THE AD MEDIATORS EMITS A /failed to load/ SIGNAL
			"""
			"Admob"
		if mediators.has(1):
			var error_code   
			if Admob.emit_signal("banner_failed_to_load", error_code):
				ads_debug += ('//banner failed to load/'+' Singleton: '+"Admob"+'/Error Code:'+ str(error_code))
			if Admob.emit_signal("banner_loaded"):
				ads_debug += ('//banner loaded')
			
			"Appodeal"
		if mediators.has(0):

			pass
			
			"Yodo1Mas"
		if mediators.has(2):
			if _yodo1mas.emit_signal("banner_ad_not_loaded"):
				ads_debug += ('//Banner Ads failed to load/')
				_are_the_ads_displaying_ = false
			if _yodo1mas.emit_signal("interstitial_ad_not_loaded"):
				ads_debug += ('//Interstitial Ads failed to load/')
				_are_the_ads_displaying_ = true
			if _yodo1mas.emit_signal("rewarded_ad_not_loaded"):
				ads_debug += ('//Rewarded Ads failed to load/')
				_are_the_ads_displaying_ = true
		if not mediators.has(0):
			return
		if not mediators.has(1):
			return
		if not mediators.has(2):
			return
			"""
			# Supposed to programmatically change the ad server once an ad mediator fails
			"""
		if _are_the_ads_displaying_ == false: 
			if mediators == str ('GodotAdMob'): # Account for the 3 ad mediators ads failing to load
				ads_debug  += str('ads fail to display')
				
			if mediators == str ('GodotAppodeal'):
				ads_debug  += str('ads fail to display')
				
			if mediators == str ("GodotYodo1Mas"):
				ads_debug  += str('ads fail to display')
				

	"""
	Ads initialization loop
	"""
	if not enabled  :
		pass
	# Loop controller
	if (_how_many_times) >= 11:
		enabled = false
		_how_many_times = 0 #resets this
		print ('Stopping Ads initialization')

func _exit_tree():
	print ('Ads Tester Exits Tree')
	#_Appodeal.appodeal.
	
	if DoEngineCheck1 or DoEngineCheck2 or DoEngineCheck3 == true: # Disables the Ads manager node
		enabled = false

"""
AD REFRESHER LOOP LOGIC
"""
func _on_Timer_timeout(): 
	#Ad refresher loop
	# Checks if the Ads are Initialized everytime Timer times out
	# Stops if Ads are initialized for specific ads
	# Doesn't have a code bloc for Yodo1mas, requires testing for that
	#Also functions as a secondary ads debugger
	
	if mediators.size() != 0 && enabled == true:
		
		# Admob
		if mediators.has(1) && singleton =="GodotAdMob":
			if Admob.get_banner_dimension() == Vector2(0,0):
				print ('Timer Timeout, Trying Again')
				admob()
			if not Admob.get_banner_dimension() == Vector2(0,0) :
				timer.stop()
				print ('Stopping Ad refresher loop', '/Ad Dimensions: ', str(Admob.get_banner_dimension()))
				_are_the_ads_displaying_ = true
		
		# Appodeal
		
	
	if not mediators.size() == 0: # Does a secondary Debug
		ads_debug = str ('Engine has singleton' , '/: ','/GodotAdMob :', DoEngineCheck1, '/GodotAppodeal :', DoEngineCheck2, '/GodotYodo1Mas :',  DoEngineCheck3)
		init()
		print ('Engine might not contain', mediators, 'test with fast debug')
		print ('initializing ', mediators ,' again for the/', _how_many_times, ' /time' )
		


func fast_debug():
	# Fast debug quickly checks if the engine compiles with the sdk
	#and triggers an ad state, so i'm not calling the engine multiple times
	# Make sure it is turned on in the inspector tab
	if Fast_debug == true:
		DoEngineCheck1 = bool (Engine.has_singleton('GodotAdMob')) # Admob
		DoEngineCheck2 = bool (Engine.has_singleton('GodotAppodeal')) # Appodeal
		DoEngineCheck3 = bool (Engine.has_singleton("GodotYodo1Mas")) # Yodo1Mas
		print('GodotAdMob :', DoEngineCheck1)
		print('GodotAppodeal :', DoEngineCheck2)
		print('GodotYodo1Mas :',  DoEngineCheck3)
	elif Fast_debug == false:
		print('Fast debug is turned off in the inspector tab')
		return



