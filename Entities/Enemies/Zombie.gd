extends KinematicBody2D

export var MAX_SPEED = 16
export var SLUG = 'zombie'

enum {
	FOLLOW,
	WANDER,
	IDLE,
	ATTACK,
}
enum STATE {
	IDLE,
	FOLLOW,
	ATTACK,
}

var focus = null setget set_focus, get_focus
func set_focus(f):
	focus = f
func get_focus():
	return focus
var state = IDLE
var velocity = Vector2.ZERO
# FIXME Move kb logic to general location, so can be applied universally
var knockbackVelocity = Vector2.ZERO setget set_knockback
func set_knockback(kb):
	knockbackVelocity = kb

onready var aggroArea = $AggroArea
onready var noticeArea = aggroArea # FIXME Make its own thing when warranted
onready var attackArea = $AttackArea
onready var health = $Health
onready var combat = $Combat
onready var healthDisplay = $HealthDisplay
onready var mood = $Mood

var follow_distances = {
	'player': 28,
	'dog': 28,
	'enemy-spawner': 28,
}

func _physics_process(_delta):
	self.focus = self.find_focus()
	if self.focus && attackArea.overlaps_body(self.focus):
		state = ATTACK
	else:
		state = FOLLOW

	mood.set_mood(mood.AFRAID, find_fear())

	match state:
		FOLLOW:
			follow(self.focus)
		ATTACK:
			attack(self.focus)

	var velocities = apply_velocity(velocity, knockbackVelocity, 150)
	velocity = velocities['movement']
	knockbackVelocity = velocities['knockback']

func find_fear(afraid_peers_limit = 3):
	return 0 # TODO Actually implement when there is a gameplay need

func on_mood_maxed(m):
	if m == mood.AFRAID:
		MAX_SPEED = MAX_SPEED * 3
		var spawns = []
		for node in get_node('/root/Game/World').get_children():
			if !node.get('SLUG'): continue

			if node.SLUG == 'enemy-spawner':
				spawns.append(node)
		if spawns.size() > 0:
			self.focus = spawns[randi()%spawns.size()] # FIXME Go to closest

func on_mood_maxed_over(m):
	if m == mood.AFRAID:
		MAX_SPEED = MAX_SPEED / 3

func find_focus():
	if mood.get_current() == mood.AFRAID: return self.focus

	var nodes = aggroArea.get_overlapping_bodies()
	for node in nodes:
		if node.name == 'Player':
			return node
		if node.name == 'Dog':
			return node
	return self.focus

func follow(target):
	#self.modulate = Color( 100, 100, 100, 1 )
	if target && state == FOLLOW:
		var follow_distance = self.follow_distances[target.SLUG]
		var distance_to_target = self.position.distance_to(target.position)
		if distance_to_target <= follow_distance:
			return

		velocity = position.direction_to(target.position) * MAX_SPEED
		return velocity # Global scope so kinda doesn't matter

func apply_velocity(v, kbv, kbStrength = 200):
	v = move_and_slide(v)
	if kbv != Vector2.ZERO:
		kbv = kbv.move_toward(Vector2.ZERO, kbStrength)
		kbv = move_and_slide(kbv)

	return {'movement': v, 'knockback': kbv}

func attack(target):
	combat.attack(target)
