class_name GamePlay
extends Node2D


#region Description
# Controls the game play
#
#endregion


#region signals, enums, constants, variables, and such

# signals

# enums

# constants

const found_frame = preload("res://scene/found_frame.tscn")


# exports (The following properties must be set in the Inspector by the designer)

@export var picture_area_vertical_offset := 60
@export var overlay_node: Node2D
@export var fh: FileHandler

# public variables

# private variables

var box: Rect2
#var patterns: Array[int]
#var patterns_available: Array[bool]
#var found_count: int
var data := {}
var frames := []
var picture_src 
var files := []
var cur_file := 0
var active: bool
# onready variables

@onready var picture_area := $PictureArea
@onready var picture := $PictureArea/Picture
@onready var file_list := $CanvasLayer/HBoxContainer/Files
#endregion


# Virtual Godot methods

# _ready()
# Called when node is ready
#
# Parameters
#		None
# Return
#		None
#==
# Place the picture in the play area
# Create Rect2 of the picture
# Load the patterns to find and shuffle them
# Arrange the patterns to find boxes on screen
func _ready() -> void:
	#var vp = get_viewport_rect()
	#picture.texture = picture_src
	#picture.region_rect = Rect2(0,0,Constant.PICTURE_WIDTH,Constant.PICTURE_HEIGHT)
	#picture.position.x = vp.end.x / 2.0 - (float(Constant.PICTURE_WIDTH) / 2.0)
	#picture.position.y = picture_area_vertical_offset
	#box = Rect2(picture.position, 
			#Vector2(Constant.PICTURE_WIDTH, Constant.PICTURE_HEIGHT))
	#found_count = 0
	
	active = false
	files = fh.get_image_files()
	for f in files:
		file_list.text += f + "\n"
	cur_file = 0
	if files.size() > 0:
		start_new_picture(files[0])
	
		
# _input(event)
# Look for mouse clicks
#
# Parameters
#	event: InputEvent          	Seconds elapsed since last frame
# Return
#	None
#==

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and 
		event.button_index == MOUSE_BUTTON_LEFT and 
		event.pressed and 
		active): 
		var frame := get_frame_clicked(event.position)
		if frame >= 0:
			var ndx = frames.find(frame)
			if ndx < 0:
				frames.append(frame)
				set_frame_found(frame)			
			else:
				delete_frame_found(frame)
				frames.remove_at(ndx)
				


# Built-in Signal Callbacks


# Custom Signal Callbacks

# Public Methods


# Private Methods

# get_frame_clicked(pos)
# Check if mouse clicked in the picture.
# If so, then return what animation frame was clicked
#
# Parameters
#	pos: Vector2					Mouse position at time of click
# Return
#	int								Frame number corresponding to click position
#	-1								Click wasn't in the picture
#==
# Check if the position is in the box.
# If not, then return -1
# Calculate the frame number and return it
func get_frame_clicked(pos: Vector2) -> int:
	if not box.has_point(pos):
		return -1
		
	var frame_number: int 	
	var boxl = pos.x - box.position.x
	var boxh = pos.y - box.position.y
	var segx: int = boxl / Constant.PATTERN_SIZE
	var segy: int = boxh / Constant.PATTERN_SIZE
	frame_number = segx + (segy * 12)

	return frame_number


func start_new_picture(src: String) -> void:
	var vp = get_viewport_rect()
	picture.texture = load("res://images/new_pictures/" + src)
	picture.region_rect = Rect2(0,0,Constant.PICTURE_WIDTH,Constant.PICTURE_HEIGHT)
	picture.position.x = vp.end.x / 2.0 - (float(Constant.PICTURE_WIDTH) / 2.0)
	picture.position.y = picture_area_vertical_offset
	box = Rect2(picture.position, 
			Vector2(Constant.PICTURE_WIDTH, Constant.PICTURE_HEIGHT))
	active = true
	$CanvasLayer/WorkingOn.text = "Working on: " + src
	frames.clear()
	delete_frame_found(-1)
	
# set_frame_found(frame)
# Player cliced on one of our pattern frames
#
# Parameters
#	frame: int						Frame number found
# Return
#	None
#==
# What the code is doing (steps)
func set_frame_found(frame: int) -> void:
	var posx := frame % Constant.HFRAME_COUNT * float(Constant.PATTERN_SIZE) + float(Constant.PATTERN_SIZE) / 2.0
	var posy := float(frame / Constant.HFRAME_COUNT * Constant.PATTERN_SIZE + float(Constant.PATTERN_SIZE) / 2.0)
	var pos := Vector2(posx, posy)
	var overlay = found_frame.instantiate()
	overlay.position = pos
	overlay.frame_number = frame
	overlay_node.add_child(overlay)

		

func delete_frame_found(frame: int) -> void:
	for o in overlay_node.get_children():
		if o is FoundFrame:
			if o.frame_number == frame or frame == -1:
				o.queue_free()
# Subclasses



func _on_next_btn_pressed():
	active = false
	var data_key := ("%04d" % cur_file)
	data[data_key] = {
		"image" = files[cur_file],
		"pattern_list" = frames.duplicate(),
	}
	
	cur_file += 1
	if cur_file >= files.size():
		print(data)
		Config.image_data = data.duplicate()
		Config.save_image_data(data)
		get_tree().quit()
	else:
		start_new_picture(files[cur_file])
