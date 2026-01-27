extends KinematicBody
# Bugs:
#(1) movement uses global positin instead of local positin for movement logic

class_name Player_3rd_Person

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")#Vector3.DOWN * 20  # strength of gravity
export (float) var speed = 10.0  # movement speed
export (float) var jump_velocity = 15.0  # jump strength
export (float) var acceleration = 10.0
export (float) var friction = 5.0
export (float) var air_friction = 0.5
export (float) var air_acceleration = 1.0
var sensitivity = 0.2
var min_angle = -80
var max_angle = 90


var look_rot = Vector3.ZERO
var move_dir = Vector3.ZERO
var velocity = Vector3.ZERO
var jump = false
onready var head = $player
onready var rigged_player = $player_rigged/AnimationPlayer

# safely get Global Singletons
onready var safe_TouchScreen = get_node("/root/GameHud").TouchInterface


func _ready():
	print_debug("3d player debug: ", rigged_player)

func _input(event):
	#view rotation
	if event is InputEventMouseMotion:
		look_rot.y -= (event.relative.x * sensitivity)
		look_rot.x -= (event.relative.y * sensitivity)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)
		


	if Input.is_action_just_pressed("roll"):
		jump = true
	if Input.is_action_just_released("roll"):
		jump = false
	pass

func _physics_process(delta):
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	if jump and is_on_floor():
		velocity.y = jump_velocity
	
	if (Input.is_action_pressed("move_up") or 
		Input.is_action_pressed("move_down") or
		Input.is_action_pressed("move_left") or
		Input.is_action_pressed("move_right")
	): 
		
		# keyboard move direction
		move_dir = Vector3(Input.get_axis("move_up","move_down"),0, Input.get_axis("move_right","move_left")).normalized().rotated(Vector3.UP, rotation.y)
	
	if (InputEventMultiScreenDrag or
		InputEventSingleScreenDrag or
		InputEventScreenPinch or
		InputEventScreenTwist or
		InputEventSingleScreenTap or
		InputEventSingleScreenTouch
	):
		# Touchscreen Move Direction
		# bug:
		# (1) breaks keyboard inputs
		move_dir = Vector3(safe_TouchScreen.direction.y, 0, safe_TouchScreen.direction.x)
		
	
	velocity.x = lerp(velocity.x, move_dir.x * speed, acceleration * delta)
	velocity.z = lerp(velocity.z, move_dir.z * speed, acceleration * delta)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	rigged_player.play("Armature|mixamocom|Layer0")

func _process(delta):
		# create a death count to change to 2d overworld scene
	#despawn conditional
	if self.position.y < -20:
		# to do:
		# (1) create and use a scene exit reource + dictionary for storingn viable sences and scen exits
		Globals.current_level = "res://scenes/levels/overworld_1.tscn"
		
		# Global Scene Transition
		Utils.Functions.change_scene_to(Globals.loading_scene, get_tree())
