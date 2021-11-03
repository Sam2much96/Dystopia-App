extends CanvasLayer


onready var Admob = $AdMob
onready var _Appodeal = $Appodeal

onready var java_singleton

export (int) var  _timeout_timer = 10
export (String, 'GodotAppodeal', "GodotAdMob") var singleton ='GodotAppodeal' #It can't auto detect during runtimes
export var ads_debug:String
export (bool) var enabled
export (int) var _how_many_times 
export (bool) var _are_the_ads_displaying_ 
export (bool) var Fast_debug


func init() -> bool:
	_how_many_times = _how_many_times+1
	print('Singleton Debug//', str(singleton))
	if(Engine.has_singleton(singleton)) == true && enabled == true:
		print('initializing ',str(singleton), ' plugin', 'checking for / ', singleton, ' singleton' )
		return true
	return false

func _ready():
	
	if enabled == true:
		
		if Engine.has_singleton(singleton)== true:
			if singleton == str ('GodotAdMob'):
				admob()
				java_singleton = Engine.get_singleton(singleton)
				
			if singleton == str('GodotAppodeal'):
				__appodeal()
				java_singleton = Engine.get_singleton(singleton)
				#_facebook() #checks for facebook login
func __appodeal():
	if (Engine.has_singleton(singleton)) == true && enabled == true:
		
		_Appodeal.appodeal.setTestingEnabled(false) 
		_Appodeal.appodeal.setSmartBannersEnabled(true)
		
		
		_Appodeal.appodeal.initialize(_Appodeal.key, 2, true) #initializes and show banner ads
		
		
		
		_how_many_times = _how_many_times + 1
		print ('Is /', singleton,' /Initialized: ', _Appodeal.appodeal.isInitializedForAdType(2)) #checks if ads is initialized

		_Appodeal.appodeal.setLogLevel(1) 
		_Appodeal.appodeal.showAd(4)
		
		#__appodeal_debug()

func __appodeal_debug(): #Debugs the current status of the appodeal ads
	print (' Appodeal debug //')
	print ('Is Appodeal initialized for Banner Ads: ',str(_Appodeal.appodeal.isInitializedForAdType(2))) 
	print ('Can Appodeal Show Banner Bottom Ads: ',str(_Appodeal.appodeal.canShow(4)))
	print ('Can Appodeal Show Banner Top Ads: ',str(_Appodeal.appodeal.canShow(2)))



func admob():
	if (Engine.has_singleton(singleton)) == true && enabled == true:
		Admob.init()
		Admob.connect_signals()
		Admob.load_banner()
		Admob.show_banner()
		print('initializing ', (singleton))
		print ('Debugging ', singleton,' : ', Admob._admob_singleton)
		print ( 'Initialized :', str(Admob.init()))
		#print ( 'Connect Signal :', str(Admob.connect_signals()))
		print ( 'Banner Dimensions :', str(Admob.get_banner_dimension()))
		#print ( 'Show Banner :', str(Admob.show_banner()))
		#if str(Admob.show_banner()) == 'true':
		#	_are_the_ads_displaying_ = true #breaks the admob loop

func _facebook(): #checks if the facebook sdk is initiated
	if Engine.has_singleton("GodotFacebook") == true && Globals.os == str("Android"):
		#The facebook script is present in the scene tree as a singleton
		print ("Facebook Is Initiated, Executing facebook function")
		facebook.set_advertiser_tracking(true)


func _process(delta):
	 #Debugs the Ad state to the Debug Panel
	if enabled == true :
		if Engine.has_singleton(singleton)== true:
			
			Debug.Ads_debug = '//Engine has '+str(singleton) +'//Ads debug//'+str(ads_debug)
			
			var error_code   
			if Admob.emit_signal("banner_failed_to_load", error_code):
				ads_debug += ('//banner failed to load//Error Code:'+ str(error_code))
			if Admob.emit_signal("banner_loaded"):
				ads_debug += ('//banner loaded')
		
			if _are_the_ads_displaying_ == false:
				if singleton == str ('GodotAdMob'):
					#$Timer.autostart() #Timer loop t
						pass

	if not enabled  :
		pass
	if int(_how_many_times) >= 11:
		enabled = false
		_how_many_times = 0 #resets this
		print ('Stopping Ads initialization')

func _exit_tree():
	print ('Ads Tester Exits Tree')
	if not Engine.has_singleton(singleton):
		enabled = false
		#var o = 
		#print (self.EditorInterface.get_editor_settings ( ))
		#EditorSettings.settings.set_setting("enabled",false)


func _on_Timer_timeout(): #Ad refresher loop
	if (Engine.has_singleton(singleton)) == true && enabled == true:
		if singleton == str ('GodotAdMob'):
			if Admob.get_banner_dimension() == Vector2(0,0):
				print ('Timer Timeout, Trying Again')
				admob()
			if not Admob.get_banner_dimension() == Vector2(0,0) :
				$Timer.stop()
				print ('Stopping Ad refresher loop', '/Ad Dimensions: ', str(Admob.get_banner_dimension()))
				_are_the_ads_displaying_ = true
		if singleton == str ('GodotAppodeal'):
			if java_singleton != null:
				if (java_singleton.isInitializedForAdType(2)) == false : #if ad initialization fails
					print ('Is /', singleton,' /Initialized: ', java_singleton.isInitializedForAdType(2), 'trying again for the', _how_many_times, ' time') #checks if ads is initialized
					#java_single
					__appodeal()
				if (java_singleton.isInitializedForAdType(2)) == true : #if ad initialization works
					print ('Is /', singleton,' /Initialized: ', java_singleton.isInitializedForAdType(2)) #checks if ads is initialized
					#$Timer.stop()
					print ('Ad ', singleton,' is initialized')
				if java_singleton.canShow(4) == false && java_singleton.canShow(2) == false: # if Top banner show fails try again,
					print ('Banner top and bottom refused to show, trying again the //', _how_many_times, " time")
					_how_many_times = _how_many_times +1
					__appodeal()
					__appodeal_debug()
				if java_singleton.canShow(4) == true  or  java_singleton.canShow(2) == true: #if banner ads show
						print ('Banners can show, Stopping timeout loop')
						$Timer.stop()
	if not Engine.has_singleton(singleton)== true:
		Debug.Ads_debug = str ('Engine has ', singleton, '/: ',Engine.has_singleton(singleton))
		init()
		print ('Engine does not contain', singleton)
		print ('initializing ', singleton ,' again for the/', _how_many_times, ' /time', ' Did it Work: ', str(init()) )
		if Fast_debug == true:
			print('GodotAdMob:', str(Engine.has_singleton('GodotAdMob')))
			print('GodotAppodeal:', str(Engine.has_singleton('GodotAppodeal')))

			#appodeal.sdk.appodeal.BuildConfig"
