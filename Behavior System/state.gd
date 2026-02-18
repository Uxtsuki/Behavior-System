extends Node
class_name State

@export var _behavior : Behavior = null

signal on_start
signal on_stop

signal on_pre_condition
signal on_condition
signal on_pos_condition

signal on_running_out

@export var _pre_condition : Callable = Callable()
@export var _condition : Callable = Callable()
@export var _pos_condition : Callable = Callable()

@export var _name : String = ""
@export var _timer : float = -1
@export var _time_limit : float = -1

@export var _condition_timer : float = -1
@export var _condition_time_limit : float = 1/30.0

@export var _remaining : int = -1
@export var _duration_timer : float = 0
@export var _duration_time_limit : float = -1

@export var _weight : float = 0

@export var _next_states : PackedStringArray = []
@export var _next_states_weights : PackedFloat32Array = []
@export var _iterator : int = 0
@export var _callable : Callable = Callable()
enum SWITCHING_TYPE { ITERATION, RANDOM, RANDOM_WEIGHTED, CALLABLE }
@export var _type : SWITCHING_TYPE = SWITCHING_TYPE.ITERATION

func _ready() -> void:
	name = _name
	set_process(false)
	set_physics_process(false)

func _start() -> void:
	if _behavior._skip_precondition:
		_behavior._skip_condition = false
	elif _pre_condition && _pre_condition.call(self):
		on_pre_condition.emit(self)
		return
	if _remaining != -1:
		if _remaining <= 0:
			return
		else:
			_remaining -= 1
	if _time_limit != -1:
		_timer = _time_limit
	print("Starting state ", _name)
	set_process(true)
	set_physics_process(true)
	on_start.emit(self)
	if _duration_time_limit != -1:
		_duration_timer = _duration_time_limit

func _process(delta: float) -> void:
	if _time_limit != -1:
		if _timer > 0:
			_timer -= delta
		elif is_processing():
			_stop()
	if _duration_time_limit != -1:
		if _duration_timer > 0:
			_duration_timer -= delta
		else:
			_duration_timer = _duration_time_limit
			on_running_out.emit(self)
	if _condition_timer != -1:
		if _condition_timer > 0:
			_condition_timer -= delta
		else:
			_condition_timer = _condition_time_limit
			if !_behavior._skip_condition && is_processing() && _condition && _condition.call(self):
				on_condition.emit(self)

func _stop() -> void:
	print("Stopping state ", _name)
	set_process(false)
	set_physics_process(false)
	if _remaining != -1 && _remaining <= 0:
		on_running_out.emit(self)
	if _behavior._skip_condition:
		_behavior._skip_condition = false
	if _behavior._skip_poscondition:
		_behavior._skip_poscondition = false
	elif _pos_condition && _pos_condition.call(self):
		on_pos_condition.emit(self)
	on_stop.emit(self)

func _get_next_state() -> String:
	match _type:
		SWITCHING_TYPE.ITERATION:
			_iterator += 1 if _iterator + 1 < _next_states.size() else -_next_states.size() - 1
			return _next_states[_iterator]
		SWITCHING_TYPE.RANDOM:
			return _next_states[_behavior._RNG.randi_range(0, _next_states.size() - 1)]
		SWITCHING_TYPE.RANDOM_WEIGHTED:
			return _next_states[_behavior._RNG.rand_weighted(_next_states_weights)]
		SWITCHING_TYPE.CALLABLE:
			if _callable:
				return _callable.call(self)
	return ""
