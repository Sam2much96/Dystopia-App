

extends Monero #It should Extend  MONERO CLASS, BUT THERES A PARSER ERROR

#class_name moner 

#var mnemonic #used to create a wallet from mnemonic seedphrase
@onready var lib_monero #= load("res://addons/monero/monero.gdns").new() #calls the library files
#// create a wallet from a mnemonic phrase
@export (String) var mnemonic 
var monero_wallet
var wallet_restored
var wallet_random
var my_sync_listener
const monero_network_type: String = 'TESTNET' #Use STAGENET for real transactions
var restored_primary: String =''
var balance : int = 0
var unlocked_account_balance : int = 0

var monero #: Monero

#Placeholders
var _x
@onready var _y

func _enter_tree():
	pass


func _create_wallet():
	monero_wallet =wallet_restored 
	wallet_restored = lib_monero.monero_wallet_full.create_wallet_from_mnemonic(
		"MyWalletRestored",                   #// wallet path and name
		"supersecretpassword123",             #// wallet password
		monero_network_type,        #// network type  #use testnet for testing
		mnemonic,                             #// mnemonic phrase
		lib_monero.monero_rpc_connection(               # // daemon connection
			str("http://localhost:38081"),  #url #Try using Networking Singleton instead
			str("superuser"), #username
			str("abctesting123")), #passwoed
		380104,                               #// restore height
		""                                    #// seed offset
		)

#// synchronize the wallet and receive progress notifications
class monero_wallet_listener :
	 
	func on_sync_progress(height:int,  start_height:int, end_height:int , percent_done, message:String)->void: 
	#// feed a progress bar?
		percent_done = float(percent_done)
		
  
func _ready():
	#_y=GDNativeLibrary.new()
	monero = Monero.new()
	#_x =y.load_once(_x) #lOADING BUG
	my_sync_listener= _x.on_sync_progress()
	wallet_restored = _x.sync(my_sync_listener)
	mnemonic = "hefty value later extra artistic firm radar yodel talent future fungal nutshell because sanity awesome nail unjustly rage unafraid cedar delayed thumbs comb custom sanity"

#// start syncing the wallet continuously in the background
	_x.start_syncing();
	get_balance_account()
	query_transaction_by_hash()

func get_balance_account():
	#// get balance, account, subaddresses
	restored_primary = wallet_restored.get_primary_address();
	balance = wallet_restored.get_balance();    #// can specify account and subaddress indices
	lib_monero.account = wallet_restored.get_account(1, true);      # // get account with subaddresses
	unlocked_account_balance = lib_monero.account.m_unlocked_balance.get(); #// get boost::optional value

func query_transaction_by_hash():
#// query a transaction by hash
	lib_monero.monero_tx_query.tx_query;
	lib_monero.tx_query.m_hash = "314a0f1375db31cea4dac4e0a51514a6282b43792269b3660166d4d2b46437ca"

#pausing the debuggin here and muting all code to sort the already written code out (Query a transaction hash line)

#shared_ptr<monero_tx_wallet> tx = wallet_restored->get_txs(tx_query)[0]; #calls a dictionary or an array
#for (const shared_ptr<monero_transfer> transfer : tx->get_transfers()) {
# # bool is_incoming = transfer->is_incoming().get();
#  uint64_t in_amount = transfer->m_amount.get();
 # int account_index = transfer->m_account_index.get();
#}

func _exit_tree():
	wallet_restored.close(true); wallet_random-.close(true)



