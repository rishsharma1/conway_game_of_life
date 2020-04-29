extends Control

onready var button = get_child(0)
onready var grid = get_node("../Grid")

func _on_Button_pressed():
	
	var pressed = button.pressed

	if pressed:
		button.text = "Stop"
		grid.start_game()
	else:
		button.text = "Start"
		grid.stop_game()
