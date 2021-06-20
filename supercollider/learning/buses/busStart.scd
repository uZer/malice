s.reboot;

(
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
~grunge_grp = Group.before(~master_grp);
)

(
// Sources
SynthDef.new(\pluck, {
  arg out=0;
  var sig;
  sig = SinOsc.ar();
  Out.ar(0, sig);
}).add;

// Grunge effects
SynthDef.new(\crushr, {
  arg in=0, out=0;
  var sig;
  sig = In.ar(in, 1);
  Out.ar(out, sig);
}).add;

// Delay, reverb and spatial effects
SynthDef.new(\spacer, {
  arg in=0, out=0;
  var sig;
  sig = In.ar(in, 1);
  sig = sig!2;
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
//
// +-------+ grunge_bus +------+ space_bus  +-----+ master_bus +------+
// |Sources|            |Crushr|            |Space|            |Master|
// |   1   >------\     |      |            |     |            |      > out0
// |   2   >------------> mono >------------> ! 2 >============> tanh |
// |   N   >------/     |      |            |     |            |      > out1
// +-------+            +------+            +-----+            +------+
//
Synth.new(\master, [\in, ~master_bus, \out, 0], ~master_grp);
Synth.new(\spacer, [\in, ~space_bus, \out, ~master_bus], ~space_grp);
Synth.new(\crushr, [\in, ~grunge_bus, \out, ~space_bus], ~grunge_grp);
Synth.new(\pluck, [\out, ~grunge_bus], ~source_grp);
// Play sources
)

~space_grp.freeAll;
~grunge_grp.freeAll;
~master_grp.freeAll;

~source_grp.freeAll;