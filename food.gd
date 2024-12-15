class_name Food
extends GridObject

signal eaten

func draw(canvas_item : CanvasItem) -> void:
	canvas_item.draw_circle(SnakeGame.CELL_SIZE * grid_position, SnakeGame.CELL_SIZE * 0.25, Color.CRIMSON)
