extends Node2D
## Audio manager node. Inteded to be globally loaded as a 2D Scene. Handles [method create_2d_audio_at_location()] and [method create_audio()] to handle the playback and culling of simultaneous sound effects.
##
## To properly use, define [enum SoundEffect.SOUND_EFFECT_TYPE] for each unique sound effect, create a Node2D scene for this AudioManager script add those SoundEffect resources to this globally loaded script's [member sound_effects], and setup your individual SoundEffect resources. Then, use [method create_2d_audio_at_location()] and [method create_audio()] to play those sound effects either at a specific location or globally.
## 
## See https://github.com/Aarimous/AudioManager for more information.
##
## @tutorial: https://www.youtube.com/watch?v=Egf2jgET3nQ

var sound_effect_dict: Dictionary = {} ## Loads all registered SoundEffects on ready as a reference.

@export var sound_effects: Array[SoundEffect] ## Stores all possible SoundEffects that can be played.

# Dictionary to track currently playing sounds by type
var playing_sounds: Dictionary = {}

func _ready() -> void:
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.type] = sound_effect
		playing_sounds[sound_effect.type] = []  # Initialize an empty list for each sound type


## Plays all sounds of a specific type at a given location, stopping the oldest sound if the limit is reached.
func create_2d_audio_at_location_with_culling(location: Vector2, type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		var sound_effect: SoundEffect = sound_effect_dict[type]
		
		# Check if the limit is reached
		while playing_sounds[type].size() >= sound_effect.limit:
			# Stop the oldest sound
			var oldest_audio = playing_sounds[type].pop_front()
			if oldest_audio:
				oldest_audio.stop()
				oldest_audio.queue_free()
		
		# Play all sounds of this type
		for sound in sound_effects:
			if sound.type == type:
				var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
				add_child(new_2D_audio)
				new_2D_audio.position = location
				new_2D_audio.stream = sound.sound_effect
				new_2D_audio.volume_db = sound.volume
				new_2D_audio.pitch_scale = sound.pitch_scale
				new_2D_audio.pitch_scale += randf_range(-sound.pitch_randomness, sound.pitch_randomness)
				new_2D_audio.finished.connect(self._on_audio_finished.bind(new_2D_audio, type))
				new_2D_audio.play()
				
				# Add the new sound to the tracking list
				playing_sounds[type].append(new_2D_audio)
	else:
		push_error("Audio Manager failed to find setting for type ", type)


## Callback to remove finished sounds from the tracking list
func _on_audio_finished(audio: AudioStreamPlayer2D, type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if playing_sounds.has(type) and audio in playing_sounds[type]:
		playing_sounds[type].erase(audio)
		audio.queue_free()


## Creates a sound effect at a specific location, with optional looping.
func create_2d_audio_at_location(location: Vector2, type: SoundEffect.SOUND_EFFECT_TYPE, loop: bool = false) -> void:
	if sound_effect_dict.has(type):
		for sound in sound_effects:
			if sound.type == type:
				if sound.has_open_limit():
					sound.change_audio_count(1)
					var new_2D_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
					add_child(new_2D_audio)
					new_2D_audio.position = location
					new_2D_audio.stream = sound.sound_effect
					new_2D_audio.volume_db = sound.volume
					new_2D_audio.pitch_scale = sound.pitch_scale
					new_2D_audio.pitch_scale += randf_range(-sound.pitch_randomness, sound.pitch_randomness)
					if loop:
						new_2D_audio.finished.connect(_on_audio_loop.bind(new_2D_audio))
					else:
						new_2D_audio.finished.connect(sound.on_audio_finished)
						new_2D_audio.finished.connect(new_2D_audio.queue_free)
					
					new_2D_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)


## Creates all sound effects of a specific type, with optional looping.
func create_audio(type: SoundEffect.SOUND_EFFECT_TYPE) -> void:
	if sound_effect_dict.has(type):
		for sound in sound_effects:
			if sound.type == type:
				if sound.has_open_limit():
					sound.change_audio_count(1)
					var new_audio: AudioStreamPlayer = AudioStreamPlayer.new()
					add_child(new_audio)
					new_audio.stream = sound.sound_effect
					new_audio.volume_db = sound.volume
					new_audio.pitch_scale = sound.pitch_scale
					new_audio.pitch_scale += randf_range(-sound.pitch_randomness, sound.pitch_randomness)
					new_audio.finished.connect(sound.on_audio_finished)
					new_audio.finished.connect(new_audio.queue_free)
					new_audio.play()
	else:
		push_error("Audio Manager failed to find setting for type ", type)

# Callback to handle manual looping
func _on_audio_loop(audio: AudioStreamPlayer2D) -> void:
	audio.play()
