# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Coin
# Coin Objects Within the Scene Tree
# To Do:
# (1) Run on Web3
# (2) Proper Documentation
# (3) Should Use $Suds
# *************************************************
# TO DO:
# (1) Fix price api serialisation
#
#
# *************************************************

extends Area2D

class_name coins

"""
Coins
"""

export(String) var item_type = "Coins"
export(int) var amount #microalgos


var status

onready var anims : AnimationPlayer = $anims
onready var timer : Timer = $Timer

onready var sub_nodes : Array = [anims]

func _ready():
	# COnnect Signals
	
	connect("body_entered", self, "_on_Item_body_entered")
	timer.connect("timeout", self, "_on_timer_timeout")
	
	
	anims.play("spawn")
	
	
	anims.play("idle")
	
	

func _on_timer_timeout():
	anims.play("idle")

func _on_Item_body_entered(body): # Priority Process
	if not body is Player: # Guard Clause For Non Player Objects
		return
		
		if amount != null:
			call_deferred("disconnect", "body_entered", self, "_on_Item_body_entered")
			#Inventory.add_item(item_type, amount)
			Globals.algos = Globals.algos + amount #should be Algos instead
			
			
			anims.play("collected")
			Music.play_track("res://sounds/item_collected.ogg")
			
			# Triggers An Escrow Withdrawal - Depreciated for Refactoring
			# Only Calls if user has created an Algo account
			#if Wallet.address && Wallet.mnemonic != null:
			#	# Withdraw from Escrow SmartContract
			#	Wallet.WITHDRAW = true
			## Run Wallet Checks & process withdrawal
			#
			#	Wallet.run_wallet_checks()
			
			# Update Global Algos with 0.005 MIcroAlgos
			Globals.suds += 5_000
			
			self.queue_free()


#func _exit_tree():
#	Utils.MemoryManagement.queue_free_array(sub_nodes)
