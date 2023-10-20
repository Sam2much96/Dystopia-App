extends Client




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


"CHATS"
func _on_Chat_Button_pressed():
	var _text = $UI/LineEdit.text
	Functions.add_chat(web_client,chat,_text)



func _on_ping_pressed():
	ping()

