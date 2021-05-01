extends Node

signal DAMAGE(target, amount)

export var ATTACK_DAMAGE = 0
export var ATTACK_COOLDOWN = 0

func _ready():
	self.connect('DAMAGE', get_node('/root/Game'), 'damage_target')

# TODO Add attack cooldown - probably need more context
func damage(target):
	emit_signal('DAMAGE', target, self.ATTACK_DAMAGE)
