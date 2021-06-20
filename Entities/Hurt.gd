extends Node

onready var HURT_PROPERTIES:Dictionary = get_parent().HURT_PROPERTIES
onready var animationPlayer = AnimationPlayer.new()

func _ready():
	_setup_pain_flash()

func pain():
	if 'pain-flash' in HURT_PROPERTIES.effects:
		animationPlayer.play('pain_flash')

func _setup_pain_flash():
	var sprite = get_node(HURT_PROPERTIES.spritePath)
	if (sprite is Sprite):
		_setup_pain_flash_sprite()
	else:
		assert(false, 'Unimplemented hurt target %s' % sprite)

func _setup_pain_flash_sprite():
	var spriteProperty = HURT_PROPERTIES.spriteProperty # Colo
	var sprite = get_node(HURT_PROPERTIES.spritePath)
	var _effect = HURT_PROPERTIES.effects

	var spritePropertyPath = '{path}:{property}'.format(
		{'path': String(sprite.get_path()), 'property': spriteProperty}
	)

	add_child(animationPlayer)

	var painFlash = Animation.new()
	animationPlayer.add_animation('pain_flash', painFlash)
	var trackIdx = painFlash.add_track(Animation.TYPE_VALUE)
	painFlash.track_set_path(trackIdx, spritePropertyPath)
	painFlash.length = 0.15
	
	var original = Color( 1, 1, 1, 1 )
	var white = Color( 100, 100, 100, 1 )
	var black = Color( 0, 0, 0, 1 )
	painFlash.track_insert_key(trackIdx, 0.0, original)
	painFlash.track_insert_key(trackIdx, 0.01, white)
	painFlash.track_insert_key(trackIdx, 0.05, black)
	painFlash.track_insert_key(trackIdx, 0.15, original)
