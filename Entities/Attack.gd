extends Node

signal DAMAGE(target, amount)

onready var ATTACK_DAMAGE:float = get_parent().ATTACK_DAMAGE
onready var ATTACK_COOLDOWN:float = get_parent().ATTACK_COOLDOWN

onready var cooldown = $Cooldown

func _ready():
	self.connect('DAMAGE', get_node('/root/Game'), 'damage_target')

func damage(target):
	if !cooldown.time_left:
		cooldown.start(self.ATTACK_COOLDOWN)
		emit_signal('DAMAGE', target, self.ATTACK_DAMAGE)
