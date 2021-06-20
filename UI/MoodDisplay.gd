extends Node2D

onready var fearBubble = $MoodBubblesControl/FearBubble
onready var rageBubble = $MoodBubblesControl/RageBubble
onready var animationPlayer = AnimationPlayer.new()

func _ready():
	for m in [
		{'bubble': fearBubble, 'name': 'AFRAID'},
		{'bubble': rageBubble, 'name': 'ANGRY'}
	]:
		_setup_mood_animation(m['bubble'], m['name'])
	if !get_parent().name == 'DogUI':
		hide()

func _unhandled_input(event):
	if get_parent().name == 'DogUI':
		return
	if !event.is_action_pressed('show_extra_ui'):
		return

	if visible:
		hide()
	else:
		show()

func update_mood(mood_name, old_value, new_value):
	# FIXME If significant spike, visualise
	if mood_name == 'AFRAID':
		fearBubble.value = new_value
	elif mood_name == 'ANGRY':
		rageBubble.value = new_value

func on_mood_maxed(mood_name):
	animationPlayer.play('moodlet_flash_'+mood_name)

func on_mood_decay(mood_name):
	pass # TODO On signal from Mood timer

func on_mood_maxed_over(mood_name):
	animationPlayer.stop(true)

func _setup_mood_animation(mood_bubble, mood_name):
	var spriteProperty = 'tint_progress'
	var sprite = mood_bubble
	var spritePropertyPath = '{path}:{property}'.format(
		{
			'path': String(sprite.get_path()),
			'property': spriteProperty
		}
	)
	var mood_flash = Animation.new()
	var trackIdx = mood_flash.add_track(Animation.TYPE_VALUE)
	mood_flash.track_set_path(trackIdx, spritePropertyPath)
	mood_flash.length = 0.2
	mood_flash.set_loop(true)
	
	var og = Color(1, 1, 1, 1)
	var lighten = Color(og.r * 1.5, og.g * 1.5, og.b * 1.5, 1)
	var darken = Color(og.r / 1.5, og.g / 1.5, og.b / 1.5, 1)

	mood_flash.track_insert_key(trackIdx, 0.0, og)
	mood_flash.track_insert_key(trackIdx, 0.01, lighten)
	mood_flash.track_insert_key(trackIdx, 0.2, darken)

	add_child(animationPlayer)
	animationPlayer.add_animation('moodlet_flash_'+mood_name, mood_flash)
