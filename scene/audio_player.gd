extends AudioStreamPlayer


const RETRO_BLIP_15 = preload("res://audio/Retro Blip 15.wav")

@onready var audio_player = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func bad_beep() -> void:
	audio_player.stream = RETRO_BLIP_15
	audio_player.play()
