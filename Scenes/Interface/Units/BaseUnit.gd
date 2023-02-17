extends NinePatchRect


var my_unit: Unit


onready var _moves_remaining = $GridContainer/MovesRemaining
onready var _unit_name = $GridContainer/UnitName


# Called when the node enters the scene tree for the first time.
func _ready():
  _unit_name.text = my_unit.unit_name
  _moves_remaining.text = str(my_unit.remaining_moves)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  _unit_name.text = my_unit.unit_name
  _moves_remaining.text = str(my_unit.remaining_moves)


## closes the unit interface screen when the cancel button is pressed
func _unhandled_input(event: InputEvent) -> void:
  if event.is_action_pressed("ui_cancel"):
    queue_free()


## closes the unit interface screen when the x button is pressed
func _on_x_Button_pressed():
  queue_free()
