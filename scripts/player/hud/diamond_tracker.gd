extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var diamond_tracker_label: Label = $DiamondTrackerLabel

var diamonds := []
var is_hud_visible := false

func _ready() -> void:
	_update_tracker()
	diamonds = get_tree().get_nodes_in_group("diamond")
	for diamond in diamonds:
		print("connecting diamond...")
		diamond.diamond_collected.connect(_diamond_looted)

func _diamond_looted() -> void:
	match is_hud_visible:
		true:
			animation_player.stop()
			animation_player.play("update")
		false:
			animation_player.play("fade_out")

func _update_tracker() -> void:
	diamond_tracker_label.text = "x " + str(DiamondManager.get_total_collected())
	print(DiamondManager.collected_items)

func _play_update_sfx() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_DIAMOND_TRACKER_UPDATED)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade_out":
			is_hud_visible = true
			animation_player.play("update")
		"update":
			is_hud_visible = false
			animation_player.play("fade_in")
