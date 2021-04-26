extends Node2D
class_name MelodyPlayer
signal melody_finished

var melody_delay := 0.7
var chord_delay := 0.06

onready var viola: Multisampler = $Viola
onready var glock: Multisampler = $Glock
onready var timer: Timer = $Timer

var playing := false
var interrupt := false

func play_note(note: String, octave := 0):
  viola.play_note(note, 4 + octave)
  glock.play_note(note, 5 + octave)
  
func play_melody(melody: Array):
  timer.wait_time = melody_delay
  # If already playing, stop the other instance
  if playing:
    interrupt = true
  playing = true
  for note in melody:
    play_note(note)
    timer.start()
    yield(timer, "timeout")
    # If interrupted, do not play further
    if interrupt:
      interrupt = false
      return
  playing = false
  emit_signal("melody_finished")

func play_chord(chord: Array):
  timer.wait_time = chord_delay
  if playing:
    interrupt = true
  playing = true
  for note in chord:
    play_note(note)
    timer.start()
    yield(timer, "timeout")
  play_note(chord[0], 1)
