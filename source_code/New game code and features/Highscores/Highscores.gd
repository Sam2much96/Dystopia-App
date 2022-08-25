# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Highscores
# Client side implementation of an online highscore system
# To Do:
#(1) Upgrade PHP Section to run on blockchain algorand blockchain using algorand SDK and Algodot (insert script )
# (2) Use GDteal or implement python in godot to use those scripts
# (3) Update enemy drops to be more randomized
# *************************************************

extends Node
"""
A CLIENT SIDE IMPLEMENTATION OF AN ONLINE HIGHSCORE SYSTEM
"""
#This Should run as a child of the Server scene
#It connects to the Highscores.php script and saves 
#data to the online highscores php database
var leaderboard = {}
var http_request : HTTPRequest = HTTPRequest.new()
const SERVER_URL = 'http://localhost/highscore.php'
const SERVER_HEADERS = ['Content-Type: application/x-www-form-urlencoded', "Cache-Control: max-age=0"]
const SECRET_KEY ='1234567890'
var nonce = null
var requesting_queue : Array = []
var is_requesting : bool = false

func _ready():
	randomize()
	
	#connect our request handler
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	
	
func _process(_delta):
	if is_requesting:
		return

	if requesting_queue.empty():
		return

	is_requesting = true
	if nonce == null:
		request_nonce()
	else:
		send_request(requesting_queue.pop_front())

func _http_request_completed(_result,_response_code,_body):# might not be needewd, might use networking singleton instead
	is_requesting = false
	if _result != HTTPRequest.RESULT_SUCCESS:
		printerr("Error w/ connection: " + String(_result))
		return
		
		
	var response_body = _body.get_string_from_utf8()
	# Grab our JSON and handle any errors reported by our php code
	var response = parse_json(response_body)
	if response['error'] != 'none':
		printerr("We returned error: " + response['error'])
		return

	# Check if we were requesting a nonce
	if response ['command'] == 'get_nonce':
		nonce = response['response']['nonce']
		print ("Got nonce: " + response ['response']['nonce'])
		return
	
	# If not requesting a nonce, we handle all other requests here
	print ("Response Body:\n" + response_body)


func request_nonce():
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({"data" : JSON.print({})})
	var body = "command=get_nonce&" + data

	# Make request to the server
	var err = http_request.request(SERVER_URL,SERVER_HEADERS,false, HTTPClient.METHOD_POST, body) #if website starts with https, change false to true, otherwise leave as is
	if err != OK:
		printerr('HTTPRequest error: ' + String(err) )
		return

func send_request( request : Dictionary):
	var client = HTTPClient.new()
	var data = client.query_string_from_dict({"data" : JSON.print(request['data'])})
	var body = "command=" + request["command"] +"&" + data

	# Generate our response nonce
	var cnonce = String(Crypto.new().generate_random_bytes(32)).sha256_text()

	# Generate our security hash
	var client_hash = (nonce + cnonce + body + SECRET_KEY).sha256_text()
	nonce = null

	# Create our custom header for the request
	var headers = SERVER_HEADERS.duplicate()
	headers.push_back("cnonce: " + cnonce)
	headers.push_back("hash: " + client_hash)

	# Make request to the server
	var err = http_request.request(SERVER_URL,SERVER_HEADERS,false, HTTPClient.METHOD_POST, body) #if website starts with https, change false to true, otherwise leave as is

# Check if there were problems
	if err != OK:
		printerr('HTTPRequest error: ' + String(err) )
		return

#Print out result for debugging
	print("Requesting... \n\tCommand: " + request['command'] + "\n\tBody: " + body)

func _get_highscores(): #Gets the top 5 highscore killcount as a dictionary
	var command = "get_scores"
	var data = {"score_offset" : 0, "score_number" : 10}
	requesting_queue.push_back({"command" : command, "data" : data});

func _submit_highscores(): #Saves your highscore and your name to the server
	var score = 0
	var username = ''
	# Generates a random name and score number for Debugging and testing
	var con = "bcdfghjklmnprstvwxyz"
	var vow = "aeiou"
	username = ""
	for _i in range(3 + randi() % 4):
		var string = con
		if _i % 2 == 0:
			string = vow
		username += string.substr(randi() % string.length(), 1)
		if _i == 0:
			username = username.capitalize()
	score - randi() % 1000
	
	var command = "add_score"
	var data = {"score" : score, "username" : username}
	requesting_queue.push_back({"command" : command, "data": data})
	
	
func _display_highsocres():
	pass
