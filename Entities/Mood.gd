extends Node

# TODO Mood sytem with defined states, weights, and callbacks for reactions to states

enum {
  NEUTRAL,
  ANGRY,
  AFRAID,
}

export var defaultMood = NEUTRAL
export var weights = {
  ANGRY: 1.0,
  AFRAID: 1.0
}

var current = defaultMood setget , get_current
func get_current():
  return current

func _ready():
  pass # TODO Register mood reactions
