extends Node

var debug_1 : bool =false
var debug_python:bool = true
var server_testing= load('res://New game code and features/Server-Client.tscn')

func _ready():
	if debug_1 == true:
		Networking.connect("request_completed", self, "_http_request_completed")
		Networking._check_connection('https://192.168.0.104/body.json')

	var request= server_testing.instance() 
	self.add_child(request)
	

	
	request.queue_free()
func _http_request_completed(result, response_code, headers, body):
	Networking.download_json_(body,"res://testing_json")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
