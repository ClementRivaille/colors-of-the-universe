extends Node2D
class_name Star

export(Color) var clue_color: Color
export(Color) var success_color: Color

var success := false
var active := false

onready var sprite: Sprite = $Sprite
onready var area: Area2D = $Area2D

func _ready():
  sprite.modulate = success_color if success else clue_color
  if success:
    scale = scale * 0.5
