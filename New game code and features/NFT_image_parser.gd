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
# To-DO:
# (1) Implement as State Machine
# Testing
#(1) Image Downloder (works)
# (2) Create NFT (doesnt work)
# (3) Parse NFT (works)
# *************************************************


extends TextureRect

class_name NFT

export (String) var local_image_path ="res://wallet/img0.png" #Loads the image file path from a folder to prevent redownloads (depreciated)
var image_url
var json= File.new()
var account_info: Dictionary = {1:[]}
var is_image_available_at_local_storage : bool  #(depreciated)
onready var Algorand = $Algodot

#*****************Wallet UI ************************************
onready var account_address = $VBoxContainer/address
onready var ingame_algos = $VBoxContainer/ingame_algos
onready var wallet_algos = $VBoxContainer/wallet_algos
onready var withdraw_button = $VBoxContainer/withdraw
onready var refresh_button= $VBoxContainer/refresh

#*****************************************************
onready var NFT= $"."
var status
#var file_checker = File.new() #use FileCheck instead (depreciated)
onready var python_request=$Node

#************** Algo Variables *************************
var Escrow_account: String="L5ESENBL23J2GJGM64Y767IXWGBCKXMGS2OGZ3MC5BBGWJAKJJAUK7BJK4"  #should ideally be a smart contract
var Escrow_mnemoic: String="""
							height decade cable deliver magnet approve chief
							only bicycle minute afford toilet increase scene 
							armed thrive then grief spy away medal quiz copper 
							able broccoli
							"""


var Player_account: String="2NFCY7HBAFJ5YP7TXUOFHHMGAZ7AHEXPS5F3NENXSC3WXRVATBR4Y23AUM"
var Player_mnemonic: String ="""rigid steak better media circle nothing range 
								tray firm fatigue pool damage welcome supply
								 police spoon soul topic grant offer chimney 
								total bronze able human"""

#var load_from_local_wallet : bool
var amount
var address
var _wallet_algos: int
var asset_name
var asset_url

#************NFT variables**************#
var _name : String
var _description : String
var _image
#************File Checkers*************#
var FileCheck1=File.new() #checks account info
var FileCheck2=File.new() #checks NFT metadata .json
var FileCheck3=File.new()#checks local image storage
var FileCheck4=File.new() # checks wallet mnemonic

var FileDirectory=Directory.new() #deletes all theon reset
func _ready():
	
	error_checkers()

	#works
	
	
	if not FileCheck1.file_exists("res://wallet/account_info.token"): # if account info doesn't exist
		#Make sure an algod node is running or connet to mainnet or testnet
		Algorand.create_algod_node()
		Algorand._test_algod_connection()
		
		"gets account info returns a dictionary"
		account_info=(yield(Algorand._check_account_information(Player_account, Player_mnemonic, ""), "completed"))
		
		
		"saves account info"
		save_account_info(account_info, 2) #works
	
	"it's always load account details when ready"
	if FileCheck1.file_exists("res://wallet/account_info.token"):
		load_account_info()
		
		#load_wallet_mnemonic_from_local() #disabling for now
		show_account_info(true)
	
	
	"Checks if the Image is avalable Locally and either downloads or loads it"
	if not FileCheck3.file_exists("res://wallet/img0.png"): #works
		print('NFT image is not available locally, Downloading now') 
		
		# Connects the Networking signal
		connect_signals()
		debug_signal_connections()
		'theres a problem with the network connection'
		'my server isnt serving the json file to godot properly'
		"using python instead"
		
		if not FileCheck2.file_exists('res://wallet/nft_metadata.json'): #checks for nft metadata
			#$Node.activate=bool(1) #doesn't work
			json.open(("res://wallet/nft_metadata.json"), File.WRITE ) #check of file exists to save bandwidth
			#makes a Python  http request to server returns a string
			json.store_line($Node._ready()) #create an entry boolean
			json.close()
			#$Node.activate=bool(0) #doesn't work
			print ('nft metadata stored locally')
		if FileCheck2.file_exists('res://wallet/nft_metadata.json'): #check for file size, so it doesn't save a 0 byte json
			json.open("res://wallet/nft_metadata.json", File.READ)
			var p =  parse_json(json.get_as_text()) #return a dictionary
			#*********Parse Json For Details***********#
			image_url= p.get('image')
			_description= p.get('description')
			_name= p.get('name')
			print ('nft host site',image_url)
			#******************************************#
		
		print ('nft host site',image_url) #image_url should not be null
		Networking.url=image_url
		 
		#makes a https request to download image from local server
		Networking._check_connection( image_url) 
		#***************************************************************
	elif FileCheck3.file_exists("res://wallet/img0.png"):
			load_local_image_texture()
	else: return


func show_account_info(load_from_local_wallet: bool): #loads from saved account info 
	if load_from_local_wallet == true: #load from wallet
		account_address.text = str(Globals.address)
		ingame_algos.text += str (Globals.algos)
		wallet_algos.text += str(_wallet_algos)
	if load_from_local_wallet== false:
		print ('loading account info from Algorand Blockchain')
		account_info=(yield(Algorand._check_account_information("2NFCY7HBAFJ5YP7TXUOFHHMGAZ7AHEXPS5F3NENXSC3WXRVATBR4Y23AUM", "rigid steak better media circle nothing range tray firm fatigue pool damage welcome supply police spoon soul topic grant offer chimney total bronze able human", ""), "completed"))
		account_address.text   = account_info['address']
		ingame_algos.text = str(Globals.algos)
		wallet_algos.text = account_info['amount']

func connect_signals(): #connects all required signals in the parent node
	return Networking.connect("request_completed", self, "_http_request_completed")

func debug_signal_connections()->void:
	#debuggers
	print("Networking Connected: ",Networking.is_connected("request_completed", self, "_http_request_completed"))


#saves account information to a dictionary
#i don't know what number does ngl. It jusst works, lol
func save_account_info( info : Dictionary, number: int): 
	var save_game = File.new() #change from save game
	save_game.open("res://wallet/account_info.token", File.WRITE)
	var save_dict = {}
	#save_dict= info #saves the raw dictionary
	save_dict.address =info["address"]
	save_dict.amount =info["amount"]
	save_dict.asset_index =info["created-assets"][number]["index"]
	save_dict.asset_name = info["created-assets"][number]["params"]["name"]
	save_dict.asset_unit_name = info["created-assets"][number]["params"]['unit-name']
	save_dict.asset_url = info["created-assets"][number]['params']['url'] #asset Uro and asset uri are different. Separate them
	
	save_game.store_line(to_json(save_dict))
	save_game.close()

	
	
	print ("saved account info")
	
	#store_wallet_mnemonic_to_local() #breaks, disabling for now
	
	print ("saved account mnemonic")


func load_account_info(check_only=false):
	var save_game = File.new()
	
	if not save_game.file_exists("res://wallet/account_info.token"):
		return false
	
	save_game.open("res://wallet/account_info.token", File.READ)
	
	var save_dict = parse_json(save_game.get_line())
	if typeof(save_dict) != TYPE_DICTIONARY:
		return false
	if not check_only:
		_restore_wallet_data(save_dict)

func _restore_wallet_data(info: Dictionary):
	# JSON numbers are always parsed as floats. In this case we need to turn them into ints
	address = str(info.address)
	Globals.address = info.address
	_wallet_algos = info.amount 
	asset_name = str (info.asset_name) 
	asset_url = str(info.asset_url) #asset url and asset meta data are different
	print ('wallet data restored from local database')

func check_is_image_avalable_()-> bool:
	if local_image_path != '':
		"Checks if image file is available"
		var file_check = ResourceLoader
		var _r = file_check.exists(local_image_path, "ImageTexture")
		#print ("Is local image available: ", _r) #for debug purposes only
		is_image_available_at_local_storage = _r
	return is_image_available_at_local_storage

'add functionality to download json file'
func _http_request_completed(result, response_code, headers, body): #works with https connection
	print (" request done: ", result) #********for debug purposes only
	print (" headers: ", headers)#*************for debug purposes only
	print (" response code: ", response_code) #for debug purposes only
	if is_image_available_at_local_storage== false: 
		"Should Parse the NFT's meta-data to get the image ink"
		if body.empty() != true:
			print ('request successful')
			
			"Downloads the NFT image"
			print (" request successful")
			NFT.set_image_(Networking.download_image_(body, "res://wallet/img0")) #works?
			
		if body.empty(): #returns an empty body
			push_error("Result Unsuccessful")
			Networking.stop_check()
	Networking.cancel_request()

func set_image_(texture):
	if FileCheck3.file_exists("res://wallet/img0.png"):#use file check
		#dowmload image
		NFT.set_texture(texture)
		"update Local image"
		print("Image Tex: ",NFT.texture)
		print("Image Format: ",NFT.texture.get_format() )
		local_image_path = "res://wallet/img0.png"
		print ("Is stored locally: ",check_is_image_avalable_())

func load_local_image_texture():
	"Doesn't load Image with proper aspect ratio"
	#improve this code base
	
	NFT.set_texture(load(local_image_path))
		#print (NFT.texture) for debug purposes only
	NFT.set_expand(true)


func store_wallet_mnemonic_to_local(): #should store the wallet details (Unused)
	# Create new ConfigFile object.
	var wallet_data = ConfigFile.new()
	
	# Store some values.
	wallet_data.set_value("Mnemonic", "mnemonic", Globals.mnemonic)
	# Save it to a file and encrypts it (overwrite if already exists).
	wallet_data.save_encrypted ( "res://wallet/wallet_keys.cfg", 1234 )
	
	pass

func load_wallet_mnemonic_from_local(): #should load the wallet details (Unused)
	var wallet_data = ConfigFile.new()
	# Load encrpyted data from a file.
	var err = wallet_data.load_encrypted_pass ( "res://wallet/wallet_keys.cfg", 1234 )
	# If the file didn't load, ignore it.
	if err != OK:
		return
	# Iterate over all sections.
	for player in wallet_data.get_sections():
	# Fetch the data for each section.
		Globals.mnemonic = wallet_data.get_value(player, "best_score") #place holder values
	pass

func _on_withraw(): #withdraws Algos from wallet data into my test algorand wallet
	if Globals.algos != 0: #cannot withdraw with zero balance
		Algorand.create_algod_node() #from an escrow account
		status = status && yield(Algorand._send_transaction_to_receiver_addr(Escrow_account , Escrow_mnemoic , "2NFCY7HBAFJ5YP7TXUOFHHMGAZ7AHEXPS5F3NENXSC3WXRVATBR4Y23AUM", "rigid steak better media circle nothing range tray firm fatigue pool damage welcome supply police spoon soul topic grant offer chimney total bronze able human", Globals.algos), "completed") #works
		#status = status && yield(_send_asset_transfers_to_receivers_address(funder_address , funder_mnemonic , receivers_address , receivers_mnemonic), "completed") #works
		print (status)
	if Globals.algos == 0:
		
		print ("Cannot withdraw from ",Globals.algos, " balance")
		
	if status:
		print('withdrawal Successful')
		show_account_info(false) #updates account info


func _on_reset():
	#should deleta all account details
	print ('----Resetting')
	var a="res://wallet/account_info.token"
	var b="res://wallet/img0"
	var c="res://wallet/wallet_keys.cfg"
	var d="res://wallet/nft_metadata.json"
	var FilesToDelete=[]#stores all files in an array
	FilesToDelete.append(a,b,c,d)
	for _i in FilesToDelete: #looped delete
		var error=FileDirectory.remove(_i)
		if error==OK:
			print ('Refreshing Wallet')
	return _ready()

func error_checkers()-> void:
	'Fixes account token 0 bytes bug'
	FileCheck1.open('res://wallet/account_info.token',File.READ)
	if FileCheck1.get_len() == 0: #prevents a  0 bytes error
		FileCheck1.close()
		FileDirectory.remove("res://wallet/account_info.token")
		return

func _exit_tree():
#	if account_info != null: #(untested) (buggy
#		save_account_info(account_info,2)
	pass


func _on_withdraw_pressed():
	Music.play_track(Music.ui_sfx[0])
	_on_withraw()


func _on_Main_menu_pressed():
	Music.play_track(Music.ui_sfx[0])
	return Globals._go_to_title()
