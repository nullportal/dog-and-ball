extends Area2D

signal SPAWNER_VISIBLE(spawnerArea)
signal SPAWNER_HIDDEN(spawnerArea)

func _ready():
  self.connect('SPAWNER_VISIBLE', get_node('/root/Game'), 'on_spawner_visible')
  self.connect('SPAWNER_HIDDEN', get_node('/root/Game'), 'on_spawner_hidden')

func _on_PlayerCameraArea_area_entered(area):
  if area.is_in_group('EnemySpawners'):
    emit_signal('SPAWNER_VISIBLE', area)

func _on_PlayerCameraArea_area_exited(area):
  if area.is_in_group('EnemySpawners'):
    emit_signal('SPAWNER_HIDDEN', area)
