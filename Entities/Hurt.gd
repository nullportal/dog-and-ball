extends Node

onready var HURT_PROPERTIES:Dictionary = get_parent().HURT_PROPERTIES
onready var animationPlayer = null

func _ready():
	var sprite = get_node(HURT_PROPERTIES.spritePath)
	var spriteProperty = HURT_PROPERTIES.spriteProperty
	var effect = HURT_PROPERTIES.effects
	if !(sprite is ColorRect):
		assert(false, 'Unimplemented hurt target %s' % sprite)
	if spriteProperty != 'color':
		assert(false, 'Unimplemented hurt target property %s' % spriteProperty)
	if effect == ['flash']:
		effect = effect[0]
	else:
		assert(false, 'Unimplemented hurt effect %s' % effect)

	var spritePropertyPath = '{path}:{property}'.format(
		{'path': String(sprite.get_path()), 'property': spriteProperty}
	)
	var spritePropertyOriginalValue:Color = sprite.color

	animationPlayer = AnimationPlayer.new()
	add_child(animationPlayer)

	var hurtFlash = Animation.new()
	animationPlayer.add_animation('hurt_flash', hurtFlash)

	var trackIdx = hurtFlash.add_track(Animation.TYPE_VALUE) # ??
	hurtFlash.track_set_path(trackIdx, spritePropertyPath)
	hurtFlash.length = 0.04
	hurtFlash.track_insert_key(trackIdx, 0.0, spritePropertyOriginalValue)
	hurtFlash.track_insert_key(trackIdx, 0.035, Color.white)
	hurtFlash.track_insert_key(trackIdx, 0.04, spritePropertyOriginalValue)

func pain():
	if 'flash' in HURT_PROPERTIES.effects:
		animationPlayer.play('hurt_flash')
	else:
		assert(false, 'Failed to react to hurt')
