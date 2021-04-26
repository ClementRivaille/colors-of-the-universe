extends Node2D
class_name Star
signal collected

export(Color) var clue_color: Color
export(Color) var success_color: Color

var success := false
var active := false
var playing := false

var rotation_speed := 2.0
var rotation_force := 0.0

onready var sprite: Sprite = $Sprite
onready var area: Area2D = $Area2D
onready var tween := $Tween
onready var animation : AnimationPlayer = $AnimationPlayer

onready var orchestra: Orchestra = get_node("/root/OrchestraInstance")

func _ready():
  sprite.modulate = success_color if success else clue_color
  if success:
    scale = scale * 0.5
  area.connect("mouse_entered", self, "on_activate")
  orchestra.connect("stop_playing_melody", self, "on_melody_stopped")
  animation.connect("animation_finished", self, "on_animation_finished")
  
func _process(delta: float):
  if rotation_force > 0.0:
    rotate(rotation_speed * rotation_force * delta)

func play_clue():
  playing = true
  orchestra.play_melody()
  tween.interpolate_property(self, "rotation_force", 0.0, 1.0,
    0.5, Tween.TRANS_SINE, Tween.EASE_IN)
  tween.start()
  
func play_success():
  playing = true
  orchestra.play_chord()
  animation.play("Collect")
  emit_signal("collected")
  
func on_melody_stopped():
  if playing:
    tween.interpolate_property(self, "rotation_force", 1.0, 0.0,
      0.7, Tween.TRANS_SINE, Tween.EASE_IN)
    tween.start()
    yield(tween, "tween_all_completed")
    playing = false
    
func on_activate():
  if active && !playing:
    if !success:
      play_clue()
    else:
      play_success()
      
func on_animation_finished(name: String):
  if name == "Collect":
    queue_free()
    
func fade_in():
  tween.interpolate_property(self, "modulate", Color.transparent, Color.white,
    0.5, Tween.TRANS_SINE, Tween.EASE_IN)
  tween.start()
