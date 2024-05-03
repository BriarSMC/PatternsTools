class_name ImageData
extends Resource

@export var image_data := {}

func save() -> void:
	ResourceSaver.save(self, "res://data/image_data.tres")
	

static func load_or_create() -> ImageData:
	return ImageData.new()
