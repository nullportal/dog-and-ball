extends KinematicBody2D

signal GIVE(item, from, to)
signal EAT(item, me)

export var MAX_SPEED = 128
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
onready var mood = $Mood
onready var noticeArea = $NoticeArea
onready var pickupArea = $PickupArea
onready var aggroArea = $AggroArea
onready var attackArea = $AttackArea
onready var combat = $Combat
onready var healthDisplay = $HealthDisplay

var enemy_groups = [
	'Enemies',
]
var focus_map = {
	'player': {
		'follow_distance': 64,
		'allure': 10,
		'fear': 0.0,
	},
	'zombie': {
		'follow_distance': 32,
		'allure': 1,
		'fear': 10.0,
	},
	'ball': {
		'follow_distance': 8,
		'allure': 500,
		'fear': null,
	},
	'bones': {
		'follow_distance': 1,
		'allure': null,
		'fear': null,
	},
}

func _ready():
	var conn
	conn = self.connect('EAT', get_node('/root/Game'), 'eat')
	if conn != 0:
		assert(false, 'Failed to connect signal')

func _physics_process(_delta):
	var foci = find_foci(noticeArea)
	if foci.size() > 0:
		self.focus = find_focus(foci)

	mood.set_mood(mood.AFRAID, find_fear(foci))
	mood.set_mood(mood.ANGRY, find_anger(foci))

	# Prevent crash when tracking destroyed targets
	if !is_instance_valid(self.focus):
		return

	match state:
		FOLLOW:
			follow(self.focus)

	if is_enemy(self.focus):
		if can_reach(self.focus):
			attack(self.focus)

	if self.focus.is_in_group('Food'):
		if can_reach(self.focus):
			eat(self.focus)

func is_enemy(node):
	for group in enemy_groups:
		if node.is_in_group(group):
			return true
	return false

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
		var deets = focus_map[node.SLUG]
		if !deets:
			continue

		var allure = deets.allure
		# If no innate allure, provide it programatically
		if allure == null && ['bones'].has(node.SLUG):
			if !node.is_edible():
				continue
			var missing_health = (health.MAX_HEALTH - health.HEALTH_POINTS)
			if missing_health > 0:
				allure = node.HEALING_POINTS / missing_health
			else:
				allure = missing_health

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
	var focus = rank_foci(nodes)[0].node
	if typeof(self.focus) != typeof(focus) || self.focus != focus:
			pass #print('%s focus change to %s' % [self.SLUG, focus.SLUG])

	return focus

func find_fear(nodes, personal_space_dist = 50):
	var health_insecurity = (health.MAX_HEALTH / health.HEALTH_POINTS)
	var fear = 0.0
	for node in nodes:
		var deets = focus_map[node.SLUG]
		if !deets || !deets['fear']:
			continue

		var dist = global_position.distance_to(node.global_position)
		if dist == 0:
			continue

		# TODO Factor in fear - shouldn't top out easily if HP > 1/2

		var closeness = (personal_space_dist / dist)
		fear += closeness * deets['fear']

	return fear + health_insecurity

func find_anger(nodes, damage_dealt_trigger = 6):
	var current_attack_target = combat.get_damage_target()
	if is_instance_valid(current_attack_target) && current_attack_target.SLUG == 'player':
		return 0

	# FIXME Damage *received* should count towards anger as well, but only until
	# an inverse trigger, after which it contributes to fear ...?

	# FIXME Not sure if health boldness works here... plays out artificially when dog regains HP suddenly
	var health_boldness = (health.HEALTH_POINTS / (health.MAX_HEALTH / 0.5))
	var anger = ((combat.get_damage_dealt() * 75) / damage_dealt_trigger) * health_boldness + 1

	return anger

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
	if command_name == 'attack': # TODO Implement attack as a command
		attack(context)

func give(item_name):
	emit_signal('GIVE', item_name, self, player)

# NOTE Slightly hacky: Just manually sets focus to player,
# but could still be distracted by more alluring targets
func retrieve(_item):
	self.focus = player

func can_reach(target):
	return attackArea.overlaps_body(target)

func attack(target):
	combat.attack(target)

func eat(target):
	emit_signal('EAT', self, target)

func on_mood_maxed(m):
	if m == mood.ANGRY:
		enemy_groups.append('Player')
		focus_map['player']['follow_distance'] /= 4
		combat.ATTACK_COOLDOWN /= 2
		combat.KNOCKBACK_FORCE *= 1.5
	elif m == mood.AFRAID:
		enemy_groups.remove(enemy_groups.find('Enemies', 0))
		focus_map['player']['follow_distance'] /= 4
		focus_map['player']['allure'] *= 10
		focus_map['zombie']['fear'] *= 2
		focus_map['zombie']['allure'] *= -1
		health.HEALTH_REGEN = true

func on_mood_maxed_over(m):
	if m == mood.ANGRY:
		enemy_groups.remove(enemy_groups.find('Player', 0))
		focus_map['player']['follow_distance'] *= 4
		combat.ATTACK_COOLDOWN *= 2
		combat.KNOCKBACK_FORCE /= 1.5
	elif m == mood.AFRAID:
		enemy_groups.append('Enemies')
		focus_map['player']['follow_distance'] *= 4
		focus_map['player']['allure'] /= 10
		focus_map['zombie']['fear'] /= 2
		focus_map['zombie']['allure'] *= -1
		health.HEALTH_REGEN = false

# NOTE Requires dict with 'sort_key'
func _sort_nodes(a, b):
	return a.sort_key > b.sort_key
