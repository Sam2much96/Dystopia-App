# *************************************************
# godot3-Dystopia-game by INhumanity_arts
# Released under MIT License
# *************************************************
# Web Browser
# SHared COnde Between Grass/Flower Objects Within the Scene Tree
#
# Features:
#
# TO DO :
# (1) Parse To Image Hosting Site
#
#
#
# *************************************************


extends Control

class_name WebBrowser

export (bool) var image 

export (String) var website_url #= '' 


 

func _ready():
	get_node("LineEdit").set_text(website_url)

	Networking.url = website_url

	Networking._check_connection(Networking.url, HTTPRequest.new())

	if website_url != '':
		#Networking._check_connection(website_url)
		Networking.request(website_url)
		
		#if Networking.emit_signal("connection_success"):
		Networking.connect("request_completed", self, "_http_request_completed")
			#Networking._http_request_completed(result, response_code, headers, body)

		#else :
		#	pass

func _http_request_completed(result, response_code, headers, body):
	if body.empty() != true:
		#var response =regex('body',(body.get_string_from_ascii ( )))

		var response = body.get_string_from_utf8()

		var _y = regex('title', response)

		print ('Parsing Webpages')
		#print(body)
		
		get_node("Label").set_text(str(_y))
		#get_node("RichTextLabel").set_text(str(_y))
		
		#print(response)
	if body.empty() == true:
		print ('web page '+ Networking.url+ ' is unavailable ')


	Networking.stop_check()

func regex(tag, html, default = ''):
	var regex =RegEx.new()
	#to customize regular expression #regex.compile('<' + tag + "insert regex symbols" + tag + '>')
	regex.compile('<' + tag + ">(.|\nj*?</)" + tag + '>')
	var result = regex.search(html)
	print("Result: ",result)
	if result:
		result.get_string().replace('<' + tag + '>', '')
		result.replace('</' + tag + '>', '')
		return result 
	return default
