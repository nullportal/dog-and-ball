extends CanvasLayer

onready var player_ui = $PlayerUI
onready var player_held_item = get_node('./PlayerUI/HeldItem')
onready var dog_ui = $DogUI
onready var dog_held_item = get_node('./DogUI/HeldItem')

func update_held_item(who, item):
	print('updating %s held item to %s' % [who.name, _desc(item)])
	if who.name == 'Player':
		if item == null:
			player_held_item.visible = false
		else:
			player_held_item.visible = true
	elif who.name == 'Dog':
		if item == null:
			dog_held_item.visible = false
		else:
			dog_held_item.visible = true

func _desc(x):
	if x == null:
		return '[NULL]'
	elif 'name' in x:
		return x.name
	elif 'SLUG' in x:
		return x.SLUG
	else:
		return x
