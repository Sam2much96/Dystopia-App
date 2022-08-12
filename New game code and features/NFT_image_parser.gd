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
var file_checker = File.new()

#************** Algo Variables *************************
var load_from_local_wallet : bool
var amount
var address
var _wallet_algos: int
var asset_name
var asset_url


var counter: int = 0 # used to trigger between json download and Image download

func _ready():
	
	
	
	#status = status && yield(Algorand.create_NFT("NFT001", "L5ESENBL23J2GJGM64Y767IXWGBCKXMGS2OGZ3MC5BBGWJAKJJAUK7BJK4", 1, "NFT", "res://body.json"), "completed") #doesnt work
	#print ("Status",status)
	
	#works
	
	
	if not file_checker.file_exists("res://account_info.token"): # if account info doesn't exist
		#Make sure an algod node is running or connet to mainnet or testnet
		Algorand._test_algod_connection()
		
		"gets account info returns a dictionary"
		account_info=(yield(Algorand._check_account_information("2NFCY7HBAFJ5YP7TXUOFHHMGAZ7AHEXPS5F3NENXSC3WXRVATBR4Y23AUM", "rigid steak better media circle nothing range tray firm fatigue pool damage welcome supply police spoon soul topic grant offer chimney total bronze able human", ""), "completed"))
		#print (account_info["created-assets"][2]["index"]) #try using 3
		#print (account_info["created-assets"][2]["params"]['unit-name'])
		"saves account info"
		save_account_info(account_info, 2) #works
	
	"it's always load account details when ready"
	if file_checker.file_exists("res://account_info.token"):
		load_account_info()
		
		#load_wallet_mnemonic_from_local() #disabling for now
		show_account_info()
	
	
	"Checks if the Image is avalable Locally and either downloads or loads it"
	if check_is_image_avalable_() == false: #works
		print('NFT image is not available locally, Downloading now') 
		var b = HTTPClient.new() #testing http client
		
		Networking.url= str(asset_url) #it needs to run 2 checks to download json
		print ("Image url :", Networking.url)# Downloads a .json
		

		
		# Connects the Networking signal
		connect_signals()
		#b.connect("request_completed", self, "_http_request_completed")
		
		#Networking._check_connection( 'https://192.168.0.104/body.png') #works with https
		Networking._check_connection( 'https://192.168.0.104/body.json') #works with https
		
		#Networking._check_connection_secured(Networking.url) #returns read and write erro
		#Networking._check_connection_secured("192.168.0.104") #gets stuck making connection
		
		
		
		
		#Networking.download_image_('http://localhost:8000/body.png', 'res:')
		#port code bloc to Networking singleton
	elif check_is_image_avalable_() == true:
			load_local_image_texture()
	else: return


func show_account_info(): #loads from saved account info 
	if load_from_local_wallet == true: #load from wallet
		account_address.text = Globals.address
		ingame_algos.text += str (Globals.algos)
		wallet_algos.text += str(_wallet_algos)

func connect_signals()-> void: #connects all required signals in the parent node
	Networking.connect("request_completed", self, "_http_request_completed")

#saves account information to a dictionary
#i don't know what number does ngl. It jusst works
func save_account_info( info : Dictionary, number: int): 
	var save_game = File.new() #change from save game
	save_game.open("res://account_info.token", File.WRITE)
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
	
	store_wallet_mnemonic_to_local()
	print ("saved account mnemonic")


func load_account_info(check_only=false):
	var save_game = File.new()
	
	if not save_game.file_exists("res://account_info.token"):
		return false
	
	save_game.open("res://account_info.token", File.READ)
	
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
	load_from_local_wallet = true
	print ('wallet data restored from local database')

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

#*************for https request below
#var response = parse_json(body.get_string_from_ascii())
#		print("Response: ",response)

'add functionality to download json file'
func _http_request_completed(result, response_code, headers, body): #works with https connection
	print (" request done: ", result)
	if is_image_available_at_local_storage== false:
		#print (body)
		#var json = JSON.parse(body.get_string_from_utf8()) #should work
		#print ("NF metadata: ",json.result) #has ssl dertificate error
		#print ("NF metadata: ",json.print('image')) #has ssl dertificate error
		Networking.download_json_(body,'res://nft_metadata')
		
		"Should Parse the NFT's meta-data to get the image ink"
		if body.empty() != true:
			print ('request successful')
			
			
			if counter == 1:
				"Downloads the NFT image"
				print (" request successful")
				NFT.set_image_(Networking.download_image_(body, "res://img0")) #works?
			
		if body.empty(): #returns an empty body
			push_error("Result Unsuccessful")
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


	

func store_wallet_mnemonic_to_local(): #should store the wallet details
	# Create new ConfigFile object.
	var wallet_data = ConfigFile.new()
	
	# Store some values.
	wallet_data.set_value("Mnemonic", "mnemonic", Globals.mnemonic)
	# Save it to a file and encrypts it (overwrite if already exists).
	wallet_data.save_encrypted ( "res://wallet_keys.cfg", 1234 )
	
	pass

func load_wallet_mnemonic_from_local(): #should load the wallet details
	var wallet_data = ConfigFile.new()
	# Load encrpyted data from a file.
	var err = wallet_data.load_encrypted_pass ( "res://wallet_keys.cfg", 1234 )
	# If the file didn't load, ignore it.
	if err != OK:
		return
	# Iterate over all sections.
	for player in wallet_data.get_sections():
	# Fetch the data for each section.
		Globals.mnemonic = wallet_data.get_value(player, "best_score") #place holder values
	pass

func _on_withraw(): #withdraws Algos from wallet data into algorand wallet
	#status = status && yield(algos._send_transaction_to_receiver_addr(funder_address , funder_mnemonic , receivers_address , receivers_mnemonic), "completed") #works
	#status = status && yield(_send_asset_transfers_to_receivers_address(funder_address , funder_mnemonic , receivers_address , receivers_mnemonic), "completed") #works
	print (status)


