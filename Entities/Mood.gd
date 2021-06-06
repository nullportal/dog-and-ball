extends Node

signal MOOD_LIMIT_REACHED(me, moodName)
signal MOOD_CHANGED(me, moodName, old_mood, new_mood)
signal MOOD_ZEROED(me, moodName)

# TODO Mood sytem with defined states, weights, and callbacks for reactions to states

enum {
	NEUTRAL,
	ANGRY,
	AFRAID,
}
export var MOOD_NAMES = {
	NEUTRAL: 'NEUTRAL',
	ANGRY: 'ANGRY',
	AFRAID: 'AFRAID',
}

export var default_mood = NEUTRAL
export var weights = {
	ANGRY: 1.0, # Aggression
	AFRAID: 1.0 # Insecurity
}

export var MOOD_DECAY_RATE = 1.0
export var LEVELS = {
	ANGRY: 0.0,
	AFRAID: 0.0,
}

onready var mood_owner = get_parent()

var current = default_mood setget , get_current
func get_current():
	return current

# TODO Register mood reactions (impl)
func _ready():
	self.connect('MOOD_LIMIT_REACHED', get_node('/root/Game'), 'mood_limit_reached')
	self.connect('MOOD_CHANGED', get_node('/root/Game'), 'mood_changed')
	self.connect('MOOD_ZEROED', get_node('/root/Game'), 'mood_zeroed')

# TODO If +raw+ don't apply modifiers
#though don't really have a need for this yet...
func set_mood(mood, n, _raw = false):
	var old_mood = LEVELS[mood]
	var new_mood = (n * weights[mood])
	LEVELS[mood] = new_mood
	if old_mood != new_mood:
		emit_signal('MOOD_CHANGED', mood_owner, mood, old_mood, new_mood)
