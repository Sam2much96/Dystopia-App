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

export (String) var local_image_path ="res://img0.png" #Loads the image file path from a folder to prevent redownloads
var image_url
var account_info: Dictionary = {1:[]}
var is_image_available_at_local_storage : bool 
onready var Algorand = $Algodot

#*****************************************************
onready var account_address = $VBoxContainer/address
onready var ingame_algos = $VBoxContainer/ingame_algos
onready var wallet_algos = $VBoxContainer/wallet_algos
onready var withdraw_button = $VBoxContainer/withdraw
onready var refresh = $VBoxContainer/refresh

#*****************************************************
onready var NFT= $"."
var status
func _ready():
	
	Algorand._test_algod_connection()
	
	#status = status && yield(Algorand.create_NFT("NFT001", "L5ESENBL23J2GJGM64Y767IXWGBCKXMGS2OGZ3MC5BBGWJAKJJAUK7BJK4", 1, "NFT", "res://body.json"), "completed") #doesnt work
	#print ("Status",status)
	
	#works
	
	#returns a dictionary
	account_info=(yield(Algorand._check_account_information("2NFCY7HBAFJ5YP7TXUOFHHMGAZ7AHEXPS5F3NENXSC3WXRVATBR4Y23AUM", "rigid steak better media circle nothing range tray firm fatigue pool damage welcome supply police spoon soul topic grant offer chimney total bronze able human", ""), "completed"))
	#print ("created assets: ",account_info['created-assets']) # lists assetscreated #for debug purposes only
	print (account_info["created-assets"][2]["index"]) #try using 3
	#print (account_info["created-assets"][2]["params"]['unit-name'])
	#print (account_info["address"])
	
	
	#[2]gets the second asset created parameters
	#var nft = account_info["created-assets"][2]['params']['url']
	#print(nft)
	#print (nft.keys())
	
	
	"works but saves a raw dictionary"
	#save_account_info(account_info) #works
	
	#print (account_info)
	#for asset in account_info["assets"]:
	#	print ("keys: ",asset.keys(), "values: ",asset.values())

	#show_account_info()
	
	
	"Checks if the Image is avalable Locally and either downloads or loads it"
	if check_is_image_avalable_() == false: #works
		#Networking.url= get_asset_url(Globals.address, Globals.mnemonic)
		Networking.url= "https://192.168.0.104/body.png"
		print ("Image url :", Networking.url)#for debug purposes
		
		# Connects the Networking signal
		Networking.connect("request_completed", self, "_http_request_completed")
		#Networking.start_check()
		#Networking.download_image_(Networking._check_connection( Networking.url), "res://")
		#Networking.download_file
		Networking._check_connection( Networking.url)
		
	elif check_is_image_avalable_() == true:
			load_local_image_texture()
	else: return


func show_account_info(): #should load from saved account info 
	if account_info.empty() == false: #load from wallet
		account_address.text += account_info["address"]
		ingame_algos.text += str (Globals.algos)
		wallet_algos.text += str (account_info["amount"])

func connect_signals()-> void: #connects all required signals in the parent node
	pass

#saves account information to a dictionary
func save_account_info( info : Dictionary):
	var save_game = File.new()
	save_game.open("res://account_info.token", File.WRITE)
	var save_dict = {}
	#save_dict= info #saves the raw dictionary
	save_dict.address =info["address"]
	save_dict.amount =info["amount"]
	save_dict.asset_index =info["created-assets"][2]["index"]
	save_dict.asset_name = info["created-assets"][2]["params"]["name"]
	save_dict.asset_unit_name = info["created-assets"][2]["params"]['unit-name']
	save_dict.asset_url = info["created-assets"][2]['params']['url'] #saves the url of the second asset
	
	save_game.store_line(to_json(save_dict))
	save_game.close()
	print ("saved account info")


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
		var _r = file_check.exists(local_image_path, "ImageTexture")
		#print ("Is local image available: ", _r) #for debug purposes only
		is_image_available_at_local_storage = _r
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
		#print (NFT.texture) for debug purposes only
		NFT.set_expand(true)

func return_account_info(): #not needed
	"Prints the Account info"
#	if not account_info.empty():
#		account_info_text.set_text(account_info)

func store_wallet_details_locally(): #should store the wallet details
	# Create new ConfigFile object.
	var wallet_data = ConfigFile.new()
	
	# Store some values.
	wallet_data.set_value("Player ", "player_name", Globals.player_name)
	wallet_data.set_value("Address", "address", Globals.address)
	wallet_data.set_value("Mnemonic", "mnemonic", Globals.mnemonic)
	
	
	# Save it to a file and encrypts it (overwrite if already exists).
	wallet_data.save_encrypted ( "res://wallet_data.cfg", 1234 )
	
	pass

func load_wallet_details_from_local(): #should load the wallet details
	var wallet_data = ConfigFile.new()

	# Load encrpyted data from a file.
	var err = wallet_data.load_encrypted_pass ( "res://wallet_data.cfg", 1234 )

	# If the file didn't load, ignore it.
	if err != OK:
		return
	# Iterate over all sections.
	for player in wallet_data.get_sections():
	# Fetch the data for each section.
		Globals.player_name = wallet_data.get_value(player, "player_name") #place holder values
		Globals.address = wallet_data.get_value(player, "best_score") #place holder values
		Globals.mnemonic = wallet_data.get_value(player, "best_score") #place holder values
	pass

func _on_withraw(): #withdraws Algos from wallet data into algorand wallet
	#status = status && yield(algos._send_transaction_to_receiver_addr(funder_address , funder_mnemonic , receivers_address , receivers_mnemonic), "completed") #works
	#status = status && yield(_send_asset_transfers_to_receivers_address(funder_address , funder_mnemonic , receivers_address , receivers_mnemonic), "completed") #works
	print (status)


