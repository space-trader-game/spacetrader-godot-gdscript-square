extends Control


var _units := {}

var _game_board: GameBoard

onready var _details_area = $Details

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
    unit.connect("show_details", self, "_show_details")


## Shows a specialty information screen for a selected object
func _show_details(the_screen: Resource):
  print("received signal and showing instance")
  add_child(the_screen.instance())