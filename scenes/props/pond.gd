extends Area2D


func _ready():
	$pond.hide()

func _on_pond_body_entered(body):
	if body is Player:
		var player_pos = body.get_position()
		var fx_pos = $pond.get_position()
		print ('Pond FX Debug: ', 'Player Position', player_pos, 'Pond Fx Position: ', $pond.get_position())
		#$pond.move_and_slide(  Vector2(player_pos))
		$pond.show()
		$pond.splash()
