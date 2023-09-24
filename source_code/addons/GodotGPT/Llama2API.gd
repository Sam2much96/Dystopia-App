class_name Llama2API

extends HTTPRequest

var replicate_api = ProjectSettings.get_setting("application/config/replicate_api")

var timer

var url
var url2
var headers
var data
var output = ""

# Make the GET request
var response2 = HTTPRequest.new()

# Create a PoolStringArray to store the headers
var _headers = PoolStringArray()
var _headers2 = PoolStringArray()

#var json_headers : String

func _enter_tree():
	# Define the API endpoint and headers
	url = "https://api.replicate.com/v1/predictions"
	
	# Append the Authorization header
	_headers.append("Authorization: Token " + replicate_api)

	# Append the Content-Type header
	_headers.append("Content-Type: application/json")


	# Define the data for the POST request
	data = {
		"version": "35042c9a33ac8fd5e29e27fb3197f33aa483f72c2ce3b0b9d201155c7fd2a287",
		"input": {
			"prompt": "You are a sentient A.I robot named Jim, in a maximum of 75 words, write an Email reminding the recipient about an Open Powerbank recycling project"
		}
	}



func _ready():
	# For testing the API

	self.add_child(response2)
	#_headers2.append(json_headers)
	
	#print_debug(_headers2)
	#Connect Signals
	# POST method
	connect("request_completed",self, "_request_callback")
	
	
	# GET method
	response2.connect("request_completed", self, "_output")
	
	
	chat("what is A.I?")
	pass


func chat(text):
	send_prompt(self, text)



func _request_callback(result, response_code, headers, body) -> void:
	#print_debug("headers", headers)
	if response_code == HTTPClient.RESPONSE_OK or HTTPClient.RESPONSE_CREATED :
		var response = str2var(body.get_string_from_utf8())
		
		
		print_debug("response", response)
		
		
		
		url2 = response["urls"]["get"]

		print_debug(url2)

		#var text = response["choices"][0]["text"].strip_edges()
		#emit_signal("received_response", text)
		
		yield(get_tree().create_timer(10), "timeout")
		
		# Get request
		response2.request(url2, _headers, false, HTTPClient.METHOD_GET)
		
	elif response_code == HTTPClient.STATUS_DISCONNECTED:
		print_debug("not connected to server")
	else:
		var response = str2var(body.get_string_from_utf8())
		print_debug("ERROR: " + str(response_code))
		print_debug("response", response)


func _output(result, response_code, headers, body) -> String:
	print("Prompt Fetched ", response_code)
	
	
	
	if response_code == HTTPClient.RESPONSE_OK:
		var response2 = str2var(body.get_string_from_utf8())
		

		#print_debug(,response2)
		# Print the response
		var output_data = response2["output"]

		for item in output_data:
			# https://replicate.com/meta/llama-2-7b-chat/versions/8e6975e5ed6174911a6ff3d60540dfd4844201974602551e10e9e87ab143d81e/api#ou>
			# print(item, end="")
			output += item
		
		print_debug(output)
	else:
		print(body)
		var response = str2var(body.get_string_from_utf8())
		print_debug("ERROR: " + str(response_code))
		print_debug("response", response)

	
	
	return output
	
	
func send_prompt(request: HTTPRequest, text: String) -> void:


	#print_debug(JSON.print(data))
	#print_debug(JSON.print(headers))

	#print (_headers2)
	request.request(url,_headers , false, HTTPClient.METHOD_POST, JSON.print(data))


	#while request.get_http_client_status()  != HTTPClient.RESPONSE_OK:
	#	yield(get_tree(), "idle_frame")
		
		# Print the response
	#	print(request.get_response_body_as_text())

		# Sleep for 30 seconds so the output is generated
	#	timer.wait_time = 30
	#	yield(timer, "timeout")

		# Define the URL for the second request
		
	
		#while response2.get_status() != HTTPClient.RESPONSE_OK:
		#	yield(get_tree(), "idle_frame")


#	print_debug(JSON.print(data))

#	var error = request.request("https://api.replicate.com/v1/predictions", headers, false ,HTTPClient.METHOD_POST, JSON.print(data)) #, body.get_string_from_utf8()
#	if error != OK:
#		print_debug("An error occurred in the HTTP request.")
#	pass





