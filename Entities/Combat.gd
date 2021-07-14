extends Node

export var ATTACK_DAMAGE := 0.0
export var ATTACK_COOLDOWN := 0.0
export var ATTACK_SPINUP := 0.0
export var KNOCKBACK_FORCE := 0
export var HURT_PROPERTIES := {'spritePath': null, 'spriteProperty': null, 'effects': []}

onready var _attack = $Attack
onready var _hurt = $Hurt

onready var damage_dealt = 0 setget , get_damage_dealt
onready var damage_received = 0 setget , get_damage_received
onready var damage_target = null setget , get_damage_target
func get_damage_target(): return damage_target
func get_damage_dealt(): return damage_dealt
func get_damage_received(): return damage_received
var attacking_timer = null
var spinup_timer = null

onready var parent = get_parent()

func _enter_tree():
	# FIXME Load this up in a config at some point,
	# but this is the const convention I'm assuming for now.
	self.HURT_PROPERTIES = {
		'spritePath': NodePath(String(get_parent().get_path())+'/Sprite'),
		'spriteProperty': 'modulate',
		'effects': ['pain-flash']
	}

func _ready():
	self.attacking_timer = _init_timer(5.0, '_on_attacks_over')
	self.spinup_timer = _init_timer(self.ATTACK_SPINUP, '_on_spinup_over')

# Track damage done and received in last interval
# FIXME This may not be the best place for this ...
func attack(target, engagement_length = 5.0):
	if spinup_timer.time_left <= 0.0:
		spinup_timer.start(self.ATTACK_SPINUP)
		return

	var damage = _attack.damage(parent, target)

	# For external getters
	if damage: damage_dealt += damage
	if is_instance_valid(target): damage_target = target

	attacking_timer.start(engagement_length)

func hurt():
	_hurt.pain()

# Just reset rolling damage for now
func _on_attacks_over():
	damage_dealt = 0

func _on_spinup_over():
	pass # Stub for timer.start

func _init_timer(wait_time, callback):
	var t = Timer.new()
	t.set_one_shot(true)
	t.set_wait_time(wait_time)
	t.connect('timeout', self, callback)
	add_child(t)

	return t
