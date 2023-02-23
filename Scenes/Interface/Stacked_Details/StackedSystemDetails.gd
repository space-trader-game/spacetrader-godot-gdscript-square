class_name StackedSystemDetails
extends HBoxContainer


var system_name: String


onready var _system_name = $SystemName


# Called when the node enters the scene tree for the first time.
func _ready():
  _system_name.text = system_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
