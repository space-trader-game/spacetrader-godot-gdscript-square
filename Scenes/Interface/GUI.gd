extends Control


signal turn_ended

var _game_board: GameBoard


# Called when the node enters the scene tree for the first time.
func _ready():
  _game_board = get_node("/root/Game/GameBoard")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


## Shows a specialty information screen for a selected object
##   takes a resource as an argument which is then instantiated
func _show_unit_details(referenced_screen: Resource, the_unit: Unit):
  var details_screen = referenced_screen.instantiate()
  details_screen.my_unit = the_unit
  
  # connect the unit details screen's window_closed signal to the gameboard so that
  # the gameboard can deselect the unit (if it's selected)
  details_screen.connect("window_closed",Callable(_game_board,"_on_details_window_closed"))
  add_child(details_screen)


func _show_system_details(referenced_screen: Resource, the_system: StarSystem):
  var details_screen = referenced_screen.instantiate()
  details_screen.my_system = the_system
  
  # connect the system details screen's window_Closed signal to the gameboard so that
  # the gameboard can deselect the system (if it's selected)
  details_screen.connect("window_closed",Callable(_game_board,"_on_details_window_closed"))
  add_child(details_screen)


func _on_EndTurnButton_pressed():
  emit_signal("turn_ended")