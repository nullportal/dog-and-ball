extends Node

signal HEALTH_CHANGED(prev, curr)
signal HEALTH_DEPLETED(overkill)

export var HEALTH_POINTS = 0

func _ready():
	self.connect('HEALTH_CHANGED', get_node('/root/Game'), 'health_changed')
	print(get_parent().name, ' initialised with ', self.HEALTH_POINTS, 'HP')

func reduce(n):
	var old_health = self.HEALTH_POINTS
	self.HEALTH_POINTS -= n
	var new_health = self.HEALTH_POINTS

	emit_signal('HEALTH_CHANGED', get_parent(), old_health, new_health)
	if new_health <= 0:
		emit_signal('HEALTH_DEPLETED', abs(old_health - new_health)) # NOTE Currently unused
