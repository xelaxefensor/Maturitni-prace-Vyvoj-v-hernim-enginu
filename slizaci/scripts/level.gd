extends Node2D

signal level_loaded
# Called when the node enters the scene tree for the first time.
func _ready():
	level_loaded.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
