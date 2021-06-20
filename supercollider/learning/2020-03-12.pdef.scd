~tempo = 120/60;

(
SynthDef(\synth01, {
  arg freq=400, atk=0.1, rel=0.3, filterFreq=10000, rq=1, pan=0, amp=0.2;
  var sig, env;
  env=EnvGen.kr(Env.perc(atk, rel), doneAction: 2);

  sig=Pulse.ar(freq);
  sig=RLPF.ar(sig, filterFreq*env, rq);
  sig=sig*env;
  sig=Pan2.ar(sig, pan, amp).tanh;
  Out.ar(0, sig);
}).add;
)

Synth(\synth01);

(
Pdef(
  \sy01,
  Pbind(
    \instrument, \synth01,
    \midinote, Prand([60], inf),
    \ctranspose, -24,
    \harmonic, Pexprand(1, 10, inf).round,
    \dur, Pseq(Bjorklund2(5, 9)/4, inf),
    \stetch, ~tempo,
    \atk, 0.001,
    \filterFreq, Pexprand(400, 7000, inf).trace,
    \rel, Pexprand(2, 6, inf),
    \pan, Prand([-0.8, 0.8], inf),
    \rq, Pexprand(0.1, 0.4, inf),
  )
).play(quant: ~tempo);

// ).quant_(~tempo);

)
