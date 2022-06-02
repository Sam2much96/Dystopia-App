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
# (3) Changwes the Ad type Programmatically
#To DO
# OS specific implementation calls to determine os differences
# DIfferent AD states to expand codes
# Unified debug for ell ad mediators
# Make Ads less invasive
# Bugs
# (2) Yodo1Mas implementation code might be broken (testing)
# (3) Compilong Appodeal SDK with yodo1mas creates a bug on the java side of the codes
# (4) 


"""
THIS CODE STARTED OUT AS A DEBUGGER FOR THE AD'S . IT IS EVOLVING TO AN AD MANAGER SYSTEM
"""
# Debug change_mediators function, especially the dictionary implementation

var Ads_debug
onready var Admob = $AdMob
onready var _Appodeal = $Appodeal
onready var _yodo1mas = $Yodo1Mas
onready var timer = $Timer


onready var java_singleton

export (int) var  _timeout_timer = 10
var mediators = {0:'GodotAppodeal',1: "GodotAdMob",2:"GodotYodo1Mas"}
export (String, 'GodotAppodeal', "GodotAdMob", "GodotYodo1Mas") var singleton #It can't auto detect during runtimes
export (String, 'banner_ad', "video_ad", 'interstitial') var _ad_type #='GodotAppodeal' #It can't auto detect during runtimes
export var ads_debug:String
export (bool) var enabled
export (bool) var testing = true
export (int) var _how_many_times 
export (bool) var _are_the_ads_displaying_ 
export (bool) var Fast_debug

onready var _Debug = get_tree().get_root().get_node("/root/Debug")

"CHECKS FOR THE SINGLETON VARIABLES SO I'M NOT MAKING FREQUENT CALLS TO THE ENGINE"
var DoEngineCheck1 #Admob
var DoEngineCheck2 # Appodeal
var DoEngineCheck3 # Yodo1Mas

export (bool) var _Has_singleton_compiled # Stores engine data if the ad singleton is compiled

func _enter_tree():
	fast_debug() # for debug purposes only

func init() -> bool:
	
	# A counting integer for an init loop
	_how_many_times = _how_many_times+1
	#print('Singleton Debug//', str(singleton)) #duplicate of fast_debug()
	if _Has_singleton_compiled  == true && enabled == true:
		print('initializing ',mediators, ' plugin', 'checking for / ', mediators, ' singleton' )
		return true
	return false

func _ready():
	_connect_ads_signals()
	
	
	if enabled == true:
		"# Checks the available ad mediators and modifies a mediator dictionary from the result"
		check_ads_mediators() 
		
		"""
		ERROR CHECKER 1
		"""
		if Engine.has_singleton(singleton)== true:
			if singleton == str ('GodotAdMob'):
				admob()
				java_singleton = Engine.get_singleton(singleton)
				enabled = false # Deactivates the ads manager to avoid a stack overflow
				
				
			if singleton == str('GodotAppodeal'):
				# initializes the appodeal ads for either smart banner or video
				__appodeal(_ad_type, testing)
				java_singleton = Engine.get_singleton(singleton)
				enabled = false # Deactivates the ads manager to avoid a stack overflow
				
				_are_the_ads_displaying_ = true
				#_facebook() #checks for facebook login
			if singleton == str ("GodotYodo1Mas"):
				 
				java_singleton = Engine.get_singleton(singleton)
				yodo1mas()
				
				enabled = false # Deactivates the ads manager to avoid a stack overflow


"""
APPODEAL AD LOADING FUNCTION
"""
####################################### the dependencies for this code are broken          #########################################
#################################### THe initialize is also broken. Disabling this for now #########################################
func __appodeal(_ad_type, testing):
	if (Engine.has_singleton(singleton)) == true && enabled == true:
		
		if _ad_type == 'banner' && testing != null or '':
			# Initializes banner Ads
			_Appodeal.appodeal.setTestingEnabled(testing) 
			_Appodeal.appodeal.setSmartBannersEnabled(true)
			_Appodeal.appodeal.initialize(_Appodeal.key, 2, true) #initializes and show banner ads

			_how_many_times = _how_many_times + 1
			print ('Is /', singleton,' /Initialized: ', _Appodeal.appodeal.isInitializedForAdType(2)) #checks if ads is initialized

			_Appodeal.appodeal.setLogLevel(1) 
			_Appodeal.appodeal.showAd(4)
		
		if _ad_type == 'video' && testing != null or '':
			_Appodeal.appodeal.setTestingEnabled(testing)
			_Appodeal.appodeal.initialize(_Appodeal.key,16,  true) 
			
			_how_many_times = _how_many_times + 1
			print ('Is /', singleton,' /Initialized: ', _Appodeal.appodeal.isInitializedForAdType(16)) #checks if ads is initialized for unskippable video

			
			_Appodeal.appodeal.showAd(16) 
			
		__appodeal_debug() # For debug purposes only, disable on release build

func __appodeal_debug(): 
#Debugs the current status of the appodeal ads
	print (' Appodeal debug //')
	print ('Is Appodeal initialized for Banner Ads: ',str(_Appodeal.appodeal.isInitializedForAdType(2))) 
	print ('Is Appodeal initialized for Video Ads: ',str(_Appodeal.appodeal.isInitializedForAdType(16))) 
	print ('Can Appodeal Show Banner Bottom Ads: ',str(_Appodeal.appodeal.canShow(4)))
	print ('Can Appodeal Show Video Ads: ',str(_Appodeal.appodeal.canShow(16)))
	print ('Can Appodeal Show Banner Top Ads: ',str(_Appodeal.appodeal.canShow(2)))



# Loads admob banner
func admob() ->  void :
	if (Engine.has_singleton(singleton)) == true && enabled == true:
		Admob.init()
		Admob.connect_signals()
		print('initializing ', (singleton),' Debugging ', singleton,' : ', Admob._admob_singleton, _ad_type)
		if _ad_type == 'banner_ad':
			Admob.load_banner()
			Admob.show_banner()
			_are_the_ads_displaying_ = true
			print ( 'Banner Dimensions :', str(Admob.get_banner_dimension()))
		if _ad_type == 'interstitial':
			Admob.load_interstitial()
			Admob.show_interstitial()
			_are_the_ads_displaying_ = true
			print ('Is interstitial initialised: ', str(Admob.is_interstitial_loaded()))
		if _ad_type == "video_ad": # I have no rewards to give the users
			Admob.load_rewarded_video()
			Admob.show_rewarded_video()
			_are_the_ads_displaying_ = true
			print ('Is rewarded video loaded: ', str(Admob.is_rewarded_video_loaded()))
		
		
		# Error Handlers
		if Admob.is_rewarded_video_loaded() == false: # if rewarded video fails to load
			# resets ad type to banner ad
			_ad_type = 'banner_ad'
			#return _ad_type
		print ( 'Is',(singleton), 'Initialized ' , str(Admob.init())) # Checks if the singleton initializes
		#print ( 'Connect Signal :', str(Admob.connect_signals()))
		
		#print ( 'Show Banner :', str(Admob.show_banner()))
		#if str(Admob.show_banner()) == 'true':
		#	_are_the_ads_displaying_ = true #breaks the admob loop



	if not bool(Engine.has_singleton(singleton)) == true && enabled == true: # AUTOMATICALLY FAST DEBUS IF THE ENGINE SINGLETON ISN'T THERE
		fast_debug()

" Breaking the code here. To Debug Later"
func yodo1mas()-> bool:
	if DoEngineCheck3 == true && enabled == true:
		#var _y =Engine.get_singleton("GodotYodo1Mas")
		if _ad_type == str ('banner_ad'):
			_yodo1mas.show_banner_ad()
			
		if _ad_type == str ( "video_ad"):
			_yodo1mas.show_rewarded_ad()
			_are_the_ads_displaying_ = true
		if _ad_type == str (  'interstitial'):
			_yodo1mas.show_interstitial_ad() 
			_are_the_ads_displaying_ = true
	if not Engine.has_singleton("GodotYodo1Mas"):
		_Debug.Ads_debug = str ('Singleton', singleton, 'is not present in the testing device') 
	if Engine.has_singleton("GodotYodo1Mas") && enabled == false:
		print ('Ads manager is not enabled')
		
		
		return true # Retuns a boolean if the ads is implemented or not
	return false # code not yet written. Broken for now



# delete this>>>>>>
func _facebook() -> void: #checks if the facebook sdk is initiated
	pass



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
	
		print ("Selected Mediator: ", str(mediators[_no]))
		singleton = mediators[_no]
	if mediators.size() == 1: #Use only 1 dictionary value if the app has only 1 mediator
		print ("//Mediator Installed://",mediators.values())
		singleton = (mediators.values())
	
	return singleton
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

func _connect_ads_signals():
	"connects Ads signals" #Changes the ads mediator if the ads fail to load
	#Yodo1Mas
	if _yodo1mas.connect('banner_ad_not_loaded', self, "change_ads_mediators") != OK:
		return _yodo1mas.connect('banner_ad_not_loaded', self, "change_ads_mediators")
		return _yodo1mas.connect("interstitial_ad_not_loaded", self, "change_ads_mediators")
		return _yodo1mas.connect("rewarded_ad_not_loaded", self, "change_ads_mediators")

	#Appodeal
	if _Appodeal.connect("banner_load_failed", self, "change_ads_mediators") != OK:
		return _Appodeal.connect("banner_load_failed", self, "change_ads_mediators")
		return _Appodeal.connect("interstitial_load_failed", self, "change_ads_mediators")
		return _Appodeal.connect("rewarded_video_load_failed", self, "change_ads_mediators")
	
	#Admob
	if Admob.connect("banner_failed_to_load", self, "change_ads_mediators") != OK:
		return Admob.connect("banner_failed_to_load", self, "change_ads_mediators")
		return Admob.connect("interstitial_failed_to_load", self, "change_ads_mediators")
		return Admob.connect("rewarded_video_failed_to_load", self, "change_ads_mediators")

func _process(_delta):
	# Logic for Checking Ad singletons from fast_debug()
	if DoEngineCheck1 or DoEngineCheck2 or DoEngineCheck3 == true : # if any of the singletons are available
		 _Has_singleton_compiled = true 
	
	
	 #Debugs the Ad state to the Debug Panel
	if enabled == true :
		if _Has_singleton_compiled == false:
			if _Debug != null:
				_Debug.Ads_debug = '//Engine does not have singleton' +'//Automatically changing Ads mediator server//'
				
				#Don't change ads mediator in process function
				#change_ads_mediator() #Automatically changes ad mediator #fix dictionary parsing bug #temporarily disabling until i'm able to properly debug
				
		if _Has_singleton_compiled == true : #engine has singleton funtion breaks
			#if _Debug != null: #
			_Debug.Ads_debug = '//Engine has singleton'+ '//Ads debug//'+str(ads_debug) + "//Are the Ads showning" + (_are_the_ads_displaying_)
			
			"""
			CHECKS IF THE AD MEDIATORS EMITS A /failed to load/ SIGNAL
			"""
			"Admob"
			var error_code   
			if Admob.emit_signal("banner_failed_to_load", error_code):
				ads_debug += ('//banner failed to load/'+' Singleton: '+"Admob"+'/Error Code:'+ str(error_code))
			if Admob.emit_signal("banner_loaded"):
				ads_debug += ('//banner loaded')
			"Appodeal"
			#if _Appodeal.showAdForPlacement() == false: # Add more parameters
			#	ads_debug += ('//Ads failed to load/'+' Singleton: '+str(singleton))
			
			"Yodo1Mas"
			
			if _yodo1mas.emit_signal("banner_ad_not_loaded"):
				ads_debug += ('//Banner Ads failed to load/')
				_are_the_ads_displaying_ = false
			if _yodo1mas.emit_signal("interstitial_ad_not_loaded"):
				ads_debug += ('//Interstitial Ads failed to load/')
				_are_the_ads_displaying_ = true
			if _yodo1mas.emit_signal("rewarded_ad_not_loaded"):
				ads_debug += ('//Rewarded Ads failed to load/')
				_are_the_ads_displaying_ = true
			"""
			# Supposed to programmatically change the ad server once an ad mediator fails
			"""
			if _are_the_ads_displaying_ == false: 
				if mediators == str ('GodotAdMob'): # Account for the 3 ad mediators ads failing to load
					_Debug.Ads_debug  += str('ads fail to display')
					#change_ads_mediator() #temporarily disabling until i'm able to properly debug
				if mediators == str ('GodotAppodeal'):
					_Debug.Ads_debug  += str('ads fail to display')
					#change_ads_mediator() #temporarily disabling until i'm able to properly debug
				if mediators == str ("GodotYodo1Mas"):
					_Debug.Ads_debug  += str('ads fail to display')
					#change_ads_mediator() #temporarily disabling until i'm able to properly debug

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
	
	if not bool(Engine.has_singleton(singleton)) == true:
		enabled = false

"""
AD REFRESHER LOOP LOGIC
"""
func _on_Timer_timeout(): 
	#Ad refresher loop
	
	
	if _Has_singleton_compiled == true && enabled == true:
		
		# Admob
		if mediators == str ('GodotAdMob'):
			if Admob.get_banner_dimension() == Vector2(0,0):
				print ('Timer Timeout, Trying Again')
				admob()
			if not Admob.get_banner_dimension() == Vector2(0,0) :
				timer.stop()
				print ('Stopping Ad refresher loop', '/Ad Dimensions: ', str(Admob.get_banner_dimension()))
				_are_the_ads_displaying_ = true
		
		# Appodeal
		if mediators == str ('GodotAppodeal'):
			if java_singleton != null:
				if (java_singleton.isInitializedForAdType(2)) == false : #if banner ad initialization fails
					print ('Is /', singleton,' /Initialized: ', java_singleton.isInitializedForAdType(2), 'trying again for the', _how_many_times, ' time') #checks if ads is initialized
					__appodeal(_ad_type, testing)
				if (java_singleton.isInitializedForAdType(2)) == true : #if banner ad initialization works
					print ('Is /', singleton,' /Initialized: ', java_singleton.isInitializedForAdType(2)) #checks if ads is initialized
					print ('Ad ', singleton,' is initialized')
				if java_singleton.canShow(4) == false && java_singleton.canShow(2) == false: # if Top banner show fails try again,
					print ('Banner top and bottom refused to show, trying again the //', _how_many_times, " time")
					_how_many_times = _how_many_times +1
					__appodeal(_ad_type, testing)
					__appodeal_debug()
				if java_singleton.canShow(4) == true  or  java_singleton.canShow(2) == true: #if banner ads show
						print ('Banners can show, Stopping timeout loop')
						timer.stop()
				if java_singleton.canShow(16) == false: #if rewarded video fails to show
					print ('Rewarded video failed to show')
					_how_many_times = _how_many_times +1
					__appodeal(_ad_type, testing)
	
	"""#####################################################################################
	CHECKS IF THE ENGINE HAS THE ENGINE SINGLETON AND RUNS A LOOP TO INITIALIZE IT
	"""
	
	if not _Has_singleton_compiled== true: # If the engine does not have the singleton
		Ads_debug = str ('Engine has singleton' , '/: ',_Has_singleton_compiled, '/GodotAdMob :', DoEngineCheck1, '/GodotAppodeal :', DoEngineCheck2, '/GodotYodo1Mas :',  DoEngineCheck3)
		init()
		print ('Engine might not contain', mediators, 'test with fast debug')
		print ('initializing ', mediators ,' again for the/', _how_many_times, ' /time', ' Did it Work: ', str(init()) )
		return null


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
		push_warning('Fast debug is turned off in the inspector tab')
		return
			#appodeal.sdk.appodeal.BuildConfig"


"""
CONNECT SIGNALS FROM YODO1mAS
"""
