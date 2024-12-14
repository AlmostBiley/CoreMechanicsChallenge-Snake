class_name Snake
extends Node2D

const BODY_SCALE : int = Grid.CELL_SIZE

var data : SnakeData

@onready var head_collider: Area2D = %HeadCollider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	data = SnakeData.new()
	data.changed.connect(on_data_changed)
	data.died.connect(on_death)
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
	data.facing_direction = Vector2i.RIGHT
	on_data_changed()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move"):
		input_facing_direction(event)

func input_facing_direction(event : InputEvent) -> void:
	var dir := data.facing_direction
	
	# Get neck
	var neck_dir : Vector2i
	if data.segments.size() >= 2:
		neck_dir = data.segments[1] - data.segments[0]
	
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
	if dir == data.facing_direction:
		# Do nothing
		pass
	elif dir == neck_dir:
		# Do nothing
		pass
	else:
		# Update facing direction
		data.facing_direction = dir

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
	head_collider.position = BODY_SCALE * Vector2(data.segments[0])
	queue_redraw()
	
func on_death() -> void:
	pass
