extends Node
class_name Behavior

signal on_finish_behavior

var _RNG : RandomNumberGenerator = RandomNumberGenerator.new()

@export var _current_state : State = null
@export var _states : Dictionary[String, State] = {}
@export var _behaviors : Dictionary[String, Dictionary] = {}
@export var _current_behavior : String = ""
@export var _state_queue : Array = []
@export var _state_history : Array = []
@export var _origin : Node2D = null

@export var _skip_precondition : bool = false
@export var _skip_condition : bool = false
@export var _skip_poscondition : bool = false

enum SWITCHING_TYPE { ITERATION, RANDOM, RANDOM_WEIGHTED, INDIVIDUAL }
@export var _type : SWITCHING_TYPE = SWITCHING_TYPE.ITERATION
func _ready() -> void:
	if get_parent():
		_origin = get_parent()

func _add_behavior(resource : BehaviorResource) -> void:
	_behaviors[resource._key] = {
		"remaining": resource._remaining,
		"states": resource._states
	}

func _switch(state : State) -> void:
	print(_state_queue)
	if _current_state:
		if _current_state.is_processing():
			_current_state._stop()
	if state:
		_state_history.append(state._name)
		_current_state = state
		_current_state._start()
		if !_current_state.on_stop.is_connected(_finish_state):
			_current_state.on_stop.connect(_finish_state)
		if _current_state._behavior != self:
			_current_state._behavior = self

func _finish_state(state : State) -> void:
	match _type:
		SWITCHING_TYPE.ITERATION:
			if _state_queue.size() > 0:
				_switch(_states[_state_queue.pop_front()])
			else:
				_behavior_switch()
		SWITCHING_TYPE.RANDOM:
			var key : String = _states.keys()[_RNG.randi_range(0, _states.size() -1)]
			if _state_queue.size() > 0:
				key = _state_queue.pop_front()
			_switch(_states[key])
		SWITCHING_TYPE.RANDOM_WEIGHTED:
			var keys : Array = _states.keys()
			var weights = []
			for state_key in _states:
				weights.append(_states[state_key]._weight)
			var key : String = keys[_RNG.rand_weighted(weights)]
			if _state_queue.size() > 0:
				key = _state_queue.pop_front()
			_switch(_states[key])
		SWITCHING_TYPE.INDIVIDUAL:
			var key : String = ""
			if _state_queue.size() > 0:
				key = _state_queue.pop_front()
			elif state._next_states.size() > 0:
				key = state._get_next_state()
			if key == "":
				return
			_switch(_states[key])

func _behavior_switch() -> void:
	if _behaviors.has(_current_behavior) && (_behaviors[_current_behavior]["remaining"] == -1 ||  _behaviors[_current_behavior]["remaining"] > 0):
		_state_queue = _behaviors[_current_behavior]["states"].duplicate()
		if _behaviors[_current_behavior]["remaining"] != -1 && _behaviors[_current_behavior]["remaining"] > 0:
			_behaviors[_current_behavior]["remaining"] -= 1
		_switch(_states[_state_queue.pop_front()])
	on_finish_behavior.emit(_current_behavior)
	
