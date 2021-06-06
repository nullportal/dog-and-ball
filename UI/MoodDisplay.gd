extends Node2D

onready var fearBar = $MoodbarsControl/FearBar
onready var rageBar = $MoodbarsControl/RageBar

func _ready():
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
	if mood_name == 'AFRAID':
		fearBar.value = new_value
	else:
		fearBar.value = fearBar.max_value
