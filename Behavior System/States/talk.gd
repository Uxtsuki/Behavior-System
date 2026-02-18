extends State
class_name TalkState

@export var _phrases : Array[String] = [
	"Sup",
	"Oh Ma Gah",
	"Hej Allihopa"
]

@export var _phrase : String = ""

func _init() -> void:
	_name = "Talk"
	_timer = 2

func _start() -> void:
	_phrase = _phrases.pick_random()
	super._start()

func _stop() -> void:
	_phrase = ""
	super._stop()
