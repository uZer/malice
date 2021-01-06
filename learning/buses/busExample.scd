s.reboot;

(
//
// +-------+ grunge_bus +------+ space_bus  +-----+ master_bus +------+
// |sources|            |grunge|            |space|            |master|
// |   1   >======\     |      |            |     |            |      > out0
// |   2   >======|=====>      >============>     >============> tanh |
// |   N   >======/     |      |            |     |            |      > out1
// +-------+            +------+            +-----+            +------+
//
~source_grp.free;
~master_grp.free;
~space_grp.free;
~grunge_grp.free;
s.newBusAllocators;
s.newBufferAllocators;

// Buses and grps init
~source_grp = Group.new;
~master_bus = Bus.audio(s, 2);
~master_grp = Group.after(~source_grp);
~space_bus = Bus.audio(s, 2);
~space_grp = Group.before(~master_grp);
~grunge_bus = Bus.audio(s, 2);
~grunge_grp = Group.before(~space_grp);
)


// SOURCES
(
SynthDef.new(\pluck, {
  arg out=0, freq=300, amp=0.2, time=0.5, pos=0;
  var sig, env;
  sig = SinOsc.ar(freq, mul: amp);
  env = EnvGen.kr(
    envelope: Env.perc(releaseTime: 0.2),
    gate: Impulse.kr(1/time),
  );
  sig = sig * env;
  sig = Pan2.ar(sig, pos);
  Out.ar(out, sig);
}).add;

// FX
// Grunge effects
SynthDef.new(\crushr, {
  arg in=0, out=0, cutfreq=2000;
  var sig;
  sig = In.ar(in, 2);
  sig = CrossoverDistortion.ar(
    in: sig,
    amp: 0.7,
    smooth: 0.7
  ).tanh;
  sig = RLPF.ar(sig, cutfreq);
  Out.ar(out, sig);
}).add;

// Delay, reverb and spatial effects
SynthDef.new(\spacer, {
  arg in=0, out=0;
  var sig;
  sig = In.ar(in, 2);
  sig = FreeVerb.ar(sig);
  Out.ar(out, sig);
}).add;

// Master effects
SynthDef.new(\master, {
  arg in=0, out=0;
  var sig;
  sig = In.ar(in, 2);
  sig = sig.tanh;
  Out.ar(out, sig);
}).add;
)

(
// Patch things
~space_grp.freeAll;
~grunge_grp.freeAll;
~master_grp.freeAll;
Synth.new(\crushr, [\in, ~grunge_bus, \out, ~space_bus], ~grunge_grp);
Synth.new(\spacer, [\in, ~space_bus, \out, ~master_bus], ~space_grp);
Synth.new(\master, [\in, ~master_bus, \out, 0], ~master_grp);
)

// Play sources
(
2.do{
  Synth.new(\pluck, target: ~source_grp, args: [
    \out, ~grunge_bus,
    \freq, exprand(50, 1000),
    \time, exprand(0.5, 10),
    \pos, -1.1.rand
  ])
};
)
~source_grp.freeAll;