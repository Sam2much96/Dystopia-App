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


# *************************************************
# Bugs:
# (1) Music debug function breaks
# (2) Debug Function breaks
# (3) Music Volume is unimplemented
# *************************************************
"""
THERE ARE TWO FUNCTIONS FOR PLAYING MUSIC TRACKS AND MUSIC PLAYLISTS
"""
extends Node
#add more controls to this script, it breaks the singleton
export (bool) var music_on 
export (bool) var sfx_on
export (int) var volume # volume controller code is not yet written

export(String, FILE, "*.ogg") var music_track = ""

# should me moved to github repository
# file checker should loop through playlist
var playlist_one = {
	0:'res://music/310-world-map-loop.ogg', 
	1:'res://music/chike san afro 1.ogg',
	2:'res://music/chike san afro 2.ogg',
	3:'res://music/chike san afro 3.ogg',
	4:'res://music/chuks-dane_chuks-dane-shoot-back.ogg',
	5:'res://music/Astrolife chike san.ogg',
	6:'res://music/chuks-dane_chuks-dane-new-breed-prod-base.ogg',
	7:'res://music/a-2-3-groovy-bgm.ogg',
	8:'res://music/Spooky-Chike-san song.ogg',
	9:'res://music/6Feet.ogg',
	10:'res://music/Blow.ogg',
	11:'res://music/HENSONN_SAHARA.ogg',
	12:'res://music/Moya.ogg',
	13:'res://music/Turn up.ogg',
	14:'res://music/wind_2.ogg'
}
var comic_sfx = {
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

var ui_sfx = {
	0:'res://sounds/Menu1A.ogg',
	1:'res://sounds/Menu1B.ogg',
}


var hit_sfx = {
	0:'res://sounds/hit01.ogg',
	1:'res://sounds/hit02.ogg',
	2:'res://sounds/hit03.ogg',
	3:'res://sounds/hit04.ogg',
	4:'res://sounds/hit05.ogg',
	5:'res://sounds/hit06.ogg',
	6:'res://sounds/hit07.ogg',
	7:'res://sounds/hit08.ogg',

}

var grass_sfx = {0:'res://sounds/Fantozzi-SandR3.ogg'}

var wind_sfx = {0:'res://music/wind_2.ogg'}

var _music
onready var Music_streamer =get_node("A")  #Refrences the music player node
onready var  Music_streamer_2 =get_node("D")
onready var sfx_streamer 
onready var track
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
onready var current_track

onready var music_bus_2 = AudioServer.get_bus_index($B.bus)
onready var music_bus = AudioServer.get_bus_index($A.bus)

#  Server File Downloads
onready var request_node = $HTTPRequest

func _ready():
	#Check if files are available locally
	
	"Downloads a Zip file from Github and unzips it locally"
	# Works
	# Written for Musics singleton optimization		
	# Texting Server File Downloads
	
	# Checks for music files in playlist one in Local Storage
	for y in playlist_one.values():
		if Globals.check_files("res://music", y) == false:
		# Use Code load API for downloading Zip files
		# Works
		# Url was gotten from Github integration API
			Networking.url = "https://codeload.github.com/Sam2much96/online-hosting/legacy.zip/8ffef2ef01f945cc3c3d3922c9aadfaf073387e7"
			Networking._check_connection(Networking.url, request_node)

		if Globals.check_files("res://music", y) == true:
			print ("File Check for music file: ", y," exists")
		
		#Globals.uncompress("res://music.zip")


	
	#load on/off music settings
	
	
	
	if music_on == true:
		randomize() #randomizes shuffle code seed
		shuffle(playlist_one) #disabled for debugging
		_music = music_track.get_file()
		play(music_track) #Not needed for release
		Globals.Music_on_settings = true
	elif music_on == false:
		$A.stop()
		Globals.Music_on_settings = false
		pass



func _process(_delta):

	"""
	Music Debug
	"""
	_music_debug()  #breaks # for debug purposes only
	
	#Auto sets Globals Music Settings

	"""
	AUTO SHUFFLE
	"""
	if Music_streamer != null:
		if Music_streamer.stream != null and int(Music_streamer.get_playback_position())==int(Music_streamer.get_stream().get_length()):
			print ('autoshuffle')
			shuffle(playlist_one) 
			play(music_track)


func _music_debug(): #Breaks
	if  music_on == true && get_tree().get_root().get_node("/root/Debug") != null: #Only Debugs if the debug singleton is running
		if music_track != null:
			for child in get_children() :
				if child is AudioStreamPlayer:
					if child.stream != null: 
				
						
						var stream = Music_streamer.get_stream()
						var stream_length = int(stream.get_length())
						var _track = music_track.get_file()
						var Playback_position = int(Music_streamer.get_playback_position())
						music_debug = str(stream , _track, Playback_position , '/', stream_length, sfx_streamer)




func play(stream):
	#kinda works
	#it bugs out when the music track node is added to a scene
	if stream != null or stream != '': #null error
		if current_track == "a":
			$B.stream = load(stream) #invalid funtion load, cannot convert arguement from nil to string
			$anims.play("AtoB")
			current_track = "b"
			music_on = true
		else:
			$A.stream = load(stream)
			$anims.play("BtoA")
			current_track = "a"
			music_on = true
	if stream == null or stream == '':
		push_error('Music stream is null, fix')
		print_debug('Stream:',stream)
		print_debug('Music Track',music_track)

func clear():# triggers an autodelete in music track nodes
	music_track = ''
	print('Music cleared')
	music_on = false



# Simple 'muffled music' effect on pause using a low pass filter
func _notification(what):
	if what == NOTIFICATION_PAUSED:
		AudioServer.set_bus_effect_enabled(music_bus,0,true)
		AudioServer.set_bus_volume_db(music_bus,-10)
	if what == NOTIFICATION_UNPAUSED:
		AudioServer.set_bus_effect_enabled(music_bus,0,false)
		AudioServer.set_bus_volume_db(music_bus,0)
	if what == NOTIFICATION_PREDELETE:
		AudioServer.set_bus_volume_db(music_bus,-100)
		AudioServer.set_bus_volume_db(music_bus_2,-100)
		#turn_off()
		print ('music off- Notificationh Predelete')
	if what == NOTIFICATION_APP_PAUSED:
		AudioServer.set_bus_mute(music_bus, true)
		AudioServer.set_bus_mute(music_bus_2, true)
		clear()
		#pass
	if what == NOTIFICATION_APP_RESUMED:
		AudioServer.set_bus_mute(music_bus, false)
		AudioServer.set_bus_mute(music_bus_2, false)
		shuffle(playlist_one)
		play(music_track)



"""
MUSIC SHUFFLE
"""
func shuffle (playlist):
	music_track = ''
	track = int(rand_range(-1,playlist.size())) #selects a random track number
	music_track = playlist[track]
	return music_track



func _on_A_finished(): #This  signals when the music has finished and autoshuffles
	randomize() #disabled for debugging
	print('music finished--music singleton') #code block works
	#shuffle()
	#play(music_track)
	#print (_n)

func play_sfx(list): #a separate bus channel for sfx using dictionary playlist
	if sfx_on== true:
		shuffle(list)
		$C.stream = load(music_track)
		$C.play()
		sfx_streamer = str ('playing sfx: ',music_track.get_file())
		yield(get_tree().create_timer(0.8), "timeout")
		$C.stop()

func play_track(_track): #for playing single sample tracks
	if _track != null  and Music_streamer_2 != null :
		if music_on == true:
			#print (_track)# For debug purposes only

			$D.set_stream ( load (_track)) #Children Scripts should not load the soundtracks
			$D.play(0.0)
			sfx_streamer  = str('playing sfx: ',_track.get_file())
			yield(get_tree().create_timer(0.8), "timeout")
			$D.stop()

func sound(what): #Turns on/ off and saves it via a global script
	#Globals.Music_on_settings = false
	if what == 'off' or 'Off' or 'OFF': #Debug
		music_on = false
		sfx_on = false
		_notification(NOTIFICATION_APP_PAUSED)
		#print ('Turned off Music', Globals.Music_on_settings) #For Debug purposes only
	if what == 'on' or 'On' or 'ON':
		music_on = true
		sfx_on = true





func _exit_tree(): 
	#turn_off()
	sound('off')


"Downloads Music files from Github"


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print (" request done 1: ", result) #********for debug purposes only
	print (" headers 1: ", headers)#*************for debug purposes only
	print (" response code 1: ", response_code) #for debug purposes only
	
	if not body.empty():
		#Buggy. Downloads a corrupt file
		return Networking.download_file_(request_node, body, "res://music",".zip")
		#RestHandler.request_pull_branch(zip_filepath, typeball_url, current_repo._repository.diskUsage)
	
	if body.empty(): #returns an empty body
		push_error("Result Unsuccessful")
		#good_internet = false
		#Networking.stop_check()
