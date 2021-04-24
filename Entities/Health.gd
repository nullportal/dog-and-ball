extends Node

signal HEALTH_CHANGED(prev, curr)
signal HEALTH_DEPLETED(overkill)

export var HEALTH_POINTS = 0

func _ready():
	print(get_parent().name, ' initialised with ', self.HEALTH_POINTS, 'HP')

func reduce(n):
	var old_health = self.HEALTH_POINTS
	self.HEALTH_POINTS -= n
	var new_health = self.HEALTH_POINTS

	emit_signal('HEALTH_CHANGED', old_health, new_health)
	if new_health <= 0:
		emit_signal('HEALTH_DEPLETED', abs(old_health - new_health))
