extends Node


var _current_turn = 0
var _current_money = 1000000000


onready var _turn_counter = $GUI/Counters/TurnCounter/Number
onready var _money_counter = $GUI/Counters/MoneyCounter/Number
onready var _gui = $GUI

# Called when the node enters the scene tree for the first time.
func _ready():
  _turn_counter.text = str(_current_turn)
  _money_counter.text = comma_sep(_current_money)
  _gui.connect("turn_ended", self, "_on_turn_ended")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# https://godotengine.org/qa/18559/how-to-add-commas-to-an-integer-or-float-in-gdscript?show=70786#a70786
static func comma_sep(n: int) -> String:
  var result := ""

  # warning-ignore:narrowing_conversion
  var i: int = abs(n)

  while i > 999:
    result = ",%03d%s" % [i % 1000, result]
    i /= 1000

  return "%s%s%s" % ["-" if n < 0 else "", i, result]

## Called when the player clicks the end turn button
func _on_turn_ended():
  # get all of the units
  var current_units = get_tree().get_nodes_in_group("units")

  # iterate over all of the units
  for unit in current_units:
    # reset the unit moves remaining to the unit's movement range
    unit.remaining_moves = unit.move_range