extends Label


func update_ammmo(mag_count, ammo_count):
	self.text = str(mag_count) + "/" + str(ammo_count)


func ammo_visible():
	visible = true


func ammo_invisible():
	visible = false
