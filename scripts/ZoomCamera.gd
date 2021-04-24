extends Camera2D
class_name ZoomCamera

onready var bg_color: ColorRect = $ColorRect

var target: Node2D

func _process(delta):
  position = target.global_position

func update_bg_color(color: Color):
  bg_color.color = color
