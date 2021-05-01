extends Node

signal DAMAGE(target, amount)

onready var attack = $Attack

func _ready():
	self.connect('DAMAGE', get_node('/root/Game'), 'damage_target')

	print('%s is set up for combat' % get_parent().SLUG)

# TODO Add attack cooldown - probably need more context
func attack(target, amount):
	emit_signal('DAMAGE', target, amount)
