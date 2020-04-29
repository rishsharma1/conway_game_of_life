extends Control

onready var button = get_child(0)
onready var grid = get_node("../Grid")

func _on_Button_pressed():
	
	var pressed = button.pressed

	if pressed:
		grid.clear()
