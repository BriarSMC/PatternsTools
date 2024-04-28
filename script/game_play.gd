class_name GamePlay
extends Node2D


#region Description
# This tool allows the user to go through the list of image files in the 
# new_pictures directory and select what points in the picture will be used
# as patterns. 
#
# When the user does a left click on the image, then we:
#	Draw a box around that spot on the image (pattern),
#	Draw that pattern on the screen for verification purposes, and
#	Add the Rect2 of the pattern to an array.
#
# The user may also use the right mouse button to remove a pattern from the
# image and the pattern array.
#endregion


#region signals, enums, constants, variables, and such

# signals

# enums

# constants

const found_frame = preload("res://scene/found_frame.tscn")


# exports (The following properties must be set in the Inspector by the designer)

@export var picture_area_vertical_offset := 200
@export var overlay_node: Node2D
@export var fh: FileHandler

# public variables

# private variables

var box: Rect2
var data := {}
var frames := []
var picture_src 
var files := []
var cur_file := 0
var active: bool
var frame_count := 0

# onready variables

@onready var picture_area := $PictureArea
@onready var picture := $PictureArea/Picture
@onready var file_list := $CanvasLayer/HBoxContainer/Files
@onready var sub_pic = $SubPic
@onready var audio_player = $AudioPlayer

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
	
	sub_pic.visible = true
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
# Step 1: Exit program on cancel
# Step 2: Check for left mouse button
#	If the mouse position is inside of an existing pattern, then ignore it.
#	Make sure the click is inside the picture image
#	Calculate the pattern box offset
# 	Show the sub-pic image box
#	Set what part of the image to display in the sub-pic box
#	Add that Rect2 to the frames array
#		Hmmm. Seems the Rect2 is in local position while event.position is in global.
#		We need the local position for drawing and such, and global for testing
#		if we've used that square before. So, we store both in the array.
#	Put a blue outline in the main image
# Step 3: Check for right mouse button
#	See if the click was inside of one of our frames
#	If not, then just return
#	Otherwise, delete the frame
func _input(event: InputEvent) -> void:
# Step 1
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
# Step 2	
	if (event is InputEventMouseButton and 
		event.button_index == MOUSE_BUTTON_LEFT and 
		event.pressed and 
		active): 
		if box.has_point(event.position):
			if mouse_in_existing_pattern(event.position) != -1:
				audio_player.bad_beep()
				return
			var xyoffset = Constant.PATTERN_SIZE / 2
			sub_pic.visible = true
			sub_pic.region_rect = Rect2(event.position.x - box.position.x - xyoffset, 
				event.position.y - box.position.y - xyoffset,
				Constant.PATTERN_SIZE, 
				Constant.PATTERN_SIZE)
			frames.append([sub_pic.region_rect, 
				Rect2(event.position.x - xyoffset,
					  event.position.y - xyoffset,
					  Constant.PATTERN_SIZE,
					  Constant.PATTERN_SIZE)])
			set_frame_found(sub_pic.region_rect)
			audio_player.good_beep()
# Step 3
	if (event is InputEventMouseButton and 
		event.button_index == MOUSE_BUTTON_MASK_RIGHT and 
		event.pressed and 
		active):
		var frame: int = mouse_in_existing_pattern(event.position)
		if frame == -1:
			return
		delete_frame_found(frame)
		audio_player.delete_beep()
		
		
# Built-in Signal Callbacks

func _on_next_btn_pressed():
	active = false
	var data_key := ("%04d" % cur_file)
	data[data_key] = {
		"image" = files[cur_file],
		"pattern_list" = frames.duplicate()
	}
	
	cur_file += 1
	if cur_file >= files.size():
		print(data)
		Config.image_data = data.duplicate()
		Config.save_image_data(data)
		get_tree().quit()
	else:
		start_new_picture(files[cur_file])


# Custom Signal Callbacks

# Public Methods


# Private Methods


func start_new_picture(src: String) -> void:
	var vp = get_viewport_rect()
	frame_count = 0
	picture.texture = load("res://images/new_pictures/" + src)
	sub_pic.texture = picture.texture
	picture.region_rect = Rect2(0,0,Constant.PICTURE_WIDTH,Constant.PICTURE_HEIGHT)
	picture.position.x = vp.end.x / 2.0 - (float(Constant.PICTURE_WIDTH) / 2.0)
	picture.position.y = picture_area_vertical_offset
	box = Rect2(picture.position, 
			Vector2(Constant.PICTURE_WIDTH, Constant.PICTURE_HEIGHT))
	active = true
	$CanvasLayer/WorkingOn.text = "Working on: " + src
	frames.clear()
	delete_frame_found(-1)
	
# set_frame_found(rect)
# Player cliced on one of our pattern frames
#
# Parameters
#	rect: Rect2					Position and size of the frame
# Return
#	None
#==
# Create a FoundFrame instance
# Set its position and size to the Rect2 passed to us
# Set the instance's frame_index to the last entry of frames
# Add instance to our tree
# Bump and display the frame count
func set_frame_found(rect: Rect2) -> void:
	var overlay = found_frame.instantiate()
	overlay.position = rect.position
	overlay.rect = rect
	overlay.frame_index = frames.size() - 1
	overlay_node.add_child(overlay)
	frame_count += 1
	$CanvasLayer/FrameCountBox/FrameCount.text = str(frame_count)

		

# delete_frame_found(frame)
# This method removes a frame from they array and screen.
# If frame is -1, then delete all of them
#
# Parameters
#	frame: int						The frame to delete
# Return
#	None
#==
# What the code is doing (steps)
func delete_frame_found(frame: int) -> void:
	printt("Deleting frame: ", frame)
	for o in overlay_node.get_children():
		if o is FoundFrame:
			if o.frame_index == frame or frame == -1:
				o.queue_free()
				frames.remove_at(frame)
				frame_count -= 1
				$CanvasLayer/FrameCountBox/FrameCount.text = str(frame_count)


# mouse_in_existing_pattern(pos)
# Check to see if pos is inside of an existing pattern
#
# Parameters
#	pos: Vectore2					Position to check
# Return
#	int								-1 = Not found
#									Index into the frames array of matching pattern
#==
# Return not found as default
# Loop through the frames array
# Test if any of the entries contains pos
# If so, then return the index into the frames array
func mouse_in_existing_pattern(pos: Vector2) -> int:
	var retval: int = -1
	for i in frames.size():
		if frames[i][1].has_point(pos):
			retval = i
	return retval
	
				
# Subclasses



