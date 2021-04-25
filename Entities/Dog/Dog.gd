extends KinematicBody2D

signal GIVE(item, from, to)
signal DAMAGE(target, amount)

export var MAX_SPEED = 128
export var ATTACK_DAMAGE = 1
export var SLUG = 'dog'

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
onready var health = $Health
onready var noticeArea = $NoticeArea
onready var pickupArea = $PickupArea
onready var aggroArea = $AggroArea
onready var attackArea = $AttackArea

var focus_map = {
	'player': {
		'follow_distance': 64,
	},
	'zombie': {
		'follow_distance': 32,
	},
	'ball': {
		'follow_distance': 8,
	},
}

func _ready():
	self.connect('DAMAGE', get_node('/root/Game'), 'damage_target')

func _physics_process(_delta):
	var foci = self.find_foci(noticeArea)
	if foci.size() > 0:
		self.focus = self.find_focus(foci)

	match state:
		FOLLOW:
			follow(self.focus)

func find_foci(area):
	var noticed = area.get_overlapping_bodies()
	return noticed

func rank_foci(nodes):
	# TODO Rank and find singular focus
	var foci = []
	for node in nodes:
		pass

func find_focus(nodes):
	var foci = self.rank_foci(nodes)

	for node in nodes:
		if node.is_in_group('Enemies'):

			# TODO Move this condition elsewhere
			if attackArea.overlaps_body(node):
				self.attack(node)
			return node
		if node.name == 'Ball':
			return node
		if node.name == 'Player':
			if node.holding_ball:
				return node
	return self.focus

func follow(target):
	if target && state == FOLLOW:
		var follow_distance = self.focus_map[target.SLUG].follow_distance
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
	if command_name == 'attack':
		attack(context)

func give(item_name):
	emit_signal('GIVE', item_name, self, player)

func retrieve(item):
	print(self.name, ' is trying to retrieve ', item)
	self.focus = player

func attack(target):
	emit_signal('DAMAGE', target, self.ATTACK_DAMAGE)
