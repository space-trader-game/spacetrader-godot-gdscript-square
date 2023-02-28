class_name StackedUnitDetails
extends HBoxContainer


signal unit_open_button_pressed


var my_unit: Unit

# the game's gui
var gui: Control

onready var _unit_name = $UnitName


# Called when the node enters the scene tree for the first time.
func _ready():
  _unit_name.text = my_unit.unit_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_open_Button_pressed():
  print("StackedUnitDetails.gd: the open button for this unit (" + _unit_name.text + ") was clicked")
  
  # tell everyone that the system details open button was pressed which should close the details stack screen
  emit_signal("unit_open_button_pressed", my_unit)
  
  # instantiate this specific system's interface screen
  var unit_interface = my_unit.interface_scene.instance()

  unit_interface.my_unit = my_unit

  gui.add_child(unit_interface)
  
