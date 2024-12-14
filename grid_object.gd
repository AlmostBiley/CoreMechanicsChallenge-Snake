class_name GridObject
extends Area2D

signal destroyed

var grid_position := Vector2i.ZERO:
	set(value):
		grid_position = value
		position = Grid.CELL_SIZE * grid_position
