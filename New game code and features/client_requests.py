#gets a http request from a self hosted python server

from godot import exposed, export
from godot import *

import requests
import ssl
#import json

requests.packages.urllib3.disable_warnings()

@exposed
class HTTPRequest(Node):
	@export(str)
	def _ready(self):
		
		ssl.match_hostname = lambda cert, hostname: True

		response = requests.get('https://192.168.0.104/body.json',verify='/home/samuel/webserver/samuel.pem')

		return (response.text)


#works
