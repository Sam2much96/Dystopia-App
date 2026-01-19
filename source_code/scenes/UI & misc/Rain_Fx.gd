# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Old Rain FX Emulator using CPU Particles
#
# This is the Rain FX controller script
# information used by the Rain FX scenes .
# 
# Bugs
# (1) Performance Hog. It slows frame ate  considerably/
		# Fix: SHould only turn on when FrameRate is high, else, should shut off (Done)
		# FIx 2: Shouldn't be a child of a canvas  Layer. Double perfomance hofg
# (2) FPS Debug Breaks emiiter
# *************************************************
# 
# Features
#
# (1)  It Emits a Particle 2D and turnis it off and on through a timer.
# (2) Is Optimized for android in Android singleton
#
# How TO USe:
# (1) Use as CHild of CanvasLayer
#
#
#

extends CPUParticles2D

class_name RainFX

@onready var rain_particles : CPUParticles2D = self #$GPUParticles2D
@onready var timer : Timer = $Timer
#export (bool) var enable






func _ready():
	# Make object global for permormance optimizations
	
	Simulation.rainFX = self


# Add other Parameters to Automatically trigger the rain on and off
func _process(_delta):
	pass



# Times out the Rain Fx
func _on_Timer_timeout(): 
 # Turns rain on/ off every 8.3 hours of playtime
	
	if emitting == true:
		timer.wait_time = 500 # For longer dry times
		emitting = false
		#timer.start()
	elif emitting== false:
		emitting = true
		timer.wait_time = 250 # For shorter rain times
