extends Node

onready var player = get_node('World/Player')
onready var dog = get_node_or_null('World/Dog')
onready var world = $World
onready var ui = get_node('UI')
onready var enemyOrchestrator = get_node('EnemyOrchestrator')

func _init():
	randomize() # Init random seed using time

func _ready():
	#
	# FIXME Have these objects all set their own connections on instantiated
	#

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
		toNode.queue_free()

	if toNode.has_method('set_knockback'):
		var knockback = fromNode.position.direction_to(toNode.position)
		toNode.set_knockback(knockback * fromNode.combat.KNOCKBACK_FORCE)

	if toNode.health.HEALTH_REGEN:
		toNode.health.reset_health_regen_timer(toNode.health.HEALTH_REGEN_WAIT)

func mood_changed(node, mood, old_value, new_value):
	if node.has_node('MoodDisplay'):
		pass # FIXME Unimplemented instance local moods in scene
	if node.SLUG == 'dog':
		ui.get_node('DogUI/MoodDisplay').update_mood(node.mood.MOOD_NAMES[mood], old_value, new_value)
	else:
		pass # TODO Implement mood visuals for zombie

func mood_maxed(node, mood):
	if node.mood.get_current() == mood: return

	if node.SLUG == 'dog':
		ui.get_node('DogUI/MoodDisplay').on_mood_maxed(node.mood.MOOD_NAMES[mood])
	node.mood.on_mood_maxed(mood)

func mood_maxed_decaying(node, mood):
	pass # TODO Gradual visual decay

func mood_maxed_over(node, mood):
	ui.get_node('DogUI/MoodDisplay').on_mood_maxed_over(node.mood.MOOD_NAMES[mood])

func mood_zeroed(node, mood):
	node.mood.on_mood_zeroed(mood)

func mood_over_maxed(node, mood, amount):
	#print('%s is over mood max "%s" by %d' % [node.name, node.mood.MOOD_NAMES[mood], amount])
	pass # FIXME Call down to node -> mood to extend max countdown?

func health_changed(node, _oldHealth, newHealth):
	if node.healthDisplay:
		node.healthDisplay.update_display(newHealth)

func health_depleted(overkill, node):
	enemyOrchestrator.on_health_depleted(overkill, node)

func eat(eater, eated):
	eater.health.change(eated.HEALING_POINTS)
	eated.queue_free()
