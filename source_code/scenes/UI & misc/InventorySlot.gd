# *************************************************
# godot4-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Inventory Slot
# One cell of the icon based inventory grid ( issue #145 ).
# Shows the item's icon and a stack count, and reports a "use" on click.
# *************************************************

extends Button

signal used(item_type : String)

@onready var _icon : TextureRect = $Icon
@onready var _count : Label = $Count

var item_type : String = ""
var amount : int = 0


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if item_type != "":
		used.emit(item_type)


# Populate the slot. Safe to call before the node is ready.
func set_item(type : String, count : int) -> void:
	item_type = type
	amount = count
	if not is_node_ready():
		await ready
	_icon.texture = Inventory.item_icon(type)
	_count.text = "x%d" % count
	_count.visible = count > 1
	tooltip_text = Inventory.item_display_name(type)
