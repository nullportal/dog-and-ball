extends Node

onready var player = get_node('World/Player')
onready var world = $World

func _ready():
	player.connect('BALL_THROWN', world, 'ball_thrown')
