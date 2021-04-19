extends KinematicBody2D

signal DAMAGE(target, amount)

export var MAX_SPEED = 16
export var ATTACK_DAMAGE = 1

enum {
	FOLLOW,
	WANDER,
	IDLE,
	ATTACK,
}

var focus = null
var state = FOLLOW
var velocity = Vector2.ZERO

# TODO Add attack cooldown

onready var aggroArea = $AggroArea
onready var attackArea = $AttackArea
onready var health = $Health

var follow_distances = {
	'Player': 28,
	'Dog': 28,
}

func _physics_process(_delta):
	self.focus = self.find_focus()
	if attackArea.overlaps_body(self.focus):
		self.attack(self.focus)

	match state:
		FOLLOW:
			follow(self.focus)
		ATTACK:
			pass

func find_focus():
	var nodes = aggroArea.get_overlapping_bodies()
	for node in nodes:
		if node.name == 'Player':
			return node
		if node.name == 'Dog':
			return node
	return self.focus

func follow(target):
	if target && state == FOLLOW:
		var follow_distance = self.follow_distances[target.name]
		var distance_to_target = self.position.distance_to(target.position)
		if distance_to_target <= follow_distance:
			return

		velocity = position.direction_to(target.position) * MAX_SPEED
		velocity = move_and_slide(velocity)

func attack(target):
	emit_signal('DAMAGE', target, self.ATTACK_DAMAGE)
