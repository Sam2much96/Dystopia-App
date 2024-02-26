# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Despawn Fx
# 
# Features:
#(1) Emits Despawn smokes and self deletes
# *************************************************


extends CPUParticles2D

class_name DeSpawnFX

@onready var timer : Node = $Timer

func _ready():
	set_timer()
	emitting = true
	#yield(get_tree().create_timer(0.8), "timeout") #causes bug, use timer instead
	return timer.connect("timeout", Callable(self, "queue_free"))


func set_timer()->void:
	timer.one_shot = true
	timer.autostart = true
	timer.start(0.8)


#func _on_Timer_timeout():
#	queue_free()

#func queue_free():
#	self.queue_free()
