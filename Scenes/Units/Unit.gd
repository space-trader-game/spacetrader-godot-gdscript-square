## https://github.com/GDQuest/godot-2d-tactical-rpg-movement

## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
@tool
class_name Unit
extends Path2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished

## Emitted when the unit is clicked in the gameboard
signal unit_clicked

## Shared resource of type Grid, used to calculate map coordinates.
@export var grid: Resource = preload("res://Scenes/Grid.tres")

## The unit's stats interface scene
@export var interface_scene: Resource

## The default name for the unit
@export var unit_name: String

## Texture2D representing the unit.
@export var skin: Texture2D : set = set_skin
## Distance to which the unit can walk in cells.
@export var move_range: int
## Offset to apply to the `skin` sprite in pixels.
@export var skin_offset := Vector2.ZERO : set = set_skin_offset
## The unit's move speed when it's moving along a path.
@export var move_speed := 600.0

## The remaining number of moves the unit has
var remaining_moves: int

## Coordinates of the current cell the cursor moved to.
var cell := Vector2.ZERO : set = set_cell
## Toggles the "selected" animation on the unit.
var is_selected := false : set = set_is_selected

var _is_walking := false : set = _set_is_walking

@onready var _sprite: Sprite2D = $PathFollow2D/Sprite2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initially set the remaining moves to the move range
	# this will need to be reset on a new turn
	remaining_moves = move_range

	# add the unit to the units group
	add_to_group("units")

	# disable processing - process is where the path movement happens
	set_process(false)

	# ensure the unit is centered in a cell when added to the scene tree
	self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.is_editor_hint():
		curve = Curve2D.new()


func _process(delta: float) -> void:
	_path_follow.progress += move_speed * delta

	if _path_follow.progress >= curve.get_baked_length():
		self._is_walking = false
		_path_follow.progress = 0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		var destination = grid.calculate_map_position(point) - position 
		if not destination == Vector2.ZERO:
			# in Godot3 adding a zero point didn't generate a zero length error,
			# but it does in Godot4
			curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true


func set_cell(value: Vector2) -> void:
	cell = grid.grid_clamp(value)


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		print("Unit.gd: playing selected animation")
		_anim_player.play("selected")
	else:
		print("Unit.gd: playing idle animation")
		_anim_player.play("idle")


func set_skin(value: Texture2D) -> void:
	skin = value
	if not _sprite:
		await self.ready
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		await self.ready
	_sprite.position = value


func click_unit() -> void:
	# the game user interface is listening for "unit_clicked" signals
	print("Unit.gd: emitting unit_clicked signal")
	emit_signal("unit_clicked", interface_scene, self)


func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)
