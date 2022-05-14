
(


Ndef(\osc01, {
  SinOsc.ar(freq: \freq.kr(220), phase: \phase.kr(0));
});

Ndef(\env01, {
  EnvGen.ar(envelope: Env.asr(), gate: \gate.kr) * \in.ar;
});

Ndef(\seq01_gate, {
  Impulse.kr(freq: \freq.kr(1));
});

Ndef(\seq01_freq, {
  Duty.kr(dur: Dseq(list: [0.5, 1], repeats: inf), level: Dseq([290, 440], inf));
});

)

// Ndef(\osc01).play;
// Ndef(\osc01).clear;

(
Ndef(\osc01, { |freq=440|
  Blip.ar(freq: freq);
});

Ndef(\osc01)[1] = \set -> Pbind(
  \dur, Pseq([1, 2], inf),
  \freq, Pseq([300, 400], inf)
);

Ndef(\osc01).play;

)



(
Ndef(\osc01, { |freq = 440|
    SinOsc.ar(freq)
});
Ndef(\osc01).play;
)
(
Ndef(\osc01)[1] = \set -> Pbind(
    \dur, Pseq([1, 2], inf),
    \freq, Pseq([300, 400], inf)
);
)





Ndef(\osc01)[1]={ |freq=440|
  Blip.ar(freq: freq);
};

Ndef(\env01).map(\gate, Ndef(\seq01_gate));


Ndef(\env01) <<>.in Ndef(\osc01);
Ndef(\osc01).map(\freq, Ndef(\seq01_freq));
Ndef(\seq01_gate).set(\freq, 2);
Ndef(\osc01).set(\freq, 330);


Ndef(\env01).play;
Ndef(\env01).stop;

Ndef.clear;