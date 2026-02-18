extends CharacterBody2D
class_name EntityBoss

var _behavior : Behavior = Behavior.new()
var _state_move : MoveToState = MoveToState.new()
var _state_talk : TalkState = TalkState.new()
var _state_idle : State = State.new()
var _state_ray : State = State.new()
var _state_hit : State = State.new()

func _ready() -> void:
	_state_move._body = self
	_state_move._speed = 100
	_state_talk._time_limit = 2.5
	_state_idle._name = "Idle"
	_state_idle._time_limit = 1.5
	_state_hit._name = "Hit"
	_state_ray._name = "Ray"
	_state_ray._time_limit = 1
	_behavior._type = Behavior.SWITCHING_TYPE.INDIVIDUAL
	
	_behavior.add_child(_state_move)
	_behavior.add_child(_state_talk)
	_behavior.add_child(_state_idle)
	_behavior.add_child(_state_ray)
	_behavior.add_child(_state_hit)
	_state_hit._pre_condition = func(_x : State):
		var player = get_tree().get_first_node_in_group("player")
		if player:
			return global_position.distance_to(player.global_position) > 64
		return false
	_state_hit.on_pre_condition.connect(func(_x : State):
		var player = get_tree().get_first_node_in_group("player")
		_state_move._target_position = player.global_position - Vector2(randf_range(-10,10), randf_range(-5,5))
		_behavior._state_queue.push_front(_state_hit.name)
		_behavior._state_queue.push_front(_state_move.name)
		_behavior._finish_state(null)
		)
	_state_hit.on_start.connect(func(_x : State):
		$Hit/CollisionShape2D.disabled = false
		await get_tree().create_timer(0.25).timeout
		$Hit/CollisionShape2D.set_deferred("disabled", true)
		_x._stop()
		)
	
	_state_ray.on_start.connect(func(_x : State):
		var player = get_tree().get_first_node_in_group("player")
		$Marker2D.look_at(player.global_position)
		for i in range(0,2):
			$Marker2D/RayCast2D.enabled = true
			await get_tree().create_timer(0.1).timeout
			$Marker2D/RayCast2D.set_deferred("enabled", false)
		)
	_state_ray.on_stop.connect(func(_x):
		$Marker2D/RayCast2D.set_deferred("enabled", false))
	
	_state_move.on_stop.connect(_behavior._finish_state)
	
	_state_talk._next_states = ["Idle", "Hit", "Ray"]
	_state_talk._type = State.SWITCHING_TYPE.ITERATION
	_state_idle._next_states = ["Hit"]
	_state_idle._type = State.SWITCHING_TYPE.RANDOM
	_state_hit._next_states = ["Ray", "Talk"]
	_state_hit._next_states_weights = [0.2, 0.8]
	_state_hit._type = State.SWITCHING_TYPE.RANDOM_WEIGHTED
	_state_ray._next_states = ["Hit", "Talk"]
	_state_ray._type = State.SWITCHING_TYPE.CALLABLE
	_state_ray._callable = func(_x):
		print("yay")
		return ["Hit", "Talk"].pick_random()

	for c in _behavior.get_children():
		c._behavior = _behavior
		_behavior._states[c._name] = c
	add_child(_behavior)
	_behavior._switch(_state_idle)

func _process(_delta: float) -> void:
	if _behavior._current_state:
		$State.text = _behavior._current_state._name
	if _state_talk:
		$Phrase.text = _state_talk._phrase
	if $Marker2D/RayCast2D.is_colliding():
		move_player($Marker2D/RayCast2D.get_collider())

func move_player(entity : Node2D) -> void:
	entity.global_position = Vector2(
		randf_range(0,1152),
		randf_range(0,648),
	)


func _on_hit_area_entered(area: Area2D) -> void:
	if area.owner is Entity:
		move_player(area.owner)
