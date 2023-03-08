## Draws the unit's movement path using an autotile.
class_name UnitPath
extends TileMap

@export var grid: Resource = preload("res://Scenes/Grid.tres")

var _pathfinder: PathFinder
var current_path := PackedVector2Array()


## Creates a new PathFinder that uses the AStar3D algorithm to find a path between two cells among
## the `walkable_cells`.
func initialize(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)


## Finds and draws the path between `cell_start` and `cell_end`
func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	clear()
	current_path = _pathfinder.calculate_point_path(cell_start, cell_end)
	for cell in current_path:
		set_cell(0, cell, 0, Vector2i(0,0))
	set_cells_terrain_path(0, current_path, 0, 0)


## Stops drawing, clearing the drawn path and the `_pathfinder`.
func stop() -> void:
	_pathfinder = null
	clear()
