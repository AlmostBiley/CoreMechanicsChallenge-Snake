class_name Grid
extends Node

const CELL_SIZE : int = 32

@onready var game_tick_timer: Timer = %GameTickTimer
@onready var snake: Snake = %Snake

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_tick_timer.timeout.connect(snake.data.on_time_tick)
	snake.data.died.connect(on_snake_death.bind(snake))

func on_snake_death(_snake : SnakeData) -> void:
	game_tick_timer.stop()
