extends Position2D

export var MAX_DISTANCE = 5

# TODO Use actual crosshair instead
func aim_reticle():
	return __old_aim_reticle()

func __old_aim_reticle():
	var direction = 0.0
	var joy_left = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var joy_up = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	var joy_vec = Vector2(
			joy_left,
			joy_up
	)
	var joy_extent = clamp((abs(joy_left) + abs(joy_up)), 0, 1)
	if joy_extent == 0:
		self.hide()
	else:
		direction = rad2deg(joy_vec.angle())
		self.rotation_degrees = direction
		self.show()

		# Extend end of reticle
		var line = self.find_node('Line')
		var base_len = Vector2(16, 0)
		var end_point = line.get_point_count() - 1
		line.points[end_point] = base_len * joy_extent * MAX_DISTANCE
	return joy_vec