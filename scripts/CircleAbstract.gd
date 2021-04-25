extends Node2D
class_name CircleAbstract
signal selected
signal unselected
signal target

enum CircleStatus {Small, Main, Large}

export(Color) var color: Color
var child_color: Color
export(CircleStatus) var status: int = CircleStatus.Small

var zoom_power := 0.0

export(int) var note := 0
var chord := []
var instrument : int = Instruments.InstrumentType.PIANO

func add_child_circle(angle: float, note: int, child_instrument: int):
  pass
func fade_in():
  pass
func on_child_select(circle):
  pass
func on_child_unselect():
  pass
func init_zoom_momentum(active: bool):
  pass
