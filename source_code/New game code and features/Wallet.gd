# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Wallet
# Implements an Algorand Wallet in GDscript
# Parses an image from an NFT url, ising a Networking singleton
# NFT "Non FUungible Token
# To Do:
#(1) Fix Hacky Spagetti Code
#(2) Implement NFT subcode.
# (3) Unimplement Networking Singleton i.e. script should run it's own networking node
# (4) Users should be able to copy wallet details
# (5) Test transaction state for Tokens and Algos
#Logic
# It uses the Networking singleton and Algorand library
# to get an asset's url and download the image from
# the asset's meta-data
# asset's url should be read 

#Features
#(1) Curerntly implements on the ALgorand blockchain, other chains not supported
# (2) Uses two states -a Accounts State & -Collectible state
# (3) Implements Binary > Utf-8 encryption
# *************************************************
#Bugs:

#(2) CHeck account state is broken (fixed)
#(3) Import Mnemonic doesnt work on free app installs without wallets
#(4) UI logic breaks apart once Account details are missing (duplicate of #3)


# To-DO:
# (1) Implement as State Machine (done)(requires testing)
# (2) Update transaction logic (done)
# (3) Test Smart Contracts
# (4) Implement Proper wallet security (needs encryption and decryption algorithm) (step 1 done)
# (5) Copy and Paste Wallet Address (done)
# (6) Use time timeout to transition btw states (depreciated)
# (7) Import wallet (done)
# (8) Implement IPFS web 2 Gateway as a callale Networking SIngleton function (done)
# 
# (10) IMplement Tokenized characters (player_v2)
# (11) Implement cryptographic encryption and decryption
# (12) Implement show mnemonic button
# (13) Improve UI 
		#alter UI scale for mobiles (done)
		#use animation player to alter UI

# Testing
#(1) Image Downloder (works)
# (2) Create NFT (doesnt work)
# (3) Parse NFT (works)
# *************************************************


extends Control

#class_name wallet

export (String) var local_image_path ="res://wallet/img0.png" #Loads the image file path from a folder to prevent redownloads (depreciated)
var image_url
var json= File.new()
var account_info: Dictionary = {1:[]}
var is_image_available_at_local_storage : bool  #(depreciated)
onready var Algorand = $Algodot

#*****************Wallet UI ************************************
onready var account_address = $wallet_ui/address
onready var ingame_algos = $wallet_ui/ingame_algos
onready var wallet_algos = $wallet_ui/wallet_algos
onready var withdraw_button = $wallet_ui/HBoxContainer/withdraw
onready var refresh_button= $wallet_ui/HBoxContainer/refresh

onready var wallet_ui = $wallet_ui
onready var mnemonic_ui = $mnemonic_ui
onready var transaction_ui = $transaction_ui
onready var txn_ui_options = $transaction_ui/txn_ui_options

onready var address_ui_options = $mnemonic_ui/address_ui_options

onready var nft_asset_id = $transaction_ui/nft
onready var txn_amount = $transaction_ui/amount 
onready var txn_ui_options_button = $transaction_ui/txn_ui_options

onready var NFT= $TextureRect
onready var state_controller = $state_controller
onready var anim = $AnimationPlayer
#*****************************************************

#var status
#var file_checker = File.new() #use FileCheck instead (depreciated)
#onready var python_request=$Node (depreciated)

#************** Algo Variables *************************
var Escrow_account: String #="L5ESENBL23J2GJGM64Y767IXWGBCKXMGS2OGZ3MC5BBGWJAKJJAUK7BJK4"  #should ideally be a smart contract
var Escrow_mnemoic: String
#Not needed, can be gotten from mnemonic alone

var Player_account: String  #="2NFCY7HBAFJ5YP7TXUOFHHMGAZ7AHEXPS5F3NENXSC3WXRVATBR4Y23AUM"
var Player_mnemonic: String 

var Player_account_details: Array =[]
var Player_account_temp: Array =[]

#************Wallet variables**************#

var amount
var address
var mnemonic

var encoded_mnemonic : PoolByteArray
var encrypted_mnemonic 

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


#************Wallet Save Path**********************#
var token_path : String = "user://wallet/account_info.token"
#var keys_path : String = "user://wallet/wallet_keys.cfg"
#var keys_passwrd : PoolByteArray = [1234]

"State Machine"

enum {NEW_ACCOUNT,CHECK_ACCOUNT, SHOW_ACCOUNT, IMPORT_ACCOUNT, TRANSACTIONS ,COLLECTIBLES, SMARTCONTRACTS, IDLE}
export var state = IDLE

var wallet_check : int = 0
var wallet_check_counter : int = 0
#'On/off Switch'
#export (bool) var enabled
#************Helper Booleans ****************************#
var algod_node_exists: bool 
var algod_node_health_is_good: bool
var imported_mnemonic : bool = false
var transaction_valid: bool =false

var loaded_wallet: bool= false #fixes looping loading bug
#	Algorand.create_algod_node("TESTNET")


#*************Signals************************************#
signal completed

func _ready():
	
	#*****Txn UI options************#
	txn_ui_options.add_item('Transactions') 
	txn_ui_options.add_item('Assets') 
	
	#**********State Controller Options***********#
	state_controller.add_item("Show Account")
	state_controller.add_item("Check Account")
	state_controller.add_item("New Account")
	state_controller.add_item("Import Account")
	state_controller.add_item("Transactions")
	state_controller.add_item("SmartContacts") #should be a sub of Transactions
	state_controller.add_item('NFT')
	
	
	
	"Mobile UI"
	print ('Screen orientation debug; ',Globals.screenOrientation)
	if Globals.screenOrientation == 1: #SCREEN_VERTICAL is 1
		#anim.play("MOBILE UI")
		
		upscale_wallet_ui()
	#ipfs test (works) # delete later
	#Networking._parse('ipfs://bafybeihhnvmussfrgymhytoykwymzhshgzdfdmshnwapiplmosdzcr4zxi#i')

	"Testing encoded mnemonic"
	# logic to encrpypt
	# load mnemonc
	#convert mnemonic to unicode integers
	#encode converted mnemonic cryptographically
	# save it locally
	
	
	# logic to decrypt
	#load encoded mnemonc
	# crytographically decrypt it
	# convert it from unicode integers to string
	#load it as mnemonic
	
	
	#load_account_info(false)
	
	#print (mnemonic)
	
	# convert mnemonic to bytes
	#encoded_mnemonic.append_array(convert_string_to_binary(mnemonic))
	
	#convert_binary_to_string(encoded_mnemonic) #works
	
	#encrypt(encoded_mnemonic)
	# store mnemonic as a pool byte array 
	#x() # save and print encoded pool byte array

	


func _process(_delta):
	# UI state Processing (works-ish)
	if state_controller.get_selected() == 0:
		state = SHOW_ACCOUNT #only loads wallet once
		
	elif state_controller.get_selected() == 1:
		#wallet_check = 0 # resets the wallet check stopper
		state = CHECK_ACCOUNT
	elif state_controller.get_selected() == 2:
		wallet_check = 0 # resets the wallet check stopper
		state = NEW_ACCOUNT
	elif state_controller.get_selected() == 3:
		wallet_check = 0 # resets the wallet check stopper
		state = IMPORT_ACCOUNT
	elif state_controller.get_selected() == 4:
		wallet_check = 0 # resets the wallet check stopper
		state = TRANSACTIONS
	elif state_controller.get_selected() == 5:
		wallet_check = 0 # resets the wallet check stopper
		state = SMARTCONTRACTS
	elif state_controller.get_selected() == 6:
		wallet_check = 0 # resets the wallet check stopper
		state = COLLECTIBLES
	
	
	## PROCESS STATES (testing)
	
	match state:
		NEW_ACCOUNT: #loads wallet details if account already exists
			
			error_checkers()
			if not algod_node_exists:
				#Make sure an algod node is running or connet to mainnet or testnet
				Algorand.create_algod_node('TESTNET')
				Algorand._test_algod_connection()
				algod_node_exists= true
		
			
			'Generates New Account'
			if not FileDirectory.file_exists(token_path) : # if account info doesn't exist
				
				"Creates Wallet Directory if it doesn't exist"
				create_wallet_directory()
				

				'Generate new Account'
				Algorand.generate_new_account = true
				Player_account_details=Algorand.create_new_account(Player_account_temp)
				
				#wallet_check += 1
				'Gets the Users Wallet Address'
				#Player_account =get_wallet_address_from_mnemonic(Player_account_details[1])
				#Escrow_account =get_wallet_address_from_mnemonic(Escrow_account)
				address= Player_account_details[0]
				mnemonic= Player_account_details[1]
				
				#save_new_account_info(Player_account_details)
				'Attempts saving new account info'
				#breaks
				var dict = {'address': address, 'amount': 0, 'mnemonic': mnemonic}
				
				"saves more account info"
				save_account_info(dict,1, false)
				
				state = SHOW_ACCOUNT
				#wallet_check += 1
			if FileDirectory.file_exists(token_path) :
				state = SHOW_ACCOUNT
				return
	
		#"Try running outside process funtion"
		CHECK_ACCOUNT:  #Works too well. Overprints texts
			#if FileCheck1.file_exists("user://wallet/account_info.token") :
			if wallet_check == 0:
				#Make sure an algod node is running or connet to mainnet or testnet
				if Algorand.algod == null:
					Algorand.create_algod_node('TESTNET')

					
					#var status
				var status : bool
				status= yield(Algorand.algod.health(), "completed")
				
				print ("Status debug: ", status,' ',wallet_check_counter)
				yield(check_wallet_info(),"completed")#ddd
				
				# Escape Current State to Show Account State
				state_controller.select(0) 
				state = SHOW_ACCOUNT
				

		
		SHOW_ACCOUNT: #buggy with state controller
			"it's always load account details when ready"
			if FileCheck1.file_exists("user://wallet/account_info.token")  :
				#use animation player to alter UI
				
				wallet_ui.show()
				mnemonic_ui.hide()
				transaction_ui.hide()
				
				load_account_info(false)
				
				show_account_info(true)
				
			
					#state = GENERATE_ADDRESS
				
			'Handles if account info is deleted'
			if not FileCheck1.file_exists("user://wallet/account_info.token"):
				#Revert to Import account state
				
				push_error('account info file does not exist')
				#state_controller.select(3) #rewrite as a method
				#state = IMPORT_ACCOUNT  #rewrite as a method
			


			return
		IMPORT_ACCOUNT: #works ish. But kinda broken too 
			# hide wallet ui, show mnemonic ui
			#use animation player to alter UI 
			transaction_ui.hide()
			wallet_ui.hide()
			mnemonic_ui.show()
			
			#hide mnemonic characters
			mnemonic_ui.set_secret(true) 
			
			
			var status : bool
			Algorand.create_algod_node("TESTNET")
			
			status= yield(Algorand.algod.health(), "completed")
			
			print ("Status Debug: ", status)
			
			if status && imported_mnemonic:
				#address=(Algorand.algod.get_address(mnemonic))
				#var address : String
				'Cannot convert argument error'
				#address = Algorand.algod.get_address(mnemonic) 
				address = address_ui_options.text 
				#print ("address debug: ", address)
				account_info = {'address': address, 'amount': 0, 'mnemonic': mnemonic}
				
				save_account_info(account_info,1, false)
			
				state_controller.select(0)
			
			if imported_mnemonic  :
				#create algod node
				#Algorand.create_algod_node("TESTNET")
				# save user's mnemonic
				#address = address_ui_options.text
				mnemonic = mnemonic_ui.text
				
				# generate address from mnemonic (causes Lag)
				#address=(Algorand.algod.get_address(mnemonic))
				# save address 
				'savins imported account info'
				
				#print(address)
				account_info = {'address': address, 'amount': 0, 'mnemonic': mnemonic}
				
				"saves more account info"
				save_account_info(account_info,1, false)
				
				
				# check account and saves automatically
				check_wallet_info()
				
				
				
				# show account
				state = SHOW_ACCOUNT
				
			#if address == null && mnemonic != null:
			#	state = GENERATE_ADDRESS
				
			pass
		TRANSACTIONS:
			#hide other ui states
			#use animation player to alter UI
			transaction_ui.show()
			mnemonic_ui.hide()
			wallet_ui.hide()
			
			txn_amount.hide()
			nft_asset_id.hide()
			
			" Swtiches Between Assets and Normal Transactions UI"
			if txn_ui_options.get_selected() == 0:
				txn_amount.show()
				nft_asset_id.hide()
				if transaction_valid && txn_amount.text != "": #user selected normal transactions

					Algorand.create_algod_node("TESTNET")
					var recievers_addr = transaction_ui.text
					var _amount = txn_amount.text
					Algorand._send_asset_transfers_to_receivers_address(mnemonic,recievers_addr, _amount)
				
			if txn_ui_options.get_selected() == 1:
				txn_amount.hide()
				nft_asset_id.show()
				if transaction_valid : # user selected asset transaction
					Algorand.create_algod_node("TESTNET")
					var _asset_id =nft_asset_id.text
					var recievers_addr = transaction_ui.text
					
					Algorand.transferAssets(mnemonic, recievers_addr,_asset_id)
			
			pass
			
		# implement regex for parsing collectibles ipfs url 
		COLLECTIBLES: #Buggy #should  handle only 1 nft
			"Checks if the Image is avalable Locally and either downloads or loads it"
			if not FileCheck3.file_exists("user://wallet/img0.png"): #works
				print('NFT image is not available locally, Downloading now') 
				
				#************NFT Logic***********#
				# check asset id for its url
				# save asset-id url locally
				#load assets id url from memory 
				#download asset image throug ipfs web2 gate (implemented in networking)
				# parse asset uri to remove "ipfs://" link name
				#save image locally
				#run image check
				#load image
				
				# Connects the Networking signal
				connect_signals()
				debug_signal_connections()
				'theres a problem with the network connection'
				'my server isnt serving the json file to godot properly'
				"using python instead"
				
				#image url should be gotten from asset-id
				
				print ('nft host site',image_url) #image_url should not be null
				Networking.url=image_url
				 
				#makes a https request to download image from local server
				
				Networking. _connect_to_ipfs_gateway(image_url) 
				#***************************************************************
			elif FileCheck3.file_exists("user://wallet/img0.png"):
					load_local_image_texture()
			else: return
		SMARTCONTRACTS: # doesnt work #opts into smart contracts with wallet
			#hide other ui states
			#use animation player to alter UI
			transaction_ui.show()
			mnemonic_ui.hide()
			wallet_ui.hide()
			
			txn_amount.hide()
			nft_asset_id.hide()
			txn_ui_options.hide()
			if transaction_valid:
				print (" Opt into Smartcontract")
			
			pass
		
		IDLE:
			set_process(false)
			pass
		
		#GENERATE_ADDRESS: #doesnt work
		#	if address == null:
		#		if mnemonic != null :
		#			if Algorand.algod != null:
		#				address=(Algorand.algod.get_address(mnemonic))
		#				print ("address debug: ",address) #for debug purposes only
		#				#save generate address to local storage
		#			elif Algorand.algod == null:
		#				Algorand.create_algod_node('TESTNET')
		#				address=(Algorand.algod.get_address(mnemonic))
						
		#				print ("address debug: ",address) #for debug purposes only
						#save generate address to local storage
			pass

# Uses Connection Health to check Account info
func check_account(): # works
#if wallet_check == 0:
	#Make sure an algod node is running or connet to mainnet or testnet
	if Algorand.algod == null:
		Algorand.create_algod_node('TESTNET')
	
	wallet_check_counter+= 1
	#var status
	var status : bool
	status= yield(Algorand.algod.health(), "completed")
	
	print ("Status debug: ", status,' ',wallet_check_counter)
	check_wallet_info()
	
	if status:
		print ("sadgnasdknslgknsalgk")
	#wallet_check += 1
#	if status: #testing using a method instead
#		check_wallet_info() 
#		(print ("----wallet check done------"))
#		return 0;

#loads from saved account info 
func show_account_info(load_from_local_wallet: bool): 
	"load from local wallet"
	if load_from_local_wallet == true && loaded_wallet == false: 
		#account_address.text = str(Globals.address)
		#looping bug : fix is bolean
		account_address.text = str(address)
		ingame_algos.text += str (Globals.algos)
		wallet_algos.text += str(_wallet_algos)
		loaded_wallet = true
		return 
	
	"load from Algorand Node"
	if load_from_local_wallet== false:
		print ('loading account info from Algorand Blockchain')
		#should load Account info from outside scene
		account_info=(yield(Algorand._check_account_information(Player_account, Player_mnemonic, ""), "completed"))
		account_address.text   = account_info['address']
		ingame_algos.text = str(Globals.algos)
		wallet_algos.text = account_info['amount']

func connect_signals(): #connects all required signals in the parent node
	return Networking.connect("request_completed", self, "_http_request_completed")

func debug_signal_connections()->void:
	#debuggers
	print("Networking Connected: ",Networking.is_connected("request_completed", self, "_http_request_completed"))


func generate_address()-> void:
	address =Algorand.algod.get_address(mnemonic)
	print ('address; ', address)
	



#saves account information to a dictionary
#i don't know what number does ngl. It jusst works, lol
func save_account_info( info : Dictionary, number: int, assets: bool): 
	var save_game = File.new() #change from save game
	save_game.open(token_path, File.WRITE)
	var save_dict = {}
	#save_dict= info #saves the raw dictionary
	if not assets:
		save_dict.address =info["address"]
		save_dict.amount =info["amount"]
		
		# encode mnemonic
		save_dict.mnemonic = convert_string_to_binary(mnemonic)  #saves mnemonic as string error
	
	#************Use Assets parameter ,Disabling for now*******************************#
	if assets:
		save_dict.asset_index =info["created-assets"][number]["index"]
		save_dict.asset_name = info["created-assets"][number]["params"]["name"]
		save_dict.asset_unit_name = info["created-assets"][number]["params"]['unit-name']
		save_dict.asset_url = info["created-assets"][number]['params']['url'] #asset Uro and asset uri are different. Separate them
	
	save_game.store_line(to_json(save_dict))
	save_game.close()
	
	print ("saved account info")




func load_account_info(check_only=false):
	if !loaded_wallet:
		var save_game = File.new()
		
		if not save_game.file_exists(token_path):
			return false
		
		save_game.open(token_path, File.READ)
		
		var save_dict = parse_json(save_game.get_line())

		if typeof(save_dict) != TYPE_DICTIONARY:
			return false
		if not check_only:
			_restore_wallet_data(save_dict)
	

func _restore_wallet_data(info: Dictionary):
	# JSON numbers are always parsed as floats. In this case we need to turn them into ints
	address = str(info.address)

	
	Globals.address = info.address
	
	#decode mnemonic
	#fixes string conversion error with regex
	
	
	mnemonic = convert_binary_to_string(info.mnemonic)
	_wallet_algos = info.amount 
	
	#***********Disabling for now*****************#
	#asset_name = str (info.asset_name) 
	#asset_url = str(info.asset_url) #asset url and asset meta data are different
	
	
	print ('wallet data restored from local database')
	
	print ("mnemonic load debug: ",mnemonic) #for debug purposes only




func check_is_image_avalable_()-> bool:
	if local_image_path != '':
		"Checks if image file is available"
		var file_check = ResourceLoader
		var _r = file_check.exists(local_image_path, "ImageTexture")
		#print ("Is local image available: ", _r) #for debug purposes only
		is_image_available_at_local_storage = _r
	return is_image_available_at_local_storage

'Downloads NFT Image from IPFS'
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


func check_wallet_info(): #works. Pass a variable check
	if address != null && mnemonic != null:
		account_info = yield(Algorand.algod.account_information(address), "completed")
		save_account_info(account_info, 0, false) #testing
	else : 
		push_error('Either address or mnemonic cannot be null')
		print ("check info Address debug: ",address)
		print ("check info Mnemonic debug: ", mnemonic)
	print (account_info) 
	
	emit_signal('completed')
	#increases a wallet check timer
	wallet_check += 1

func _on_withraw(): #withdraws Algos from wallet data into my test algorand wallet
	var status
	if Globals.algos != 0: #cannot withdraw with zero balance
		Algorand.create_algod_node() #from an escrow account
		
		status = status && yield(Algorand._send_transaction_to_receiver_addr(Escrow_mnemoic ,"rigid steak better media circle nothing range tray firm fatigue pool damage welcome supply police spoon soul topic grant offer chimney total bronze able human", Globals.algos), "completed") #works
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
	if FileDirectory.file_exists("user://wallet/account_info.token"):
		FileCheck1.open('user://wallet/account_info.token',File.READ)
		if FileCheck1.get_len() == 0: #prevents a  0 bytes error
			FileCheck1.close()
			FileDirectory.remove("user://wallet/account_info.token") #use Globals delete function instead
			return

func create_wallet_directory()-> void:
# Creates a Wallet folder.
	if not FileDirectory. dir_exists("user://wallet"):
		FileDirectory.make_dir("user://wallet")
	else: return 


'Encryption and Decryption ALgorithms'
# cryptographically encrypt users mnemonic
func convert_string_to_binary(string : String)-> Array:
	var binary : Array = []
	for i in string:
		binary.append(ord(i))
	#print( 'Encoded Mnemonic: ',binary) #for debug purposes only
	return binary


func convert_binary_to_string(binary : PoolByteArray)-> String:
	var string : String
	string =binary.get_string_from_utf8()
	#print (string)# for debug purposes only
	return string


"UI Buttons"
#increases all UI parents scale for horizontal screens
func upscale_wallet_ui()-> void:
	var newScale = Vector2(0.08, 0.08)
	var newScale2 = Vector2(0.25,0.25)
	var newScale3 = Vector2(1.5,1.5)
	
	wallet_ui.set_scale(newScale) 
	mnemonic_ui.set_scale(newScale2)
	transaction_ui.set_scale(newScale2)
	
	#upscale their childern
	
	for i in wallet_ui.get_children():
		i.set_scale(newScale)
	
	for t in mnemonic_ui.get_children():
		if not t is Timer:
			t.set_scale(newScale3)
	
	#transaction_ui.get_children().set_scale(newScale)
	
	#scale selection button
	state_controller.set_scale(newScale2) #doenst work. Using aniamtion player instead
	pass

func _on_withdraw_pressed():
	Music.play_track(Music.ui_sfx[0])
	_on_withraw()


func _on_Main_menu_pressed():
	Music.play_track(Music.ui_sfx[0])
	return Globals._go_to_title()


func _on_testnetdispenser_pressed():
	return OS.shell_open('https://testnet.algoexplorer.io/dispenser')


#Updates Local Account Info
func _on_refresh_pressed():
	#Algorand.algod.url = "node.testnet.algoexplorerapi.io"
	#print (Algorand.algod.url)
	check_account()
	#check_wallet_info()


#Deletes Local Account Info
func reset()-> void:
	Globals.delete_local_file(token_path)


'Copies Wallet Addresss to Clipboard'
func _on_Copy_address_pressed():
	print ("copied wallet address to clipboard")
	OS.set_clipboard(address) 



'For Importing Mnemonic and Address'
func _on_enter_mnemonic_pressed():
	imported_mnemonic = true


func _on_enter_transaction_pressed():
	transaction_valid = true



