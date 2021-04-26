extends Node2D
class_name Orchestra
signal stop_playing_melody

onready var drums: Drums = $Drums
onready var string: Multisampler = $String
onready var main_instruments: Instruments = $MainInstruments
onready var small_instruments: Instruments = $SmallInstruments
onready var melody_player: MelodyPlayer = $MelodyPlayer

var keys := ['C', 'D', 'E', 'F', 'G', 'A', 'Bb']

var progressing := false

var progress_amplifier: AudioEffectAmplify

var melody_size := 7
var melody := []
var melody_position := -1

func _ready():
  var progress_bus_idx := AudioServer.get_bus_index("Progress")
  progress_amplifier = AudioServer.get_bus_effect(progress_bus_idx, 0)

func drum_event():
  drums.play_rand()
  
func get_chord(index: int, start := false):
  var notes := []
  for i in range(0, 3):
    var note = (index + i * 2)%keys.size()
    notes.push_back(note)
    
  if start && !notes.has(melody[0]):
    notes.push_back(melody[0])
  
  if notes.size() < 4 && (index%2 != 0 || randf() > 0.4):
    var extra_note = randi()%keys.size()
    while notes.has(extra_note):
      extra_note = randi()%keys.size()
    notes.push_back(extra_note)
    
  return notes

func play_main_note(index: int):
  string.release()
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

func generate_melody():
  var last_note := 1 + randi()%(keys.size() - 1)
  melody = [last_note]
  while melody.size() < melody_size:
    var dest: int = melody[0]
    melody.push_front((keys.size() + dest - ((1 + randi()%2) * 2) )%keys.size())
  melody_position = -1
  
func update_position(note_index):
  if melody[(melody_position + 1)%melody.size()] == note_index:
    melody_position += 1
  else:
    melody_position = -1 if note_index != melody[0] else 0

func validate_path(note_idx: int, pos: int):
  return pos < melody.size() && melody[pos] == note_idx
  
func is_melody_end(note_idx: int):
  return melody.size() > 0 && melody[melody.size() - 1] == note_idx
  
func play_melody():
  var melody_notes := []
  for idx in melody:
    melody_notes.push_back(keys[idx])
  melody_player.play_melody(melody_notes)
  
func play_chord():
  var chord_notes := [keys[0], keys[2], keys[4], keys[6]]
  melody_player.play_chord(chord_notes)

func on_melody_finished():
  emit_signal("stop_playing_melody")
