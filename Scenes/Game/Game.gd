extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var current_turn = 0
var current_money = 1000

onready var turn_counter = $GUI/Counters/TurnCounter/Number
onready var money_counter = $GUI/Counters/MoneyCounter/Number

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_counter.text = str(current_turn)
	money_counter.text = str(current_money)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
