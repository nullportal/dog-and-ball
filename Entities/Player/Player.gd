extends KinematicBody2D

signal BALL_THROWN(from, direction)
signal UPDATE_HELD_ITEM(item)
signal COMMAND(command_name, context)

export var HEALTH_POINTS = 10
export var ACCELERATION = 500
export var MAX_SPEED = 128
export var FRICTION = 800
enum {MOVE}

var state = MOVE
var holding_ball = true
var velocity = Vector2.ZERO
var aim_vec = Vector2.ZERO

onready var reticle = $Reticle
onready var pickupArea = $PickupArea
onready var health = $Health
onready var dog = get_node_or_null('/root/Game/World/Dog')

func _ready():
	pass

func _physics_process(delta):
	state = MOVE
	if Input.is_action_just_pressed("throw"):
		if holding_ball:
			emit_signal('BALL_THROWN', self.global_position, aim_vec)
			emit_signal('UPDATE_HELD_ITEM', null)
			holding_ball = false
		elif dog:
			if pickupArea.overlaps_area(dog.pickupArea):
				print('Trying to get item from dog...')
				emit_signal('COMMAND', 'give', 'Ball')
			else:
				print('Trying to get dog to retrieve ball...')
				emit_signal('COMMAND', 'retrieve', 'Ball')

	match state:
		MOVE:
			move_state(delta)

	aim_vec = reticle.aim_reticle()

func move_state(delta):
	var move_vec = Vector2.ZERO
	move_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	move_vec.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")	
	move_vec = move_vec.normalized()

	if move_vec != Vector2.ZERO:
		velocity = velocity.move_toward(
			move_vec * MAX_SPEED,
			ACCELERATION * delta
		)
	else:
		velocity = velocity.move_toward(
			Vector2.ZERO, 
			FRICTION * delta
		)
	velocity = move_and_slide(velocity)

func take(item_name):
	print('Player is taking ', item_name)
	if item_name == 'Ball':
		self.holding_ball = true
		emit_signal('UPDATE_HELD_ITEM', item_name)