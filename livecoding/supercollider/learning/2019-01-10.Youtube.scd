s.boot;

(
SynthDef.new(\soundTest1, {
  arg ampHz=4, fund=40, maxPartial=4, width=0.5;
  var sig1, sig2, freq1, freq2, amp1, amp2;

  amp1 = LFPulse.kr(freq: ampHz, iphase: 0, width: 0.12) * 0.75;
  amp2 = LFPulse.kr(freq: ampHz, iphase: 0.5, width: 0.12) * 0.75;
  freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
  freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
  sig1 = Pulse.ar(freq1, width);
  sig1 = FreeVerb.ar(sig1, mix: 0.7, room: 0.8, damp: 0.25);
  sig2 = Pulse.ar(freq2, width);
  sig2 = FreeVerb.ar(sig2, mix: 0.7, room: 0.8, damp: 0.25);
  Out.ar(0, sig1);
  Out.ar(1, sig2);
  // env1 = Env.new(levels: [0, 1, 0], times: [0.5, 1, 2], curve: [3, -3, 0]);
  // env1.plot;

}).add;
)

x = Synth.new(\soundTest1);
x.set(\width, 0.60);
x.set(\fund, 80);
x.set(\maxPartial, 20);
x.set(\ampHz, 0.25);
x.free;