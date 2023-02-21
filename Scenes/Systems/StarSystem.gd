tool
class_name StarSystem
extends Node2D

## Emitted when the system is clicked in the gameboard
signal system_clicked

## The default name for the unit
export var system_name: String

## Shared resource of type Grid, used to calculate map coordinates.
export var grid: Resource = preload("res://Scenes/Grid.tres")

## The systems' stats interface scene
export var interface_scene: Resource

## coordinates of the star system
var cell := Vector2.ZERO setget set_cell

## Toggles the "selected" animation on the unit.
var is_selected := false setget set_is_selected

onready var _anim_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
  # ensure the system is centered in a cell when added to the scene tree
  self.cell = grid.calculate_grid_coordinates(position)
  position = grid.calculate_map_position(cell)
  add_to_group("systems")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
# pass


# Uses the Grid's clamp function to ensure the cell doesn't go outside the grid
func set_cell(value: Vector2) -> void:
  cell = grid.clamp(value)


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		print("StarSystem.gd: playing selected animation")
		_anim_player.play("selected")
	else:
		print("StarSystem.gd: playing idle animation")
		_anim_player.play("idle")


func click_system() -> void:
	# the game user interface is listening for "unit_clicked" signals
	print("StarSystem.gd: emitting system_clicked signal")
	emit_signal("system_clicked", interface_scene, self)

