extends Node2D

#
# FIXME Consider moving this whole dealie into Health
#

var greenBar = preload("res://UI/bar-green.png")
var yellowBar = preload("res://UI/bar-yellow.png")
var redBar = preload("res://UI/bar-red.png")

onready var healthbar = $Healthbar

func _ready():
  # TODO Init with max health
  hide()

func update_display(n):
  healthbar.texture_progress = greenBar
  if n < healthbar.max_value * 0.75:
      healthbar.texture_progress = yellowBar
  if n < healthbar.max_value * 0.35:
      healthbar.texture_progress = redBar
  if n < healthbar.max_value:
      show()
  healthbar.value = n