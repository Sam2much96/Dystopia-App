# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# The Purpose of this Outside_Level_Properties is
#(1) Simplify this level by listing all the Nodes and Effects Present in this environment
#(2) I want to implement a Loading screen while this level loads. This Node lays the groundwork for that
#(3) It should be able to iterate through all it's sub nodes, read ,preserve their states for sending in < 20 bytes

# Bugs:
#
# (1) Frame rate Drop from 60 fps to 5 fps. because of too much Collision objects in the scene (3/3)
#
#
# *************************************************

extends Node2D


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
# (1) Dungeons
# (2) Projectile sEnemy Type
# (3) Forest Environment (Done)
# (4) Forest Maze
# (5) Forest Exit
# (6) Redesign scene with tilemaps to reduce scene object count (Done)

"Bugs in Level"
# (1) Too many particles emitting at once, creates a performance hog (2/3)
# (2) Too many AI processes calculating, produced a performance hog
# (3) Scene loading scene is long. (2/3)
# (4) Collision Shapes Coliliding Introduces New Bugs
# (5) Scene uses to much RAM 


