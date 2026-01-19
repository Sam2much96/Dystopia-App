# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Blood SPlat FX
# Blood Particles Within the Scene Tree
# Features:
#(1) Uses CPU particles as opposed to particle 2d
# (2) Uuses an inbuilt script because it's instanced alot
# *************************************************
# To Do:
# (1 ) Play sound file through the music singleton
# Bugs
# (1) Contains a sound file, all sounds should be handled by the Music singleton.
# (2) Probably causes a performance hog by allowing high level access to a process of low priority on the scenetree 
# *************************************************

extends CPUParticles2D

class_name BloodSplatter #, 'res://resources/FX/Blood splatter fx.webp'
@onready var blood_splatter_sfx : String = Music.blood_fx[0]

# Get Music Singleton
@onready var music_singleton_ : music_singleton = get_node("/root/Music")
func _ready():
	emitting = true
	await music_singleton_.play_track(blood_splatter_sfx) # Calls the music singleton to play this track

	#print ('Update to play sfx from Music singleton') # FOr debug purposes only
	


func _on_Timer_timeout():
	queue_free() # Deletes itself from the scene tree
