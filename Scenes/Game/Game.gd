extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_turn = 0
var current_money = 1000000000

onready var turn_counter = $GUI/Counters/TurnCounter/Number
onready var money_counter = $GUI/Counters/MoneyCounter/Number

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_counter.text = str(current_turn)
	money_counter.text = comma_sep(current_money)


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
