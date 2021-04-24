extends Node

onready var Ball = preload('res://Items/Ball.tscn')

func ball_thrown(from, direction):
	var ball = Ball.instance()
	ball.global_position = from
	self.add_child(ball)
	ball.throw(direction)

func ball_picked_up(ball, by):
	by.holding_ball = true
	ball.queue_free()
	print(by.name, ' picked up ball')
