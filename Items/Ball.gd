extends KinematicBody2D

signal BALL_PICKED_UP(ball, area)

export var FRICTION = 5
export var MAX_SPEED = 8
export var ACCELERATION = 6
export var THROW_DISTANCE = 100
export var SLUG = 'ball'

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

onready var pickupable_area = $PickupableArea

func _ready():
	self.connect('BALL_PICKED_UP', get_node('/root/Game/World'), 'ball_picked_up')

func _physics_process(delta):
	match state:
		IDLE:
			pickupable = true
		ROLLING:
			rolling(delta)
		THROWN:
			thrown()

	var pu_area = pickup_area_overlapping(pickupable_area)
	if pu_area:
		emit_signal('BALL_PICKED_UP', self, pu_area.get_parent())
		# Keep double evt from firing
		self.pickupable = false
		self.queue_free()

	var collision = move_and_collide(velocity)
	if collision:
		bounce(collision)

	if velocity == Vector2.ZERO:
		state = IDLE

func pickup_area_overlapping(my_area):
	var intersecting_areas = my_area.get_overlapping_areas()
	for area in intersecting_areas:
		if area.name == 'PickupArea' && area.get_parent().name in self.can_pick_up && self.pickupable:
			return area

func bounce(collision):
	state = ROLLING
	velocity = velocity.bounce(collision.normal)
	FRICTION *= 4

func rolling(delta):
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
