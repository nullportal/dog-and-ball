extends Node

export var ATTACK_DAMAGE := 0.0
export var ATTACK_COOLDOWN := 0.0
export var KNOCKBACK_FORCE := 0
export var HURT_PROPERTIES := {'spritePath': null, 'spriteProperty': null, 'effects': []}

onready var _attack = $Attack
onready var _hurt = $Hurt

onready var parent = get_parent()

func _enter_tree():
	# FIXME Load this up in a config at some point,
	# but this is the const convention I'm assuming for now.
	self.HURT_PROPERTIES = {
		'spritePath': NodePath(String(get_parent().get_path())+'/ColorRect'),
		'spriteProperty': 'color',
		'effects': ['pain-flash']
	}

func _ready():
	print('%s is set up for combat: %s' % [
		get_parent().name,
		{
			'ATTACK_DAMAGE': _attack.ATTACK_DAMAGE,
			'ATTACK_COOLDOWN': _attack.ATTACK_COOLDOWN,
			'HURT_PROPERTIES': _hurt.HURT_PROPERTIES
		}
	])

func attack(target):
	_attack.damage(parent, target)

func hurt():
	_hurt.pain()
