extends RichTextLabel

@onready var jump_comp: JumpComponent = %JumpComponent

func _process(_delta: float) -> void:
	text = str(jump_comp.remaining_bonus_jumps)
