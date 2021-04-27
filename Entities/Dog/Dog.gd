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
var holding_ball = false
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
		'allure': 10,
	},
	'zombie': {
		'follow_distance': 32,
		'allure': 1,
	},
	'ball': {
		'follow_distance': 8,
		'allure': 500,
	},
}

func _ready():
	self.connect('DAMAGE', get_node('/root/Game'), 'damage_target')

func _physics_process(_delta):
	var foci = self.find_foci(noticeArea)
	if foci.size() > 0:
		self.focus = self.find_focus(foci)

	# Prevent crash when tracking destroyed targets
	if !is_instance_valid(self.focus):
		return

	match state:
		FOLLOW:
			self.follow(self.focus)

	if self.focus.is_in_group('Enemies'):
		if self.can_attack(self.focus):
			self.attack(self.focus)

func find_foci(area):
	var noticed = area.get_overlapping_bodies()
	var filtered = []
	for n in noticed:
		if n == self:
			continue
		filtered.append(n)
	return filtered

# TODO Reproduce extra allure of Player holding Ball
func rank_foci(nodes):
	if nodes.size() <= 1:
		return [{'node': nodes[0]}]
	var foci = []
	for node in nodes:
		var distance = self.global_position.distance_to(node.global_position)
		var allure = focus_map[node.SLUG].allure
		var entry = {
			'sort_key': allure - distance,
			'node': node,

			# Some debug members while tweaking this
			'_distance': distance,
			'_allure': allure,
			'_slug': node.SLUG,
		}
		foci.append(entry)

	# NOTE Oh jeez, mutation >_<
	foci.sort_custom(self, '_sort_nodes')
	return foci

func find_focus(nodes):
	var focus = self.rank_foci(nodes)[0].node
	if typeof(self.focus) != typeof(focus) || self.focus != focus:
		print('%s focus change to %s' % [self.SLUG, focus.SLUG])

	return focus

func follow(target):
	if !target:
		return

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

func can_attack(focus):
	return attackArea.overlaps_body(focus)

func attack(target):
	emit_signal('DAMAGE', target, self.ATTACK_DAMAGE)

# NOTE Requires dict with 'sort_key'
func _sort_nodes(a, b):
	return a.sort_key > b.sort_key
