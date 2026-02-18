extends State
class_name HugState

@export var _entity : Entity = null
@export var _target : CharacterBody2D = null
@export var _speed : float = 50
@export var _hug_timer : float = 0
@export var _hug_time_limit : float = 0

func _init() -> void:
	_name = "Hug"

func _start() -> void:
	if !_entity || !_target:
		_stop()
		return
	_hug_timer = _hug_time_limit
	super._start()

func _physics_process(delta: float) -> void:
	if _target:
		if _entity.global_position.distance_to(_target.global_position) <= 4:
			_entity.velocity = Vector2.ZERO
			if _hug_timer > 0:
				_hug_timer -= delta
			elif is_processing():
				_stop()
		else:
			_entity.velocity = (_target.global_position - _entity.global_position).normalized() * _speed
			_entity.move_and_slide()

func _stop() -> void:
	_target = null
	super._stop()
