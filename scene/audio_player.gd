extends AudioStreamPlayer


const RETRO_BLIP_15 = preload("res://audio/Retro Blip 15.wav")
const RETRO_BEEEP_06 = preload("res://audio/Retro Beeep 06.wav")
const RETRO_BLIP_07 = preload("res://audio/Retro Blip 07.wav")

@onready var audio_player = $"."



func bad_beep() -> void:
	audio_player.stream = RETRO_BLIP_15
	audio_player.play()

func good_beep() -> void:
	audio_player.stream = RETRO_BEEEP_06
	audio_player.play()
	
func delete_beep() -> void:
	audio_player.stream = RETRO_BLIP_07
	audio_player.play()
