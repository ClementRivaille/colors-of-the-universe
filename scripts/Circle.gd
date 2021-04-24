extends CircleAbstract
class_name Circle
signal is_top

onready var circle_scene := load("res://prefabs/Circle.tscn")
export(float) var scale_speed := 0.5
export(bool) var zooming := false
var successor_circle: CircleAbstract

var child_step := 0.05
var top_step := 1.1

var child_added := false
var on_top := false


func _ready():
  self_modulate = color
  
  
  var color_pick := randf()
  if color_pick < 0.5:
    child_color = color.lightened(0.2 + randf() * 0.6)
  else:
    child_color = color.darkened(0.2 + randf() * 0.6)
  
func _process(delta):
  if zooming:
    scale = scale * (1 + (delta * scale_speed))
    
  if !child_added && global_scale.x >= child_step:
    add_child_circle()
    child_added = true
  if !on_top && global_scale.x > top_step:
    emit_signal("is_top", successor_circle)
    on_top = true

func add_child_circle():
  var child: CircleAbstract = circle_scene.instance()
  child.color = child_color
  child.scale = Vector2.ONE * child_scale
  add_child(child)
  successor_circle = child
