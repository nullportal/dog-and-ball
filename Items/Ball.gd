extends KinematicBody2D

signal BALL_PICKED_UP(ball, area)

export var FRICTION = 5
export var MAX_SPEED = 8
export var ACCELERATION = 6
export var THROW_DISTANCE = 100

# TODO Attract dog
export var ALLURE = 999

enum {
	THROWN,
	ROLLING,
	IDLE,
}

var start_position = Vector2.ZERO
var velocity = Vector2.ZERO
var state = IDLE
var pickupable = false
var can_pick_up = ['Player', 'Dog']
var bounces = 0

func _ready():
	self.connect('BALL_PICKED_UP', get_node('/root/Game/World'), 'ball_picked_up')

func _physics_process(delta):
	if velocity == Vector2.ZERO:
		state = IDLE

	match state:
		IDLE:
			pickupable = true
		ROLLING:
			rolling(delta)
		THROWN:
			thrown()

	var collision = move_and_collide(velocity)
	if collision:
		bounce(collision)

func bounce(collision):
	state = ROLLING
	velocity = velocity.bounce(collision.normal)

func rolling(delta):
	pickupable = true
	velocity = velocity.move_toward(
		Vector2.ZERO,
		FRICTION * delta
	)

func thrown():
	var distance_thrown = start_position.distance_to(self.global_position)
	if distance_thrown > THROW_DISTANCE:
		state = ROLLING

func throw(aim_vec):
	state = THROWN
	pickupable = false
	start_position = self.global_position
	velocity = velocity.move_toward(
		aim_vec * MAX_SPEED,
		ACCELERATION
	)

func _on_PickupArea_area_entered(area):
	if area.get_parent().name in self.can_pick_up && self.pickupable:
		emit_signal('BALL_PICKED_UP', self, area.get_parent())
