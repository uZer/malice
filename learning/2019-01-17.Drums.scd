Quarks.gui;

// Faire un synth qui joue les samples

// Jouer des patterns

// Interface en cli


(
SynthDef(\samplePlayer, { |out=0, bufnum=0|
  Out.ar(out,
    PlayBuf.ar(numChannels: 1, bufnum: bufnum, BufRateScale.kr(bufnum))
});)
)


(
~sampleNames = (
  kick: "kick.wav",
  snare: "snare.wav",
  hats: "hats.wav"
)
)

(
~samples = ();
~sampleNames.keysValuesDo {
  |key, value|
  ~samples.put(key, Buffer.read(server: s, path: Document.current.dir + "/" + value
  ));
};
)
Synth(\samplePlayer, [bufnum: ~sample[\kick]]);

TempoCLock.default.tempo = 60/60;

(
Pbind(*[
  instrument: \samplePlayer,
  bufnum: ~samples[\kick],
  dur: Pbjorklund2(1, 4)
]).play(quant: 1)
)