extends Node2D
class_name Drums

export(Array, AudioStream) var sounds := []

var players := []
var index := 0

func _ready():
  for player in get_children():
    players.push_front(player)
    
func play_rand():
  var sound: AudioStream = sounds[randi()%sounds.size()]
  var player: AudioStreamPlayer = players[index]
  player.stream = sound
  player.play()
  
  index = (index + 1)%players.size()
