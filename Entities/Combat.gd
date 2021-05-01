extends Node

export var ATTACK_DAMAGE := 0.0
export var ATTACK_COOLDOWN := 0.0

onready var _attack = $Attack

func _ready():
	print('%s is set up for combat: %s' % [
		get_parent().name,
		{
			'ATTACK_DAMAGE': _attack.ATTACK_DAMAGE,
			'ATTACK_COOLDOWN': _attack.ATTACK_COOLDOWN
		}
	])

func attack(target):
	_attack.damage(target)
