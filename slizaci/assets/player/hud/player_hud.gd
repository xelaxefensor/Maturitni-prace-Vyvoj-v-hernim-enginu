extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$/root/Main/%Game.game_loaded.connect(hud_visible)
	$/root/Main/%Game.game_ended.connect(hud_invisible)
	
	

func hud_visible():
	visible = true
	
	
func hud_invisible():
	visible = false
