class_name Snake
extends Node2D

const BODY_SCALE : int = 20

var data : SnakeData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data = SnakeData.new()
	data.changed.connect(on_data_changed)
	data.facing_direction = Vector2i.RIGHT
	data.segments = [
		Vector2i(5,5),
		Vector2i(5,6),
		Vector2i(5,7),
		Vector2i(4,7),
		Vector2i(3,7),
		Vector2i(2,7),
		Vector2i(2,6),
		Vector2i(2,5),
		Vector2i(1,5),
	]
	on_data_changed()

func _draw() -> void:
	draw_head()
	draw_body()
	draw_tail()

func draw_head() -> void:
	var head_pos := BODY_SCALE * Vector2(data.segments[0])
	var head_tip := head_pos + BODY_SCALE * 0.5 * Vector2(data.facing_direction)
	draw_line(head_pos, head_tip, Color.FOREST_GREEN, 0.5 * BODY_SCALE)

func draw_body() -> void:
	var body_segments : PackedVector2Array = []
	for segment in data.segments:
		var body_segment := BODY_SCALE * Vector2(segment)
		body_segments.append(body_segment)
	draw_polyline(body_segments, Color.FOREST_GREEN, 0.4 * BODY_SCALE)

func draw_tail() -> void:
	pass

func on_data_changed() -> void:
	queue_redraw()
	
