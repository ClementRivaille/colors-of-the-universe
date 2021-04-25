extends CircleAbstract
class_name Circle
signal is_top

onready var circle_scene := load("res://prefabs/Circle.tscn")
export(float) var scale_speed := 0.4
var zoom_ease := 0.5
export(bool) var zooming := false

var child_scale := 0.2

var child_step := 0.02
var top_step := 2.0
var progress_step := 0.6

var child_position_radius := 600.0
var children_circle: Array = []
var active_child: CircleAbstract
var child_added := false
var on_top := false

onready var tween: Tween = $Tween
onready var area: Area2D = $Area2D
onready var sprite: Sprite = $Sprite

onready var debug_label: Label = $DebugLabel

onready var orchestra: Orchestra = get_node("/root/OrchestraInstance")

func _ready():
  sprite.self_modulate = color
  chord = orchestra.get_chord(note)

  # Pick Children color
  var saturation := 0.3 + randf() * 0.6
  var value := 1.0 - saturation + randf() * 0.2
  var child_hue := color.h
  if randf() < 0.2:
    child_hue = fmod(abs(color.h + 0.15), 1.0)
  child_color = Color.from_hsv(child_hue, 0.4, 0.4 + randf() * 0.3)
#  var hue_diff := 0.1 + randf() * 0.1
#  if randf() > 0.5:
#    hue_diff = -hue_diff
#  var child_hue := fmod(abs(color.h + hue_diff), 1.0)
#  child_color = Color.from_hsv(child_hue, 0.5 + randf()*0.3, 0.7 + randf() * 0.3)

  # Area detection
  area.connect("mouse_entered", self, "on_mouse_enter")
  area.connect("mouse_exited", self, "on_mouse_exit")
  
func _process(delta):
  if zooming && zoom_power > 0.0:
    scale = scale * (1 + (delta * scale_speed * zoom_power))
    
    if scale.x > progress_step:
      var progress_value := (scale.x - progress_step) / (top_step - progress_step)
      orchestra.update_progress_volume(progress_value)
      if !orchestra.progressing:
        orchestra.progressing = true
        if active_child:
          orchestra.play_main_note(active_child.note)
    
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
  var successor := active_child
  emit_signal("is_top", successor)
  if successor.zoom_power == 0.0:
    successor.zoom_power = 1.0;
    successor.init_zoom_momentum(false)
    
func fill_children():
  var angle := randf() * 2 * PI
  for note in chord:
    add_child_circle(angle, note)
    angle = (angle + (2 * PI) / chord.size())
  

func add_child_circle(angle: float, note: int):
  var child: CircleAbstract = circle_scene.instance()
  child.note = note
  child.color = child_color
  child.status = CircleStatus.Small if status != CircleStatus.Large else CircleStatus.Main
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
  orchestra.drum_event()
  emit_signal("selected", self)
func on_mouse_exit():
  orchestra.drum_event()
  emit_signal("unselected")
  
func on_child_select(circle: CircleAbstract):
  active_child = circle
  emit_signal("target", active_child)
  
  # Zoom momentum  
  init_zoom_momentum(true)
  
  # Play sound
  if status == CircleStatus.Large && circle.status == CircleStatus.Main && orchestra.progressing:
    orchestra.play_main_note(circle.note)
  
func on_child_unselect():
  # Zoom momentum
  init_zoom_momentum(false)
  
  if status == CircleStatus.Large && orchestra.progressing:
    orchestra.release_main()
    
func init_zoom_momentum(active: bool):
  var dest := 1.0 if active else 0.0
  var zoome_ease := Tween.EASE_IN if active else Tween.EASE_OUT
  if (tween.is_active()):
    tween.stop(self, "zoom_power")
  tween.interpolate_property(self, "zoom_power", zoom_power, dest,
    zoom_ease, Tween.TRANS_SINE, zoom_ease)
  tween.start()

func target_child(grandchild: Node2D):
  emit_signal("target", grandchild)

func set_top():
  zooming = true
  status = CircleStatus.Large
  for child in children_circle:
    child.status = CircleStatus.Main
  orchestra.release_main()
  orchestra.progressing = false
