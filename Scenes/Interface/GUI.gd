extends Control


var _units := {}

var _game_board: GameBoard

#onready var _details_area = $Details

# Called when the node enters the scene tree for the first time.
func _ready():
  _game_board = get_parent().get_node("GameBoard")
  _reinitialize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
  _units.clear()

  for child in _game_board.get_children():
    var unit := child as Unit

    if not unit:
      continue
    _units[unit.cell] = unit

    # we connect the show_details signal for each unit to the _show_details method
    # warning-ignore:return_value_discarded
    unit.connect("unit_clicked", self, "_show_unit_details")


## Shows a specialty information screen for a selected object
##   takes a resource as an argument which is then instantiated
func _show_unit_details(referenced_screen: Resource, the_unit: Unit):
  var details_screen = referenced_screen.instance()
  details_screen.my_unit = the_unit
  add_child(details_screen)
