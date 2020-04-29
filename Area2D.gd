extends Area2D

onready var cell = get_parent()

func _input_event(viewport, event, shape_idx):
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		self.on_click()

func on_click():
	var sprite = get_node("../Sprite")
	sprite.visible = !sprite.visible
	cell.alive = !cell.alive
