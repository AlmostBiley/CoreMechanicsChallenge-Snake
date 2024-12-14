class_name SnakeData
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
	food.queue_free()
	var tail_pos := segments[-1]
	segments.append(tail_pos)
	segments.append(tail_pos)

func is_eating_self() -> bool:
	var head_pos := segments[0]
	for i in range(1, segments.size()):
		if head_pos == segments[i]:
			return true
	return false

func on_time_tick() -> void:
	move()

func kill() -> void:
	died.emit()
