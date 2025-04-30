extends Node
class_name FiniteStateMachine

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(change_state)
	
	if initial_state:
		initial_state.Enter()
		print("Initial State: " + initial_state.name)
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.Update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func change_state(source_state: State, new_state_name: String) -> void:
	if source_state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	print("Entered new state: " + new_state_name)
	new_state.Enter()
	
	current_state = new_state
