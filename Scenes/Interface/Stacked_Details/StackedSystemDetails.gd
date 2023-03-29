class_name StackedSystemDetails
extends HBoxContainer

signal system_open_button_pressed


var my_star_system: StarSystem

# the game's gui
var gui: Control


@onready var _system_name = $SystemName


# Called when the node enters the scene tree for the first time.
func _ready():
	_system_name.text = my_star_system.system_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_open_Button_pressed():
	print("StackedSystemDetails.gd: the open button for this system (" + _system_name.text + ") was clicked")

	# tell everyone that the system details open button was pressed which should close the details stack screen
	emit_signal("system_open_button_pressed", my_star_system)
