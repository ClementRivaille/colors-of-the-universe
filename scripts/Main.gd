extends Node2D
class_name Main

onready var root_circle: Circle = $Circle
onready var camera: ZoomCamera = $Camera2D

func _ready():
  root_circle.connect("is_top", self, "switch_root_circle")
  
func switch_root_circle(circle: Circle):
  camera.update_bg_color(root_circle.color)
  circle.scale = circle.global_scale
  root_circle.remove_child(circle)
  add_child(circle)
  circle.set_owner(self)
  circle.connect("is_top", self, "switch_root_circle")
  circle.zooming = true
  
  root_circle.queue_free()
  root_circle = circle
