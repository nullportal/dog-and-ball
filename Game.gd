extends Node

onready var player = get_node('World/Player')
onready var dog = get_node('World/Dog')
onready var world = $World

func _ready():
	player.connect('BALL_THROWN', world, 'ball_thrown')
	player.connect('COMMAND', dog, 'command')
	dog.connect('GIVE_UP', player, 'take')
