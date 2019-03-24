(
// Bootstrap ////////////////////////////////////////////////////

// Server
Server.default = s = Server.local;
s.recHeaderFormat = "wav";
s.options.sampleRate = 44100;
s.options.memSize = 65536;
s.options.numWireBufs = 128;
s.boot;

(
// Clock
~tempo = 120/60;
TempoClock.default.tempo = ~tempo;
)
)

(
// Server Definitions ///////////////////////////////////////////

// "Modular" synth for Pmono usage.
// Should not be stopped or have any doneActions
SynthDef(\modular01, { |out, freq = 50, dist = 2|

  // Audio processing
  var rlpf01 = { |sound, freq| RLPF.ar(sound, freq, 50/(freq/4)) };

  // Control functions
  var env01 = EnvGen.kr(Env.perc);
  var lfo01 = LFPar.kr(freq: 1/16, mul: 0.1, add: 0.45);

  // Simple stereo square oscillator with width control
  var sound1;
  sound1 = Pulse.ar(freq, width: lfo01, mul: dist);
  sound1 = rlpf01.(sound1, freq: MouseX.kr(20, 1000)).fold2(1) * 0.4;
  sound1 = LPF.ar(sound1, MouseX.kr(20, 10000));
  // sound1 = [sound1.lag(0.5), sound1.lag(1)];

  Out.ar(out, sound1!2);
}).add;


// Simple external mouse control for bus usage
SynthDef(\mouseControl, { |out, min = 1, max = 100|
  // Simple mouse control
  Out.kr(out, MouseY.kr(min, max));
}).add;
)

// Client side control //////////////////////////////////////////
(
~bus = Bus.control(s, 1);
~mouse = Synth(\mouseControl, [out: ~bus, min: 1, max: 50]);
Pmono(\modular01,
  \degree, Pseq([8, 1, -5, -4, -5], inf),
  \scale, Scale.minor,
  \mtranspose, -12,
  \dur, Pseq([0.5, 0.25, 0.5, 0.25, 0.5], inf),
  \dist, ~bus.asMap,
).play(quant: 1);

)

(
~mouse.free;
~width.free
)

// Questions /////////////////////////////////////////////////////
/*
- Clock divider for Pseq of durations? (so I don't have to change each value)
- multichannel bus: how to select one specific channel of a bus ? ~bus.asMap(1)
- How to delay a signal, lag/lag2 not doing what I though (!= delay)
- Other stuff to play with polar width (PanAZ not doing what I though)
- How to trigger an EnvGen from outside, without reinstantiating the Synth (generate the gate signal in Pmono)
*/
