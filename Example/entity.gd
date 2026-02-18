extends CharacterBody2D
class_name Entity

var _behavior : Behavior = Behavior.new()
var _state_move : MoveToState = MoveToState.new()
var _state_hug : HugState = HugState.new()

var _hug_cooldown : float = 1

@export var _documents : int = 0
var _state_refil : MoveToState = MoveToState.new()
var _state_shred : MoveToState = MoveToState.new()
var _state_store : MoveToState = MoveToState.new()
var _state_deliver : MoveToState = MoveToState.new()

func _ready() -> void:
	#_state_move._body = self
	#_state_move.on_stop.connect(_reached)
	
	#_state_hug._entity = self
	#_state_hug._hug_time_limit = 2
	#_state_hug.on_stop.connect(func(_x : State): _hug_cooldown = 1)
	
	#_behavior.add_child(_state_hug)
	#_behavior.add_child(_state_move)
	#_reached(null)
	
	#_state_refil._body = self
	#_state_refil._name = "Refill"
	#_behavior.add_child(_state_refil)
	#_state_shred._body = self
	#_state_shred._name = "Shred"
	#_behavior.add_child(_state_shred)
	#_state_store._body = self
	#_state_store._name = "Store"
	#_behavior.add_child(_state_store)
	#_state_deliver._body = self
	#_state_deliver._name = "Deliver"
	#_behavior.add_child(_state_deliver)
	
	for c in _behavior.get_children():
		c._behavior = _behavior
		_behavior._states[c._name] = c
	add_child(_behavior)
	
	#_behavior._current_behavior = "Wander"
	#_behavior._add_behavior(load("res://Behavior System/Behaviors/wander.tres"))
	#_behavior._finish_state(null)

func _reached(_x : State) -> void:
	_state_move._target_position = Vector2(
		_behavior._RNG.randf_range(100,1052),
		_behavior._RNG.randf_range(100,548),
	)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent():
		$Area2D.set_deferred("monitoring", false)
		_state_hug._target = area.get_parent()
		_behavior._state_queue.push_front(_state_hug._name)

func _process(delta: float) -> void:
	if !$Area2D.monitoring && _hug_cooldown != -1:
		if _hug_cooldown > 0:
			_hug_cooldown -= delta
		else:
			_hug_cooldown = -1
			$Area2D.set_deferred("monitoring", true)
