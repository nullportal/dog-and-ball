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
	if target.combat && target.combat.has_method('hurt'):
		target.combat.hurt()

	target.health.reduce(amount)
	if target.health.HEALTH_POINTS <= 0:
		print(target.name, ' destroyed!')
		target.queue_free()

func health_changed(node, oldHealth, newHealth):
	if node.healthDisplay:
		print('%s health changed from %s to %s'%[node.name, oldHealth, newHealth])
		node.healthDisplay.update_display(newHealth)
