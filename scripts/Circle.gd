extends CircleAbstract
class_name Circle
signal is_top

onready var circle_scene := load("res://prefabs/Circle.tscn")
export(float) var scale_speed := 0.4
var zoom_ease := 0.5
export(bool) var zooming := false

var child_step := 0.02
var top_step := 2.0

var child_position_radius := 600.0
var children_circle: Array = []
var active_child: CircleAbstract
var child_added := false
var on_top := false

onready var tween: Tween = $Tween
onready var area: Area2D = $Area2D

onready var debug_label: Label = $DebugLabel

func _ready():
  self_modulate = color

  # Pick Children color
  var color_pick := randf()
  if color_pick < 0.5:
    child_color = color.lightened(0.2 + randf() * 0.6)
  else:
    child_color = color.darkened(0.2 + randf() * 0.6)

  # Area detection
  area.connect("mouse_entered", self, "on_mouse_enter")
  area.connect("mouse_exited", self, "on_mouse_exit")
  
func _process(delta):
  if zooming && zoom_power > 0.0:
    scale = scale * (1 + (delta * scale_speed * zoom_power))
    
  if !child_added && global_scale.x >= child_step:
    fill_children()
    child_added = true
  if !on_top && global_scale.x > top_step:
    go_on_top()
    on_top = true
    
  # debug_label.text = str(zoom_power)
    
func go_on_top():
  for child in children_circle:
    child.disconnect("selected", self, "on_child_select")
    child.disconnect("unselected", self, "on_child_unselect")
    child.disconnect("target", self, "target_child")
  var successor = active_child
  emit_signal("is_top", successor)
  if successor.zoom_power == 0.0:
    successor.zoom_power = 1.0;
    successor.on_child_unselect()
    
func fill_children():
  var angle := randf() * 2 * PI
  var nb_child = 3
  for i in range(0,nb_child):
    add_child_circle(angle)
    angle = (angle + (2 * PI) / nb_child)
  

func add_child_circle(angle: float):
  var child: CircleAbstract = circle_scene.instance()
  child.color = child_color
  child.position.x = cos(angle) * child_position_radius
  child.position.y = sin(angle) * child_position_radius
  child.scale = Vector2.ONE * child_scale
  child.modulate.a = 0.0
  child.connect("selected", self, "on_child_select")
  child.connect("unselected", self, "on_child_unselect")
  child.connect("target", self, "target_child")
  add_child(child)
  child.fade_in()
  children_circle.push_front(child)

func fade_in():
  tween.interpolate_property(self, 'modulate', Color.transparent, Color.white,
    0.5, Tween.TRANS_SINE, Tween.EASE_IN)
  tween.start()

func on_mouse_enter():
  emit_signal("selected", self)
func on_mouse_exit():
  emit_signal("unselected")
  
func on_child_select(circle: CircleAbstract):
  active_child = circle
  emit_signal("target", active_child)
  
  if (tween.is_active()):
    tween.stop(self, "zoom_power")
  tween.interpolate_property(self, "zoom_power", zoom_power, 1.0,
    zoom_ease, Tween.TRANS_SINE, Tween.EASE_IN)
  tween.start()
func on_child_unselect():
  if (tween.is_active()):
    tween.stop(self, "zoom_power")
  tween.interpolate_property(self, "zoom_power", zoom_power, 0.0,
    zoom_ease, Tween.TRANS_SINE, Tween.EASE_OUT)
  tween.start()

func target_child(grandchild: Node2D):
  emit_signal("target", grandchild)
