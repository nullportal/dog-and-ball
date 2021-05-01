extends Node

onready var player = get_node('World/Player')
onready var dog = get_node_or_null('World/Dog')
onready var world = $World
onready var ui = get_node('UI')

func _ready():
	player.connect('BALL_THROWN', world, 'ball_thrown')
	player.connect('MOVED', ui, 'move_camera')
	world.connect('UPDATE_HELD_ITEM', ui, 'update_held_item') # For take

	if dog:
		player.connect('COMMAND', dog, 'command')
		dog.connect('GIVE', world, 'give')

func damage_target(target, amount):
	if !target || !target.health:
		return
	if target.has_method('hurt_animation'):
		target.hurt_animation()
	target.health.reduce(amount)
	print(target.name, ' damaged for ', amount, ' points')
	if target.health.HEALTH_POINTS <= 0:
		print(target.name, ' destroyed!')
		target.queue_free()
