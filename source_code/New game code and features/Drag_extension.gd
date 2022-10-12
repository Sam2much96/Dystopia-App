extends Comics


" Drag and Drop for NFT's"
#extends comic node
# Buggy #flicks around. Im not sure why
# works best with snappy movements
# needs improvement

# Called when the node enters the scene tree for the first time.
func _ready():
	enabled = true
	comics_placeholder = self
	loaded_comics = true
	Kinematic_2d = $KinematicBody2D
	#position = Kinematic_2d.position
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass




func _handle_input_(event): #Works but buggy
	
	"Stops From Processing Mouse Inputs"
	if event is InputEventMouse:
		#return
		pass
	if event in InputEventMouseMotion:
		#return
		pass
	
	if event is InputEventMouseButton && event.doubleclick : #doesnt work
		
		_zoom() #disabled for debugging, enable when done debugging
		return
	
	
	
	if event is InputEventScreenDrag :
		
		
		
		
		target = event.get_position()
		#print ("Drag and Drop Debug: ",target.x, "/",target.y, "can drag", can_drag, ' position: ', Kinematic_2d.position) #for debug purposes only
		print ("Drag and Drop Debug 2: ", Kinematic_2d.position,' Distance debug: ', Kinematic_2d.position.distance_to(target)) #for debug purposes only
		
		return drag(Vector2(round(target.x), round(target.y)), Kinematic_2d.position, Kinematic_2d)
		pass


func _on_TextureRect_gui_input(event):
	_handle_input_(event)
	pass



