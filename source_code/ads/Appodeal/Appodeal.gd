# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Appodeal
# Broken Initialization function. Requires fixing
# To Do:
#(1) Update to work
# (2) Implement their new sdk version
# *************************************************
# Bugs:
#(1) Yodo1Mas is broken
#(2) Appodeal is Broken
# *************************************************

#tool

extends Node
'''A Implementation Of Appodeals banner add in Godot '''

# The SDK is broken as at Godot 3.4.3.rc. It compiles, but breaks like a bad bitch.
@export var ads_debug:String
@export var enabled : bool

#A parameter for the Ads functions
@export var precached : bool
@export var banner_id:String = 'ca-app-pub-1198869974398081/1991292180'
@export var key:String= "b14288f5b650ec9807ab324195ec819be92c7d4c0b1a65e8"

var appodeal


func _enter_tree(): #Restricts initialization to Android OS 
	if Globals.os != 'Android':
		#enabled = false
		push_warning('Ads Can Only Be Enable on Mobile Devices, not / '+ str(OS.get_name()))
	if Globals.os == 'Android':
		_init()
		print('Initilizing Appodeal Ads on/',str(Globals.os))


func _ready():
	if Engine.has_singleton("GodotAppodeal"):
		appodeal = Engine.get_singleton("GodotAppodeal")
		print ("Engine has Appodeal Ad Module", appodeal, Engine.has_singleton("GodotAppodeal"))



class Appodeal :#, "res://ads/Appodeal/appodeal_logo.png" 

	"""
	INTERSTITIAL
	"""
	# Emit when interstitial is loaded
	signal interstitial_loaded(precached) #bool

	# Emit when interstitial failed to load
	signal interstitial_load_failed()

	# Emit when interstitial is shown
	signal interstitial_shown()

	# Emit when interstitial show failed
	signal interstitial_show_failed()

	# Emit when interstitial is clicked
	signal interstitial_clicked()

	# Emit when interstitial is closed
	signal interstitial_closed()

	# Emit when interstitial is expired
	signal interstitial_expired()

	"""
	BANNER
	"""

	# Emit when banner is loaded
	signal banner_loaded(precached)
	# Emit when banner failed to load
	signal banner_load_failed()
	# Emit when banner is shown
	signal banner_shown()

	# Emit when banner show failed
	signal banner_show_failed()
	# Emit when banner is clicked
	signal banner_clicked()
	# Emit when banner is expired
	signal banner_expired()


	"""
	REWARDED VIDEO
	"""

	# Emit when rewarded video is loaded
	signal rewarded_video_loaded(precache) #precache: bool

	# Emit when rewarded video failed to load
	signal rewarded_video_load_failed()

	# Emit when rewarded video is shown
	signal rewarded_video_shown()
	# Emit when rewarded video show failed
	signal rewarded_video_show_failed()
	# Emit when rewarded video is viewed until the end
	signal rewarded_video_finished(amount, currency) #amount(float), currency(string)

	# Emit when rewarded video is closed
	signal rewarded_video_closed(finished)

	# Emit when rewarded video is expired
	signal rewarded_video_expired()

	# Emit when rewarded video is clicked
	signal rewarded_video_clicked()


	"""
	NON SKIPPABLE VIDEO
	"""

	# Emit when non-skippable video is loaded
	signal non_skippable_video_loaded(precache) #precache: bool

	# Emit when non-skippable video failed to load
	signal non_skippable_video_load_failed()

	# Emit when non-skippable video is shown
	signal non_skippable_video_shown()

	# Emit when non-skippable video show failed
	signal non_skippable_video_show_failed()

	# Emit when non-skippable video is viewed until the end
	signal non_skippable_video_finished()

	# Emit when non-skippable video is closed
	signal non_skippable_video_closed(finished) #finished: bool

	# Emit when non-skippable video is expired
	signal non_skippable_video_expired()



	
	var _how_many_times = 0
	var is_real
	var Ads
	


	
	#var _t #A test variable to connect to Appodeal engine's singletons
	enum AdType {
	INTERSTITIAL = 1,
	BANNER = 2,
	NATIVE = 4,
	REWARDED_VIDEO = 8,
	NON_SKIPPABLE_VIDEO = 16,
	}

	enum ShowStyle {
	INTERSTITIAL = 1,
	BANNER_TOP = 2,
	BANNER_BOTTOM = 4,
	REWARDED_VIDEO = 8,
	NON_SKIPPABLE_VIDEO = 16,
	}

	#export (String, '320x50', '728x90', 'SMARTBANNER' ) var banner_size 

	#@export var banner_size : PackedStringArray = ['320x50','728x90', 'SMARTBANNER']

	@export_enum('320x50','728x90', 'SMARTBANNER') var banner_size : String = "320x50"


	#class_name Appodeal 


	"""
	APPODEAL INITIALIZATION BREAKS. none EXISTENT SINGLETON
	"""

	static func _init(enabled : bool, key : String, appodeal):
		# Initialization here
		# 
		# 
		# #Error catcher
			if(Engine.has_singleton("GodotAppodeal")) && enabled == true:
				key = "b14288f5b650ec9807ab324195ec819be92c7d4c0b1a65e8"
				appodeal = Engine.get_singleton("GodotAppodeal") ###None Existent SIngleton.
				appodeal.initialize( key, 2, false)
				appodeal.setTestingEnabled(true)
				appodeal.showAd(4)
				Debug.Ads_debug += ('Showing Ads: '+str(appodeal.showAd(4)))
			
		



	static func initialize(app_key: String, ad_types: int, consent: bool) -> void:
		return


	# Display ad
	static func showAd(show_style: int, appodeal) -> bool:
		return (appodeal)
	# Checking initialization for ad type
	static func isInitializedForAdType(ad_type: int, appodeal) -> bool:
		return (appodeal)
	# Display ad for specified placement
	static func showAdForPlacement(show_style: int, placement: String, appodeal) -> bool: 
		return  (appodeal)

	# Check ability to display ad
	static func canShow(show_style: int, appodeal) -> bool :
		return  (appodeal)

	# Check ability to display ad for specified placement
	static func canShowForPlacement(ad_type: int, placement: String, appodeal) -> bool :
		return  (appodeal)
	# Hide banner
	func hideBanner():
		return


	"""
	ANDROID ONLY
	"""
	# Request Android M permissions
	func requestAndroidMPermissions() -> void : #For Android only
		return

	"""
	CONFIGURE SDK
	"""
	# Enable/Disable testing
	func setTestingEnabled(enabled: bool) -> void:
		return

	# Enable/Disable smart banners
	func setSmartBannersEnabled(enabled: bool) -> void:
		return

	# Enable/Disable banner animation
	func setBannerAnimationEnabled(enabled: bool) -> void:
		return

	"""
	CACHING
	"""

	# Enable/Disable autocache
	static func setAutocache(enabled: bool, ad_type: int) -> void:
		return

	# Check autocache enabled
	static func isAutocacheEnabled(ad_type: int, appodeal) -> bool:
		return (appodeal)

	# Check cache
	static func isPrecacheAd(ad_type: int, appodeal) -> bool:
		return (appodeal)
 
	# Cache
	func cacheAd(ad_type: int) -> void:
		return

	# Set logging
	func setLogLevel(log_level: int) -> void:
		return


	# Disable specified networks
	func disableNetworks(networks: Array) -> void:
		return

	# Disable specified networks for ad type
	func disableNetworksForAdType(networks: Array, ad_type: int) -> void:
		return

	# Disable specified network
	func disableNetwork(network: String) -> void:
		return

	# Disable specified network for ad type
	func disableNetworkForAdType(network: String, ad_type: int) -> void:
		return

	# Disable location tracking (use before initialization).
	# setLocationTracking(true) don't have effect on Android.
	func setLocationTracking(enabled: bool) -> void:
		return

	# Disable data collection for kids apps
	func setChildDirectedTreatment(for_kids: bool) -> void:
		return

	# Change GDPR consent status
	func updateConsent(consent: bool) -> void:
		return

	# Disable write external storage permission check (Android-only)
	func disableWriteExternalStoragePermissionCheck() -> void:
		return

	# Mute videos if call volume is muted (Android-only)
	func muteVideosIfCallsMuted(mute: bool) -> void:
		return

	# Send extra data
	func setExtras(data: Dictionary) -> void:
		return

	# Set segment filter
	func setSegmentFilter(filter: Dictionary) -> void:
		return

	# Enable/Disable 728x90 banners
	# Enable if 1, otherwise disable
	func setPreferredBannerAdSize(size: int) -> void:
		return


	"""
	USER SETTINGS
	"""
	# Set user ID for S2S callbacks
	func setUserId(user_id: String) -> void:
		return

	# Set user age
	func setUserAge(age: int) -> void:
		return

	# Set user gender
	func setUserGender(gender: int) -> void:
		return

	"""
	OTHERS
	"""

	# Get predicted eCPM for ad type
	static func getPredictedEcpmForAdType(ad_type: int, appodeal) -> float:
		return (appodeal)

	# Get Reward info for placement
	static func getRewardForPlacement(placement: String, appodeal) -> Dictionary:
		return (appodeal)

	# Track in-app purchases
	func trackInAppPurchase(amount: float, currency: String) -> void:
		return 


