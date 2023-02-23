class_name StackedDetailsInterface
extends NinePatchRect


## Emitted when this details window should be removed/closed
signal window_closed

# an array of all of the units in the cell
var units: Array

# if the stack includes a starsystem to present
var star_system = null


onready var _list_container = $ScrollContainer/VBoxContainer


# The stacked details unit screen
export var _stacked_unit_details_resource: Resource = preload("res://Scenes/Interface/Stacked_Details/StackedUnitDetails.tscn")

# The stacked system details screen
export var _stacked_system_details_resource: Resource = preload("res://Scenes/Interface/Stacked_Details/StackedSystemDetails.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
  # iterate over the units and add them to the stack interface
  for unit in units:
    print("StackedDetailsInterface.gd: adding a unit stack")
    var stacked_unit_interface = _stacked_unit_details_resource.instance()
    stacked_unit_interface.unit_name = unit.unit_name
    
    _list_container.add_child(stacked_unit_interface)
    
  if !(star_system == null):
    print("StackedDetailsInterface.gd: adding a system stack")
    var stacked_system_interface = _stacked_system_details_resource.instance()
    stacked_system_interface.system_name = star_system.system_name
    
    _list_container.add_child(stacked_system_interface)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# closes the stacked details interface screen when the cancel button is pressed
func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_cancel"):
    _close_window()


# called when the window should be destroyed
func _close_window():
  emit_signal("window_closed", self)
  queue_free()


# closes the stacked details interface screen when the x button is pressed
func _on_x_Button_pressed():
  print("StackedDetailsInterface.gd: x button pressed")
  _close_window()

