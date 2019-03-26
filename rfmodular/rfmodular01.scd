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
  var lfo = { |time = 0.25, min = 0, max = 1|
    LFPar.kr(1/time, iphase: 0.5, mul: (max - min) / 2, add: (min + max) / 2)
  };

  //
  // [Audio processing]
  //

  // Turn a mono sound to a width controlled stereo signal,
  // by adding a small delay to the left channel.
  // arg width: should be somewhere between 0 (mid) and 1 (side)
  var widel = { |sound, width = 0.005, max = 0.01|
    [DelayN.ar(sound, max, width * max), sound]
  };

  // Fat PWM + PM
  var lfo01, lfo02, lfo03;
  var osc01, osc02;
  var sound1;

  lfo01 = lfo.(16);
  lfo02 = lfo.(16, min: 0.42, max: 0.58);  // pulse width
  lfo03 = lfo.(16, min: 0.40);             // stereo width

  osc01 = Pulse.ar(freq + 0.2, width: lfo02);
  osc02 = SinOsc.ar(freq - 0.2, phase: lfo02);

  sound1 = (osc01 * 0.5) + (osc02 * (1 - 0.5));
  sound1 = RLPFD.ar(sound1, ffreq: MouseX.kr(30, 6000), res: MouseY.kr(0, 0.9));
  sound1 = (sound1 * dist).fold2(1);
  sound1 = LPF.ar(sound1, 15000);
  sound1 = widel.(sound1, width: lfo03, max: 0.03);

  // sound1 = Compander.ar(sound1, sound1,
  //   thresh: 0.2,
  //   slopeBelow: 2,
  //   slopeAbove: 0,
  //   clampTime: 0.1,
  //   relaxTime: 0.4
  // ) * 0.8;

  Out.ar(out, sound1);
}).add;

// Simple external mouse control for bus usage
SynthDef(\mouseControl, { |out, min = 2, max = 10|
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

- Have to make a class instead of a var containing a function?

*/
