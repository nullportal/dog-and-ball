extends KinematicBody2D

export var MAX_SPEED = 16

enum {
	FOLLOW,
	WANDER,
	IDLE,
}

var focus = null
var state = FOLLOW
var velocity = Vector2.ZERO

onready var aggroArea = $AggroArea

var follow_distances = {
	'Player': 8,
	'Dog': 8,
}

func _physics_process(_delta):
	self.focus = self.find_focus()

	match state:
		FOLLOW:
			follow(self.focus)

func find_focus():
	#var nodes = get_node('/root/Game/World').get_children()
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