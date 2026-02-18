extends Node2D
class_name Office

func _ready() -> void:
	#$Entity._behavior._type = Behavior.SWITCHING_TYPE.RANDOM
	$Entity._state_refil._target_position = $Refill.global_position
	$Entity._state_refil._pre_condition = func(_x):
		return $Entity._documents > 0
	$Entity._state_shred._target_position = $Shred.global_position
	$Entity._state_store._target_position = $Storage.global_position
	$Entity._state_deliver._target_position = $Delivery.global_position
	
	$Entity._behavior._type = Behavior.SWITCHING_TYPE.RANDOM_WEIGHTED
	$Entity._state_deliver._weight = 0.7
	$Entity._state_store._weight = 0.2
	$Entity._state_shred._weight = 0.1
	
	$Entity._behavior._finish_state(null)
	pass


func _on_refill_area_entered(area: Area2D) -> void:
	if area.get_parent():
		var entity : Entity = area.owner
		entity._documents += randi_range(1,9)

func _on_shred_area_entered(area: Area2D) -> void:
	if area.get_parent():
		var entity : Entity = area.owner
		if entity._documents <= 0:
			entity._behavior._state_queue.push_front(entity._state_shred._name)
			entity._behavior._state_queue.push_front(entity._state_refil._name)
		else:
			entity._documents -= randf_range(0, entity._documents)

func _on_storage_area_entered(area: Area2D) -> void:
	if area.get_parent():
		var entity : Entity = area.owner
		if entity._documents <= 0:
			entity._behavior._state_queue.push_front(entity._state_store._name)
			entity._behavior._state_queue.push_front(entity._state_refil._name)
		else:
			entity._documents -= randf_range(0, entity._documents)


func _on_delivery_area_entered(area: Area2D) -> void:
	if area.get_parent():
		var entity : Entity = area.owner
		if entity._documents <= 0:
			entity._behavior._state_queue.push_front(entity._state_deliver._name)
			entity._behavior._state_queue.push_front(entity._state_refil._name)
		else:
			entity._documents -= randf_range(0, entity._documents)

func _process(delta: float) -> void:
	$Label.text = "Documents: " + str($Entity._documents)
