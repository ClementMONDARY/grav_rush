extends RichTextLabel

@onready var jump_comp: JumpComponent = %JumpComponent

func _process(_delta: float) -> void:
	text = str(DiamondManager.get_total_collected())
