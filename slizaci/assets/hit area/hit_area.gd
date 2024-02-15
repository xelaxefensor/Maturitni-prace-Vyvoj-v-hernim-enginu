extends Area2D

signal take_damage()

func _on_area_entered(area):
	if area.has_method("do_damage"):
		take_damage.emit(area.do_damage())	
