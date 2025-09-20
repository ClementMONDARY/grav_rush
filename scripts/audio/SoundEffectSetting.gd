class_name SoundEffect 
extends Resource
## Sound effect resource, used to configure unique sound effects for use with the AudioManager. Passed to [method AudioManager.create_2d_audio_at_location()] and [method AudioManager.create_audio()] to play sound effects.

## Stores the different types of sounds effects available to be played to distinguish them from another. Each new SoundEffect resource created should add to this enum, to allow them to be easily instantiated via [method AudioManager.create_2d_audio_at_location()] and [method AudioManager.create_audio()].
enum SOUND_EFFECT_TYPE {
	ON_PLAYER_DASH, # 0
	ON_PLAYER_WALL_GRAB, # 1
	ON_PLAYER_FOOTSTEP_STONE, # 2
	ON_PLAYER_LAND_STONE, # 3
	ON_PLAYER_JUMP, # 4
	ON_PLAYER_LAND_WOOD, # 5
	ON_DIAMOND_LOOTED, # 6
	ON_PLAYER_FOOTSTEP_WOOD, # 7
	ON_DIAMOND_TRACKER_UPDATED, # 8
	ON_ITEM_PICKUP, # 9
	ON_PLAYER_SWORD_ATTACK_MISS, # 10
	ON_PLAYER_SWORD_ATTACK_HIT_ENNEMY, # 11
	ON_PLAYER_SWORD_ATTACK_HIT_WORLD, # 12
	ON_PLAYER_FOOTSTEP_METAL, # 13
	ON_PLAYER_LAND_METAL, # 14
	ON_WALL_CRACK_STONE, # 15
	ON_WALL_BREAK_STONE, # 16
}

@export_range(0, 10) var limit: int = 5 ## Maximum number of this SoundEffect to play simultaneously before culled.
@export var type: SOUND_EFFECT_TYPE ## The unique sound effect in the [enum SOUND_EFFECT_TYPE] to associate with this effect. Each SoundEffect resource should have it's own unique [enum SOUND_EFFECT_TYPE] setting.
@export var sound_effect: AudioStream ## The audio resource to play.
@export_range(-40, 20) var volume: float = 0 ## The volume of the [member sound_effect].
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0 ## The pitch scale of the [member sound_effect].
@export_range(0.0, 1.0,.01) var pitch_randomness: float = 0.0 ## The pitch randomness setting of the [member sound_effect].
@export var bus: StringName = &"Master" ## The audio bus to use for this sound effect.

var audio_count: int = 0 ## The instances of this [AudioStreamMP3] currently playing.


## Takes [param amount] to change the [member audio_count]. 
func change_audio_count(amount: int) -> void:
	audio_count = max(0, audio_count + amount)


## Checkes whether the audio limit is reached. Returns true if the [member audio_count] is less than the [member limit].
func has_open_limit() -> bool:
	return audio_count < limit


## Connected to the [member sound_effect]'s finished signal to decrement the [member audio_count].
func on_audio_finished() -> void:
	change_audio_count(-1)
