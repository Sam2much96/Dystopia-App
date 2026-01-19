# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# The Purpose of this Outside_Level_Properties is
#(1) Simplify this level by listing all the Nodes and Effects Present in this environment
#(2) I want to implement a Loading screen while this level loads. This Node lays the groundwork for that
#(3) It should be able to iterate through all it's sub nodes, read ,preserve their states for sending in < 20 bytes
#
# To Do:
# (1) Create a Sprite Atlas resource file for all resources in the project and code for player spawing
# Bugs:
#
# (1) Frame rate Drop from 60 fps to 5 fps. because of too much Collision objects in the scene (3/3)
#
#
#
# *************************************************

#extends Node2D


"List of FX in Level"
# (1) Blood FX
# (2) Smoke FX
# (3) Flame FX
# (4) Rain FX

"List of Objects present in Level"
# (1) Sign Post
# (2) Puddle
# (3) Items
# (4) Blocks
# (5) Saving Idol
# (6) Enemies
# (7) Player
# (8) Enemy Spawner
# (9) Broken Ship
# (10) Dune Textures
# (11) Dune Collisions
# (12) StoneWalkway
# (13) UI
# (14) Grass & Flowers
# (15) Mushrooms
# (16) World Boundary
# (17) Temple
# (18) Extralife
# (19) Quest Node
# (20) Pond
# (21) Trees

"Objects to Add"
# (1) Dungeons (done
# (2) Projectile sEnemy Type
# (3) Forest Environment (Done)
# (4) Forest Maze
# (5) Forest Exit
# (6) Redesign scene with tilemaps to reduce scene object count (Done)

"Bugs in Level"
# (1) Too many particles emitting at once, creates a performance hog (done)
# (2) Too many AI processes calculating, produced a performance hog (1/2)
# (3) Scene loading scene is long. (2/3)
# (4) Collision Shapes Coliliding Introduces New Bugs (done)
# (5) Scene uses to much RAM  (done)
# (6) Grass object is unimplemented in web port
extends Resource
class_name TileConfig

# each of the tile id's and fuunctions

# warning-ignore:unused_class_variable
export var TILE_CONFIG : Dictionary = {
	1: {"collision" : false, "draw": true}, # desert dune tiles
	2: {"collision" : false, "draw": true }, #skull head tiles
	3: {"collision" : false, "draw": false, "spawn": "res://scenes/props/signpost.tscn"}, # signpost object 
	4:{"collision" : false, "spawn": "res://scenes/props/hole.tscn"}, # hole object
	5: {"collision": true, "spawn": "res://scenes/props/flowers.tscn"}, #flower
	6: {"collision": false, "spawn": "res://scenes/props/Grass.tscn"}, #grass
	7: {}, #small stone
	8: {}, #boulder
	9:{"collision" : true, "draw": true}, # small tree
	10: {"collision": true, "draw":true}, # group of trees
	11: {"collision" : true, "draw": true}, #mushroom big
	12: {},
	13: {},
	14:{},
	21:{"collision":false, "spawn":"res://scenes/items/bomb.tscn"}, # Bomb item
	22: {"collision" : false, "spawn":"res://scenes/items/extra life.tscn"}, # health potion
	23:{"collision": false, "spawn":"res://scenes/items/coins.tscn"}, # coins
	24:{"collision": false, "spawn":"res://scenes/items/Arrow.tscn"}, #arrow item object
	25:{"collision": false, "spawn":"res://scenes/items/bow.tscn"}, #Bow Item
	26:{"collision": false, "draw":false}, # blood sfx tile
	27:{"collision": false, "draw": false}, # water bottle item : to do
	28:{"collision": false, "spawn": "res://scenes/items/ring.tscn"}, # ring item
	
	# Temple exterior, tiles 29-34
	29:{"collision": true, "draw": true},
	34:{"collision": true, "draw": true},
	35: {"collision": false, "spawn": "res://scenes/items/enemy spawner.tscn"}, # enemy spawner
	41:{"collision": false, "spawn": "res://scenes/characters/AarinSideScrolling.tscn"}, #side scrolling player
	42: {"collision": false, "spawn": "res://scenes/characters/Npc CHIEFPRIEST.tscn"},#shaman NPC
	
	#Temple tiles, 43 -48
	43:{},
	44:{},
	45:{"collision": true, "spawn": "res://scenes/Exit/TempleDoor.tscn"}, # Temple Exit Door 
	46:{},
	47:{},
	48:{},
	49:{"collision": false, "spawn":"res://scenes/Exit/House1.tscn"}, # House 1 Exit
	50:{"collision": false, "spawn":"res://scenes/Exit/House2.tscn"}, # house 2 exit
	51:{"collision": false, "spawn":"res://scenes/items/GenericItem.tscn"}, #generic item
	52: {"collision" : false, "spawn": "res://scenes/characters/Aarin.tscn"}, # top down player
	53: {"collision": false, "spawn": "res://scenes/characters/Enemy.tscn"}, #enemy onject
	54:{"collision": false, "spawn": "res://scenes/characters/NPC Merchant.tscn"}, # NPC Merchant
	55:{"collision": false, "spawn": "res://scenes/characters/NpcOldWoman.tscn"}, # Old woman NPC
	56:{"collision": false, "spawn": "res://scenes/Exit/Stairs.tscn"}, #stairs Exit
	
	# 57 -62 more temple tiles
	
	#spaceship exits
	97:{"collision": false, "spawn": "res://scenes/Exit/SpaceShip1.tscn"}, # ship 1
	98:{"collision": false, "spawn": "res://scenes/Exit/SpaceShip2.tscn"} # ship 2
}
