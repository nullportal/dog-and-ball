extends Node

onready var HURT_PROPERTIES:Dictionary = get_parent().HURT_PROPERTIES
onready var animationPlayer = null

func _ready():
	_setup_pain_flash()

func pain():
	if 'pain-flash' in HURT_PROPERTIES.effects:
		animationPlayer.play('pain_flash')

func _setup_pain_flash():
	var sprite = get_node(HURT_PROPERTIES.spritePath)
	var spriteProperty = HURT_PROPERTIES.spriteProperty
	var effect = HURT_PROPERTIES.effects
	if !(sprite is ColorRect):
		assert(false, 'Unimplemented hurt target %s' % sprite)
	if spriteProperty != 'color':
		assert(false, 'Unimplemented hurt target property %s' % spriteProperty)
	if effect == ['pain-flash']:
		effect = effect[0]
	else:
		assert(false, 'Unimplemented hurt effect %s' % effect)

	var spritePropertyPath = '{path}:{property}'.format(
		{'path': String(sprite.get_path()), 'property': spriteProperty}
	)
	var spritePropertyOriginalValue:Color = sprite.color

	animationPlayer = AnimationPlayer.new()
	add_child(animationPlayer)

	var painFlash = Animation.new()
	animationPlayer.add_animation('pain_flash', painFlash)

	var trackIdx = painFlash.add_track(Animation.TYPE_VALUE) # ??
	painFlash.track_set_path(trackIdx, spritePropertyPath)
	painFlash.length = 0.04
	painFlash.track_insert_key(trackIdx, 0.0, spritePropertyOriginalValue)
	painFlash.track_insert_key(trackIdx, 0.035, Color.white)
	painFlash.track_insert_key(trackIdx, 0.04, spritePropertyOriginalValue)
