# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Wallet
# Implements an Algorand Wallet in GDscript
# Parses an image from an NFT url, ising a Networking singleton
# NFT "Non FUungible Token
# To Do:
# (1) Implement Request Page as Asset Optin UI
# (2) Finish implementing Gallery UI + thumbnails
# (7) Test UX
		#- fix check account UX
		#- fix collectibles state (done 2/3) 
#(3) Refactor Codes
#Logic
# It uses the Networking singleton and Algorand library
# to get an asset's url and download the image from
# the asset's meta-data
# asset's url should be read 

#Features
#(1) Curerntly implements on the ALgorand blockchain
# (2) Uses state machine -a Accounts State & -Collectible state & Other states
# (3) Implements Binary > Utf-8 encryption
# (4) Networking Test for Algorand node health, Good internet connection and local img storage
# (5) Drag and Drop Mechanics using custom comics script
# (6) Swipe Gestures using custom comics script
# (7) Animation Player, To fix State Controller button Positioning When changing states
# (8) UI scaling for Mobile & PC screens 
# *************************************************
#Bugs:

#(1) UX is not intuitive.
#(2) NFT drag and Drop is buggy 

# (4) Wallet's Animation UI has Stuck animation transition bug. Use Animation Tree to Activate and Deactivate UI animations
# (5) _process method is buggy (stuck input bug)
# (6) _state_controller's implementation of the process controller method is buggy
# (7) Coin Implementation of Escrow Smart Contract does not work if user doesn't create Testnet account
# (8) Wallet Restore should happen on app boot up

# To-DO:
# (9) Implement 
# (10) IMplement Tokenized characters (player_v2)
# (11) Implement cryptographic encryption and decryption
#
# (17) Delete local NFT's if token is sent
		#logic
		#if asset_url ='' && local_image_texture exists
		#delete local image texture
# (18) Show Asset ID on NFT
		#- Implement Asset UI
# (19) Transfer assets back to Creator Wallet
# (20) Implement Gallery UI for wallet (1/2)
		#-Collectibles UI logic
# (21) Separate Codebase into Reference Classes (Done)
# 
#( 23) Implement NFT asset place functionalities
# (24) Methods cant be called from Other Scenes. (Done)
# (25) Make all methods Static Functions
# (26) Implement Wallet Translations
# *************************************************


extends Control

class_name wallet


var image_url
var json= File.new()
var account_info: Dictionary = {1:[]}
var save_dict: Dictionary = {}

#*****************************************************



#************** Algo Variables *************************


var Player_account: String 
var Player_mnemonic: String 

var Player_account_details: Array =[]
var Player_account_temp: Array =[]

#************Wallet variables**************#

var amount : int
export (String) var address #: String
var mnemonic : String

var recievers_addr : String = '' #for transactions
var _amount : int = 0#for transactions

var _asset_id :int = 0 # used for asset transactions
var smart_contract_addr : String = ""
var _app_id : int = 0
var _app_args : String = ""
var encoded_mnemonic : PoolByteArray
var encrypted_mnemonic 

var _wallet_algos: int
var asset_name : String
var asset_url : String
var asset_index : int
var asset_unit_name : String

#************NFT variables**************#
var _name : String
var _description : String
var _image
#************User Data as a Dictionary*************#
# For easier programmability with Static functions
var UserData : Dictionary = {
	"address": address,
	"mnemonic" : mnemonic,
	"wallet algos" : _wallet_algos
}

#************File Checkers*************#
var FileCheck1= Utils.file #File.new() #checks account info
var FileCheck2= Utils.file #File.new() #checks NFT metadata .json
var FileCheck3= Utils.file #File.new()#checks local image storage
var FileCheck4= Utils.file #File.new() # checks wallet mnemonic


var FileDirectory=Directory.new() #deletes all theon reset


#***********Escrow*****************#
var WITHDRAW : bool = false


#************Wallet Save Path**********************#
var token_write_path : String = "user://wallet/account_info.token" #creating directory bugs out
var token_dir : String = "user://wallet"

export (String) var local_image_path ="user://wallet/img0.png" #Loads the image file path from a folder to prevent redownloads (depreciated)
var local_image_file : String = "user://wallet/img0.png.png" 


#************Wallet Password & Keys **********************#
#var keys_path : String = "user://wallet/wallet_keys.cfg"
#var keys_passwrd : PoolByteArray = [1234]

"State Machine"

enum {NEW_ACCOUNT,CHECK_ACCOUNT, SHOW_ACCOUNT, IMPORT_ACCOUNT, TRANSACTIONS ,COLLECTIBLES, SMARTCONTRACTS, IDLE, PASSWORD, SHOW_MNEMONIC}
export var state = IDLE

var wallet_check : int = 0
var wallet_check_counter : int = 0
var params
var txn_check : int = 0 #stops transaction spamming
#************Helper Booleans ****************************#
var algod_node_exists: bool 
var algod_node_health_is_good: bool
var imported_mnemonic : bool = false
var transaction_valid: bool =false
var asset_id_valid : bool = false
var asset_optin : bool = false
var asset_txn : bool = false


var Asset_UI_showing : bool = false


var password_valid : bool = false
var loaded_wallet: bool= false #fixes looping loading bug
#var good_internet : bool #debugs user's internet Use GLobal Networking.good_internet

var passed_all_connectivity_checks : bool = false #debugs all connectivity checks
var is_image_available_at_local_storage : bool  = FileCheck4.file_exists(local_image_path)
#*************Signals************************************#
signal completed #placehoder signal
#signal transaction #unused signal

#**********************************#

#************ All Used Nodes in Wallet Scene**********************#
#onready var timer = $Timer #depreciated
onready var q = HTTPRequest.new()
onready var q2 = HTTPRequest.new()

 
var Algorand : Algodot
var state_controller : OptionButton

var account_address : Label
var wallet_algos : Label
var ingame_algos : Label
var CreatAccountSuccessful_Mnemonic_Label : Label

var WalletRoot : Control
var dashboard_UI : Control
var passward_UI : Control
var Asset_UI : Control
var smart_contract_UI : Control
var transaction_ui : Control
var mnemonic_ui : Control
var funding_success_ui : Control
var CreatAccountSuccessful_UI : Control
var collectibles_UI : Control

var smartcontract_UI_button : Button 
var txn_txn_valid_button : Button
var funding_success_close_button : Button
var imported_mnemonic_button : Button
var fund_Acct_Button : Button
var make_Payment_Button : Button
var _Create_Acct_button : Button

var canvas_layer : CanvasLayer


var password_Entered_Button : Button
var asset_txn_valid_button : Button
var asset_optin_txn_valid_button : Button
var asset_optin_txn_reject_button : Button
var CreatAccountSuccessful_Copy_Mnemonic_button : Button
var CreatAccountSuccessful_Proceed_home_button : Button

var UI_Elements : Array
var passward_UI_Buttons : Array

var txn_addr : LineEdit
var txn_amount : LineEdit
var nft_asset_id : LineEdit
var mnemonic_ui_lineEdit : LineEdit
var smartcontract_ui_address_lineEdit : LineEdit
var smartcontract_ui_appID_lineEdit : LineEdit
var smartcontract_ui_args_lineEdit : LineEdit

#*****Collectible UI*******#
var NFT : TextureRect
var pfp : TextureRect
var kinematic2d : KinematicBody2D  # for NFT dragNdrop
var NFT_index_label : Label #Displays Asset Index
var Asset_UI_index : Label
var Asset_UI_amount : Label

#*****Password UI******#
var password_LineEdit : LineEdit
var _1 : Button
var _2 : Button
var _3 : Button
var _4 : Button
var _5 : Button
var _6 : Button
var _7 : Button
var _8 : Button
var _9 : Button
var _0 : Button
var zero : Button
var delete_last_button : Button 


# Processor Boolean
var processing : bool


#*****Animation Player******#
var _Animation : AnimationPlayer 
var _Animation_UI : AnimationPlayer
var _Animation_Tree : AnimationTree


# Placeholder Dictionary for creating New Accts
var dict : Dictionary = {'address': address, 'amount': 0, 'mnemonic': mnemonic }


#************ All Unused Nodes in Wallet Scene**********************#
# For easy scaling up and down programmatically
var All_UI_elements : Array = []


# For UI Translations
var UI_Button_Nodes : Array = []
var UI_Label_Nodes : Array = []

# For Performance optimization
var frame_counter : int = 0

"Checks the Nodes connection Between Singleton & UI"
func check_Nodes() -> bool:
	 
	
	#*****************Wallet UI ************************************
	
	"UI elements used in Wallet UX"
	UI_Elements = [
		state_controller, Algorand, dashboard_UI, wallet_algos, ingame_algos, mnemonic_ui,
		mnemonic_ui_lineEdit, txn_txn_valid_button, imported_mnemonic_button, passward_UI, 
		txn_addr, txn_amount, funding_success_ui, funding_success_close_button, smart_contract_UI, 
		smartcontract_ui_address_lineEdit, smartcontract_ui_appID_lineEdit, smartcontract_ui_args_lineEdit,
		smartcontract_UI_button, nft_asset_id, fund_Acct_Button, make_Payment_Button, password_Entered_Button,
		password_LineEdit, collectibles_UI, NFT, kinematic2d, NFT_index_label, _Animation, _Animation_UI, _Animation_Tree ,_Create_Acct_button,
		CreatAccountSuccessful_UI, CreatAccountSuccessful_Mnemonic_Label, CreatAccountSuccessful_Copy_Mnemonic_button,
		CreatAccountSuccessful_Proceed_home_button, Asset_UI, asset_txn_valid_button, asset_optin_txn_valid_button,
		asset_optin_txn_reject_button, pfp, Asset_UI_index, Asset_UI_amount 
	]
	
	passward_UI_Buttons = [_1,_2, _3, _4, _5, _6, _7, _8, _9, _0, zero,delete_last_button]
	
	# UI buttons used for Wallet Translation
	UI_Button_Nodes = [smartcontract_UI_button, txn_txn_valid_button, funding_success_close_button, imported_mnemonic_button,
	fund_Acct_Button, make_Payment_Button, _Create_Acct_button, password_Entered_Button, asset_txn_valid_button, asset_optin_txn_valid_button,
	asset_optin_txn_reject_button, CreatAccountSuccessful_Copy_Mnemonic_button, CreatAccountSuccessful_Proceed_home_button
	]
	
	
	# UI Labels used for Translations
	# Label nodes should have dedicated translations in the diaglous subsystem
	UI_Label_Nodes = [CreatAccountSuccessful_Mnemonic_Label ]
	
	var p : bool
	#checks if any UI element is null
	#works
	for i in UI_Elements:
		if i != null && is_instance_valid(i):
			p = i.is_inside_tree() 
		else: p = false
	return p
func __ready():
	
	#load_account_info(false)
	
	
	
	"Mobile UI"
	print ('Screen orientation debug; ',Globals.screenOrientation)
	if Globals.screenOrientation == 1: #SCREEN_VERTICAL is 1
		#anim.play("MOBILE UI")
		
		#upscale_wallet_ui() #depreciated
		pass
	"PC UI"
	if Globals.screenOrientation == 0 :
		print (" --Scaling UI for Platform " + Globals.os) # for debug purposes only
		
		#Functions.ScaleUI(passward_UI_Buttons, Vector2(1,1))
		pass
	
	#Functions.ScaleUI(UI_Elements, Vector2(5,5))
	
		#*****Txn UI options************#
	if bool(check_Nodes()) == true:
	
		#check if methods exist
		if (self.state_controller.get_item_count() == 0):
			
			#**********State Controller Options***********#
			# State Controller Node would need a font overide for International Languages
			
			
			self.state_controller.add_item("Show Account")
			self.state_controller.add_item("Check Account")
			#self.state_controller.add_item("New Account") # remove from state controller control. Has been mapped to UI button
			self.state_controller.add_item("Import Account")
			self.state_controller.add_item("Transactions")
			self.state_controller.add_item("Smart Contracts") #should be a sub of Transactions
			self.state_controller.add_item('Collectibles')
			self.state_controller.add_item('Login')
			self.state_controller.add_item('Show Mnemonic')
			self.state_controller.add_item('Back')
		print ("HTTP REQUEST NODE: ",typeof(q))
		
		
		
	" Shows Login UI"
	
	#if user first boots app
	if OS.get_ticks_msec() < 10_000: 
		self.state_controller.select(6) #show password login


	
	'Connect and Debug Networking signals'
	Functions.connect_signals(q,q2, self)
	Functions.debug_signal_connections(q, self)

	"Connect buttons"
	"BUTTON PRESSES"
		
		# Disabling for Debugging
		
#		if asset_txn_valid_button.pressed:
#			asset_txn = true
#		if asset_optin_txn_valid_button.pressed:
#			asset_optin = true
#		if asset_optin_txn_reject_button.pressed:
#			print ("asset optin cancelled")
#			return self.state_controller.select(3) # Return to Transaction UI

	
	txn_txn_valid_button.connect("pressed", self, "_on_txn_txn_valid_button_pressed")

	smartcontract_UI_button.connect("pressed", self, "_on_smart_contract_UI_button_pressed")


	password_Entered_Button.connect("pressed", self, "_on_password_entered_pressed")

	CreatAccountSuccessful_Proceed_home_button.connect("pressed", self, "_on_cr8_Acct_Successfull_Homebutton_pressed")
	CreatAccountSuccessful_Copy_Mnemonic_button.connect("pressed", self, "_on_cr8_Acct_Successfull_CopySK_pressed" )

		
		
		
	fund_Acct_Button.connect("pressed", self, "_on_fund_Acct_Button_pressed")
	
#		if make_Payment_Button.pressed:
#			self.state_controller.select(3)
	_Create_Acct_button.connect("pressed", self,"_on_create_acc_button_pressed") # Null Button Error
	imported_mnemonic_button.connect("pressed", self, "_on_mnemonic_pressed")
	funding_success_close_button.connect("pressed", self, "on_funding_success_close")



#			#************PassWord UI**********#
	for i in passward_UI_Buttons:
		i.connect("pressed", self, "_on_pass_buttons_pressed")




	print ("NFT debug: ", NFT)

	"General Wallet Checks"
	run_wallet_checks() #should be used sparingly?


	#connect_buttons() depreciated
	'NFT checks'
	
	"NFT Downloads"
	#if asset_url != "":
	#Networking. _connect_to_ipfs_gateway("ipfs://QmXYApu5uDsfQHMx149LWJy3x5XRssUeiPzvqPJyLV2ABx", q2) 
	

		#*******UI***********#

func _ready():
	self.add_child(q) #add networking node to the scene tree
	self.add_child(q2) #add networking node to the scene tree
	
	
	
	
	if Algorand == null: 
		Algorand = Algodot.new()


	#load_account_info(false)
	
	#print("----loaded acct info------")

func _process(_delta):
	
	frame_counter += 1
	
	if frame_counter > 600:
		frame_counter = 0
		
	# Called Every 60th frame
	if frame_counter % 6 == 0:
		pass
		
	if Globals.curr_scene == "Wallet_scene":
		
		# Get the Wallet Root Scene
		WalletRoot = get_tree().get_nodes_in_group("Wallet").pop_front()
		
		# UI state Processing (works-ish)
		# Remove New Account State. It has a new UI mapping
		"Constantly Running Process Introduces a stuck state Bug"
		if self.state_controller.visible :
			if self.state_controller.get_selected() == 0:
				state = SHOW_ACCOUNT #only loads wallet once
				
			elif self.state_controller.get_selected() == 1:
				#wallet_check = 0 # resets the wallet check stopper
				state = CHECK_ACCOUNT
		#	elif self.state_controller.get_selected() == 2:
		#		wallet_check = 0 # resets the wallet check stopper
		#		state = NEW_ACCOUNT
			elif self.state_controller.get_selected() == 2:
				wallet_check = 0 # resets the wallet check stopper
				state = IMPORT_ACCOUNT
			elif self.state_controller.get_selected() == 3:
				wallet_check = 0 # resets the wallet check stopper
				state = TRANSACTIONS
			elif self.state_controller.get_selected() == 4:
				wallet_check = 0 # resets the wallet check stopper
				state = SMARTCONTRACTS
				
				
				
			elif self.state_controller.get_selected() == 5:
				wallet_check = 0 # resets the wallet check stopper
				state = COLLECTIBLES
			elif self.state_controller.get_selected() == 6:
				wallet_check = 0
				state = PASSWORD
			elif self.state_controller.get_selected() == 7:
				wallet_check = 0
				state = SHOW_MNEMONIC
			elif self.state_controller.get_selected() == 8:
				wallet_check = 0
				Globals.curr_scene = "Menu"
				state = IDLE
				
				loaded_wallet = false
				return Globals._go_to_title() # Breaks wallet scene
	
			elif self.state_controller.get_selected() == -1:
				state = NEW_ACCOUNT
	
	"WALLET STATES"
	
	#if canvas_layer != null: # null pointer Error Fixer
		
	match state:
		NEW_ACCOUNT: #loads wallet details if account already exists
			
			# Reset UI animation for State controller 
			_Animation_UI.play("RESET_UI")
			
			
			'Generates New Account'
			# if account info directory doesn't exist
			# Error Catcher 1
			if not FileDirectory.dir_exists(token_dir): 
				print ("File directory" + token_dir + " doesn't exist") # for debug purposes only
				
				
				"Creates Wallet Directory if it doesn't exist"
				
				
				create_wallet_directory()
			if not FileCheck1.file_exists(token_write_path):
				return save_account_info(dict , 0)
			
			# Error Catcher 3
			if FileCheck1.file_exists(token_write_path):
				'Generate new Account'
				self.Algorand.generate_new_account = true
				Player_account_details=self.Algorand.create_new_account(Player_account_temp)
				
				#wallet_check += 1
				'Gets the Users Wallet Address'
				
				address= Player_account_details[0]
				mnemonic= Player_account_details[1]
					
					#save_new_account_info(Player_account_details)
				'Attempts saving new account info'
					
				var _dict : Dictionary = {'address': address, 'amount': 0, 'mnemonic': mnemonic, 'asset_index': '','asset_name': '','asset_unit_name': '', 'asset_url': '' }
				
				print_debug (_dict)
				
				"saves more account info"
				print (" Save account Info: ",save_account_info(_dict,0))
						
						#dsfsf
					# Exit Process Loop Show Mnemonic
				self.state_controller.select(7)
					
				return self.set_process(false)
				#state = SHOW_ACCOUNT
				#wallet_check += 1
				#if FileDirectory.file_exists(token_dir) :
					#state = SHOW_ACCOUNT
					
					# Exit Process Loop
				#	return self.state_controller.select(0)
				
				# Exit Process Loop to SHow Menm
				#return self.state_controller.select(0)
		CHECK_ACCOUNT:  #Works 
			
			if wallet_check == 0: # stops overflow bug from running processes
				#Make sure an algod node is running or connet to mainnet or testnet
				if self.Algorand.algod == null:
					self.Algorand.create_algod_node('TESTNET')
				var status : bool
				status= yield(self.Algorand.algod.health(), "completed")
				
				if not status :
					print_debug ("Status debug: ", status,' ',wallet_check_counter) #for debug purposes only
				
				# wallet check info returns an integer
				Wallet.check_wallet_info(self.Algorand.algod, UserData, account_info, FileDirectory, token_dir, self) #checks saved wallet variables for error
				
				# Escape Current State to Show Account State
				self.state_controller.select(0) 
				state = SHOW_ACCOUNT
				
		#Loads all wallet details into Memory
		# Entering any other derivative states without 
			# entering show account previously would present new bugs
		SHOW_ACCOUNT: 
				
			var t : Dictionary
			# Reset UI animation for State controller 
			_Animation_UI.play("RESET_UI")
				
				
			"it's always load account details when ready"
				
			if FileCheck1.file_exists(token_write_path)  :
				#use animation player to alter UI
				
				Functions.hideUI(canvas_layer)
				
				self.dashboard_UI.show()
				
				# duplicate of fast load
				if !loaded_wallet:
					#returns a steady steam dictionadt
					
					t = Wallet.load_account_info(false, token_write_path, FileCheck3, UserData)
					
					# fast load
					account_address.text = t.get("address")
					wallet_algos.text = str(t.get("_wallet_algos"))
					 
				
				
				#print (UserData) # For Debug Purposes only
				#load_from_local_wallet: bool, loaded_wallet: bool, account_address : Label, wallet_algos : Label, UserData : Dictionary, Algorand : Algod
				
				# slow load
				var load_from_local_wallet : bool = true
				Functions.show_account_info(load_from_local_wallet, loaded_wallet,account_address, wallet_algos, UserData, Algorand, self)
				
				#set_process(false)
					#state = GENERATE_ADDRESS
					
			'Handles if account info is deleted'
				#buggy on Android
			if not FileCheck1.file_exists(token_write_path) :
				#Revert to Import account state
				
				push_error('account info file does not exist, Import Wallet or generate New One')
				self.state_controller.select(2) 
				
				return
		IMPORT_ACCOUNT: #works 
			
			#gdsfgsfdgdfgsd
			Functions.hideUI(canvas_layer)
			
			
			# Reset UI animation for State controller 
			_Animation_UI.play("RESET_UI")
			
			self.mnemonic_ui.show()
			
			#self.set_process(false)
			
			if imported_mnemonic:
				
				
				'Cannot convert argument error'
				
				mnemonic = self.mnemonic_ui_lineEdit.text
					
				#*******Generates Address************#
				address = generate_address(mnemonic) #works
				
				'savins imported account info'
				
				#FIxes null parameters errors
				account_info = {"address":address, "amount":0, "mnemonic": mnemonic , "created-assets": [{"index": 0, "params":{"clawback":'', "creator":"", "decimals":0, "default-frozen": '', "freeze": '', "manager":"", "name":"Punk_001", "reserve":"", "total":1, "unit-name": 'XYZ', "url":""}}]}
					
					#"saves more account info"
					# Saves acct info & Debugs it to Output
				print ("Saved Acct Info: ",save_account_info(account_info,0)) 
				Wallet.check_wallet_info(self.Algorand.algod, UserData, account_info, FileDirectory, token_dir, self)

					#state = SHOW_MNEMONIC

					#return self.set_process(false)
				return self.state_controller.select(7)
			#Saves transactions to be processed in the ready function
			# Saves the Transaction parameters and runs the txn() function
			# as a subprocess of the _ready() function
			#check https://github.com/lucasvanmol/algodot/issues/20 for more clarifications
		TRANSACTIONS: #Debugging
			#hide other ui states
			#use animation player to alter UI
			Functions.hideUI(canvas_layer)
			self.transaction_ui.show()
			self.transaction_ui.focus_mode = 2
			# Reset UI animation for State controller 
			_Animation_UI.play("RESET_UI")

			
			#transaction_hint.show()
			
			" Swtiches Between Assets and Normal Transactions UI"
				
			if transaction_valid : #user selected normal transactions
					
					#saves transaction details
					#make them into a global variable so changing scenes doesn't reset it
				recievers_addr = self.txn_addr.text
				_amount = int(self.txn_amount.text)
					
					# cannot process any txn less than 10_000 microAlgos
				if _amount  < 100_000:
						
						#should ideally be sent to the UI
					# Use OS alert
					OS.alert("Cannot send balance less than 100_000 MicroAlgos","Alert")
					push_error('Cannot send balance less than 100_000 MicroAlgos')
					
					
					'Error Catcher 1'
						# return to show account
					self.state_controller.select(0)
				if _amount > 100_000 && txn_check == 0:
						
						
						
						#Saves the transaction files to be done
						
						#goes to the title screen to reset ready function
						#state = SHOW_ACCOUNT 
					self.state_controller.select(0) 
						#calls the transaction function which is a child of _ready()
					__ready()
						
					txn_check += 1
					return txn_check
				#uses two different buttons for assets and algo transactions
				
				# Remap asset_id_valid to Asset UI
				# Asset Optin Txn
				
				#Parameters : 
				# Asset optin Txn take 0 Amount as a Parameter with asset ID
				# The wallet address is same as users address & UI linedit is empty
				if asset_optin:
					
					Functions.hideUI(canvas_layer)
					self.Asset_UI.show()
					self.asset_UI_amountLabel. text = amount
					self.asset_UI_ID_Label.text = asset_index
				
					recievers_addr = address
				
					asset_id_valid = true
				# Sends Asset Transactions
				
				#Parameters : 
				# Asset Transaction take 1 or more as an amount parameter
				# THe wallet address is different from the users address
				if asset_txn && _amount >= 1: # user selected asset transaction
					#eee
					_asset_id = int(self.nft_asset_id.text)
					recievers_addr = self.txn_addr.text
					
					
					asset_id_valid = true
					
					#Asset_UI.show()
					
					#change wallet state
					#state = SHOW_ACCOUNT 
					
					#self.state_controller.select(0) 
				if asset_id_valid:
				#calls the transaction function which is a subprocess of _ready() function
					__ready()
					
					
		COLLECTIBLES:
			# Reset UI animation for State controller 
			_Animation_UI.play("RESET_UI")
			
			"Checks if the Image is avalable Locally and either downloads or loads it"
			if wallet_check == 0:
				Functions.hideUI(canvas_layer) 
				collectibles_UI.show()
				if not FileCheck3.file_exists(local_image_file): #works
					
					
					#print('NFT image is not available locally, Downloading now') 
					
					#************NFT Logic***********#
					if wallet_check == 0 && asset_url == '':
						#Make sure an algod node is running or connet to mainnet or testnet
						if self.Algorand.algod == null:
							self.Algorand.create_algod_node('TESTNET')
							#var status
						var status : bool
						status= yield(self.Algorand.algod.health(), "completed")
						if not status:
							print ("Status debug: ", status,' ',wallet_check_counter)
						
						#duplicates check wallet state function
						Wallet.check_wallet_info(self.Algorand.algod, UserData, account_info, FileDirectory, token_dir, self)#saves account info with assets details
						
						# show account
						#self.state_controller.select(0) #Temporarily Disabling
					if asset_url && asset_name != '':
						
						'theres a problem with the network connection'
						'my server isnt serving the json file to godot properly'
						"using python instead"
						
						#image url should be gotten from asset-id
						# some hosted assets might be meta data, 
						#thats why image url is different fromasset-url
						
						#print ("asset url: ", asset_url) #for debug purposes only
						
						image_url=asset_url 
						
						print ('nft host site',image_url) #image_url should not be null
						Networking.url=image_url #disabling for now
						
						#makes a https request to download image from local server
						Networking.start_check(5)
						if not Networking.Timeout && wallet_check == 0 :
							wallet_check += 1
							
							# selet a random IPFS web 2.0 Gateway
							#Networking.genrate_random_gateway()
							
							# implement vaid gateways ass array link
							Networking. _connect_to_ipfs_gateway(false,Networking.url, Networking.gateway[0], q2)  
							#run this download in the __ready function
							__ready()
							return wallet_check
						
							
					#***************************************************************
				if FileCheck3.file_exists(local_image_file) or is_image_available_at_local_storage:
					wallet_check += 1
					
						#connect to wallet NFT logic
						
						#NFT PFP
					NFT_index_label.text = "ID: "+ str(asset_index) + "/" + str(asset_name)
					Asset_UI_index.text = str(asset_index)
					Asset_UI_amount.text = "100,000"
					
					
					
					Comics_v6.load_local_image_texture_from_global(self.pfp, local_image_file, true, 7)
					
					# Disabling Collectibes UI thumbnails
					return Comics_v6.load_local_image_texture_from_global(self.NFT, local_image_file, true,1)
					
				"NFT PFP"
				#if is_image_available_at_local_storage:
					# set image texture
				
					
				#if Asset_UI.is_visible_in_tree():
					# Set Asset ID variables
				
				#pass
					
				#if Comics_v5.is_swiping == true:
				#	collectibles_UI.hide()
				#	Asset_UI.show()
				#else: return
			#opts into smart contracts with wallet
		SMARTCONTRACTS: # doesnt work 
			#hide other ui states
			#use animation player to alter UI
			#opt into counter smart contract deployed to host address
			#try running in ready function
			
			Functions.hideUI(canvas_layer)
			smart_contract_UI.show()
			
			#Play Animation
			if state_controller.get_selected_id() == 4 :# && wallet_check == 0:
				#_Animation_UI.play("SWIPE_UP_UI")
				_Animation_UI.play("REST_UP")
				
			
			if transaction_valid: 
				smart_contract_addr = smartcontract_ui_address_lineEdit.text 
				_app_id = int(smartcontract_ui_appID_lineEdit.text)
				_app_args = smartcontract_ui_args_lineEdit.text
				
				#runs a smart contract deferred function in the ready function
				__ready()
				
				
				self.state_controller.select(0) #check account state 1,  show account state 0
			pass
		
		IDLE:
			set_process(false)
			pass
		PASSWORD:
			#Shows Password UI once app is booted first
			
			# Reset UI animation for State controller 
			#_Animation_UI.play("PASSWORD")
			
			
			Functions.hideUI(canvas_layer)
			
			passward_UI.show()
			
			self.set_process(false)
			
			if password_valid: 
				
				# Revert to dashboard state
				self.state_controller.select(0)
				
		SHOW_MNEMONIC:
			if mnemonic != "":
				Functions.hideUI(canvas_layer)
				
			# Rest Up UI animation for State controller 
				_Animation_UI.play("SHOW_MNEMONIC")
				
				# Show CreatAccountSuccessful UI
				CreatAccountSuccessful_UI.show()
				
				# Display Mnemonic in UI label
				CreatAccountSuccessful_Mnemonic_Label.text = "Mnemmonic : "+ mnemonic
				self.set_process(false)
			elif mnemonic == "":
				# Revert to Import Mnemonic state
				self.state_controller.select(2) 
				return OS.alert("Mnemonic invalid", "Error")

# Uses Connection Health and internet health to check Account info

func run_wallet_checks()-> bool: # works 
	#Make sure an algod node is running or connet to mainnet or testnet
	# should be run in process method to avoid looping bug
	
	#if self.Algorand.algod == null: # Error bug 1
	self.Algorand.create_algod_node('TESTNET')
	
	Functions.check_internet(Networking.good_internet,q)
	
	wallet_check_counter+= 1
	#var status
	var status : bool
	status= yield(self.Algorand.algod.health(), "completed")
	
	print ("Status debug:" , status, wallet_check_counter,  "good internet:", Networking.good_internet)
	
	#calculates suggested parameters for all transactions
	params = yield(self.Algorand.algod.suggested_transaction_params(), "completed") #works
	
	
	if status:
		print ("Node Health is Ok")
	if Networking.good_internet:
		print ('Internet connection is Ok')
	if params != null:
		print ('Suggested Transaction Parameters calculated')
	
	
	
	if status and Networking.good_internet: #prevents app breaking bug
		passed_all_connectivity_checks = true
		pass

	"Checks if image file is available"
	#should delete is assert url is empty string
	if local_image_path != '':
		#"Checks if image file is available"
		is_image_available_at_local_storage = FileCheck4.file_exists(local_image_file)
		print ("Is local image available: ", is_image_available_at_local_storage) #for debug purposes only
		 #= _r
	#return is_image_available_at_local_storage
	'Fixes account token 0 bytes bug'
	if FileDirectory.file_exists(token_write_path ):
		FileCheck1.open(token_write_path ,File.READ)
		if FileCheck1.get_len() == 0: #prevents a  0 bytes error
			FileCheck1.close()
			FileDirectory.remove(token_write_path ) #use Globals delete function instead

	"Load local wallet data"
	if !loaded_wallet:
		var t : Dictionary = Wallet.load_account_info(false, token_write_path, FileCheck3, UserData)
		address = t.get("address", "Null")
		mnemonic = t.get("mnemonic", "Null")
		
		#print ("mnemonic debug 2: ", mnemonic)

	print ("----wallet check done------")
	

	
	#***********Transaction and Smart Contract functions**************#
	call_deferred('txn')
	
	call_deferred('smart_contract')
	
	#Experimental
	#call_deferred("escrow_withdrawal")
	
	#works
	#escrow_withdrawal(params) # works too
	call_deferred("escrow_withdrawal", params)
	return 0;







	# Connect Comics swipe signals
	#if not Comics_v5.is_connected("previous_panel", self, "prev_UI"):
	#	Comics_v5.connect("previous_panel", self, "prev_UI")

	#if not Comics_v5.is_connected("next_panel", self, "next_UI"):
	#	Comics_v5.connect("next_panel", self, "next_UI")



func generate_address(_mnemonic:String)-> String: #works
	
	var _address =self.Algorand.algod.get_address(_mnemonic)
	print ('address; ', _address)
	return _address
	




#saves account information to a dictionary
#i don't know what number does ngl. It jusst works, lol
func save_account_info( info : Dictionary, number: int)-> bool: 
	if not Functions.check_local_wallet_directory(FileDirectory,token_dir):
		push_error('Wallet Directry Not Yet Created.')
		create_wallet_directory()
	
	if FileDirectory.open(token_dir) == OK && Functions.check_local_wallet_directory(FileDirectory,token_dir) :
		FileCheck1.open(token_write_path, File.WRITE)
		#************Use Assets parameter ,Disabling for now*******************************#
		save_dict.address =info["address"] # stops presaved info from deletion
		save_dict.amount =info["amount"]
			
		# encode mnemonic
		save_dict.mnemonic = Encryption.convert_string_to_binary(mnemonic)  #saves mnemonic as string error
		
		# saves if address has assets
		# doesnt account for multiple assets, only saves the first Asset
		if info.has("assets") :
			save_dict.asset_index =  info['assets'][number].get('asset-id')  #info["created-assets"][number]["index"] 
			save_dict.asset_amount = info['assets'][number].get('amount')
			
			# saves if address has created assets
		if info.has("created-assets"):
			save_dict.asset_name = info["created-assets"][number]["params"]["name"] 
			save_dict.asset_unit_name = info["created-assets"][number]["params"]['unit-name']
			save_dict.asset_url = info["created-assets"][number]['params']['url'] #asset Uro and asset uri are different. Separate them
			
		else: pass
		
		
		FileCheck1.store_line(to_json(save_dict))
		FileCheck1.close()
		
		print ("saved account info 1")
		return true
	
			#print ("saved account info")
			#return true
	if not FileDirectory.open(token_dir) == OK: 
		push_error("Error: " + str(FileDirectory.open(token_dir)))
		return false
	return false






'Performs a Bunch of HTTP requests'
#(1) To Check if internet connection is good (works)
# (2) To download Images from IPFS (buggy)
func _http_request_completed(result, response_code, headers, body): #works with https connection
	print (" request done 1: ", result) #********for debug purposes only
	print (" headers 1: ", headers)#*************for debug purposes only
	print (" response code 1: ", response_code) #for debug purposes only
	
	if not body.empty():
		Networking.good_internet = true
	
	
	if body.empty(): #returns an empty body
		push_error("Result Unsuccessful")
		Networking.good_internet = false
		#Networking.stop_check()
	

			
	else: return


func _http_request_completed_2(result, response_code, headers, body): 
	print (" response code 2: ", response_code) #for debug purposes only
	if !body.empty() && !is_image_available_at_local_storage:
	
	#if not is_image_available_at_local_storage: 
		"Should Parse the NFT's meta-data to get the image ink"
		print ('request successful')
			
		"Downloads the NFT image"
		print (" request successful", typeof(body))
			
		
		#check if body is image type
		set_image_(Networking.download_image_(body, local_image_path,q2)) #works
	if body.empty():
		push_error("Problem downloading Image ")


func set_image_(texture):
	if FileCheck3.file_exists(local_image_path):#use file check
		#dowmload image
		self.NFT.set_texture(texture)
		"update Local image"
		print("Image Tex: ",NFT.texture)
		print("Image Format: ",NFT.texture.get_format() )
		print ("Is stored locally: ",is_image_available_at_local_storage)




func _on_reset():
	#should deleta all account details
	print ('----Resetting')
	var a=token_write_path 
	var b=local_image_path
	#var c="res://wallet/wallet_keys.cfg"
	#var d="res://wallet/nft_metadata.json"
	var FilesToDelete=[]#stores all files in an array
	FilesToDelete.append(a,b)
	for _i in FilesToDelete: #looped delete
		var error=FileDirectory.remove(_i)
		if error==OK:
			print ('Deleting Wallet Details')
	return __ready()




func create_wallet_directory()-> void:
# Creates a Wallet folder.
	print (" Creating Wallet Directory")
	if not FileDirectory. dir_exists(token_dir):
		FileDirectory.make_dir(token_dir)
	else: return 



func _on_Main_menu_pressed():
	return Globals._go_to_title()


func _on_testnetdispenser_pressed(): #connect to UI
	_on_Copy_address_pressed() #copy address to clipboard
	#return OS.shell_open('https://testnet.algoexplorer.io/dispenser')
	return OS.shell_open('https://bank.testnet.algorand.network/')


func _on_mnemonic_pressed():
	if imported_mnemonic_button.pressed:
		print("Mnemonic pressed")
		imported_mnemonic = true
		self.set_process(imported_mnemonic)


func on_funding_success_close():
	if funding_success_close_button.pressed :
		reset_transaction_parameters()# fixes double spend bug
		state_controller.select(0) #show account dashboard

func _on_pass_buttons_pressed():
	if state == PASSWORD:
		for i in passward_UI_Buttons:
			if i.pressed:
				password_LineEdit.text += i.text

func _on_password_entered_pressed():
	if password_Entered_Button.pressed:
		password_valid = true
		print ("Password Placeholder entered", password_valid)
		self.set_process(true)


func _on_create_acc_button_pressed():
	if _Create_Acct_button.pressed:
	
		# Fixes Stuck State Bug
		# Check state controller process()
		
		state = NEW_ACCOUNT
		self.state_controller.select(-1)
		#self.state_controller.select(2) #Create Account 
		print ("Create Acct button pressed", state)
		
		#return state


func _on_cr8_Acct_Successfull_Homebutton_pressed():
	if CreatAccountSuccessful_Proceed_home_button.pressed:
		return self.state_controller.select(0) # Show Account

func _on_cr8_Acct_Successfull_CopySK_pressed():
	if CreatAccountSuccessful_Copy_Mnemonic_button.pressed:
		return _on_Copy_mnemonic_pressed()

func _on_txn_txn_valid_button_pressed():
	if txn_txn_valid_button.pressed:
		transaction_valid = true #works
		print ("Txn button pressed: ",transaction_valid) #for debug purposes only


func _on_fund_Acct_Button_pressed():
	if fund_Acct_Button.pressed:
		_on_testnetdispenser_pressed()

func _on_smart_contract_UI_button_pressed():
	if smartcontract_UI_button.pressed: 
		transaction_valid = true
		print ("SmartContract button pressed: ",transaction_valid) #for debug purposes only

#Updates Local Account Info
func _on_refresh_pressed(): #disabling refresh button
	#check_account()
	if passed_all_connectivity_checks:
		Wallet.check_wallet_info(self.Algorand.algod, UserData, account_info,FileDirectory, token_dir, self)
	
	pass
	



'Copies Wallet Addresss to Clipboard'
func _on_Copy_address_pressed():
	print ("copied wallet address to clipboard")
	OS.set_clipboard(address) 



'Copies Wallet Addresss to Clipboard'
func _on_Copy_mnemonic_pressed():
	print ("copied wallet mnemonic to clipboard")
	OS.set_clipboard(mnemonic) 

# State Controller Methods
func off_processing(): 
	return set_process(false)

func on_processing(): 
	return set_process(true)


"Parses Input frm UI buttons"
func _input(event):
	
	if Globals.curr_scene == "Wallet_scene":
		"Collectibles multitouch"
		# (1) Rewrite Zoom to take parameters like drag()
		# (2) Map Pinch , Twist and Tap iput actions in Comics script
		# (3) Upgrade Comics v 5.1 to implement proper gestures and global Swipe Dir indicator
		# (4) Depreciate Wallet Animation for Comics Animation Structure

		
		"Swipe Direction Debug"
		# Should Ideally be in COmics script. Requires rewrite for better structure
		# The current implementation is a fast hack
		if event is InputEventScreenDrag : #kinda works, for NFT Drag & Drop #Disbled for refactoring
			#Networking.start_check(4) #should take a timer as a parameter
			#if Networking.Timeout == false:
			
			
			#Networking.start_check(4)
			
			
			"Swipe Detection"
			
			#Comics_v5.enabled = true
			#_position, enabled: bool, _e : Timer ,swipe_target_memory_x : Array, swipe_target_memory_y : Array 
			
			
			#Comics_v6.Swipe._start_detection(event.position, true, Comics_v6._e ,Comics_v6.swipe_target_memory_x, Comics_v6.swipe_target_memory_y )
			
			
			# End Detection once Networking check has timedout
			
			#sdfhsdfhsdhsdg
			# Swipe Detection SHould SHow A new Aset UI with NFT PFP
			#__position, direction : Vector2, direction_var, _state, _e : Timer, swipe_target_memory_x : Array, swipe_target_memory_y : Array, swipe_start_position : Vector2, swipe_parameters: float, x1,x2,y1,y2,MAX_DIAGONAL_SLOPE
			#__position, direction : Vector2, direction_var, _state, _e : Timer, swipe_target_memory_x : Array, swipe_target_memory_y : Array, swipe_start_position : Vector2, swipe_parameters: float, x1,x2,y1,y2,MAX_DIAGONAL_SLOPE
			
			
			#Comics_v6.Swipe._end_detection(event.position, Comics_v6.direction, Comics_v6.direction_var , Comics_v6._state, Comics_v6._e ,Comics_v6.swipe_target_memory_x, Comics_v6.swipe_target_memory_y,Comics_v6.swipe_start_position, Comics_v6.swipe_parameters, Comics_v6.x1, Comics_v6.x2, Comics_v6.y1, Comics_v6.y2, Comics_v6.MAX_DIAGONAL_SLOPE)
			
			
			"NFT drag and drop"
			#works
			# Disabled for debugging
			#if self.NFT.visible:
				#print ("NFT visible: ",self.NFT.visible)
				
				#Comics_v6.can_drag = self.NFT.visible
				
				# Activates Zoom
				#Comics_v6.loaded_comics = self.NFT.visible
				#Comics_v6.comics_placeholder = self.NFT
				#Comics_v6.drag(event.position, event.position, kinematic2d)
				
				#print_debug("NFT Visible: %s" % [self.NFT.visible])
		
		
			pass
		
		
		#Depreciated
		#
		# Turns on and Off Wallet Processing with Single screen touches
		# 
		# Uses a Timer of 4 seconds to turn processing off
		
		if event is InputEventScreenTouch:#InputEventSingleScreenTouch:
			Networking.start_check(4) #should take a timer as a parameter
			
			
			#Turns processing off for 20 secs
			#if Networking.Timeout == false :
				
			#	print ('Wallet Processing')
			#	self.set_process(true)
			#	processing = false
			#	return processing
			
			
			
			#if Networking.Timeout == true :
			#	
			#	print ('Stopping Wallet Processing')
			#	
			#	self.set_process(false)
			#	processing = false
			#	return processing
		
		
		"BUTTON PRESSES"
		
		# Disabling for Debugging
		# Rewriten as signats to _ready() method


'Processes Algo and Asset Transactions'
func txn(): #runs presaved transactions once wallet is ready
	"MicroAlgo Transactions"
	if recievers_addr != '' && _amount >= 100_000:
		print ('Transaction Debug: ',recievers_addr, '/','amount: ',_amount, '/', 'txn check', txn_check)
		
		yield(self.Algorand._send_txn_to_receiver_addr(params,mnemonic,recievers_addr, _amount), "completed")

		#reset transaction details
		recievers_addr = ''
		_amount = 0
		
		reset_transaction_parameters()
		Functions.hideUI(canvas_layer)
		self.funding_success_ui.show()
	
	"Asset Transactions"
	# Sends Asset Transactions
	
	#Parameters : 
	# Asset Transaction take 1 or more as an amount parameter
	# THe wallet address is different from the users address
	
	if _asset_id != 0 && asset_id_valid  && _amount > 0:
		
		# Parameters
		if recievers_addr != address:
			print (' Asset Txn Debug: ',recievers_addr, '/','asset id: ',_asset_id, '/', 'txn check', txn_check)
		
			#can be used to send both NFT's and Tokens
			yield(self.Algorand.transferAssets(params,mnemonic, recievers_addr,_asset_id, _amount), "completed")
			
			#reset transaction details
			reset_transaction_parameters()
			Functions.hideUI(canvas_layer)
			self.funding_success_ui.show()
		
	"Asset Optin Transactions"
	# Asset Optin Txn
	
	#Parameters : 
	# Asset optin Txn take 0 Amount as a Parameter with asset ID
	# The wallet address is same as users address & UI linedit is empty
	
	if _asset_id != 0 && asset_id_valid && _amount == 0:
		
		
		# Parameters
		if recievers_addr == address:
			
			print (' Asset Txn Debug: ',recievers_addr, '/','asset id: ',_asset_id, '/', 'txn check', txn_check)
			
			#can be used to send both NFT's and Tokens
			yield(self.Algorand.transferAssets(params,mnemonic, recievers_addr,_asset_id, _amount), "completed")
			
			#reset transaction details
			reset_transaction_parameters()
			Functions.hideUI(canvas_layer)
			self.funding_success_ui.show()
	




'Processes Smart Contract NoOp transactions'
func smart_contract(): 
	if transaction_valid && _app_id != 0 && smart_contract_addr != "":
		#check that the address string variable length is valid
		var noOp_txn = self.Algorand.algod.construct_app_call(params, smart_contract_addr, _app_id,_app_args)
	
		print ("NoOp transcation: ",noOp_txn) 
		#print ("opt in transcation: ",noop_txn) #for debug purposes only
	
		# Signs the Raw transaction
		var stx = self.Algorand.algod.sign_transaction(noOp_txn, mnemonic)
		print ("Signed Transaction: ",stx) #shouldn't be null
		var txid = self.Algorand.algod.send_transaction(stx) # sends raw signed transaction to the network
		txid = self.Algorand.algod.send_transaction(stx)
		print ('Tx ID: ',txid)
		
		Functions.hideUI(canvas_layer)
		self.funding_success_ui.show()
		
		self._Animation_UI.play("SUCCESS")
	
	transaction_valid = false
	_app_id = 0
	smart_contract_addr = ""
	return transaction_valid

"Escrow Withdrawals through ABI method calls"
func escrow_withdrawal(params):
	#Experimental Method
	#
	# Should ideally return an tx id and confirmed round
	if WITHDRAW :
		
		Wallet.load_account_info(false, token_write_path, FileCheck3, UserData)
		#FileCheck2.open(token_write_path, File.READ)
		
		# deconstructed load wallet method
		# implement calls to get specific data in the database
		#var save_dict = parse_json(FileCheck2.get_line())
		#_restore_wallet_data(save_dict)
		
		# My Testnet Escrow App
		var app_id : int = 161737986
		
		
		var app_arg = "withdraw"
		
		
		# Async Method
		var p : Dictionary = yield(self.Algorand.algod.construct_atc(params, UserData.get("address"), UserData.get("mnemonic") ,app_id, app_arg ), "completed")
		
		#Implement txid from reference in Algodot
		#var txid = Algorand.algod.execute(t)]
		print_debug("Transaction : ",p) # Prints transaction details
		reset_transaction_parameters()
	else : pass


func _on_enter_asset_pressed(): #depreciated
	asset_id_valid = true


"Resets All Transaction Boolean & String Parameters"
#fixes double spend bug
func reset_transaction_parameters():
	transaction_valid = false
	asset_id_valid = false
	smart_contract_addr = ''
	recievers_addr = ""
	asset_optin = false
	asset_txn = false
	WITHDRAW = false

"Collectibles UI Logic"
# drag and Drop (done)
# comics node implemented (done)
# link with collectibles state
# Gallery View
# Multigesture Swipes for Collectibles Zoom in
# Implement Asset ID UI for Transactions
# Implement Asset Optin UX
#sdfksdlfnskdfnglk
#func _NFT():
	# create and hide buttons depending on the amount of Assets counted
	# Set gallery UI testure button to Asset NFT texture downloaded
	
	# load NFT script as child of Collectubles UI texture react
	
	# load, show and hide NFT's on Button clicks
	# Implement Drag and Drop mechanics
#	pass

"UI Methods as a Class"
class Functions extends Reference:
	# Requires logic to sort calling methods for Different node types
	# Requires Memory Pointers to Wallet Scene Nodes
	# Should loop through all UI elements
	static func ScaleUI(ui_elements : Array,size: Vector2 )-> void: # Works
		for i in ui_elements:
			if i is Control:
				i.set_size(size, false)
				
				
				#for t in i.get_children():
				#	if not t is YSort && not t is Timer && not t is KinematicBody2D && not t is Polygon2D && not t is CanvasLayer:
				#		#print (t)
				#		t.set_size(size, false) # Returns an Array
				
				
				
			#if i is Label:
			#	i.set_size(size, false)




	"UI methods for handling the new Wallet UI"
	static func hideUI(canvas_layer : CanvasLayer)-> void:
		#if canvas_layer.get_child_count() > 0: # Null Ptr error catcher
		#if canvas_layer != null:#canvas_layer.is_inside_tree(): # Null Ptr error catcher
		for i in canvas_layer.get_children():
			i.set_mouse_filter(1)
			i.focus_mode = 0
			i.hide()

	static func showUI(canvas_layer : CanvasLayer)-> void:
		for i in canvas_layer.get_children():
			i.focus_mode = 1
			i.show()



	static func connect_signals(q: HTTPRequest, q2: HTTPRequest, node) : #connects all required signals in the parent node
		print ("Connect Networking Signls please")
		#checks internet connectivity
		if not q.is_connected("request_completed", node, "_http_request_completed"):
			return q.connect("request_completed", node, "_http_request_completed")
			#return q.connect("request_completed", self, "_http_request_completed")

		#checks Image downloader
		if not q2.is_connected("request_completed", node, "_http_request_completed_2"):
			return q2.connect("request_completed", node, "_http_request_completed_2")

	static func connect_signals_statecontroller(t: OptionButton, node ) -> bool :#fixes stuck input bug
		print_debug ("Connect StateCOntroller Signls")
		#checks internet connectivity
		if not t.is_connected("button_up", node, "on_processing"):
			t.connect("button_up", node, "on_processing")
			return t.is_connected("button_up", node, "on_processing")

		if not t.is_connected("button_down", node, "off_processing"):
			t.connect("button_down", node, "off_processing")
			return t.is_connected("button_down", node, "off_processing")

		else : return false

	static func debug_signal_connections(q : HTTPRequest, node)->void:
		#debuggers
		print("Networking Connected: ",q.is_connected("request_completed", node, "_http_request_completed"))
		print ("please connect Networking Signals")


	#Deletes Local Account Info
	static func reset(token_write_path : String)-> void:
		Utils.delete_local_file(token_write_path)

	
	static func check_internet(good_internet : bool ,q : HTTPRequest):
		if !good_internet:
			Networking._check_if_device_is_online(q)


	static func check_local_wallet_directory( FileDirectory : Directory, path : String)-> bool:
		return FileDirectory. dir_exists(path)




	#loads from saved account info 
	static func show_account_info(load_from_local_wallet: bool, loaded_wallet: bool, account_address : Label, wallet_algos : Label, UserData : Dictionary, Algorand : Algodot, wallet_node ) -> void: 
		# Load from Local Wallet Boolean parameters,
		#determine which data source to display user info
		# from
		# Polymorphism

		"load from local wallet"
		if load_from_local_wallet == true && loaded_wallet == false: 
			
			account_address.text = UserData.get("address")
			#self.ingame_algos.text = str (Globals.algos)
			wallet_algos.text = "Algo: "+  str(UserData._wallet_algos)
			
			
			
			loaded_wallet = true
			return loaded_wallet
		
		"load from Algorand Node"
		if load_from_local_wallet== false:
			print ('loading account info from Algorand Blockchain')
			
			var account_info : Dictionary = (yield(Algorand._check_account_information(UserData.address, UserData.mnemonic, ""), "completed"))
			
			if not account_info.empty() :
				account_address.text   = account_info['address']
				#ingame_algos.text = str(Globals.algos)
				wallet_algos.text = account_info['amount']



"Encryption & Decryption Algorithms"
class Encryption extends Reference:
	
	#'Encryption and Decryption ALgorithms'
	# cryptographically encrypt users mnemonic
	static func convert_string_to_binary(string : String)-> Array:
		var binary : Array = []
		for i in string:
			binary.append(ord(i))
		#print( 'Encoded Mnemonic: ',binary) #for debug purposes only
		return binary


	static func convert_binary_to_string(binary : PoolByteArray)-> String:
		var string : String
		string =binary.get_string_from_utf8()
		#print (string)# for debug purposes only
		return string


"Wallet Functions"

class Wallet extends Reference:
	
	static func check_wallet_info(algod_node : Algod, UserData: Dictionary, account_info : Dictionary,FileDirectory : Directory, token_dir : String, wallet_script ) -> int: #works. Pass a variable check
		#check if wallet token exits
		# check if Internet is OK
		#THen checks wallet account information
		
		# Has overflow bug error that corrupts wallet local data
		# Suggested Fix: 
		# (1) Implement Classes as Reference
		# (2) Implement Static Functions 
		
		# String Comparisons are 
		if UserData.address && UserData.mnemonic != "" && Functions.check_local_wallet_directory(FileDirectory,token_dir) && Networking.good_internet : 
			#print (Algorand.algod)
			account_info = yield(algod_node.account_information(UserData.address), "completed")
			#account_info = self.Algorand.algod.account_information(address)
			wallet_script.save_account_info(account_info, 0) #testing  
			print ("acct info: ",account_info) #for debug purposes only 
		if UserData.address == "":
			print ("check info Address debug: ",UserData.address)
			push_error('Either address  cannot be null')
		if UserData.mnemonic == "":
			push_error("mnemonic cannot be null Import Mnemonic or Generate New Account")
			print ("check info Mnemonic debug: ", UserData.mnemonic)
		
		if !Networking.good_internet:
			push_error(" Internet Connection Is Bad")
			Functions.check_internet(Networking.good_internet,Wallet.q)
		
		
		
		wallet_script.emit_signal('completed')
		#increases a wallet check timer
		wallet_script.wallet_check += 1
		return wallet_script.wallet_check

	""

	# Load account info stops escrow withdrawal method from being executed
	# Converting it to Static function as refernce might fix it
	static func load_account_info(check_only: bool, token_write_path : String, FileCheck : File, UserData: Dictionary) -> Dictionary:
		
		# Returns an empty dictionary by default
		var empty = {"": ""}
		#if !loaded_wallet:
		if not FileCheck.file_exists(token_write_path):
			return empty
			
		FileCheck.open(token_write_path, File.READ)
		
		var load_dict = parse_json(FileCheck.get_line())
		if typeof(load_dict) != TYPE_DICTIONARY:
			return empty
		if not check_only:
			#return t
			return _restore_wallet_data(UserData,load_dict)
		return empty


	#address: String, mnemonic : String, _wallet_algos: int , asset_url : String, asset_index : int, asset_name : String, asset_unit_name : String
	"Loads Wallet Variables into Scene Tree Memory"
	# By Modifying a loaded dictionary into the scene tree
	static func _restore_wallet_data(user_data: Dictionary, info: Dictionary ) -> Dictionary:
		# Bugs : It's called repeatedly
		# Need a Paramter so it's only called onnce
		print_debug(info)
		
		# JSON numbers are always parsed as floats. In this case we need to turn them into ints
		user_data.address = info.address
		
		Globals.address = info.address
		
		"decode mnemonic"
		
		user_data.mnemonic = Encryption.convert_binary_to_string(info.mnemonic)
		user_data._wallet_algos = info.amount 
		
		#***********Assets Information*****************#
		
		#asset_name=info.asset_name
		#asset_index=info.asset_index
		#asset_url=info.asset_url
		
		if info.has('asset_index'):
			#asset_amount = int (info.asset_amount)
			user_data.asset_index = info.asset_index
			
		if info.has('asset_name'):
			user_data.asset_name = str (info.asset_name) 
			user_data.asset_url = str(info.asset_url) #asset url and asset meta data are different
			user_data.asset_unit_name = str(info.asset_unit_name)
		
		
		
		
		
		#print ('wallet data restored from local database') # for debug purposes only
		
		#print ("mnemonic load debug: ",user_data.mnemonic) #for debug purposes only
		#print ("asset url debug: ",user_data.asset_url) # for debug purposes only
		
		#print (" User Data Debug 1: ",user_data) # for debug purposes only
		

		# Constantly serves back user data as a dictionary

		#print ("mnemonic load debug: ",user_data.mnemonic) #for debug purposes only
		#print ("asset url debug: ",user_data.asset_url) # for debug purposes only

		return user_data

