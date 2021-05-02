extends Node

export var ATTACK_DAMAGE := 0.0
export var ATTACK_COOLDOWN := 0.0

onready var _attack = $Attack
onready var _hurt = $Hurt

func _ready():
	# TODO Set up hurt anim
	_hurt.set_rect(get_parent().get_node('./ColorRect'))

	print('%s is set up for combat: %s' % [
		get_parent().name,
		{
			'ATTACK_DAMAGE': _attack.ATTACK_DAMAGE,
			'ATTACK_COOLDOWN': _attack.ATTACK_COOLDOWN,
			'HURT_RECT': _hurt.get_rect()
		}
	])

func attack(target):
	_attack.damage(target)

func hurt():
	print('HURT!')
	_hurt.flash()
