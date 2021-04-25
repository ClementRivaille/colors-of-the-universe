extends Node2D
class_name Main

onready var root_circle: Circle = $Circle
onready var camera: ZoomCamera = $Camera2D

func _ready():
  root_circle.connect("is_top", self, "switch_root_circle")
  root_circle.connect("target", self, "change_target")
  root_circle.set_top()
  camera.target = root_circle
  
func switch_root_circle(circle: Circle):
  camera.update_bg_color(root_circle.color)
  circle.scale = circle.global_scale
  circle.position = circle.global_position
  root_circle.remove_child(circle)
  add_child(circle)
  circle.set_owner(self)
  circle.connect("is_top", self, "switch_root_circle")
  circle.connect("target", self, "change_target")
  circle.set_top()
  
  root_circle.queue_free()
  root_circle = circle

func change_target(node: Node2D):
  camera.target = node
