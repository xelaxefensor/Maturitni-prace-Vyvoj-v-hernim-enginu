extends Node

var player_name = "Bob"
var player_color = "yellow"
var window_mode = 0
var max_fps = 0

var config

func _ready():
	config =  ConfigFile.new()
	load_file()
	

func save_file():
	config.set_value("settings", "player_name", player_name)
	config.set_value("settings", "player_color", player_color)
	config.set_value("settings", "window_mode", window_mode)
	config.set_value("settings", "max_fps", max_fps)
	
	config.save("res://config.cfg")
	

func load_file():
	var err = config.load("res://config.cfg")

# If the file didn't load, ignore it.
	if err != OK:
		return
	
	player_name = config.get_value("settings", "player_name")
	player_color = config.get_value("settings", "player_color")
	window_mode = config.get_value("settings", "window_mode")
	max_fps = config.get_value("settings", "max_fps")
