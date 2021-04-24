extends Camera2D
class_name ZoomCamera

onready var bg_color: ColorRect = $ColorRect

func update_bg_color(color: Color):
  bg_color.color = color
