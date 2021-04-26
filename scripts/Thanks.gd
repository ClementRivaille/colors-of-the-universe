extends Label

onready var tween: Tween = $Tween

func _ready():
  tween.interpolate_property(self, "self_modulate", Color.transparent, Color(1.0,1.0,1.0,0.8),
    1.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
  tween.start()
