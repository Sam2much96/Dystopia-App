extends Control

"""
The purpose of this code is to beautify the UI programmatically
"""
" " # Doesnt work
#()I matched a bunch of UI Animation to an Animational variable node to the
# The purpose is to show a loadinbg animation once the outside environment scene loads
#doesn't work on low process pc


#changes Title Screen Art using Global Screen Orientation
onready var art1 = $TextureRect
onready var art2 = $TextureRect2

# Texting Server File Downloads
onready var u = $u#= HTTPRequest.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.screenOrientation == 0:
		art1.show()
		art2.hide()
	elif Globals.screenOrientation == 1:
		art1.hide()
		art2.show()
	pass
# Called every fra

	# Testing  Unzip
	# Works
	#var t=Globals.uncompress('res://music/music.zip')
	#Works
#	print(t.get_string_from_utf8())

	"Downloads a Zip file from Github and unzips it locally"
	# Works
	# Written for Musics singleton optimization		
	# Texting Server File Downloads
	if Globals.check_files("res://", "res://music.zip") == false:
		# Use Code load API for downloading Zip files
		# Works
		Networking.url = "https://codeload.github.com/Sam2much96/online-hosting/legacy.zip/8ffef2ef01f945cc3c3d3922c9aadfaf073387e7"
		Networking._check_connection(Networking.url, u)
	
	if Globals.check_files("res://", "res://music.zip") == true:
		Globals.uncompress("res://music.zip")


func _on_u_request_completed(result, response_code, headers, body):
	print (" request done 1: ", result) #********for debug purposes only
	#print (" headers 1: ", headers)#*************for debug purposes only
	print (" response code 1: ", response_code) #for debug purposes only
	
	if not body.empty():
		#Buggy. Downloads a corrupt file
		Networking.download_file_(u, body, "res://music",".zip")
		#RestHandler.request_pull_branch(zip_filepath, typeball_url, current_repo._repository.diskUsage)
	
	if body.empty(): #returns an empty body
		push_error("Result Unsuccessful")
		#good_internet = false
		#Networking.stop_check()
