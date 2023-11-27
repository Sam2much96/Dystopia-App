extends TileMap

func _enter_tree():
	pass


func _ready():
	# Make Global for Procedural Calculations
	Globals.tile_map = self
