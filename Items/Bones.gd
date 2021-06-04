extends KinematicBody2D

export var SLUG = 'bones'
export var HEALING_POINTS = 25

onready var edible = false setget set_edible, is_edible
onready var edible_timer = $EdibleTimer

func _on_EdibleTimer_timeout(new_edible):
  set_edible(new_edible)

func is_edible():
  return edible

func set_edible(b):
  edible = b