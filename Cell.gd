extends Node2D

onready var alive = false
onready var sprite = get_node("./Sprite")

func alive():
	alive = true
	sprite.visible = true

func kill():
	alive = false
	sprite.visible = false

