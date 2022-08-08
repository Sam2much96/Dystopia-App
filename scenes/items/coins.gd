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
export(int) var amount #microalgos


var status

func _ready():
	connect("body_entered", self, "_on_Item_body_entered")
	if Globals.player[0]._ready():
		$anims.play("spawn")
	
	yield(get_tree().create_timer(2),"timeout")
	
	$anims.play("idle")
	

func _on_Item_body_entered(body): #kinda buggy -inhumanity
	if body is Player && amount != null:
		call_deferred("disconnect", "body_entered", self, "_on_Item_body_entered")
		#Inventory.add_item(item_type, amount)
		Globals.algos = Globals.algos + amount #should be Algos instead
		$anims.play("collected")
		Music.play_track("res://sounds/item_collected.ogg")
		#body.emit_signal("health_changed", body.hitpoints)
		yield(get_tree().create_timer(0.8), "timeout")
		$pickup.stop()
	pass


