# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Loading
# (1) Shows a loading screen with a message
# (2) Uses a shader to load
#
# *************************************************



extends ColorRect

class_name loading

@export var VISIBLE : bool

@onready var Progress : ProgressBar = $VBoxContainer/ProgressBar
@onready var Number : Label= $VBoxContainer/Number
@onready var message : Label = $VBoxContainer/Message


@onready var  loading2 : TextureRect = $VBoxContainer/loading2


# related to Github scene
@onready var RestHandler_ = get_parent().get_node_or_null("RestHandler")



func _ready():
	Progress.hide()
	Number.hide()
	
	# Codebase for GitHUB scenes
	if is_instance_valid(RestHandler_):
		RestHandler_._loading = self
	
	
	# COnnect Signals for redundancy errors
	if not is_connected("visibility_changed", Callable(self, "_on_loading_visibility_changed")):
		connect("visibility_changed", Callable(self, "_on_loading_visibility_changed"))


func _input(_event):
	visibility_logic(VISIBLE)

func _on_loading_visibility_changed():
	# connects to a Github node signal
	VISIBLE = visible
	if visible:
		loading2.show()
		loading2.material.set_shader_parameter("speed",5)
	if not visible:
		Progress.hide()
		Progress.set_value(0)
		Number.hide()
		Number.set_text("...")
		loading2.material.set_shader_parameter("speed",0)

func visibility_logic( _visible : bool):
	if _visible:
		loading2.show()
		loading2.material.set_shader_parameter("speed",5)
	if not _visible:
		Progress.hide()
		Progress.set_value(0)
		Number.hide()
		Number.set_text("...")
		loading2.material.set_shader_parameter("speed",0)

# Shows a Progress Bar
func show_progress(value : float , max_value : float):
	Progress.show()
	Progress.set_value(remap(value,0,max_value,0,100))

func hide_progress():
	Progress.hide()

# Shows a Progress Number
func show_number(value : float , ref_value : float, type : String):
	Number.show()
	Number.set_text(str(value)+" "+type+" downloaded (of ~"+str(ref_value)+" "+type+")")

func hide_number():
	Number.hide()
