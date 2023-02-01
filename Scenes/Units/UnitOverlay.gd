# Draws an overlay over an array of cells.
class_name UnitOverlay
extends TileMap

# By making the tilemap half-transparent, using the modulate property, we only have two draw the
# cells, and we automatically get a nice overlay on the board.
# The function fills the tilemap with the cells, giving visual feedback on where a unit can walk.
func draw(cells: Array) -> void:
	clear()
    # We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for cell in cells:
		set_cellv(cell, 0)