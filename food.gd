class_name Food
extends GridObject

const SCENE = preload("res://food.tscn")

signal eaten

static func create() -> Food:
	return SCENE.instantiate()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, Grid.CELL_SIZE * 0.25, Color.CRIMSON)
