extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var diamond_tracker_label: Label = $DiamondTrackerLabel

var lootable_diamonds := []
var is_hud_visible := false

func _ready() -> void:
	visible = false
	_update_tracker()
	lootable_diamonds = get_tree().get_nodes_in_group("diamond")
	for diamond in lootable_diamonds:
		diamond.diamond_collected.connect(_diamond_looted)

func _diamond_looted() -> void:
	match is_hud_visible:
		true:
			animation_player.stop()
			animation_player.play("update")
		false:
			visible = true
			animation_player.play("fade_out")

func _update_tracker() -> void:
	diamond_tracker_label.text = "x " + str(DiamondManager.get_total_collected())

func _play_update_sfx() -> void:
	AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.ON_DIAMOND_TRACKER_UPDATED)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade_out":
			is_hud_visible = true
			animation_player.play("update")
		"fade_in":
			visible = false
		"update":
			is_hud_visible = false
			animation_player.play("fade_in")
