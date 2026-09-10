# *************************************************
# godot4-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Load Map Script
# 
# Reads data from the Sprite Atlas Tile Config resource and 
# spawns objects at the tile position
#
# to do:
# (1) add logic that implements rigid body physics + timer for the side scrolling levels
# (2) logic should account for level name and trigger different loading mechanics
# *************************************************
extends TileMapLayer

@export var tile_config : Resource

@onready var levelObject : Array = []

func _ready():
	if tile_config == null:
		push_error("TileConfig resource not assigned!")
		return
	
	loadMap()

func loadMapSideScrolling():
	#logic
	# (1) cycle throught the tileset and get the tile data
	# (2) spawn the Sidescrolling tiles and attach each obhect to the level object
	# (3) create a timer for triggering the entire level's collisions
	
	pass

func loadMap():
	#print_debug("Loading Map Triggered")
	
	# Get all used cells in the tilemap
	var used_cells = get_used_cells()
	#print_debug("Total used cells: ", used_cells.size())
	
	for cell_pos in used_cells:
		# Get the tile data at this position
		var tile_data = get_cell_tile_data(cell_pos)
		
		if tile_data == null:
			continue
		
		# Get atlas coordinates
		var atlas_coords = get_cell_atlas_coords(cell_pos)
		
		# Get the alternative tile ID (this is what you need!)
		var source_id = get_cell_source_id(cell_pos)
		var tile_id = get_cell_alternative_tile(cell_pos)
		
		# If alternative tile is 0, try using atlas coords to find tile ID
		# This assumes your tiles are numbered sequentially in your tileset
		if tile_id == 0:
			# Calculate tile_id based on atlas position in your tileset
			# Assuming tiles are arranged in rows (adjust based on your atlas layout)
			var atlas_size_x = 14  # ADJUST THIS: How many tiles wide is your tileset is i.e how many tiles per row?
			tile_id = atlas_coords.x + (atlas_coords.y * atlas_size_x) + 1  # +1 because your IDs start at 1
		
		#print_debug("Cell: ", cell_pos, " | Atlas: ", atlas_coords, " | Tile ID: ", tile_id)
		
		if tile_config.TILE_CONFIG.has(tile_id):
			var config = tile_config.TILE_CONFIG[tile_id]
			#print_debug("Config found for tile ", tile_id, ": ", config)
			
			# Check if we should hide the tile
			if config.has("draw") and not config["draw"]:
				erase_cell(cell_pos)  # Erase the cell
			
			# Spawn objects based on tile type
			if config.has("spawn"):
				#print_debug("Spawning: ", config["spawn"])
				spawn(cell_pos, config["spawn"])
		else:
			#sprint_debug("No config for tile ID: ", tile_id)
			pass
func spawn(cell_pos: Vector2i, object_scene_path: String):
	#print_debug("Spawning object: ", object_scene_path, " at ", cell_pos)
	
	# Load and instantiate the object
	var object_scene = load(object_scene_path)
	if object_scene == null:
		push_error("Failed to load scene: " + object_scene_path)
		return
	
	var object_instance = object_scene.instantiate()
	
	# Position it at the tile's world position
	var world_pos = map_to_local(cell_pos)
	object_instance.position = world_pos
	
	self.call_deferred("add_child", object_instance)
	
	# Optionally remove the tile after spawning
	erase_cell(cell_pos)
