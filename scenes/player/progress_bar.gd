extends ProgressBar

var stamina: StaminaComponent

func _ready() -> void:
	stamina = $"../Components/StaminaComponent"

func _physics_process(_delta: float) -> void:
	value = stamina.stamina
