extends Node

onready var player = get_node('/root/Game/World/Player') # FIXME Do better
onready var spawners = []
onready var enemies = []

func on_enemy_spawned(enemy):
	print('enemyOrchestrator handling %s spawn...' % enemy.name)
	enemy.set_focus(player)
	enemies.append(enemy)

func on_spawner_hidden(spawner):
	spawner.start_spawning()

func on_spawner_visible(spawner):
	spawner.stop_spawning()

func attach_spawner(spawner):
	print('enemyOrchestrator initialising spawner %s' % [spawner.name])
	spawner.start_spawning()
	spawners.append(spawner)
