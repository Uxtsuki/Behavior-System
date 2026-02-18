extends Node2D
class_name World

func _ready() -> void:
	var behavior : Behavior = $Entity._behavior
	behavior._add_behavior(load("res://Behavior System/Behaviors/wander.tres"))
	behavior._current_behavior = "Wander"
	behavior._behavior_switch()
