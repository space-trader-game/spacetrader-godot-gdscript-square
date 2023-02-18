extends Control


signal turn_ended


# Called when the node enters the scene tree for the first time.
func _ready():
  pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


## Shows a specialty information screen for a selected object
##   takes a resource as an argument which is then instantiated
func _show_unit_details(referenced_screen: Resource, the_unit: Unit):
  var details_screen = referenced_screen.instance()
  details_screen.my_unit = the_unit
  add_child(details_screen)


func _show_system_details(referenced_screen: Resource, the_system: StarSystem):
  var details_screen = referenced_screen.instance()
  details_screen.my_system = the_system
  add_child(details_screen)


func _on_EndTurnButton_pressed():
  emit_signal("turn_ended")