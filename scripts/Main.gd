extends Node2D
class_name Main

onready var root_circle: Circle = $Intro
onready var camera: ZoomCamera = $Camera2D

onready var orchestra: Orchestra = get_node("/root/OrchestraInstance")

var thanks_scene: PackedScene = preload("res://prefabs/Thanks.tscn")

var thanks_displayed := false
var last_melody := false

func _ready():
  randomize()
  connect_circle(root_circle)
  root_circle.set_top()
  camera.target = root_circle
  orchestra.generate_melody()
  
func switch_root_circle(circle: Circle):
  camera.update_bg_color(root_circle.color)
  circle.scale = circle.global_scale
  circle.position = circle.global_position
  root_circle.remove_child(circle)
  add_child(circle)
  circle.set_owner(self)
  connect_circle(circle)
  circle.set_top()
  
  orchestra.update_position(circle.note)
  if orchestra.melody_position == orchestra.melody_size - 1:
    last_melody = orchestra.is_last_melody()
    orchestra.transpose(circle.note)
    orchestra.generate_melody()
  
  disconnect_circle(root_circle)
  root_circle.fade_out()
  root_circle = circle

func change_target(node: Node2D):
  camera.target = node

func on_validate_end():
  if !thanks_displayed && last_melody:
    var thanks: Label = thanks_scene.instance()
    root_circle.add_child(thanks)
    thanks_displayed = true

func connect_circle(circle: Circle):
  circle.connect("is_top", self, "switch_root_circle")
  circle.connect("target", self, "change_target")
  circle.connect("end_validated", self, "on_validate_end")

func disconnect_circle(circle: Circle):
  circle.disconnect("is_top", self, "switch_root_circle")
  circle.disconnect("target", self, "change_target")
  circle.disconnect("end_validated", self, "on_validate_end")
