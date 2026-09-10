
# to do
#(1) Implement programmatic collision transitions for this shape
#(2) Implement rigid body state transforms for this object and export it's triggers via signalss

extends Node2D

@onready var collision: CollisionPolygon2D = $RigidBody2D/CollisionPolygon2D

# Half-size constant - change this to match your tile size
# e.g. if tile is 64px, half = 32
const HALF: float = 128.0

func _ready() -> void:
	right_triangle()  # default shape on spawn

func square():
	collision.polygon = PackedVector2Array([
		Vector2(-HALF, -HALF),  # top-left
		Vector2( HALF, -HALF),  # top-right
		Vector2( HALF,  HALF),  # bottom-right
		Vector2(-HALF,  HALF),  # bottom-left
	])

func right_triangle():
	# Right angle sits at bottom-left
	collision.polygon = PackedVector2Array([
		Vector2(-HALF, -HALF),  # top-left
		Vector2( HALF,  HALF),  # bottom-right
		Vector2(-HALF,  HALF),  # bottom-left  ← right angle here
	])

func left_triangle():
	# Right angle sits at bottom-right
	collision.polygon = PackedVector2Array([
		Vector2(-HALF,  HALF),  # bottom-left
		Vector2( HALF, -HALF),  # top-right
		Vector2( HALF,  HALF),  # bottom-right ← right angle here
	])
