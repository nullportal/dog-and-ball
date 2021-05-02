extends Node

# TODO Copy sprite to module (and overlay?)
# TODO Programmatically play hurt anim (white flash) - this:
#   [sub_resource type="Animation" id=2]
#   resource_name = "flash"
#   length = 0.04
#   step = 0.005
#   tracks/0/type = "value"
#   tracks/0/path = NodePath(".:color")
#   tracks/0/interp = 1
#   tracks/0/loop_wrap = true
#   tracks/0/imported = false
#   tracks/0/enabled = true
#   tracks/0/keys = {
#   "times": PoolRealArray( 0, 0.015, 0.03, 0.04 ),
#   "transitions": PoolRealArray( 1, 1, 1, 1 ),
#   "update": 1,
#   "values": [ Color( 0.772549, 0, 0, 1 ), Color( 1, 1, 1, 1 ), Color( 1, 0, 0, 1 ), Color( 0.772549, 0, 0, 1 ) ]
#   }

onready var rect = null setget set_rect, get_rect
onready var animationPlayer = null

func _ready():
  animationPlayer = AnimationPlayer.new()
  add_child(animationPlayer)

  var hurtFlash = Animation.new()
  animationPlayer.add_animation('hurt_flash', hurtFlash)

  var trackIdx = hurtFlash.add_track(Animation.TYPE_VALUE) # ??
  var path = String(get_parent().get_parent().get_path()) + '/ColorRect:color'
  hurtFlash.track_set_path(trackIdx, path)
  hurtFlash.length = 0.1
  hurtFlash.track_insert_key(trackIdx, 0.1, Color(1,1,1,1))

  var x = NodePath(path)
  var y = get_node(NodePath(path))
  print([x,y])
  print('Setting up %s hurt behaviour using %s ...' % [get_parent().name, NodePath(path)])

func flash():
  animationPlayer.play('hurt_flash')

func get_rect():
  return rect

func set_rect(r):
  rect = r
