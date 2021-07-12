extends Node

signal MOOD_MAXED(me, moodName)
signal MOOD_MAXED_OVER(me, moodName)
signal MOOD_OVER_MAXED(me, mood, amount)
signal MOOD_CHANGED(me, moodName, old_mood, new_mood)
signal MOOD_ZEROED(me, moodName)
signal MOOD_INCREASED(me, mood, amount)
signal MOOD_DECREASED(me, mood, amount)

const MOOD_MAX = 100
const MOOD_MIN = 0
const MOOD_MAXED_TIMER = 5.0

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

export var DEFAULT_MOOD = NEUTRAL
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

# Dominant mood - usage is this mood is currently affecting behaviour
var current = DEFAULT_MOOD setget set_current, get_current
func get_current():
	return current
func set_current(m):
	current = m

var mood_maxed_timers = {
	ANGRY: _init_timer(weights[ANGRY] * MOOD_MAXED_TIMER, 'on_mood_maxed_over', [ANGRY]),
	AFRAID: _init_timer(weights[AFRAID] * MOOD_MAXED_TIMER, 'on_mood_maxed_over', [AFRAID]),
}

func _ready():
	assert(mood_owner.has_method('on_mood_maxed'), 'Mood owner missing DI "on_mood_maxed"')
	assert(mood_owner.has_method('on_mood_maxed_over'), 'Mood owner missing DI "on_mood_maxed_over"')

	self.connect('MOOD_MAXED', get_node('/root/Game'), 'mood_maxed')
	self.connect('MOOD_CHANGED', get_node('/root/Game'), 'mood_changed')
	self.connect('MOOD_ZEROED', get_node('/root/Game'), 'mood_zeroed')
	self.connect('MOOD_OVER_MAXED', get_node('/root/Game'), 'mood_over_maxed')
	self.connect('MOOD_MAXED_OVER', get_node('/root/Game'), 'mood_maxed_over')
	self.connect('MOOD_INCREASED', get_node('/root/Game'), 'mood_increased')
	self.connect('MOOD_DECREASED', get_node('/root/Game'), 'mood_decreased')

func _unhandled_input(event):
	if !event is InputEventKey:
		return
	if event.scancode == KEY_1:
		print('Debug anger')
		set_mood(ANGRY, MOOD_MAX)
	elif event.scancode == KEY_2:
		print('Debug fear')
		set_mood(AFRAID, MOOD_MAX)

func set_mood(mood, n, min_change = MOOD_MAX / 16.0):
	if !mood_maxed_timers[mood].time_left:
		mood_maxed_timers[mood].stop()

	var old_mood = LEVELS[mood]
	var new_mood = n
	var mood_diff = new_mood - old_mood

	if abs(new_mood - old_mood) < min_change:
		return

	new_mood *= weights[mood]
	LEVELS[mood] = new_mood

	emit_signal('MOOD_CHANGED', mood_owner, mood, old_mood, new_mood)
	if new_mood >= MOOD_MAX:
		emit_signal('MOOD_MAXED', mood_owner, mood)
	if new_mood <= MOOD_MIN:
		emit_signal('MOOD_ZEROED', mood_owner, mood)
	if new_mood < old_mood:
		emit_signal('MOOD_DECREASED', mood_owner, mood, mood_diff)
	if new_mood > old_mood:
		emit_signal('MOOD_INCREASED', mood_owner, mood, mood_diff)


	# TODO If current dominant mood is the same, do... something
	#make maxed mood "stickier"
	if current == mood && old_mood >= MOOD_MAX:
		var mood_value_change = (MOOD_MAX - old_mood) # XXX Err, this is wrong
		if mood_value_change > 0:
			emit_signal('MOOD_OVER_MAXED', mood_owner, mood, mood_value_change)
	else:
		pass # Else what ???

func on_mood_maxed(m):
	# TODO Increased to this mood extend timer indefinitely

	set_current(m)
	mood_maxed_timers[m].start()
	mood_owner.on_mood_maxed(m)

func on_mood_maxed_over(m):
	set_current(DEFAULT_MOOD)
	var timer = mood_maxed_timers[m]
	if timer.time_left:
		timer.stop()
	mood_owner.on_mood_maxed_over(m)
	emit_signal('MOOD_MAXED_OVER', mood_owner, m)

func on_mood_zeroed(m):
	LEVELS[m] = 0
	if get_current() != DEFAULT_MOOD:
		on_mood_maxed_over(m)

func _init_timer(wait_time, callback, params = []):
	var t = Timer.new()
	t.set_one_shot(true)
	t.set_wait_time(wait_time)
	t.connect('timeout', self, callback, params)
	add_child(t)

	return t
