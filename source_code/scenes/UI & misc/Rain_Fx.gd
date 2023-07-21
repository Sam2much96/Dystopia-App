# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is the Rain FX controller script
# information used by the Rain FX scenes .
# 
# Bugs
# (1) Performance Hog. It slows frame ate  considerably/
		# Fix: SHould only turn on when FrameRate is high, else, should shut off (Done)
# *************************************************
#It Emits a Particle 2D and turnis it off and on through a timer.


extends CanvasLayer

class_name RainFX

onready var rain_particles = $Particles2D
onready var timer = $Timer
export (bool) var enable

export (float) var time #in secs

const MINUMUM_FPS : int = 10

# Lifetime OPtimizations for Particle FX
const Mobile_lifetime : int = 6
const Default_lifetime : int = 3


func _ready():
	
	"Performance Optimizations"
	
	if Globals.os == "Android":
		rain_particles.lifetime = Mobile_lifetime
	elif not Globals.os == "Android":
		rain_particles.lifetime = Default_lifetime


# Add other Parameters to Automatically trigger the rain on and off
func _process(_delta):
	
	# Programmatically controls the Rain FX using the GLobal Game Framerate to OPtimize for perfomance
	# Using the time node. set to 500 for 8.3 mins
	
	
	if enable == true && int (Debug.FPS_debug()) >= MINUMUM_FPS:
		rain_particles.emitting = true
		#print ('Emitting Rain Particles') #-introducees a bug
		
	if enable == false:
		rain_particles.emitting = false
	
	"Performance Saver"
	
	if  enable == true && int (Debug.FPS_debug()) < MINUMUM_FPS:
		rain_particles.emitting = false

#	if  enable == true && int (Debug.FPS_debug()) >= 30:
#		rain_particles.emitting = true
	
	
	else:
		pass




func _on_Timer_timeout(): 
 # Turns rain on/ off every 8.3 hours of playtime
	if enable == true:
		timer.wait_time = 500 # For longer dry times
		enable = false
		#timer.start()
	elif enable == false:
		enable = true
		timer.wait_time = 250 # For shorter rain times
