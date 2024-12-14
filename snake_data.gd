class_name SnakeData
extends Resource

var segments : Array[Vector2i] = []
var facing_direction : Vector2i

func move() -> void:
	segments.pop_back()
	var head_pos := segments[0]
	var new_head_pos := head_pos + facing_direction
	segments.insert(0, new_head_pos)
	emit_changed()

func on_time_tick() -> void:
	move()
