extends TileMap

func _ready():
	# Hacky fix for slow fps on mobiles
	# TIlemap adss to much draw calls for godot engine
	#if Globals.os == "Android":
	#	self.visible = false
	pass
