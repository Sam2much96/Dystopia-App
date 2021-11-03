tool
#extends Node
extends Node
'''A Implementation Of Appodeals banner add in Godot '''


export var ads_debug:String

class_name Appodeal , "res://Appodeal/appodeal_logo.png"

#A parameter for the Ads functions
export (bool) var precached

# Emit when interstitial is loaded
signal interstitial_loaded(precached)
# Emit when banner is loaded
signal banner_loaded(precached)
# Emit when banner failed to load
signal banner_load_failed()
# Emit when banner is shown
signal banner_shown()
# Emit when banner is clicked
signal banner_clicked()
# Emit when banner is expired
signal banner_expired()



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
	if Globals.os != str('Android'):
		enabled = false
		push_warning('Ads Can Only Be Enable on Mobile Devices, not / '+ str(Globals.os))
	if OS.get_name() == str('Android'):
		_init()
		print('Initilizing Appodeal Ads on/',str(Globals.os))

func _init():
	# Initialization here
	if str(OS.get_name()) == str ("Android"): #Error catcher
#		if(Engine.has_singleton("GodotAppodeal")) && enabled == true:
#			key = "b14288f5b650ec9807ab324195ec819be92c7d4c0b1a65e8"
		appodeal = Engine.get_singleton("GodotAppodeal")
#			appodeal.initialize( key, 2, false)

#			appodeal.showAd(4)
			#Debug.Ads_debug += ('Showing Ads: '+str(appodeal.showAd(4)))

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

# Request Android M permissions
func requestAndroidMPermissions() -> void : #For Android only
	return

# Enable/Disable testing
func setTestingEnabled(enabled: bool) -> void:
	return

# Enable/Disable smart banners
func setSmartBannersEnabled(enabled: bool) -> void:
	return

# Enable/Disable banner animation
func setBannerAnimationEnabled(enabled: bool) -> void:
	return

# Enable/Disable autocache
func setAutocache(enabled: bool, ad_type: int) -> void:
	return

# Check autocache enabled
func isAutocacheEnabled(ad_type: int) -> bool:
	return (appodeal)

# Set logging
func setLogLevel(log_level: int) -> void:
	return
