# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Impact FX
# Impact FX shader Within the Scene Tree
# Linked to Player's Animation
# To Do:
# (1) SHould only impact if player object is colliding with enemy object
#
# Bugs
# (1) FX doesnt center on player. FIx with RestaVectores ( Done)
# *************************************************

extends Node2D

class_name ImpactFX


@export var _impact : bool
@export var power: float #= 1;
@export var maxSize: float #= 3;
@export var offsetDecreaseSpeed: float #= 0.01;
@export var maxOffsetStrength: float #= 0.178;


var currentScale = 0;
var currentOffsetStrength = 0;
var expand = false;
var decreaseStrength = false;

@onready var playerRef = get_tree().get_nodes_in_group('player').pop_front()
# Called when the node enters the scene tree for the first time.
func _ready():
	self.scale = Vector2.ZERO;
	currentOffsetStrength = maxOffsetStrength;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if _impact == true:
		impact()
	
	#self.scale += Vector2.ONE * currentScale;
	if(expand):
		if(self.scale.x < maxSize):
			self.scale += Vector2.ONE * power * delta;
		else:
			expand = false;
			decreaseStrength = true;
	if(!expand && decreaseStrength):
		currentOffsetStrength -= offsetDecreaseSpeed;
		self.material.set_shader_parameter("offsetStrength", currentOffsetStrength);
		if(currentOffsetStrength <=0):
			_resetObject();
			pass;
	pass

#func _input(event): #rewrite to use buttons
#	if event is InputEventMouseButton:
#		shockwave()


#calls the shockwave effects
func impact():  
	if(!expand && !decreaseStrength): 
		#var fx_pos = self.position
		#var player_pos =  playerRef.position
		#self.position = Globals.restaVectores(fx_pos, player_pos)
		#self.position = get_global_mouse_position();
		var x = playerRef.position.x / 100
		var y = playerRef.position.y / 100
		self.position = Vector2(x,y); #player
		expand = true;
		#print ("Fx position", self.position)
		#print ("player position", playerRef.position)
		

func _resetObject():
	self.scale = Vector2.ZERO;
	currentOffsetStrength = maxOffsetStrength;
	self.material.set_shader_parameter("offsetStrength", maxOffsetStrength);
	expand = false;
	decreaseStrength = false;
	_impact = false;
	pass



func is_collision() -> bool :
	# Checks if player and enemy collisions are interacting
	# returns a boolean
	
	return false
