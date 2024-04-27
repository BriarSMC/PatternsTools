extends Node


var current_picture := 0

var image_data_res: ImageData 
var image_data := {}

func _ready() -> void:
	image_data_res = ImageData.load_or_create()
	image_data = image_data_res.image_data
	
func save_image_data(data: Dictionary) -> void:
	image_data_res.image_data = data
	image_data_res.save()
