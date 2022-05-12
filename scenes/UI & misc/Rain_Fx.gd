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
# *************************************************
#It Emits a Particle 2D and turnis it off and on through a timer.


extends CanvasLayer

onready var rain_particles = $Particles2D
onready var timer = $Timer
export (bool) var enable

export (float) var time #in secs



# Add other Parameters to Automatically trigger the rain on and off
func _process(_delta):
	
	
	# Programmatically controls the Rain FX 
	# Using the time node. set to 500 for 8.3 mins
	
	
	if enable == true:
		rain_particles.emitting = true
		#print ('Emitting Rain Particles') -introducees a bug
		
	if enable == false:
		rain_particles.emitting = false
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
