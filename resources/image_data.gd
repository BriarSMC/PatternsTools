class_name ImageData
extends Resource

@export var image_data := {}

func save() -> void:
	ResourceSaver.save(self, "res://data/image_data.tres")
	

static func load_or_create() -> ImageData:
	var res:  ImageData = load("res://data/image_data.tres") as ImageData
	if not res:
		res = ImageData.new()
	return res
