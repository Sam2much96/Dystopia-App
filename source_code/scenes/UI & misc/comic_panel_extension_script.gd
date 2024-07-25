extends AnimatedSprite2D

class_name comicPanel

"""
The goal of this script is to store and send comic page details 
to the comic class script. 
"""
# TO DO: Implement Polymorphism for all Chapter pages
# It should also synconize data with the word bubble in a way that is playable 

@export var panel : Vector2
@export var word_buble_count : int 

const TotalPageCount : int = 7
var CurrentPage : int

const PageData : Array = [0,1,2,3,4,5,6] # total page count

@export var Chapter_Data : Dictionary = {
	"Word Bubbles": word_buble_count,
	"All Pages" : TotalPageCount,
	"Name" : "Neo Sud, the New South",
	"Current Page": CurrentPage,
}

# Update 
func _process(_delta):
	CurrentPage = get_frame()
	
	# Makes Current Page a Global integer
	Comics_v6.current_page = CurrentPage
	Comics_v6.comics_sprite = self
