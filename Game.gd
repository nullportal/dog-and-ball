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

func damage_target(fromNode, toNode, amount):
	if !toNode || !toNode.health:
		return
	if toNode.combat && toNode.combat.has_method('hurt'):
		toNode.combat.hurt()

	toNode.health.reduce(amount)
	if toNode.health.HEALTH_POINTS <= 0:
		print(toNode.name, ' destroyed!')
		toNode.queue_free()

	if toNode.has_method('set_knockback'):
		var knockback = fromNode.position.direction_to(toNode.position)
		toNode.set_knockback(knockback * fromNode.combat.KNOCKBACK_FORCE)

func health_changed(node, oldHealth, newHealth):
	if node.healthDisplay:
		print('%s health changed from %s to %s'%[node.name, oldHealth, newHealth])
		node.healthDisplay.update_display(newHealth)
