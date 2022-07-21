extends Area2D


class_name Bullet


export (int) var speed = 750

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_Bullet_body_entered(body):
	if body is Enemy: # Can attack other enemies
		body.queue_free()
	if body is Player:
		body.hitpoints = body.hitpoints - 1
	queue_free()


func _on_Timer_timeout(): # Stops multiple instance bug
	queue_free()
