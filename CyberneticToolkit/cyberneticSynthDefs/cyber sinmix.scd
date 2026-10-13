/////////////////////////////////
// Collection of sines affected by amplitude, envelope follower and frequency of feedback.
/////////////////////////////////


(
SynthDef(\sinMix, { | amp=0.3, freqa=110, freqb=147, detune=1.003 |
	var fbIn = LocalIn.ar(2);

	var fbMono = (fbIn.sum * 0.5);
	var loud = Amplitude.ar(fbMono, 0.01, 0.2);
	var zc = Feedback.ar(fbMono).clip(40, 8000);
	//var zc = ZeroCrossing.ar(fbMono).clip(40, 8000); // if ZerCrossing instead of Feedback result is hyper-noisy
	var hz = (freqa * zc) + (freqb * 1.5 * loud);

	var sig = SinOsc.ar((0..30).normalize.linexp(0,1, \startfq.ar(5400),\endfq.ar(18))) * amp;
	sig = Mix.ar(sig);

	sig = sig * (SinOsc.ar(hz + (zc * loud * 0.12) - (SampleRate.ir * 0.1), 0, zc) * LFNoise2.ar(loud.linlin(-1, 1, 0.001, 1.0)));

	sig = sig.tanh;
	LocalOut.ar(sig!2);
	sig = (Limiter.ar(LeakDC.ar(sig), 0.9)) * amp;
	Out.ar(0, sig!2 * amp);
}).add;
)
