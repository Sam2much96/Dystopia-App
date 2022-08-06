# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Coin
# Coin Objects Within the Scene Tree
# To Do:
#(1) Run on Web3
# (2) Proper Documentation
# (3) Should Use Algos
# *************************************************

extends Area2D

"""
Coins
"""

export(String) var item_type = "Coins"
export(int) var amount 

onready var algos = $Algodot
var status

func _ready():
	connect("body_entered", self, "_on_Item_body_entered")
	connect("body_entered", self, "_send_algo_transaction") #for algo transaction
	
	pass

func _on_Item_body_entered(body): #kinda buggy -inhumanity
	if body is Player && amount != null:
		call_deferred("disconnect", "body_entered", self, "_on_Item_body_entered")
		#Inventory.add_item(item_type, amount)
		Globals.Suds += amount
		$anims.play("collected")
		#body.emit_signal("health_changed", body.hitpoints)
		yield(get_tree().create_timer(0.8), "timeout")
		$pickup.stop()
	pass


func _send_algo_transaction():
	status = status && yield(algos._send_transaction_to_receiver_addr(funder_address , funder_mnemonic , receivers_address , receivers_mnemonic), "completed") #works
	#status = status && yield(_send_asset_transfers_to_receivers_address(funder_address , funder_mnemonic , receivers_address , receivers_mnemonic), "completed") #works
	print (status)
