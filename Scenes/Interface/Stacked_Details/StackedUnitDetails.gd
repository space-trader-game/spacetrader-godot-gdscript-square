class_name StackedUnitDetails
extends HBoxContainer


var unit_name: String


onready var _unit_name = $UnitName


# Called when the node enters the scene tree for the first time.
func _ready():
  _unit_name.text = unit_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
