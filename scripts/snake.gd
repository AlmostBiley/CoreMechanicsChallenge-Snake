class_name Snake
extends Resource

const COLOR : Color = Color(0, 0.744, 0.371)
const HEAD_SIZE : float = SnakeGame.CELL_SIZE * 0.5

var segments : Array[Vector2i] = [Vector2i.ZERO]
var facing_direction : Vector2i:
	set(value):
		facing_direction = value
		#emit_changed()

var head : Vector2i:
	set(value):
		pass
	get():
		return segments[0]

var alive : bool = true

signal died
signal moved

func _init() -> void:
	var grid_center := (SnakeGame.GRID_MIN + SnakeGame.GRID_MAX) / 2 
	var grid_left := Vector2i(SnakeGame.GRID_MIN.x, grid_center.y)
	segments = [grid_left + Vector2i.RIGHT, grid_left]
	facing_direction = Vector2i.RIGHT

func input_facing_direction(event : InputEvent) -> void:
	var dir := facing_direction
	
	# Get neck
	var neck_dir : Vector2i
	if segments.size() >= 2:
		neck_dir = segments[1] - segments[0]
	
	# Get input direction
	if event.is_action_pressed("move_down"):
		dir = Vector2i.DOWN
	elif event.is_action_pressed("move_left"):
		dir = Vector2i.LEFT
	elif event.is_action_pressed("move_right"):
		dir = Vector2i.RIGHT
	elif event.is_action_pressed("move_up"):
		dir = Vector2i.UP
	
	# Set direction
	if dir == facing_direction:
		# Do nothing
		pass
	elif dir == neck_dir:
		# Do nothing
		pass
	else:
		# Update facing direction
		facing_direction = dir

func move() -> void:
	segments.pop_back()
	var head_pos := segments[0]
	var new_head_pos := head_pos + facing_direction
	segments.insert(0, new_head_pos)
	emit_changed()
	moved.emit()
	if is_eating_self():
		kill()

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

func kill() -> void:
	alive = false
	died.emit()

func on_game_tick() -> void:
	if alive:
		move()

func draw(canvas_item : CanvasItem) -> void:
	draw_head(canvas_item)
	draw_body(canvas_item)
	draw_tail(canvas_item)

func draw_head(canvas_item : CanvasItem) -> void:
	var head_pos := SnakeGame.CELL_SIZE * Vector2(segments[0])
	var rect : Rect2 = Rect2(head_pos.x - HEAD_SIZE / 2, head_pos.y - HEAD_SIZE / 2, HEAD_SIZE, HEAD_SIZE)
	canvas_item.draw_rect(rect, COLOR)

func draw_body(canvas_item : CanvasItem) -> void:
	var draw_segments : PackedVector2Array = []
	for segment in segments:
		var draw_segment := SnakeGame.CELL_SIZE * Vector2(segment)
		draw_segments.append(draw_segment)
	canvas_item.draw_polyline(draw_segments, COLOR, 0.4 * SnakeGame.CELL_SIZE)

func draw_tail(canvas_item : CanvasItem) -> void:
	pass
