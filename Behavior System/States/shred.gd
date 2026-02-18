extends State
class_name ShredState

@export var _target_position : Variant = null
@export var _body : CharacterBody2D = null
@export var _speed : float = 200
@export var _number_of_files : int = 0
@export var _shred_timer : float = 1.5
@export var _shred_time_limit : float = 1.5

func _init() -> void:
	_name = "Shred"

func _start() -> void:
	if !_body || !_target_position:
		_stop()
		return
	_number_of_files = randi_range(1, _behavior._origin._documents)
	_behavior._origin._documents -= _number_of_files
	super._start()

func _process(delta: float) -> void:
	super._process(delta)
	if !_body || !_target_position:
		_stop()
		return
	if _body.global_position.distance_to(_target_position) > 4:
		_body.velocity = (_target_position - _body.global_position).normalized() * _speed
		_body.move_and_slide()
	else:
		if _number_of_files > 0:
			if _shred_timer > 0:
				_shred_timer -= delta
			else:
				_number_of_files -= 1
				_shred_timer = _shred_time_limit
		elif is_processing():
			_stop()
			pass
