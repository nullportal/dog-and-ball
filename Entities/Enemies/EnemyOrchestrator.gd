extends Node

export var HEALTH_DROP_CHANCE = 0.25

onready var Bones = preload("res://Items/Bones.tscn")
onready var player = get_node('/root/Game/World/Player') # FIXME Do better
onready var world = get_node('/root/Game/World')
onready var spawners = []
onready var enemies = []

func on_enemy_spawned(enemy):
	enemy.set_focus(player)
	enemies.append(enemy)

func on_spawner_hidden(spawner):
	spawner.start_spawning()

func on_spawner_visible(spawner):
	spawner.stop_spawning()

func on_health_depleted(overkill, node):
	if rand_range(0, 1) <= HEALTH_DROP_CHANCE:
		var bones = Bones.instance()
		bones.global_position = node.global_position
		world.add_child(bones)


func attach_spawner(spawner):
	spawner.start_spawning()
	spawners.append(spawner)
