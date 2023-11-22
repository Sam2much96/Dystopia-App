# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Simulation Version 1
# Handles all Non Player Simulations within the game core loop
#
# *************************************************
# Features:
# (1) Shares Game Code With the Networking, Player& Enemy scripts
# (2) Optimizes Enemy Mob Physics and Processess into a single Script with threads
# *************************************************
# Bugs:
#
# *************************************************

extends Node

class_name Simulationv1


enum {SIMULATING, NON_SIMULATING}

# Frame ID
onready var frame_id : int 

# Frame Counter
onready var frame_counter : int = 0

# Refactored to A Simulation Singleton on Nov 20, 23
# COnnetcs to a Player Input Signal from the Networking Singleton
# Simulates player position on Kinematic body 2d
func poop(id : String, player : Player_v2_networking):

	"Server Simulation Logic"
	# Refactored to A Simulation Singleton on Nov 20, 23
	# Merges Server Player Info to Server Player Info with Peer ID's
	# Trying to get updated positinal data from data packed
	# SHould Ideally be called i the Player Networking script
	# SHould connect to a Networking Signal to optimize performance

	# SHould instead be a physics process method
	
	if Networking.player_info["peer id"].has(id):
			
			

			# position simulation
			#print(Vector2(float(i["peer id"][id_as_string]["position"]["x"]), float(i["peer id"][id_as_string]["position"]["y"]))) # For Debug Purposes only
			
		# should ideally be called in a process method
		# SHould implement position translations using the Networking frame buffer
		player.set_position(Vector2(float(Networking.player_info["peer id"][id]["position"]["x"]), float(Networking.player_info["peer id"][id]["position"]["y"])))
		
		# facing
		self.facing = Networking.player_info["peer id"][id]["facing"]
		
		# State
		
		# roll directin
		
		#linear velocity
		
		# BroadCast Update to all Network Peers
		# 
		Networking.broadcast_world_positions()

func _ready():
	print_debug("Frame ID debug: ",frame_id)

func _process(delta : float):
	
	# Physics Simulation Only happens when Player is Online
	if Networking.GamePlay == Networking.ONLINE:
		
		frame_counter += 1
		
		if (frame_counter) % 12 == 0: # every 12th frame
			frame_id = get_tree().get_frame() # Get the current frame id
			#print_debug(frame_id)
		
		# Reset Frame Counter TO Conserver Memory
		if frame_counter >= 1000:
			frame_counter = 0

func _physics_process(delta):
	pass

static func set_position(x : Vector2):
	pass
