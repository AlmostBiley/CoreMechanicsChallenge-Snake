class_name Snake
extends Resource

var segments : Array[Vector2i] = [Vector2i.ZERO]
var facing_direction : Vector2i:
	set(value):
		facing_direction = value
		emit_changed()

var head : Vector2i:
	set(value):
		pass
	get():
		return segments[0]

signal died
signal moved

func _init() -> void:
	segments = [Vector2i(5, 5),	Vector2i(5, 6)]
	facing_direction = Vector2i.RIGHT

func move() -> void:
	segments.pop_back()
	var head_pos := segments[0]
	var new_head_pos := head_pos + facing_direction
	segments.insert(0, new_head_pos)
	emit_changed()
	moved.emit()
	if is_eating_self():
		died.emit()

func eat(food : Food) -> void:
	var tail_pos := segments[-1]
	segments.append(tail_pos)
	segments.append(tail_pos)

func is_eating_self() -> bool:
	var head_pos := segments[0]
	for i in range(1, segments.size()):
		if head_pos == segments[i]:
			return true
	return false

func on_game_tick() -> void:
	move()

func kill() -> void:
	died.emit()

func draw(canvas_item : CanvasItem) -> void:
	draw_head(canvas_item)
	draw_body(canvas_item)
	draw_tail(canvas_item)

func draw_head(canvas_item : CanvasItem) -> void:
	var head_pos := SnakeGame.CELL_SIZE * Vector2(segments[0])
	var head_tip := head_pos + SnakeGame.CELL_SIZE * 0.5 * Vector2(facing_direction)
	canvas_item.draw_line(head_pos, head_tip, Color.FOREST_GREEN, 0.5 * SnakeGame.CELL_SIZE)

func draw_body(canvas_item : CanvasItem) -> void:
	var draw_segments : PackedVector2Array = []
	for segment in segments:
		var draw_segment := SnakeGame.CELL_SIZE * Vector2(segment)
		draw_segments.append(draw_segment)
	canvas_item.draw_polyline(draw_segments, Color.FOREST_GREEN, 0.4 * SnakeGame.CELL_SIZE)

func draw_tail(canvas_item : CanvasItem) -> void:
	pass
