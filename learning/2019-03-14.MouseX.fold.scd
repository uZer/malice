(
Server.default = s = Server.local;
s.recHeaderFormat = "wav";
s.options.sampleRate = 44100;
s.options.memSize = 65536;
s.options.numWireBufs = 128;
s.boot;
)

({SynthDef(\rfmodular01, { |out|
  //
  // OSC
  //
  // Simple stereo sinus oscillator
  var sSin = { |freq=300, mul=1|
    SinOsc.ar([freq - 1, freq + 1], mul)
  };

  // Simple stereo square oscillator with width control
  var sSqu = { |freq=300, width=0.5, mul=1|
    Pulse.ar([freq - 1, freq + 1], width, mul)
  };

  //
  // Sound processing
  //
  // Fold an input with mul coefficient
  var foldr = { |sound, dist=1| (sound * dist).fold2(1) };

  // Simple Low Pass filter
  var filtr = { |sound, freq| LPF.ar(sound, freq) };

  //
  // Tools
  //
  // Quantize an input signal to a scale, output is a frequency
  var quant = { |input, scale|
    DegreeToKey.kr(scale.as(LocalBuf), input, scale.stepsPerOctave, 1, 24).midicps.poll
  };

  //
  // Sequencers
  //
  var seq1 = Routine({
    loop({
      Pseq([10, 2, 1], inf).asStream;
      0.2.wait;
    })
  });

  //
  // Patch
  //
  var sound1 = sSqu.(freq: quant.(seq1, Scale.minorPentatonic));
  var sound1_d = foldr.(sound1, dist: MouseY.kr(1, 100));
  var sound1_df = filtr.(sound1_d, freq: MouseX.kr(10, 10000));

  Out.ar(out, sound1_df);


}).add;
s.sync;

// Trigger and external control
d=Synth(\rfmodular01);
}.fork
)