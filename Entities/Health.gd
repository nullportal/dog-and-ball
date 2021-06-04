extends Node

signal HEALTH_CHANGED(prev, curr)
signal HEALTH_DEPLETED(overkill, who)

export var MAX_HEALTH = 0 # TODO Actually use in instances
export var HEALTH_POINTS = 0
export var HEALTH_REGEN = false
export var HEALTH_REGEN_WAIT = 0
export var HEALTH_REGEN_AMOUNT = 0

onready var healthOwner = get_parent()
onready var timer = $Timer

func _ready():
	# TODO Separate max HP and current HP in exports
	self.MAX_HEALTH = self.HEALTH_POINTS

	self.connect('HEALTH_CHANGED', get_node('/root/Game'), 'health_changed')
	self.connect('HEALTH_DEPLETED', get_node('/root/Game'), 'health_depleted')
	print(healthOwner.name, ' initialised with ', self.HEALTH_POINTS, 'HP')

func _process(_delta):
	if self.HEALTH_REGEN:
		var healths = health_regen(self.HEALTH_REGEN_AMOUNT)
		if healths != null:
			self.HEALTH_POINTS = healths['new_health']
			emit_signal('HEALTH_CHANGED', healthOwner, healths['old_health'], healths['new_health'])
			timer.start(self.HEALTH_REGEN_WAIT)

func change(n):
	var old_health = self.HEALTH_POINTS
	self.HEALTH_POINTS += n
	var new_health = self.HEALTH_POINTS

	emit_signal('HEALTH_CHANGED', healthOwner, old_health, new_health)
	if new_health <= 0:
		emit_signal('HEALTH_DEPLETED', abs(old_health - new_health), healthOwner)

func reduce(n):
	change(-n)

func reset_health_regen_timer(wait_time):
	timer.start(wait_time)

func health_regen(amount):
	var old_health = self.HEALTH_POINTS
	var new_health = self.HEALTH_POINTS
	if !timer.time_left && old_health < self.MAX_HEALTH:
		new_health = clamp(old_health + amount, 0, self.MAX_HEALTH) # XXX Not working?
		return {'old_health': old_health, 'new_health': new_health}
	return null
