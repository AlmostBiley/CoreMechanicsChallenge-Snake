class_name SnakeGame
extends Node2D

const CELL_SIZE : int = 32
const GRID_SIZE : Vector2i = Vector2i(16, 16)

var grid_objects : Array[GridObject] = []
var snake : Snake
var tick_length := 0.25
var pause : bool = false
var tick_progress := 0.0

signal unpaused
signal tick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	snake = Snake.new()
	snake.died.connect(on_snake_death.bind(snake))
	snake.moved.connect(on_snake_moved.bind(snake))
	snake.changed.connect(draw_game)
	tick.connect(on_game_tick)
	tick.connect(snake.on_game_tick)
	add_food()
	on_game_tick()
	

#func _process(delta: float) -> void:
	#tick_progress += delta
	#if tick_progress >= tick_length:
		#tick_progress -= tick_length
		#tick.emit()

func _draw() -> void:
	snake.draw(self)
	for grid_object in grid_objects:
		grid_object.draw(self)

func draw_game() -> void:
	queue_redraw()

func on_snake_death(_snake : Snake) -> void:
	pass

func is_every_cell_filled() -> bool:
	for x in range(GRID_SIZE.x):
		for y in range(GRID_SIZE.y):
			if is_cell_empty(Vector2i(x, y)):
				return false
	return true

func is_cell_empty(cell_pos : Vector2i) -> bool:
	if snake:
		for segment : Vector2i in snake.segments:
			if cell_pos == segment:
				return false
	for grid_object in grid_objects:
		if not is_instance_valid(grid_object):
			grid_objects.erase(grid_object)
		elif cell_pos == grid_object.grid_position:
			return false
	return true

func is_position_valid(pos : Vector2i) -> bool:
	if pos.x < 0:
		return false
	if pos.y < 0:
		return false
	if pos.x > GRID_SIZE.x:
		return false
	if pos.y > GRID_SIZE.y:
		return false
	return true

func add_food() -> void:
	var rand_pos := Vector2i(randi_range(0, GRID_SIZE.x - 1), randi_range(0, GRID_SIZE.y - 1))
	while not is_cell_empty(rand_pos):
		rand_pos = Vector2i(randi_range(0, GRID_SIZE.x - 1), randi_range(0, GRID_SIZE.y - 1))
	
	var new_food := Food.new()
	grid_objects.append(new_food)
	new_food.grid_position = rand_pos
	new_food.eaten.connect(on_food_eaten.bind(new_food))

func remove_grid_object(grid_object : GridObject) -> void:
	grid_objects.erase(grid_object)

func on_food_eaten(food : Food) -> void:
	remove_grid_object(food)
	add_food()

func on_snake_moved(snake : Snake) -> void:
	if not is_position_valid(snake.head):
		snake.kill()

func on_game_tick() -> void:
	if pause:
		await unpaused
	var timer := get_tree().create_timer(tick_length)
	timer.timeout.connect(tick.emit)
