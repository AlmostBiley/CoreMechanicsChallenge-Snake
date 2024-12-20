class_name SnakeGame
extends AudioStreamPlayer2D

const CELL_SIZE : int = 32
const GRID_MIN : Vector2i = Vector2i(3, 3)
const GRID_MAX : Vector2i = Vector2i(12, 12)
const GRID_COLOR_1 := Color(0.352, 0.301, 0.47)
const GRID_COLOR_2 := Color(0.279, 0.211, 0.39)
const SFX_PICKUP : AudioStream  = preload("res://audio/retro_beeps_collect_item_01.wav")
const SFX_DEATH : AudioStream = preload("res://audio/retro_jump_dizzy_spin_01.wav")
const SFX_STARTGAME : AudioStream = preload("res://audio/retro_synth_beeps_04.wav")
const FONT_KENNEY_PIXEL : Font = preload("res://Kenney Pixel.ttf")

var grid_objects : Array[GridObject] = []
var snake : Snake
var tick_length := 0.25
var pause : bool:
	set(value):
		pause = value
		if not pause:
			unpaused.emit()
	
var tick_progress := 0.0
var score : int = 0:
	set(value):
		score = value
		if score > high_score:
			high_score = score
var high_score : int = 0
var message : String:
	set(value):
		message = value
		queue_redraw()

var default_font : Font = ThemeDB.fallback_font

signal unpaused
signal tick

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_game()
	snake.alive = false
	message = "Press space to start."
	pause = true
	on_game_tick()
	#start_game()

func reset_game() -> void:
	# Set up snake
	snake = Snake.new()
	snake.died.connect(on_snake_death.bind(snake))
	snake.moved.connect(on_snake_moved.bind(snake))
	snake.changed.connect(queue_redraw)
	tick.connect(snake.on_game_tick)
	# Set up grid
	grid_objects.clear()
	# Set up messages
	score = 0
	message = ""

func start_game() -> void:
	add_food()
	play_sfx(SFX_STARTGAME)
	pause = false

func play_sfx(to_play : AudioStream, pitch : float = 1.0) -> void:
	stream = to_play
	pitch_scale = pitch
	play()

func _unhandled_input(event: InputEvent) -> void:
	if not pause:
		if event.is_action_pressed("move"):
			snake.input_facing_direction(event)
	
	if event.is_action_pressed("pause"):
		if pause:
			if not snake.alive:
				reset_game()
				start_game()
			pause = false
			message = ""
		else:
			pause = true
			message = "Game paused. Press space to resume."

func _draw() -> void:
	draw_grid()
	draw_messages()
	for grid_object in grid_objects:
		grid_object.draw(self)
	snake.draw(self)
	
func draw_grid() -> void:
	for x in range(GRID_MIN.x - 1, GRID_MAX.x):
		for y in range(GRID_MIN.y - 1, GRID_MAX.y):
			var box := Rect2(x * CELL_SIZE + CELL_SIZE / 2, y * CELL_SIZE + CELL_SIZE / 2, CELL_SIZE, CELL_SIZE)
			if (x + y) % 2 == 0:
				draw_rect(box, GRID_COLOR_1, true)
			else:
				draw_rect(box, GRID_COLOR_2, true)

func draw_messages() -> void:
	var bottom_bound := get_viewport_rect().end.y
	var right_bound := get_viewport_rect().end.x
	draw_string(FONT_KENNEY_PIXEL, Vector2(10, 30), "SCORE = %d" % score, HORIZONTAL_ALIGNMENT_LEFT, right_bound, 48)
	draw_string(FONT_KENNEY_PIXEL, Vector2(10, 60), "HIGH SCORE = %d" % high_score, HORIZONTAL_ALIGNMENT_LEFT, right_bound, 48)
	draw_string(FONT_KENNEY_PIXEL, Vector2(0, bottom_bound - 12), message.to_upper(), HORIZONTAL_ALIGNMENT_CENTER, right_bound, 36)

func is_every_cell_filled() -> bool:
	for x in range(GRID_MAX.x):
		for y in range(GRID_MAX.y):
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
	if pos.x < GRID_MIN.x:
		return false
	if pos.y < GRID_MIN.y:
		return false
	if pos.x > GRID_MAX.x:
		return false
	if pos.y > GRID_MAX.y:
		return false
	return true

func add_grid_object(obj : GridObject) -> void:
	grid_objects.append(obj)
	obj.destroyed.connect(remove_grid_object)

func add_food() -> void:
	var rand_pos := Vector2i(randi_range(GRID_MIN.x, GRID_MAX.x - 1), randi_range(GRID_MIN.x, GRID_MAX.y - 1))
	while not is_cell_empty(rand_pos):
		rand_pos = Vector2i(randi_range(GRID_MIN.x, GRID_MAX.x - 1), randi_range(GRID_MIN.x, GRID_MAX.y - 1))
	
	var new_food := Food.new()
	grid_objects.append(new_food)
	new_food.grid_position = rand_pos
	new_food.activated.connect(snake.eat.bind(new_food))
	new_food.activated.connect(on_food_eaten.bind(new_food))

func remove_grid_object(grid_object : GridObject) -> void:
	grid_objects.erase(grid_object)

func on_food_eaten(food : Food) -> void:
	# Pitch will increase as score increases
	var sfx_pitch := 0.8 + 0.03 * score
	score += 1
	play_sfx(SFX_PICKUP, sfx_pitch)
	remove_grid_object(food)
	add_food()

func on_snake_moved(snake : Snake) -> void:
	if not is_position_valid(snake.head):
		snake.kill()
		return
	for grid_object in grid_objects:
		if snake.head == grid_object.grid_position:
			grid_object.activate()

func on_snake_death(_snake : Snake) -> void:
	# Play death sounds
	play_sfx(SFX_DEATH)
	# Prompt player to restart
	message = "You died! Press space to restart."
	pause = true
	# Remove snake
	snake.died.disconnect(on_snake_death)
	snake.moved.disconnect(on_snake_moved)
	snake.changed.disconnect(queue_redraw)
	tick.disconnect(snake.on_game_tick)

func on_game_tick() -> void:
	if pause:
		await unpaused
	else:
		tick.emit()
	var timer := get_tree().create_timer(tick_length)
	timer.timeout.connect(on_game_tick)
	queue_redraw()
