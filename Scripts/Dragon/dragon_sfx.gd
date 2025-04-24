extends AudioStreamPlayer3D

# clips
const SFX_DICTIONARY = {
	"SLEEPING": 0, 
	"ROAR": 1, 
	"FOOTSTEPS": 2, 
	"WINGS": 3,
	"DEFEATED": 4,
	"QUICK-ROAR": 5,
	"GROUND-IMPACT": 6,
	"ATTACK": 7,
	"FIREBREATH": 8}
	
var sfx

func _ready() -> void:
	sfx = get_stream_playback()
	print(sfx)

func change_sound(clip):
	sfx.switch_to_clip(clip)

func get_currentClip():
	return sfx.get_current_clip_index()
