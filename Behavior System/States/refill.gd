extends State
class_name RefillState

@export var _target_position : Variant = null
@export var _body : CharacterBody2D = null
@export var _speed : float = 250

func _init() -> void:
	_name = "Refill"

func _start() -> void:
	if !_body || !_target_position:
		_stop()
		return
	super._start()

func _physics_process(_delta: float) -> void:
	if !_body || !_target_position:
		_stop()
		return
	if _body.global_position.distance_to(_target_position) > 3:
		_body.velocity = (_target_position - _body.global_position).normalized() * _speed
		_body.move_and_slide()
	elif is_processing():
		_behavior._origin._documents = _behavior._RNG.randi_range(0,9)
		_stop()

func _stop() -> void:
	super._stop()
