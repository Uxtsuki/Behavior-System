extends State
class_name MoveToState

@export var _target_position : Variant = null
@export var _body : CharacterBody2D = null
@export var _speed : float = 200

func _init() -> void:
	_name = "Move To"

func _start() -> void:
	if !_body || !_target_position:
		_stop()
		return
	super._start()

func _physics_process(_delta: float) -> void:
	if !_body || !_target_position:
		_stop()
		return
	_body.velocity = (_target_position - _body.global_position).normalized() * _speed
	_body.move_and_slide()
	if is_processing() && _body.global_position.distance_to(_target_position) <= 3:
		_stop()
