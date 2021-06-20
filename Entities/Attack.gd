extends Node

signal DAMAGE(fromNode, toNode, amount)

onready var ATTACK_DAMAGE:float = get_parent().ATTACK_DAMAGE
onready var ATTACK_COOLDOWN:float = get_parent().ATTACK_COOLDOWN

onready var cooldown = $Cooldown

func _ready():
	self.connect('DAMAGE', get_node('/root/Game'), 'damage_target')

func damage(fromNode, toNode):
	if !cooldown.time_left:
		cooldown.start(get_parent().ATTACK_COOLDOWN)
		emit_signal('DAMAGE', fromNode, toNode, get_parent().ATTACK_DAMAGE)

		return self.ATTACK_DAMAGE
