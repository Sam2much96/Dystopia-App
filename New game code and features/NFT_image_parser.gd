# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Parses an image from an NFT url, ising a Networking singleton
# NFT "Non FUungible Token
# To Do:
#(1) c
#Logic
# It uses the Networking singleton and Algorand library
# to get an asset's url and download the image from
# the asset's meta-data
# asset's url should be read 

#Features
#(1) Curerntly implements on the ALgorand blockchain, other chains not supported
# *************************************************
# Testing
#(1) Image Downloder
# (2) Create NFT
# (3) Parse NFT
# *************************************************


extends TextureRect

class_name NFT

export (String) var local_image_path ="" #Loads the image file path from a folder to prevent redownloads
var image_url
var account_info: Dictionary = {}
var is_image_available_at_local_storage : bool 
onready var Algorand = $Algodot
onready var account_info_text = $account_info_text

onready var NFT= self
var status
func _ready():
	
	
	
	#status = status && yield(Algorand.create_NFT("NFT001", Globals.address, 1, "NFT", "http://localhost:8000/body.png"), "completed") #untested
	#print (status)
	check_is_image_avalable_()
	
	"Checks if the Image is avalable Locally and either downloads or loads it"
	if is_image_available_at_local_storage == false:
		#Networking.url= get_asset_url(Globals.address, Globals.mnemonic)
		Networking.url= "http://localhost:8000/body.png"
		print ("Image url :", Networking.url)#for debug purposes
		
		# Connects the Networking signal
		Networking.connect("request_completed", self, "_http_request_completed")
		#Networking.start_check()
		#Networking.download_image_(Networking._check_connection( Networking.url), "res://")
		#Networking.download_file
		Networking._check_connection( Networking.url)
		
	elif is_image_available_at_local_storage == true:
			load_local_image_texture()
	else: return



# Parses Asset MetaData
func get_asset_url(address, mnemonic) :
	var account_info = []
	account_info = yield(Algorand._check_account_information(address, mnemonic), "completed")
	for _i in account_info:
		if _i == "url" :
		#var _a = _info.assets
			var asset_url = _i 
			return asset_url

func check_is_image_avalable_()-> bool:
	if local_image_path != '':
		"Checks if image file is available"
		var file_check = ResourceLoader
		is_image_available_at_local_storage = file_check.exists(local_image_path, "ImageTexture")
	return is_image_available_at_local_storage
	
func _http_request_completed(result, response_code, headers, body):
	print (" request done", result)
	if is_image_available_at_local_storage== false:
		if body.empty() != true:
			print (" request successful")
			NFT.set_image_(Networking.download_image_(body, "res://img0")) #kina works?
			#return_account_info()
		if body.empty():
			push_error(str(Networking.result))
			Networking.stop_check()


func set_image_(texture):
	if not is_image_available_at_local_storage:
		#dowmload image
		NFT.set_texture(texture)
		"update Local image"
		print("Image Tex: ",NFT.texture)
		print("Image Format: ",NFT.texture.get_format() )
		local_image_path = "res://img0.png"
		print ("Is stored locally: ",check_is_image_avalable_())

func load_local_image_texture():
	if is_image_available_at_local_storage:
		NFT.set_texture(load(local_image_path))

func return_account_info():
	"Prints the Account info"
	if not account_info.empty():
		account_info_text.set_text(account_info)

func store_NFT_variables(): #should store the image variables
	pass
