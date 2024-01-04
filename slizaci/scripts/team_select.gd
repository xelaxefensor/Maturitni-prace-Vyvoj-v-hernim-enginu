extends CanvasLayer


signal team_selected(team)


# Called when the node enters the scene tree for the first time.
func _ready():
	$/root/Main/%Game.team_select.connect(visible_self)
	MultiplayerManager.connection_lost.connect(invisible_self)
	
	
func visible_self():
	visible = true
	
	
func invisible_self():
	visible = false
	

func _on_team_1_pressed():
	invisible_self()
	team_selected.emit(1)


func _on_team_2_pressed():
	invisible_self()
	team_selected.emit(2)


func _on_spectate_pressed():
	invisible_self()
	team_selected.emit(0)
