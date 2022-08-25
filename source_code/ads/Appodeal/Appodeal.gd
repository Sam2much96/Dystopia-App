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

tool

extends Node
'''A Implementation Of Appodeals banner add in Godot '''

# The SDK is broken as at Godot 3.4.3.rc. It compiles, but breaks like a bad bitch.
export var ads_debug:String

class_name Appodeal , "res://ads/Appodeal/appodeal_logo.png"

#A parameter for the Ads functions
export (bool) var precached

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



export (bool) var enabled
var _how_many_times = 0
var is_real
var Ads
export var banner_id:String = 'ca-app-pub-1198869974398081/1991292180'
var appodeal

export var key:String= "b14288f5b650ec9807ab324195ec819be92c7d4c0b1a65e8"
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

export (String, '320x50', '728x90', 'SMARTBANNER' ) var banner_size 





#class_name Appodeal 

func _enter_tree(): #Restricts initialization to Android OS 
	if str(OS.get_name()) != str('Android'):
		enabled = false
		push_warning('Ads Can Only Be Enable on Mobile Devices, not / '+ str(OS.get_name()))
	if str(OS.get_name()) == str('Android'):
		_init()
		print('Initilizing Appodeal Ads on/',str(Globals.os))

"""
APPODEAL INITIALIZATION BREAKS. none EXISTENT SINGLETON
"""

func _init():
	# Initialization here
	# The entire initilization is broken
	# It doesn't detect the singleton
	#if str(OS.get_name()) == str ("Android"): #Error catcher
	#	if(Engine.has_singleton("GodotAppodeal")) && enabled == true:
	#		key = "b14288f5b650ec9807ab324195ec819be92c7d4c0b1a65e8"
	#	appodeal = Engine.get_singleton("GodotAppodeal") ###None Existent SIngleton.
	#	appodeal.initialize( key, 2, false)
#
#		appodeal.showAd(4)
		#Debug.Ads_debug += ('Showing Ads: '+str(appodeal.showAd(4)))
	pass

func initialize(app_key: String, ad_types: int, consent: bool) -> void:
	return


# Display ad
func showAd(show_style: int) -> bool:
	return (appodeal)
# Checking initialization for ad type
func isInitializedForAdType(ad_type: int) -> bool:
	return (appodeal)
# Display ad for specified placement
func showAdForPlacement(show_style: int, placement: String) -> bool: 
	return  (appodeal)

# Check ability to display ad
func canShow(show_style: int) -> bool :
	return  (appodeal)

# Check ability to display ad for specified placement
func canShowForPlacement(ad_type: int, placement: String) -> bool :
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
func setAutocache(enabled: bool, ad_type: int) -> void:
	return

# Check autocache enabled
func isAutocacheEnabled(ad_type: int) -> bool:
	return (appodeal)

# Check cache
func isPrecacheAd(ad_type: int) -> bool:
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
func getPredictedEcpmForAdType(ad_type: int) -> float:
	return (appodeal)

# Get Reward info for placement
func getRewardForPlacement(placement: String) -> Dictionary:
	return (appodeal)

# Track in-app purchases
func trackInAppPurchase(amount: float, currency: String) -> void:
	return 


