
s.boot;
OSCFunc.trace(true, true);

(
~mapper={|osccmd, synth, param, min, max|
  OSCdef(
    osccmd,
    {
      |msg, time, addr, recvPort|
      synth.set(param, msg[1].linlin(0, 1, min, max));
      msg[1].postln;
    },
    '/' ++ osccmd.asString
  );
};


SynthDef.new(\test, { |freq=440, amp=0.2|
  var sig = SinOsc.ar(freq) * amp;
  Out.ar(0, sig);
}).add;

)

(
x = Synth(\test);
~mapper.value(\freq, x, \freq, 100, 1000);
~mapper.value(\amp, x, \amp, 0, 1);
)

'a' + 'b';


m = NetAddr("127.0.0.1", 57120); // loopback
(
m.sendMsg("/freq", rrand(0.0, 1.0));
m.sendMsg("/amp", rrand(0.0, 1.0));
)