extends CanvasLayer


signal team_selected(team)


# Called when the node enters the scene tree for the first time.
func _ready():
	$/root/Main/%Game.team_select.connect(team_select)
	MultiplayerManager.connection_lost.connect(invisible_self)

func team_select(visibility):
	if visibility == "visible":
		visible_self()
	if visibility == "invisible":
		invisible_self()
		
	if visibility == "switch":
		if visible:
			invisible_self()
		else:
			visible_self()
	
	
func visible_self():
	visible = true
	
	
func invisible_self():
	visible = false
	

func _on_team_1_pressed():
	team_selected.emit(1)


func _on_team_2_pressed():
	team_selected.emit(2)


func _on_spectate_pressed():
	team_selected.emit(0)
