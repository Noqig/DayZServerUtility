extends Window



func _on_close_requested():
	get_node("../../Control").refreshText()
	self.queue_free()
