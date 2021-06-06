extends Node

onready var player = get_node('World/Player')
onready var dog = get_node_or_null('World/Dog')
onready var world = $World
onready var ui = get_node('UI')
onready var enemyOrchestrator = get_node('EnemyOrchestrator')

func _init():
	randomize() # Init random seed using time

func _ready():
	player.connect('BALL_THROWN', world, 'ball_thrown')
	world.connect('UPDATE_HELD_ITEM', ui, 'update_held_item') # For take

	if dog:
		player.connect('COMMAND', dog, 'command')
		dog.connect('GIVE', world, 'give')

func on_spawner_ready(spawner):
	enemyOrchestrator.call_deferred('attach_spawner', spawner)
func on_spawner_visible(spawner):
	enemyOrchestrator.on_spawner_visible(spawner)
func on_spawner_hidden(spawner):
	enemyOrchestrator.on_spawner_hidden(spawner)
func on_enemy_spawned(enemy):
	enemyOrchestrator.on_enemy_spawned(enemy)

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

	if toNode.health.HEALTH_REGEN:
		toNode.health.reset_health_regen_timer(toNode.health.HEALTH_REGEN_WAIT)

func mood_changed(node, mood, oldValue, newValue):
	if node.has_node('MoodDisplay'):
		pass # FIXME Unimplemented instance local moods in scene
	if node.SLUG == 'dog':
		ui.get_node('DogUI/MoodDisplay').update_mood(node.mood.MOOD_NAMES[mood], oldValue, newValue)

func mood_limit_reached(node, mood): # FIXME '_maxed' better name for this
	pass # TODO
func mood_zeroed(node, mood):
	pass # TODO

# TODO Like this but for mood
func health_changed(node, oldHealth, newHealth):
	if node.healthDisplay:
		print('%s health changed from %s to %s'%[node.name, oldHealth, newHealth])
		node.healthDisplay.update_display(newHealth)

func health_depleted(overkill, node):
	enemyOrchestrator.on_health_depleted(overkill, node)

func eat(eater, eated):
	eater.health.change(eated.HEALING_POINTS)
	eated.queue_free()
	print('%s ate %s for %sHP' % [eater.name, eated.name, eated.HEALING_POINTS])
