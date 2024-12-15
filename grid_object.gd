class_name GridObject
extends Resource

signal destroyed
signal activated

var grid_position := Vector2i.ZERO

func draw(canvas_item : CanvasItem) -> void:
	pass

func activate() -> void:
	activated.emit()
