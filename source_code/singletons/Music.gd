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
# (1) Use state machine to descibe different states for this signleton
# (2) Turn on/ off debugging reduce draining performance
# (3) Separate Off sfx and off music
# (4) Document code
# (5) Organize code into states {Finite State Machine}
# (6) Implement Global file checker and Directory Checker
# (7) Implement Spotify API (Depreciated)

# *************************************************
# Bugs:
# (1) Music debug function breaks
# (2) Debug Function breaks
# (3) Music Volume is unimplemented
# (4) Music Downloads is buggy for large (20mb) files (fixed : Public AWS s3 Bucket)
# (5) Music Unzip takes too long (Hours) to unzip, take s up half the FPS in core game loop
# (6) Music sfx plays on the wrong Track
# *************************************************
"""
THERE ARE TWO FUNCTIONS FOR PLAYING MUSIC TRACKS AND MUSIC PLAYLISTS
"""
extends Node

class_name music_singleton
#add more controls to this script, it breaks the singleton
@export var music_on : bool
@export var sfx_on : bool
@export var volume : int # volume controller code is not yet written


# Music COntrol Settings
#var Music_on_settings : int = 0

@export var music_track : String = "" # (String, FILE, "*.ogg")

var default_playlist : Dictionary ={
	0:"res://music/310-world-map-loop.ogg",
	1:"res://music/Astrolife chike san.ogg",
	2:"res://music/chike san afro 1.ogg",
	3:"res://music/chike san afro 2.ogg",
	4:"res://music/chike san afro 3.ogg",
	5: "res://music/Inhumanity Game Track 3.ogg",
	6:"res://music/Spooky-Chike-san song.ogg",
	7:"res://music/Gregorian-Chant(chosic.com).ogg",
	8:"res://music/zelda2.ogg",
	9: "res://music/Track 1-1.ogg"
}

# Files Hosted on AWS S3 Bucket
# file checker should loop through playlist
var local_playlist_one : Dictionary = {
	0:'res://music/310-world-map-loop.ogg', 
	1:'user://Music/Dystopia-App/source_code/music/chike san afro 1.ogg',
	2:'user://Music/Dystopia-App/source_code/music/chike san afro 2.ogg',
	3:'user://Music/Dystopia-App/source_code/music/chike san afro 3.ogg',
	4:'user://Music/Dystopia-App/source_code/music/Astrolife chike san.ogg',
	5:'user://Music/Dystopia-App/source_code/music/a-2-3-groovy-bgm.ogg',
	6:'user://Music/Dystopia-App/source_code/music/Spooky-Chike-san song.ogg',
	7:'user://Music/Dystopia-App/source_code/music/6Feet.ogg',
	8:'user://Music/Dystopia-App/source_code/music/Blow.ogg',
	9:'user://Music/Dystopia-App/source_code/music/HENSONN_SAHARA.ogg',
	10:'user://Music/Dystopia-App/source_code/music/Moya.ogg',
	11:'user://Music/Dystopia-App/source_code/music/Turn up.ogg',
	12:'user://Music/Dystopia-App/source_code/music/310-world-map-loop.ogg',
}
var comic_sfx : Dictionary = {
	0: 'res://sounds/book_flip.1.ogg',
	1:'res://sounds/book_flip.10.ogg',
	2:'res://sounds/book_flip.2.ogg',
	3:'res://sounds/book_flip.3.ogg',
	4:'res://sounds/book_flip.4.ogg',
	5:'res://sounds/book_flip.5.ogg',
	6:'res://sounds/book_flip.6.ogg',
	7:'res://sounds/book_flip.7.ogg',
	8:'res://sounds/book_flip.8.ogg',
	9:'res://sounds/book_flip.9.ogg'
}

var ui_sfx : Dictionary = {
	0:'res://sounds/Menu1A.ogg',
	1:'res://sounds/Menu1B.ogg',
}

var blood_fx : Dictionary = {
	0 :"res://sounds/blood-spilling.ogg" 
	
}

var hit_sfx : Dictionary = {
	0:'res://sounds/hit01.ogg',
	1:'res://sounds/hit02.ogg',
	2:'res://sounds/hit03.ogg',
	3:'res://sounds/hit04.ogg',
	4:'res://sounds/hit05.ogg',
	5:'res://sounds/hit06.ogg',
	6:'res://sounds/hit07.ogg',
	7:'res://sounds/hit08.ogg',

}

var grass_sfx : Dictionary  = {0:'res://sounds/Fantozzi-SandR3.ogg'}

var wind_sfx : Dictionary = {0:'res://sounds/wind_2.ogg'}

var nokia_soundpack : Dictionary = {
	0: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/bad_melody.ogg",
	1: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip1.ogg",
	2: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip2.ogg",
	3: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip3.ogg",
	4: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip4.ogg",
	5: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip5.ogg",
	6: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip6.ogg",
	7: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip7.ogg",
	8: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip8.ogg",
	9: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip9.ogg",
	10: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip10.ogg",
	11: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip11.ogg",
	12: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip12.ogg",
	13: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip13.ogg",
	14: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/blip14.ogg",
	15: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/C5.ogg",
	16: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/crust.ogg",
	17: "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/good1.ogg",
	18 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/good2.ogg",
	19 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/good3.ogg",
	20 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit1.ogg",
	21 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit2.ogg",
	22 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit3.ogg",
	23 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit4.ogg",
	24 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit5.ogg",
	25 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/hit6.ogg",
	26 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/jingle1.ogg",
	27 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/negative1.ogg",
	28 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/negative2.ogg",
	29 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/odd1.ogg",
	30 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/odd2.ogg",
	31 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/odd3.ogg",
	32 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/odd4.ogg",
	33 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/ring1.ogg",
	34 : "res://sounds/nokai_3310_soundpack_2023/nokia_soundpack_@trix/soundtest.ogg",
}


#create all your music actions here as animated nodes
"""
I put in an automatic music shuffling script in here. Feel free to update it 
and map the buttons to the game's UI when finished
"""



"""
Music singleton that handles crossfading when a new song starts
and applies a low pass filter when the game is paused. Nothing too wise
"""
var music_debug =''
@onready var current_track

@onready var A : AudioStreamPlayer = $A
@onready var B : AudioStreamPlayer = $B
@onready var C : AudioStreamPlayer = $C
@onready var D : AudioStreamPlayer = $D 

@onready var music_bus_2 = AudioServer.get_bus_index(B.bus)
@onready var music_bus = AudioServer.get_bus_index(A.bus)


@onready var requests : HTTPRequest = $HTTPRequest # for downloading musio files
@onready var timer : Timer #= $Timer


var _music
@onready var Music_streamer : AudioStreamPlayer = get_node_or_null("A")  #Refrences the music player node
@onready var  Music_streamer_2  : AudioStreamPlayer=get_node_or_null("D")
@onready var sfx_streamer 
@onready var track


@onready var transitions : AnimationPlayer = $anims

# Pointers to Node for Memory Mgmt
@onready var my_nodes : Array = [Music_streamer,B,C,Music_streamer_2,transitions,requests]


# THis URL fetches a Zip file from an AWS s3 buzket
#var musicAWS3_URL : Dictionary = {"zip":"https://llama2-7b.s3.eu-north-1.amazonaws.com/music.zip"
#} 

@onready var FileCheck= Utils.file  # checks Music Files
@onready var FileDirectory=Utils.dir #checks Music Irectory


# Debug Variables
var stream : AudioStream
var stream_length : int
var Playback_position : int
var _track : String


func _ready():
	
	# Debug Music  nodes
	#print_debug(my_nodes)
	
	# connect signals
	requests.connect("request_completed", Callable(self, "_http_request_completed"))
	
	# Check if Local Music Directory exists & Makes directory
	if not wallet.Functions.check_local_wallet_directory(FileDirectory,"user://Music") :
		FileDirectory.make_dir("user://Music")
		
	# Check if Music Unzip root folder exists
	if not wallet.Functions.check_local_wallet_directory(FileDirectory, "user://Music/Dystopia-App/source_code/music"):
		FileDirectory.make_dir_recursive("user://Music/Dystopia-App/source_code/music")
	
	
	
	"load on/off music settings"
	# Disabled for porting
	#Utils.Functions.load_game(true, Globals)
	


	print_debug("Music_on_settings :",bool (music_on))
	#	music_on = bool (Music_on_settings)
	
	
	"Music Player Logic"
	if music_on == true:
		#Utils._randomize(self)
		
		randomize()
		
		"Default Music"
		music_track = shuffle(default_playlist)
		
		
		# Debug Music Track
		#print_debug("Mus Track Debug: ",music_track)
		
		play(music_track) #Not needed for release
		
		
		
	if music_on == false:
		A.stop()



func _process(_delta):
	
	#_music_debug()
	
	"Music On.Off"
	
	
	"""
	Music Uncompress
	"""
	
	
	#Auto sets Globals Music Settings
	
	"""
	AUTO SHUFFLE
	"""
	# Bugs:
	# (1) Bugs Out In Headless Server Build
	if Music_streamer != null:
		if Music_streamer.stream != null and int(Music_streamer.get_playback_position())==int(Music_streamer.get_stream().get_length()):
			print_debug ('autoshuffle')
			if music_on: #Music_Available_Locally && music_on:
				music_track = shuffle(default_playlist) 
				play(music_track)
				




func _music_debug(): #Breaks
	if  music_on == true && get_tree().get_root().get_node("/root/Debug") != null: #Only Debugs if the debug singleton is running
		if music_track != null:
			for child in get_children() :
				if child is AudioStreamPlayer:
					if child.stream != null: 
						stream = Music_streamer.get_stream()
						stream_length = int(stream.get_length())
						_track = music_track.get_file()
						Playback_position = int(Music_streamer.get_playback_position())
						music_debug = str(stream , _track, Playback_position , '/', stream_length, sfx_streamer)




func play(_stream: String):
	#kinda works
	#it bugs out when the music track node is added to a scene
	if _stream != null or !_stream.is_empty(): #null error
		if current_track == "a":
			B.stream = load(_stream) #invalid funtion load, cannot convert arguement from nil to string
			transitions.play("AtoB")
			current_track = "b"
			music_on = true
		else:
			A.stream = load(_stream)
			transitions.play("BtoA")
			current_track = "a"
			music_on = true
	if _stream.is_empty() :
		push_error('Music stream is null, fix')
		print_debug('Stream:',stream, _stream)
		print_debug('Music Track',music_track)
	
	Utils.Functions.save_game(
		[], 
		0, 
		0, 
		0, 
		"", 
		"", 
		0, 
		"", 
		null,
		""
		)
	print_debug('Play Music setting debug: ', music_on) #For Debug purposes only


func clear():# triggers an autodelete in music track nodes
	music_track = ''
	print_debug('Music cleared')
	self.music_on = false
	Utils.Functions.save_game(
		[], 
		0, 
		0, 
		0, 
		"", 
		"", 
		0, 
		"", 
		null,
		""
		)
	print_debug('Clear Music setting debug: ', self.music_on) #For Debug purposes only
	return self.music_on


# Simple 'muffled music' effect on pause using a low pass filter
func _notification(what : int):
	# Docs: This code bloc calls uses multiple node states to Alter the State of this Music Object
	
	#print_debug(what) # for debug purposes only
	if what == NOTIFICATION_PAUSED:
		AudioServer.set_bus_effect_enabled(music_bus,0,true)
		AudioServer.set_bus_volume_db(music_bus,-10)

	if what == NOTIFICATION_UNPAUSED:
		AudioServer.set_bus_effect_enabled(music_bus,0,false)
		AudioServer.set_bus_volume_db(music_bus,0)

	if what == NOTIFICATION_PREDELETE:
		AudioServer.set_bus_volume_db(music_bus,-100)
		AudioServer.set_bus_volume_db(music_bus_2,-100)
		

	if what == NOTIFICATION_APPLICATION_PAUSED:
		
		AudioServer.set_bus_mute(music_bus, true)
		AudioServer.set_bus_mute(music_bus_2, true)
		
		clear()
	if what == NOTIFICATION_APPLICATION_RESUMED:
		AudioServer.set_bus_mute(music_bus, false)
		AudioServer.set_bus_mute(music_bus_2, false)
		
		music_track = shuffle(default_playlist)
		print_debug("Mus Debug 3: ", music_track)
		play(music_track)
		


"""
MUSIC SHUFFLE
"""
# Shuffles A Dictionary, Returns a string
static func shuffle (playlist : Dictionary) -> String:
	# Debug SHuffled Items 
	#print_debug("shuffling" ,playlist)
	
	#music_track = ''
	var track = int(randf_range(-1,playlist.size())) #selects a random track number
	
	
	print_debug("selected Item After Shuffle: ",playlist[track])
	return playlist[track]



func _on_A_finished(): #This  signals when the music has finished and autoshuffles
	randomize() 
	print_debug('music finished--music singleton') #code block works


func play_sfx(list : Dictionary): #a separate bus channel for sfx using dictionary playlist
	# 
	if sfx_on== true:
		var sfx : String = shuffle(list) 
		
		C.stream = load(sfx)
		C.play()
		sfx_streamer = str ('playing sfx: ',sfx.get_file())
		await get_tree().create_timer(0.8).timeout
		C.stop()

func play_track(_track : String): 
	#for playing single sample tracks
	#_track is a pointer to the music file path
	if _track != null  and Music_streamer_2 != null :
		#if music_on == true:
			#print (_track)# For debug purposes only

		D.set_stream ( load (_track)) #Children Scripts should not load the soundtracks
		D.play(0.0)
		sfx_streamer  = str('playing sfx: ',_track.get_file())
		await get_tree().create_timer(0.8).timeout
		D.stop()


func _exit_tree(): 
	Utils.MemoryManagement.queue_free_array(my_nodes)


