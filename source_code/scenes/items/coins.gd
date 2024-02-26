# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Coin
# Coin Objects Within the Scene Tree
# To Do:
# (1) Run on Web3
# (2) Proper Documentation
# (3) Should Use Algos
# *************************************************

extends Area2D

class_name coins

"""
Coins
"""

@export var item_type: String = "Coins"
@export var amount: int #microalgos


var status

@onready var anims : AnimationPlayer = $anims
@onready var timer : Timer = $Timer

@onready var sub_nodes : Array = [anims]

func _ready():
	# COnnect Signals
	
	connect("body_entered", Callable(self, "_on_Item_body_entered"))
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
	
	anims.play("spawn")
	
	Networking.start_check_v2(2)
	
	anims.play("idle")
	
	

func _on_timer_timeout():
	anims.play("idle")

func _on_Item_body_entered(body : Player): # Priority Process
	if amount != null:
		call_deferred("disconnect", "body_entered", self, "_on_Item_body_entered")
		#Inventory.add_item(item_type, amount)
		Globals.algos = Globals.algos + amount #should be Algos instead
		
		
		anims.play("collected")
		Music.play_track("res://sounds/item_collected.ogg")
		
		
		# Only Calls if user has created an Algo account
		if Wallet.address && Wallet.mnemonic != null:
			# Withdraw from Escrow SmartContract
			Wallet.WITHDRAW = true
		# Run Wallet Checks & process withdrawal
		
			Wallet.run_wallet_checks()
		
		# Update Global Algos with 0.005 MIcroAlgos
		Globals.algos += 5000
		
		self.queue_free()
		
	else :pass


func _exit_tree():
	Utils.MemoryManagement.queue_free_array(sub_nodes)
