class_name Grid
extends Node

const CELL_SIZE : int = 32
const GRID_SIZE : Vector2i = Vector2i(16, 16)

@onready var game_tick_timer: Timer = %GameTickTimer
@onready var snake: Snake = %Snake

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_tick_timer.timeout.connect(snake.data.on_time_tick)
	game_tick_timer.timeout.connect(add_food)
	snake.data.died.connect(on_snake_death.bind(snake))

func on_snake_death(_snake : SnakeData) -> void:
	game_tick_timer.stop()

func is_every_cell_filled() -> bool:
	for x in range(GRID_SIZE.x):
		for y in range(GRID_SIZE.y):
			if is_cell_empty(Vector2i(x, y)):
				return false
	return true

func is_cell_empty(cell_pos : Vector2i) -> bool:
	if snake:
		for segment : Vector2i in snake.data.segments:
			if cell_pos == segment:
				return false
	return true

func add_food() -> void:
	var rand_pos := Vector2i(randi_range(0, GRID_SIZE.x - 1), randi_range(0, GRID_SIZE.y - 1))
	while not is_cell_empty(rand_pos):
		rand_pos = Vector2i(randi_range(0, GRID_SIZE.x - 1), randi_range(0, GRID_SIZE.y - 1))
	
	var new_food := Food.create()
	add_child(new_food)
	new_food.position = rand_pos * CELL_SIZE
