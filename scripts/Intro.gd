extends Circle
class_name Intro

onready var circle: Circle = $Circle
onready var clue_label: Label = $Clue

var clue_step = 8.0
var clue_displayed := false

func _process(_delta: float):
  if !clue_displayed && scale.x > clue_step:
    print('FU')
    tween.interpolate_property(clue_label, "modulate", Color.transparent, Color(1.0,1.0,1.0,0.7),
      1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
    tween.start()
    clue_displayed =true

func init_self():
  top_step = 20.0
  progress_step = 3.0
  child_added = true
  
  circle = $Circle
  circle.connect("selected", self, "on_child_select")
  circle.connect("unselected", self, "on_child_unselect")
  circle.connect("target", self, "target_child")
  circle.child_step = 0.2
  circle.instrument = Instruments.InstrumentType.CELLO
  children_circle = [circle]
  active_child = circle
  
func fill_children():
  pass
  
func set_top():
  pass
