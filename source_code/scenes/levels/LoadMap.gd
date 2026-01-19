# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Load Map Script
# 
# Reads data from the Sprite Atlas Tile Config resource and 
# spawns objects at the tile position
#
# *************************************************

extends TileMap

export(Resource) var tile_config

func _ready():
	if tile_config == null:
		push_error("TileConfig resource not assigned!")
		return
	
	loadMap()

func loadMap():
	# Get all used cells in the tilemap
	var used_cells = get_used_cells()
	
	for cell_pos in used_cells:
		# Get the tile ID at this position
		var tile_id = get_cellv(cell_pos)
		
		if tile_id == -1:
			continue
		
		#print_debug("tile_debug: ", tile_config.TILE_CONFIG)
		if tile_config.TILE_CONFIG.has(tile_id):
			var config = tile_config.TILE_CONFIG[tile_id]
			
			# Check if we should hide the tile
			if config.has("draw") and not config["draw"]:
				set_cellv(cell_pos, -1)  # Erase the cell
			
			# Spawn objects based on tile type
			if config.has("spawn"):
				spawn(cell_pos, config["spawn"])

func spawn(cell_pos: Vector2, object_scene_path: String):
	
	#print_debug("objectg spawn debug: ", object_scene_path)
	# Load and instantiate the object
	var object_scene = load(object_scene_path)
	if object_scene == null:
		push_error("Failed to load scene: " + object_scene_path)
		return
	
	var object_instance = object_scene.instance()
	
	# Position it at the tile's world position
	var world_pos = map_to_world(cell_pos)
	# Add half cell size to center the object on the tile
	world_pos += cell_size / 2
	object_instance.position = world_pos
	
	
	get_parent().call_deferred("add_child", object_instance)
	
	# Optionally remove the tile after spawning
	set_cellv(cell_pos, -1)
