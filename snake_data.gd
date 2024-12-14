class_name SnakeData
extends Resource

var segments : Array[Vector2i] = [Vector2i.ZERO]
var facing_direction : Vector2i:
	set(value):
		facing_direction = value
		emit_changed()

signal died

func move() -> void:
	segments.pop_back()
	var head_pos := segments[0]
	var new_head_pos := head_pos + facing_direction
	segments.insert(0, new_head_pos)
	emit_changed()
	if is_eating_self():
		died.emit()

func is_eating_self() -> bool:
	var head_pos := segments[0]
	for i in range(1, segments.size()):
		if head_pos == segments[i]:
			return true
	return false

func on_time_tick() -> void:
	move()
