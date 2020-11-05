extends KinematicBody2D

export var MAX_SPEED = 128

enum {
	FOLLOW,
	WANDER,
	IDLE,
}
var state = FOLLOW
var holding_ball = true
var velocity = Vector2.ZERO

func _physics_process(_delta):
	self.focus = self.find_focus()

	match state:
		FOLLOW:
			follow(self.focus)

func find_focus():
	var nodes = get_node('/root/Game/World').get_children()
	# TODO Use a map instead
	for node in nodes:
		if node.name == 'Ball':
			return node
	return null

# TODO Move toward focus
func follow(focus):
	if focus && state == FOLLOW:
		velocity = position.direction_to(focus.position) * MAX_SPEED
		velocity = move_and_slide(velocity)
