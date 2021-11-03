extends Control

export (bool) var image 

export (String) var website_url #= '' 



func _ready():
	get_node("LineEdit").set_text(website_url)

	Networking.url = website_url

	Networking._check_connection(Networking.url)

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

		var response = body.get_string_from_ascii ( )

		var _y = regex('body', response)

		print ('Parsing Webpages')
		get_node("RichTextLabel").set_text(str(_y))
		
		#print(response)
	if body.empty() == true:
		print ('web page '+ Networking.url+ ' is unavailable ')


	Networking.stop_check()

func regex(tag, html, default = ''):
	var regex =RegEx.new()
	#to customize regular expression #regex.compile('<' + tag + "insert regex symbols" + tag + '>')
	regex.compile('<' + tag + ">(.|\nj*?</)" + tag + '>')
	var result = regex.search(html)
	if result:
		result.get_string().replace('<' + tag + '>', '')
		result.replace('</' + tag + '>', '')
		return result 
	return default
