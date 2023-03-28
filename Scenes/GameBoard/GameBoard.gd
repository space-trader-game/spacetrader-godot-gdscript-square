## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
@export var grid: Resource = preload("res://Scenes/Grid.tres")

# The stacked details interface screen
@export var _stacked_details_interface: Resource = preload("res://Scenes/Interface/Stacked_Details/StackedDetailsInterface.tscn")

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _walkable_cells := []

var _star_systems := {}
var _active_system: StarSystem

var _gui: Control

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath


func _ready() -> void:
	_gui = get_parent().get_node("CanvasLayer/GUI")
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()
	
	if _active_system and event.is_action_pressed("ui_cancel"):
		_deselect_active_system()
		_clear_active_system()


func _get_configuration_warnings() -> PackedStringArray:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return PackedStringArray([warning])


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return _units.has(cell)


## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.remaining_moves)

## Returns a distance in integer units between to points on the gameboard
func get_distance(start_cell: Vector2, end_cell: Vector2) -> int:
	var difference: Vector2 = (end_cell - start_cell).abs()
	var distance := int(difference.x + difference.y)
	return distance
  

# adds a unit to the gameboard dictionary and handles stack things
func _add_unit_to_cell(unit: Unit) -> void:
	# check if the unit dictionary already has an entry for the key
	if _units.has(unit.cell):
		# if there is an entry, check if it is an array
		if _units[unit.cell] is Array:
			# if it is an array, append the unit
			_units[unit.cell].append(unit)
		else:
			# temporarily copy the single unit from the dict
			var temp_unit = _units[unit.cell]
		
			# assign the existing unit to the 0 position and the new unit to the 1 position
			# in a new array of units
			_units[unit.cell] = [temp_unit, unit]
	else:
		# if there is no entry store the first unit in the dict 
		_units[unit.cell] = unit
	

# removes a unit from the gameboard dictionary and handles stack things
func _remove_unit_from_cell(unit: Unit) -> void:

	# we know the dictionary is going to have the key, so we can skip validating that
	# check if the dictionary has an array or just a single item
	if _units[unit.cell] is Array:
		# if it's an array, remove the unit from the array
		var stack = _units[unit.cell]
		stack.erase(unit)
	
		# if the array's length is now 1, replace the array with just the remaining unit
		if stack.size() == 1:
			var temp_unit = stack[0]
			_units[temp_unit.cell] = temp_unit

	else:
		# it's a single item, just clear the cell
		# warning-ignore:return_value_discarded
		_units.erase(unit.cell)


## Clears, and refills the `_units` and `_systems` dictionaries with game
## objects that are on the board.
func _reinitialize() -> void:
	_units.clear()
	_star_systems.clear()

	for unit in $UnitContainer.get_children():
		# connect the clicked signal emitted by the unit to the GUIs show unit details method
		unit.connect("unit_clicked",Callable(_gui,"_show_unit_details"))
	
		_add_unit_to_cell(unit)
	
	for star_system in $SystemContainer.get_children():
		# put the star system into the dictionary
		_star_systems[star_system.cell] = star_system
	
		# connect the clicked signal emitted by the star system to the GUIs show system details method
		star_system.connect("system_clicked",Callable(_gui,"_show_system_details"))


## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.is_empty():
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		if get_distance(cell, current) > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if coordinates in array:
				continue

			stack.append(coordinates)
	return array


## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	print("GameBoard.gd: attempting to move active unit")

	# if the cell that was selected is occupied or isn't walkable, don't do anything and return
	#if is_occupied(new_cell) or not new_cell in _walkable_cells:
	if not new_cell in _walkable_cells:
		print("GameBoard.gd: destination cell is not walkable, returning")
		return

	# remove the active unit from the dictionary at its current location
	_remove_unit_from_cell(_active_unit)

	# reduce the remaining number of moves by the distance walked
	_active_unit.remaining_moves -= get_distance(new_cell, _active_unit.cell)

	# walk the unit
	_active_unit.walk_along(_unit_path.current_path)

	# finishing the walk updates the cell value for the unit object
	await _active_unit.walk_finished

	# update the dictionary with the units new position
	_add_unit_to_cell(_active_unit)

	# clear the overlay so that the pathing can start again
	_unit_overlay.clear()
	_unit_path.stop()

	# reinitialize the pathy stuff
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)

	## deselect the unit
	#_deselect_active_unit()

	## clear the active unit
	#_clear_active_unit()


# determines if a stack is selected
func _is_stack_selected(cell: Vector2) -> bool:
	# are there any units in the cell?
	if _units.has(cell):
		# are there multiple units in the cell?
		if _units[cell] is Array:
			# there is a stack
			return true

	# is there at least one unit on a system? - if the _units dict has the cell key it means
	# there is at least one unit in that cell
	if _units.has(cell) && _star_systems.has(cell):
		return true

	# no conditions for stack selected
	return false

# runs a specific set of steps involved in selecting and activating a unit
func _select_unit(unit: Unit) -> void:
	_active_unit = unit
	_active_unit.is_selected = true
	_active_unit.click_unit()

	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)

## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_thing(cell: Vector2) -> void:

	# check if we have a unit on a system or multiple units
	if _is_stack_selected(cell):
		print("GameBoard.gd: selected a cell with a stack")
		var stacked_details_interface = _stacked_details_interface.instantiate()

		# tell the stacked details interface where the game gui is
		stacked_details_interface.gui = _gui
		stacked_details_interface.game_board = self
	
		# determine if there are one or multiple units in the cell
		if _units[cell] is Array:
			print("GameBoard.gd: there are multiple units in the cell")
			# if there are multiple units (an array), duplicate and pass to the interface scene
			stacked_details_interface.units = _units[cell].duplicate()
		else:
			print("GameBoard.gd: there is only one unit in the cell")
			# otherwise, pass the single unit as an array
			stacked_details_interface.units = [_units[cell]]

		# pass the system into the stacked interface screen if there is one
		if _star_systems.has(cell):
			print("GameBoard.gd: there is a star system in this cell")
			stacked_details_interface.star_system = _star_systems[cell]

		_gui.add_child(stacked_details_interface)
		return
	
	if _units.has(cell):
		print("GameBoard.gd: unit selected")
		_select_unit(_units[cell])
		return
	
	if _star_systems.has(cell):
		print("GameBoard.gd: system selected")
		_active_system = _star_systems[cell]
		_active_system.is_selected = true
		_active_system.click_system()
		return
	
	print("GameBoard.gd: looks like clicked on empty space")

## Deselects the active system
func _deselect_active_system() -> void:
	_active_system.is_selected = false


## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	print("GameBoard.gd: deselecting active unit")
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_system
func _clear_active_system() -> void:
	_active_system = null


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()


## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	print("GameBoard.gd: " + str(cell))
	if not _active_unit && not _active_system:
		print("GameBoard.gd: not active unit or system, so selecting")
		_select_thing(cell)

	elif _active_unit:
		if _active_unit.is_selected:
			# a selected active unit would be moved by a click
			_move_active_unit(cell)


## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)


# called when an individual unit or system details window is closed
func _on_details_window_closed(details_screen):
	print("GameBoard.gd: received details window closed signal")
	if details_screen is UnitDetailsScreen:
		print("GameBoard.gd: it's a unit details screen")
		if _active_unit:
			_deselect_active_unit()
		_clear_active_unit()
	if details_screen is SystemDetailsScreen:
		print("GameBoard.gd: it's a system details screen")
		_deselect_active_system()
		_clear_active_system()

# called when a unit open button is pressed in a stacked list in order to activate the unit
# for movement
func _on_unit_open_button_pressed(unit):
	print("GameBoard.gd: received unit open button signal")
	_select_unit(unit)
