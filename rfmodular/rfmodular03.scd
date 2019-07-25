(

~tempo = 120/60;
TempoClock.default.tempo = ~tempo;

{{
  var note=rrand(51, 69), seq, trigger, reset=0, scale;

  trigger = TDuty.kr(Dseq([2, 1, 2], inf)/8);
  scale = Scale.minorPentatonic;
  seq = Demand.kr(
    trigger,
    reset,
    Dseq(
      scale.degreeToFreq(
        (note - 50) + [0, 0, -2, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4, -4 ],
        50.midicps, 1), inf));
  SinOsc.ar(seq) * EnvGen.kr(Env.asr(releaseTime: 0.8), trigger) * 0.2;

}.play}.fork(quant: 1)
)

// Duty
// Demand
// TDuty
//
// Dibrown
// Scale.directory

