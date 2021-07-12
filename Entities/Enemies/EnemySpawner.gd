extends Node2D

signal SPAWNER_READY(spawner)
signal ENEMY_SPAWNED(enemy)

var Zombie = preload("res://Entities/Enemies/Zombie.tscn")

export var SLUG = 'enemy-spawner'

export var MAX_SPAWNS = 10
export var SPAWN_INTERVAL = 5
export var INSTANCES_PER_SPAWN = 3
export var SPAWN_CHOICES = ['Zombie']
enum SPAWN_STATE {
	ACTIVE,
	PAUSED,
	EMPTY,
}

onready var shape = $Area2D/CollisionShape2D.shape
onready var spawnTimer = $SpawnTimer

var state = null
var no_spawns = 0

func _ready():
	self.connect('SPAWNER_READY', get_node('/root/Game'), 'on_spawner_ready')
	self.connect('ENEMY_SPAWNED', get_node('/root/Game'), 'on_enemy_spawned')
	self.call_deferred('emit_signal', 'SPAWNER_READY', self) # Wait for Game-orthogonal dep

func _process(_delta):

	if no_spawns >= MAX_SPAWNS:
		print('%s is out of spawns!', self.name)
		state = SPAWN_STATE.EMPTY
		queue_free() # FIXME Something from Orchestrator

	match state:
		SPAWN_STATE.ACTIVE:
			if !spawnTimer.time_left:
				no_spawns += 1
				spawnTimer.start(SPAWN_INTERVAL)
				var enemy = spawn_enemy(get_random_point())
				emit_signal('ENEMY_SPAWNED', enemy)
		SPAWN_STATE.PAUSED:
			pass # I Dunno, I guess don't do anything
		SPAWN_STATE.EMPTY:
			pass # TODO Send signal, and probably die

func start_spawning():
	print('%s activated' % self.name)
	state = SPAWN_STATE.ACTIVE

func stop_spawning():
	print('%s paused' % self.name)
	state = SPAWN_STATE.PAUSED

func spawn_enemy(pos):
	var world = get_node('/root/Game/World')
	var enemy = Zombie.instance()
	enemy.global_position = pos
	world.call_deferred('add_child', enemy)

	return enemy

func get_random_point():
	var r = shape.radius * sqrt(rand_range(0, 1))
	var theta = rand_range(0, 1) * 2 * PI
	var x = global_position.x + r * cos(theta)
	var y = global_position.y + r * sin(theta)

	return Vector2(x,y)

