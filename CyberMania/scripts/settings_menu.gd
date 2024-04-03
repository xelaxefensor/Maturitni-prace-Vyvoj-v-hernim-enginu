extends VBoxContainer

func load_settings():
	%PlayerName.text = PlayerSettings.player_name
	%PlayerColor.color = PlayerSettings.player_color
	%MaxFps.value = PlayerSettings.max_fps
	%WindowMode.selected = PlayerSettings.window_mode


func _on_player_name_text_changed(new_text):
	PlayerSettings.player_name = new_text
	PlayerSettings.save_file()

	
func _on_player_color_color_changed(color):
	PlayerSettings.player_color = color
	PlayerSettings.save_file()


func _on_max_fps_value_changed(value):
	PlayerSettings.max_fps = value
	Engine.max_fps = value
	PlayerSettings.save_file()


func _on_screen_option_item_selected(index):
	PlayerSettings.window_mode = index
	match index:
		0:	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		1:	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	PlayerSettings.save_file()
