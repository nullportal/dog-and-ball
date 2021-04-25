extends Node

# NOTE Hmmm might be a better spot for this ...
signal UPDATE_HELD_ITEM(who, what)

onready var Ball = preload('res://Items/Ball.tscn')

func ball_thrown(by, from, direction):
	print('%s threw ball %s in direction %s' % [by.name, from, direction])
	emit_signal('UPDATE_HELD_ITEM', by, null)
	by.holding_ball = false
	var ball = Ball.instance()
	ball.global_position = from
	self.add_child(ball)
	ball.throw(direction)

func ball_picked_up(ball, by):
	emit_signal('UPDATE_HELD_ITEM', by, ball)
	by.holding_ball = true
	print(by.name, ' picked up ball')

func give(item, from, to):
	print('%s gave %s to %s' % [from.name, item, to.name])
	emit_signal('UPDATE_HELD_ITEM', from, null)
	emit_signal('UPDATE_HELD_ITEM', to, item)
	if item == 'Ball':
		from.holding_ball = false
		to.holding_ball = true
