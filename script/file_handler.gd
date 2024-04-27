class_name FileHandler
extends Node

const SRC_DIR := "res://images/new_pictures/"
const DST_DIR := "res://images/pictures/"

func _ready():
	get_image_files()
	
func get_image_files() -> Array:
	var retarr = []
	var dir = DirAccess.open(SRC_DIR)
	var files = dir.get_files()
	for s in files:
		#if not s.contains('.import'):
		if not '.import' in s:
			retarr.append(s)

	retarr.shuffle()
	return retarr

