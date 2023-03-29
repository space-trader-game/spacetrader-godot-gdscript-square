class_name StackedDetailsInterface
extends NinePatchRect


## Emitted when this details window should be removed/closed
signal window_closed


# an array of all of the units in the cell
var units: Array

# if the stack includes a starsystem to present
var star_system = null

# the game's gui
var gui: Control

# the gameboard
var game_board: Node2D


@onready var _list_container = $ScrollContainer/VBoxContainer


# The stacked details unit screen
@export var _stacked_unit_details_resource: Resource = preload("res://Scenes/Interface/Stacked_Details/StackedUnitDetails.tscn")

# The stacked system details screen
@export var _stacked_system_details_resource: Resource = preload("res://Scenes/Interface/Stacked_Details/StackedSystemDetails.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	# iterate over the units and add them to the stack interface
	for unit in units:
		print("StackedDetailsInterface.gd: adding a unit stack")
		var stacked_unit_interface = _stacked_unit_details_resource.instantiate()
	
		# connect the unit open button signal to this scene so that we can close the stack details screen
		stacked_unit_interface.connect("unit_open_button_pressed",Callable(self,"_on_unit_open_button_pressed"))
	
		# connect the unit open button signal to the gameboard so that the chosen unit can be activated
		# this also results in the unit interface screen being opened
		stacked_unit_interface.connect("unit_open_button_pressed",Callable(game_board,"_on_unit_open_button_pressed"))
	
		stacked_unit_interface.my_unit = unit
		stacked_unit_interface.gui = gui

		_list_container.add_child(stacked_unit_interface)
	
	# then, if the star system exists, add it to the stack interface last
	if !(star_system == null):
		print("StackedDetailsInterface.gd: adding a system stack")
		var stacked_system_interface = _stacked_system_details_resource.instantiate()
	
		# connect the system open button signal to this scene so that we can close the stack details screen
		stacked_system_interface.connect("system_open_button_pressed",Callable(self,"_on_system_open_button_pressed"))

		# connect the system open button signal to the gameboard so that the chosen system can be activated
		# this also results in the system interface screen being opened
		stacked_system_interface.connect("system_open_button_pressed",Callable(game_board,"_on_system_open_button_pressed"))
	
		stacked_system_interface.my_star_system = star_system
		stacked_system_interface.gui = gui
	
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


# called when the system open button press emits a signal - "closes" the stacked details interface
# warning-ignore:unused_argument
func _on_system_open_button_pressed(_system):
	print("StackedDetailsInterface.gd: received system details open button signal")
	queue_free()

# called when the unit open button press emits a signal - "closes" the stacked details interface
# warning-ignore:unused_argument
func _on_unit_open_button_pressed(_unit):
	print("StackedDetailsInterface.gd: received unit details open button signal")
	queue_free()
