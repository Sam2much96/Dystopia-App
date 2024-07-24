extends Comics



func _ready():
	"Load ingame Comics"
	# 
	# Loads GamePlay Comics from GameHUD Comics Instance
	#print_debug(Globals.curr_scene)
	# Bug 1: Instances Comics Twice
	# Bug 2: Comics node is not visibe in Overworld
	
	if (Globals.curr_scene == "Outside" && 
	_loaded_comics == false && 
	comics_sprite == null
	):
		print_debug("-----Loading GamePlay Comics-----")
		comics_sprite =  Functions.load_comics(
			comics[8], 
			memory,
			get_tree(),
			enabled, 
			can_drag, 
			zoom,
			current_frame, 
			Kinematic_2d, 
			self#get_tree().get_root().get_node("root/Outside/GameHUD/Comics")
			)

		# Show Comics
		Functions.show_comics(
			comics_sprite, 
			self,#get_tree().get_root().get_node("root/Outside/GameHUD/Comics"),# cmx_root # should be the game HUD insstead
			self
		)
		
		# Boolean Checker
		_loaded_comics =true
		return _loaded_comics
	
