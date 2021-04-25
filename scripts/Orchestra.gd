extends Node2D
class_name Orchestra

onready var drums: Drums = $Drums
onready var string: Multisampler = $String
onready var main_instruments: Instruments = $MainInstruments
onready var small_instruments: Instruments = $SmallInstruments

var keys := ['C', 'D', 'E', 'F', 'G', 'A', 'Bb']

var progressing := false

var progress_amplifier: AudioEffectAmplify


func _ready():
  var progress_bus_idx := AudioServer.get_bus_index("Progress")
  progress_amplifier = AudioServer.get_bus_effect(progress_bus_idx, 0)

func drum_event():
  drums.play_rand()
  
func get_chord(index: int):
  var notes := []
  for i in range(0, 3):
    var note = (index + i * 2)%keys.size()
    notes.push_front(note)
    
  if index%2 == 0 && randf() > 0.4:
    var extra_note = randi()%keys.size()
    while notes.has(extra_note):
      extra_note = randi()%keys.size()
    notes.push_front(extra_note)
    
  return notes

func play_main_note(index: int):
  var note: String = keys[index]
  string.play_note(note, 4)
  string.play_note(note, 3)
  
func release_main():
  string.release()
  
func update_progress_volume(value: float):
  progress_amplifier.volume_db = lerp(-30.0, 0.0, value)
  
func play_instrument(type: int, note_idx: int, small: bool):
  var note: String = keys[note_idx]
  if small:
    small_instruments.play_instrument(type, note)
  else:
    main_instruments.play_instrument(type, note)
