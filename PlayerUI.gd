extends Control

onready var held_item = $HeldItem

func update_held_item(item):
	# XXX Hack
	if item == null:
		held_item.visible = false
	else:
		held_item.visible = true
