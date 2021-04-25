extends Node2D
class_name Instruments

enum InstrumentType {PIANO, SAXO, ORGAN, OBOE, CELESTIA, GUITAR}

export(PackedScene) var organ_prefab: PackedScene
export(PackedScene) var piano_prefab: PackedScene
export(PackedScene) var saxo_prefab: PackedScene
export(PackedScene) var oboe_prefab: PackedScene
export(PackedScene) var celestia_prefab: PackedScene
export(PackedScene) var guitar_prefab: PackedScene

var instruments := {}
var octaves := {
  InstrumentType.PIANO: 4,
  InstrumentType.SAXO: 4,
  InstrumentType.OBOE: 5,
  InstrumentType.CELESTIA: 6,
  InstrumentType.ORGAN: 4,
  InstrumentType.GUITAR: 5,
 }

export(String, "Instruments", "Small") var bus := "Instruments"

func _ready():
  instantiate_instrument(InstrumentType.ORGAN, organ_prefab)
  instantiate_instrument(InstrumentType.PIANO, piano_prefab)
  instantiate_instrument(InstrumentType.SAXO, saxo_prefab)
  instantiate_instrument(InstrumentType.CELESTIA, celestia_prefab)
  instantiate_instrument(InstrumentType.OBOE, oboe_prefab)
  instantiate_instrument(InstrumentType.GUITAR, guitar_prefab)
  
func instantiate_instrument(type: int, prefab: PackedScene):
  var instrument: Multisampler = prefab.instance()
  instrument.bus = bus
  add_child(instrument)
  instruments[type] = instrument

func play_instrument(instrument: int, note: String):
  if instruments.has(instrument):
    var sampler: Multisampler = instruments[instrument]
    var octave: int = octaves[instrument]
    sampler.play_note(note, octave)
