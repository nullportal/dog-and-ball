extends Node

onready var health = $Health
onready var player = get_node('World/Player')
onready var dog = get_node('World/Dog')
onready var world = $World
onready var ui = get_node('UI/PlayerUI')

func _ready():
	player.connect('BALL_THROWN', world, 'ball_thrown')
	player.connect('COMMAND', dog, 'command')
	dog.connect('GIVE_UP', player, 'take')
	player.connect('UPDATE_HELD_ITEM', ui, 'update_held_item')

func damage_target(target, amount):
	if !target || !target.health:
		return
	target.health.reduce(amount)
	print(target.name, ' damaged for ', amount, ' points')
	if target.health.HEALTH_POINTS <= 0:
		print(target.name, ' destroyed!')
		target.queue_free()
