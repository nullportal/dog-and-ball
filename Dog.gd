extends KinematicBody2D

signal GIVE_UP(item_name, to_name)

export var MAX_SPEED = 128

enum {
	FOLLOW,
	WANDER,
	IDLE,
}
var focus = null
var state = FOLLOW
var holding_ball = true
var velocity = Vector2.ZERO

onready var player = get_node('/root/Game/World/Player')
onready var noticeArea = $NoticeArea
onready var pickupArea = $PickupArea
onready var aggroArea = $AggroArea

var follow_distances = {
	'Player': 64,
	'Ball': 4
}

func _physics_process(_delta):
	self.focus = self.find_focus()

	match state:
		FOLLOW:
			follow(self.focus)

func find_focus():
	var nodes = get_node('/root/Game/World').get_children()
	var noticed = noticeArea.get_overlapping_bodies()

	for node in nodes:
		if !node in noticed:
			continue
		if node.name == 'Ball':
			return node
		if node.name == 'Player':
			if node.holding_ball:
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

func command(command_name, context):
	if command_name == 'give':
		give(context)
	if command_name == 'retrieve':
		retrieve(context)

func give(item_name):
	emit_signal('GIVE_UP', item_name)
	self.holding_ball = false

func retrieve(item):
	print(self.name, ' is trying to retrieve ', item)
	self.focus = player
