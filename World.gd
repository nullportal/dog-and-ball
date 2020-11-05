extends Node

onready var Ball = preload('res://Ball.tscn')

onready var game = get_node('/root/Game')

func ball_thrown(from, direction):
	var ball = Ball.instance()
	ball.connect('BALL_PICKED_UP', self, 'ball_picked_up')
	ball.global_position = from
	self.add_child(ball)
	ball.throw(direction)

func ball_picked_up(ball, by):
	by.holding_ball = true
	ball.queue_free()
