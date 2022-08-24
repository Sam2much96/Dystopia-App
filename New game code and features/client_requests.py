#gets a http request from a self hosted python server

from godot import exposed, export
from godot import *

import requests
import ssl

requests.packages.urllib3.disable_warnings()
debug=True


@exposed
class Node2D(Node):
	@export(int)
	def _ready(self):
		try:
			ssl.match_hostname = lambda cert, hostname: True
			response = requests.get('https://192.168.0.104/body.json',verify='/home/samuel/webserver/samuel.pem')
			if debug== True:
				print(response.text) #for debug purposes onlly
			return (response.text)
		except requests.exceptions.RequestException as e:  # This is the correct syntax
			if debug==True:
				print(e)
			return self.queue_free()
			#raise SystemExit(e) #exits the system
