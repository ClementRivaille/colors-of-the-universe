extends Sprite
class_name CircleAbstract
signal selected
signal unselected

export(Color) var color: Color
var child_color: Color
var child_scale := 0.2

var zoom_power := 0.0

func add_child_circle():
  pass
func fade_in():
  pass
func on_child_select():
  pass
func on_child_unselect():
  pass
