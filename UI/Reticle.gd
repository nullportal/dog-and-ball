extends Position2D

export var MAX_DISTANCE = 5

func aim_reticle(event):
	if event is InputEventJoypadMotion:
		return _aim_joy_reticle()
	else:
		assert(false, 'Unknown input event %s' % event)

func _aim_joy_reticle():
	var joy_left = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var joy_up = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	var joy_vec = Vector2(
			joy_left,
			joy_up
	)

	return _update_reticle(joy_vec)

func _update_reticle(vec):
	var extent = clamp((abs(vec.y) + abs(vec.x)), 0, 1)
	if extent == 0:
		self.hide()
	else:
		var direction = rad2deg(vec.angle())
		self.rotation_degrees = direction

		# Extend end of reticle
		var line = self.find_node('Line')
		var base_len = Vector2(16, 0)
		var end_point = line.get_point_count() - 1
		line.points[end_point] = base_len * extent * MAX_DISTANCE

		self.show()

	# Just return as-is. May do more with it later...
	return vec
