class_name SystemDetailsScreen
extends NinePatchRect


## Emitted when this details window should be removed/closed
signal window_closed


var my_system: StarSystem


@onready var _system_name = $GridContainer/SystemName

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_system_name.text = my_system.system_name


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# called when the window should be destroyed
func _close_window():
	emit_signal("window_closed", self)
	queue_free()


## closes the system interface screen when the cancel button is pressed
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_close_window()


## closes the unit interface screen when the x button is pressed
func _on_x_Button_pressed():
	_close_window()

