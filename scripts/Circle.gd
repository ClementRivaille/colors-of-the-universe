extends CircleAbstract
class_name Circle
signal is_top
signal end_validated

onready var circle_scene := load("res://prefabs/Circle.tscn")
onready var star_scene := preload("res://prefabs/Star.tscn")

export(float) var scale_speed := 0.4
var zoom_ease := 0.5
export(bool) var zooming := false

var child_scale := 0.2

var child_step := 0.02
var top_step := 2.0
var progress_step := 0.5

var child_position_radius := 600.0
var children_circle: Array = []
var active_child: CircleAbstract
var child_added := false
var on_top := false

onready var tween: Tween = $Tween
onready var area: Area2D = $Area2D
onready var sprite: Sprite = $Sprite
var star: Star

onready var debug_label: Label = $DebugLabel

onready var orchestra: Orchestra = get_node("/root/OrchestraInstance")

func _ready():
  init_self()
  
func init_self():
  sprite.self_modulate = color
  chord = orchestra.get_chord(note, clue)

  # Pick Children color
  var saturation := 0.3 + randf() * 0.6
  var value := 1.0 - saturation + randf() * 0.2
  var child_hue := color.h
  if melody_position > 0:
    child_hue = fmod(abs(color.h + 0.04), 1.0)
  child_color = Color.from_hsv(child_hue, 0.4, 0.4 + randf() * 0.3)

  # Area detection
  area.connect("mouse_entered", self, "on_mouse_enter")
  area.connect("mouse_exited", self, "on_mouse_exit")
  
  # Add star
  if clue || final:
    star = star_scene.instance()
    star.success = final
    star.connect("collected", self, "on_star_collected")
    add_child(star)
  
  # debug_label.text = str(note)
  
func _process(delta):
  if zooming && zoom_power > 0.0:
    scale = scale * (1 + (delta * scale_speed * zoom_power))
    
    if !on_top && scale.x > progress_step:
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
  var children_instrument := randi()%(Instruments.InstrumentType.size())
  while children_instrument == instrument:
    children_instrument = randi()%(Instruments.InstrumentType.size())

  for note in chord:
    add_child_circle(angle, note, children_instrument)
    angle = (angle + (2 * PI) / chord.size())
  

func add_child_circle(angle: float, note: int, child_instrument: int):
  var child: CircleAbstract = circle_scene.instance()
  child.note = note
  child.instrument = child_instrument
    
  child.color = child_color
  child.status = CircleStatus.Small if status != CircleStatus.Large else CircleStatus.Main
  child.position.x = cos(angle) * child_position_radius
  child.position.y = sin(angle) * child_position_radius
  child.scale = Vector2.ONE * child_scale
  
  child.melody_position = -1
  if final:
    child.melody_position = -2
  elif orchestra.validate_path(note, melody_position + 1):
    child.melody_position = (melody_position + 1)%orchestra.melody_size
  elif orchestra.validate_path(note, 0):
    child.melody_position = 0
  
  if child.melody_position == orchestra.melody_size - 1:
    child.final = true
    child.color.h = fmod(abs(color.h + 0.5), 1.0)
  elif !final && melody_position >= -1 && orchestra.is_melody_end(note):
    child.clue = true

  child.connect("selected", self, "on_child_select")
  child.connect("unselected", self, "on_child_unselect")
  child.connect("target", self, "target_child")

  child.modulate.a = 0.0
  add_child(child)
  child.fade_in()
  children_circle.push_back(child)

func fade_in():
  tween.interpolate_property(self, 'modulate', Color.transparent, Color.white,
    0.5, Tween.TRANS_SINE, Tween.EASE_IN)
  tween.start()

func fade_out():
  tween.remove_all()
  sprite.self_modulate = Color.transparent
  var shadow: Sprite = $Shadow
  shadow.self_modulate = Color.transparent
  zoom_power = 0.3
  tween.interpolate_property(self, 'modulate', Color.white, Color.transparent,
    0.3, Tween.TRANS_SINE, Tween.EASE_IN)
  tween.start()
  yield(tween, "tween_all_completed")
  queue_free()

func on_mouse_enter():
  if status == CircleStatus.Main:
    orchestra.drum_event()
  if status != CircleStatus.Large:
    orchestra.play_instrument(instrument, note, status == CircleStatus.Small)
  emit_signal("selected", self)
func on_mouse_exit():
  if status == CircleStatus.Main:
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
  if on_top:
    return
  var dest := 1.0 if active else 0.0
  var zoome_ease := Tween.EASE_IN if active else Tween.EASE_OUT
  if (tween.is_active()):
    tween.remove(self, "zoom_power")
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
  if (clue || final) && star:
    star.active = true

func on_star_collected():
  emit_signal("end_validated")
