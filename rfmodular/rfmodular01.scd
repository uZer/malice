(
// Bootstrap ///////////////////////////////////////////////////////////////////

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
// Server Definitions //////////////////////////////////////////////////////////

// "Modular" synth for Pmono usage.
// Should not be stopped or have any doneActions
SynthDef(\modular01, { |out, freq = 50, dist = 2|

  //
  // [Control functions and tools]
  //
  var env01 = EnvGen.kr(Env.perc);

  // Sinusoïdal LFO with oscillating between min and max
  var lfo01 = { |time = 0.25, min = 0, max = 1|
    LFPar.kr(freq: 1/time, iphase: 0.5, mul: (max - min) / 2, add: (min + max) / 2)
  };

  //
  // [Audio processing]
  //
  // Resonant low pass filter with an adaptive Q
  var rlpf01 = { |sound, freq| RLPF.ar(sound, freq, 50/(freq/4)) };

  // Turn a mono sound to a width controlled stereo signal
  // by adding a small delay to the left channel.
  // arg width: should be somewhere between 0 (mid) and 100 (side)
  var widel = { |sound, width = 0.005, max = 0.01|
    [DelayN.ar(sound, max, width * max / 100), sound]
  };

  // Fat PWM
  var sound1;
  sound1 = Pulse.ar(freq, width: lfo01.(8, 0.45, 0.55), mul: dist);
  sound1 = rlpf01.(sound1, freq: MouseX.kr(20, 1000)).fold2(1) * 0.4;
  sound1 = LPF.ar(sound1, freq: MouseX.kr(20, 10000));
  sound1 = widel.(sound1, width: lfo01.(time: 16, min: 40, max: 100), max: 0.02);

  Out.ar(out, sound1);
}).add;

// Simple external mouse control for bus usage
SynthDef(\mouseControl, { |out, min = 1, max = 100|
  Out.kr(out, MouseY.kr(min, max));
}).add;
)

// Client side control /////////////////////////////////////////////////////////
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

// Clear
(
~mouse.free;
~width.free
)

// Questions ///////////////////////////////////////////////////////////////////
/*

- Clock divider for a Pseq of \dur? (so I don't have to change each value)

- multichannel bus: how to select one specific channel of a bus ? ~bus[1].asMap

- What is lag?

- Other stuff to play with polar width
  (PanAZ not doing what I though or I don't understand it)

- How to trigger an EnvGen from outside, without reinstantiating the Synth
  (generate the gate signal in Pmono)

*/
