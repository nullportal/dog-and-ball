extends Node2D

#
# FIXME Consider moving this whole dealie into Health
#

# TODO switch to sheet
var hiBar = preload("res://UI/healthbar-hi.png")
var midBar = preload("res://UI/healthbar-mid.png")
var lowBar = preload("res://UI/healthbar-low.png")

onready var healthbar = $Healthbar

func _ready():
  # TODO Init with max health
  hide()

func update_display(n):
  healthbar.texture_progress = hiBar
  if n < healthbar.max_value * 0.75:
      healthbar.texture_progress = midBar
  if n < healthbar.max_value * 0.35:
      healthbar.texture_progress = lowBar
  if n < healthbar.max_value:
      show()
  healthbar.value = n