## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
export var grid: Resource = preload("res://Scenes/Grid.tres")

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _walkable_cells := []

var _star_systems := {}
var _active_system: StarSystem

var _gui: Control

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _unit_path: UnitPath = $UnitPath


func _ready() -> void:
	_gui = get_parent().get_node("GUI")
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()
		
	if _active_system and event.is_action_pressed("ui_cancel"):
		_deselect_active_system()
		_clear_active_system()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


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


## Clears, and refills the `_units` and `_systems` dictionaries with game
## objects that are on the board.
func _reinitialize() -> void:
	_units.clear()
	_star_systems.clear()
	
	for unit in $UnitContainer.get_children():
		# put the unit into the dictionary
		_units[unit.cell] = unit
		
		# connect the clicked signal emitted by the unit to the GUIs show unit details method
		unit.connect("unit_clicked", _gui, "_show_unit_details")
		
	for star_system in $SystemContainer.get_children():
		# put the star system into the dictionary
		_star_systems[star_system.cell] = star_system
		
		# connect the clicked signal emitted by the star system to the GUIs show system details method
		star_system.connect("system_clicked", _gui, "_show_system_details")


## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.empty():
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
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue

			stack.append(coordinates)
	return array


## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:

	# if the cell that was selected is occupied or isn't walkable, don't do anything and return
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return

	# change the unit dictionary that the gameboard is maintaining to have the place the unit is going to
	# warning-ignore:return_value_discarded
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()

	# reduce the remaining number of moves by the distance walked
	_active_unit.remaining_moves -= get_distance(new_cell, _active_unit.cell)

	_active_unit.walk_along(_unit_path.current_path)
	yield(_active_unit, "walk_finished")
	_clear_active_unit()


## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_thing(cell: Vector2) -> void:

	if _units.has(cell) && _star_systems.has(cell):
		print("GameBoard.gd: haven't handled this situation yet")
		return
		
	if _units.has(cell):
		print("GameBoard.gd: unit selected")
		_active_unit = _units[cell]
		_active_unit.is_selected = true
		_active_unit.click_unit()

		_walkable_cells = get_walkable_cells(_active_unit)
		_unit_overlay.draw(_walkable_cells)
		_unit_path.initialize(_walkable_cells)
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
