class_name Food
extends Node2D

const SCENE = preload("res://food.tscn")

static func create() -> Food:
	return SCENE.instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
