# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
#
# This is a auto-included singleton containing
# information used by the music codes.
# it only works with .ogg sound files
# Features
# (1) Plays Music
# (2) Plays SFX
# (3) Plays single music file
# (4) Uses 4 Music channels
# (5) Downloads music files from Server

# To do:


# *************************************************
# Bugs:
# (1) 
# (2) 
# (3) Music Volume is unimplemented
# (4) 
# (5) 
# (6) Music sfx plays on the wrong Track
# *************************************************
"""
THERE ARE TWO FUNCTIONS FOR PLAYING MUSIC TRACKS AND MUSIC PLAYLISTS
"""
extends Node

class_name music_singleton

signal music_finished
@export var MusicConfig : Resource 

#export (bool) var enable 
#export (bool) var sfx_on
#export (int) var volume # volume controller code is not yet written
#export (int) var play_back_position : int
#export (int) var track_length : int

@onready var current_track : String

@onready var A : AudioStreamPlayer = $A
@onready var B : AudioStreamPlayer = $B
@onready var C : AudioStreamPlayer = $C
@onready var D : AudioStreamPlayer = $D 

@onready var music_bus_2 = AudioServer.get_bus_index(B.bus)
@onready var music_bus = AudioServer.get_bus_index(A.bus)


#var _music
@onready var Music_streamer : AudioStreamPlayer = A #get_node("A")  #Refrences the music player node
@onready var Music_streamer_3 : AudioStreamPlayer = B #get_node("B")  #Refrences the music player node
@onready var  Music_streamer_2  : AudioStreamPlayer= D#get_node("D")
#onready var sfx_streamer 
#onready var track : String 

@onready var music_debug : String = "" 

@onready var transitions : AnimationPlayer = $anims

# Pointers to Node for Memory Mgmt
@onready var my_nodes : Array = [Music_streamer, A,B,C,D,Music_streamer_2,transitions]



# Debug Variables
#var stream : AudioStream
#var stream_length : int
#var Playback_position : int
#var _track : String



@onready var selected_sound_fx : int = get_random_sound_effect()

@onready var safe_Utils = get_node("/root/Utils")

func _ready():
	
	if MusicConfig == null:
		push_error("Music Config resource not assigned!")
		return
	
	
	print_debug("Sound Fx Debug: ",selected_sound_fx)
	
	
	"load on/off music settings"
	#Utils.Functions.load_game(true, Globals)
	
	"Check If Node Paths Are Broken"
	safe_Utils.UI.check_for_broken_links(my_nodes)

# Temporarily disabled for refactroing Jan 19, 26
	#if safe_Utils.Functions.hasSave(File.new()):
		# load all user data individually
		# 
	#	safe_Utils.Functions.load_user_data('music', get_tree())

	print_debug("Music_on_settings :",bool (MusicConfig.enable))
	#	music_on = bool (Music_on_settings)
	
	
	"Music Player Logic"
	if MusicConfig.enable :
		randomize() # randomise the engine's seed generator
		"Default Music"
		# bug:
		# (1) does not shuffle music
		var music_track = shuffle(MusicConfig.default_playlist)
		play(music_track) #Not needed for release
		#play_track(music_track)
		
	if !MusicConfig.enable:
		A.stop()



func _process(_delta):
	
	#_music_debug()
	
	"Music On.Off"
	

	
	"""
	AUTO SHUFFLE
	"""
	# Bugs:
	# (1) Bugs Out In Headless Server Build
	if MusicConfig.enable == false:
		return
	
	if Music_streamer == null:
		return
	
	if Music_streamer_3 == null:
		return
	
	if Music_streamer.stream == null:
		return
	

	# Get The Current Music Streamer And Feed The Data to The inspector Tab
	
	if Music_streamer.is_playing():
		MusicConfig.play_back_position = int(Music_streamer.get_playback_position() )#works
		MusicConfig.track_length = int(Music_streamer.get_stream().get_length() - 1 )
		Music_streamer_3.stop()
		
		if MusicConfig.play_back_position == MusicConfig.track_length:
			print_debug ('autoshuffle debug 1')
			
			#emit_signal("music_finished")
			Music_streamer.emit_signal("finished")
			return

	
	if Music_streamer_3.stream == null:
		return 
		
	if Music_streamer_3.is_playing(): # audio error catcher 1
		MusicConfig.play_back_position = Music_streamer_3.get_playback_position()
		MusicConfig.track_length = Music_streamer_3.get_stream().get_length()
		Music_streamer.stop()
	
	#print_debug(current_track)







func play(_stream: String):
	#print_stack()
	# Features
	# Preloads Randomised Tracks into A and B music streamer and transitions 
	# Between Both Tracks using animation player BtoA and AtoB once each track finishes
	# Randomises The Playlist once A or B finished playing
	# Emits a signal once each track finished playing for all AudioStreamPlayers
	# (1) loads a track
	# (2) Loads B Track
	#it bugs out when the music track node is added to a scene
	# Bugs:
	# (1) Method is called Twice During process funtion and loads 2 different music tracks
	# (2) This method triggers the audio to play at another pitch?
	print_stack()
	print_debug('Stream:', _stream,'Music Track',MusicConfig.music_track,"Current Track: ", current_track)
	if _stream == null: return # guard clauses
	if _stream.is_empty(): return
	if _stream.is_empty() : # debug
		push_error('Music stream is null, fix')
		
	if !MusicConfig.enable : return
	# note: track a is for triggering sfx, track b is for playing audio
	# bugs:
	# (1) bugs out on playing the second track
	if current_track == "a":
		print_debug("Load Track A: ", _stream)
		B.stream = load(_stream) #invalid funtion load, cannot convert arguement from nil to string
		transitions.play("AtoB")
		current_track = "a"
		MusicConfig.enable = true
		#Music_streamer_3.stop() #hacky fix
		return
	
	if current_track == "b" or current_track.is_empty(): # current track is initially empty, then it's set to a
		print_debug("Load Track B: ", current_track, "/", _stream)
		A.stream = load(_stream)
		transitions.play("BtoA")
		current_track = "b" # current track is set to a
		MusicConfig.enable = true
		return
	# settings saving should be done in controls scene
	
	#print_debug('Play Music setting debug: ', enable) #For Debug purposes only


func clear():# triggers an autodelete in music track nodes
	MusicConfig.music_track = ''
	print_debug('Music cleared')
	MusicConfig.enable = false
	#print_debug('Clear Music setting debug: ', self.music_on) #For Debug purposes only
	#return self.music_on


"Simple 'muffled music' effect on pause using a low pass filter"
func _notification(what):
	# Features: 
	#
	# This code bloc calls uses multiple node states to Alter the State of this Music Object
	# It implement a sound effect on Bus B and Lowers Bus A's volume to -100 and increases Bus B volume to Positive 1
	# It The Plays an Animation Changing the Bus's AUdio and uses that to Transition Between Effects
	# Audio Bus Effect Documentation : https://docs.godotengine.org/en/3.6/tutorials/audio/audio_buses.html
	# TO DO : 
	# (1) Map FX To Local Enumeration variable
	# (2) Export Audio Effects To Other Scenes Via Singleton Methods
	
	#print_debug(what) # for debug purposes only
	if what == NOTIFICATION_PAUSED: # Called When App Is Paused And Sets A's Bus first Music Fx the low pass filter
		
		AudioServer.set_bus_effect_enabled(music_bus,selected_sound_fx,true) # B's music Bus
		AudioServer.set_bus_volume_db(music_bus,-3)
		#AudioServer.set_bus_volume_db(music_bus_2,10)

	if what == NOTIFICATION_UNPAUSED:
		
		AudioServer.set_bus_effect_enabled(music_bus,selected_sound_fx,false)
		AudioServer.set_bus_volume_db(music_bus,0)
		#AudioServer.set_bus_volume_db(music_bus_2,-100)

	if what == NOTIFICATION_PREDELETE:
		AudioServer.set_bus_volume_db(music_bus,-100)
		#AudioServer.set_bus_volume_db(music_bus_2,-100)
		

	if what == NOTIFICATION_APPLICATION_PAUSED:
		print_debug("1111111111")
		AudioServer.set_bus_mute(music_bus, true)
		#AudioServer.set_bus_mute(music_bus_2, true)
		
		clear()
	if what == NOTIFICATION_APPLICATION_RESUMED:
		print_debug("22222222")
		# Unmute both music bus's
		AudioServer.set_bus_mute(music_bus, false)
		AudioServer.set_bus_mute(music_bus_2, false)


"""
MUSIC SHUFFLE
"""
# Shuffles A Dictionary, Returns a string
static func shuffle (playlist : Dictionary) -> String:
	
	var track = int(randf_range(-1,playlist.size())) #selects a random track number
	#print_debug("selected Item After Shuffle: ",playlist[track]) # for debugging purposes only
	return playlist[track]

static func shuffle_array(_fx : Array) -> int : # selects a random number of an array
	var sel = int (randf_range(-1,_fx.size()))
	
	return _fx[sel]

# Play the Next Track and Shuffle
func _on_A_finished(): #This  signals when the music has finished and autoshuffles
	randomize() #  reset the random seed in the random number generator
	# shuffle music track
	MusicConfig.music_track = shuffle(MusicConfig.default_playlist)
	get_random_sound_effect()
	print_debug('music finished A /', MusicConfig.music_track, "| sfx: ", selected_sound_fx) #code block works
	transitions.play("AtoB")
	#plays the music trac twuce
	
	play(MusicConfig.music_track)

# Play the Next Track And Shuffle
func _on_B_finished():
	
	
	print_debug('music finished B/', MusicConfig.music_track,"/",selected_sound_fx) 
	transitions.play("BtoA") # B to A Has higher Pitch
	# plays the music track twice

func play_sfx(list : Dictionary): #a separate bus channel for sfx using dictionary playlist
	# 
	if MusicConfig.sfx_on== true:
		var sfx : String = shuffle(list) 
		
		C.stream = load(sfx)
		C.play()
		#print_debug ('playing sfx: ',sfx.get_file()) #works
		await get_tree().create_timer(0.8).timeout
		C.stop()

func play_track(_track : String): 
	#for playing single sample tracks
	#_track is a pointer to the music file path
	if _track != null  and Music_streamer_2 != null :
		D.set_stream ( load (_track)) #Children Scripts should not load the soundtracks
		D.play(0.0)
		print_debug ('playing sfx: ',_track.get_file()) # for debug purposes only
		await get_tree().create_timer(0.8).timeout
		D.stop()


func _exit_tree(): 
	safe_Utils.MemoryManagement.queue_free_array(my_nodes)
	
	# memory management
	#blood_fx.clear()
	#hit_sfx.clear()
	#grass_sfx.clear()
	#ui_sfx.clear()
	#comic_sfx.clear()
	#item_use_sfx.clear()
	#nokia_soundpack.clear()
	#sword_sfx.clear()
	#wind_sfx.clear()

func get_random_sound_effect() -> int :
	
	selected_sound_fx= shuffle_array(MusicConfig.FX.values())
	return selected_sound_fx


func set_sound_effect(fx_ : int, state : bool):
	# Exportable Function To Set Sound Effect From Any Scene
	if MusicConfig.FX.values().has(fx_):
		AudioServer.set_bus_effect_enabled(music_bus,fx_,state)
	else:
		push_error("Selected Sound FX is Beyond The Scope Of Usable SFX")



# Music Finished Playing
func _on_Music_music_finished():
	print_debug("music funished playing B")
	randomize()
	MusicConfig.music_track = shuffle(MusicConfig.default_playlist)
	play(MusicConfig.music_track)
