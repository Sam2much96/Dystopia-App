extends TileMap

func _enter_tree():
	pass


func _ready():
	push_error("Dune Procedural Scene Requires More Optimization")
	
	
	# Make Global for Procedural Calculations
	Globals.tile_map = self
