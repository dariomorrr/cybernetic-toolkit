/////////////////////////////////
// Feedback-driven granular synth to simulate insects
/* Two independent sensors continuously and directly modulate a chaotic H ́enon oscillator, a self-referential tremolo oscillator and the density and duration of a four-voice granular texture; the only discrete element is the stochastic triggering of Dust, a random impulse generator whose rate is itself a continuous function of the system’s sensed state. Regulation is concentrated and mainly excitatory, and that is precisely what allows it to model, through purely cybernetic means, the qualitative behavior of a biological chorusing system.
*/
/////////////////////////////////

(
SynthDef(\crickets, {
	var fb = LocalIn.ar(1);
	var fbAmp = Amplitude.ar(fb);
	var zc = ZeroCrossing.ar(fb);
	var sig, grn;
	fbAmp = fbAmp * SinOsc.ar(0.1 + Clip.ar(zc, 0.0, \noiseQ.ar(34)) + fb);
	sig = HenonC.ar(\freq.ar(13100) + fb * fbAmp.linlin(0, 1, 0.01, 0.8));
	grn = (GrainSin.ar(1,
		Dust.ar(\dens.ar(0.12) + fbAmp + Clip.ar(sig, 0.01, 0.9)),
		1 + Clip.ar((zc * sig), 0.01, 0.9),
		([1,2,3,4] + \baseFreq.ar(136.midicps)) + sig));
	grn = grn.sum;
	sig = (sig * grn).tanh;
	sig = sig.fold2;
	sig = Limiter.ar(LeakDC.ar(sig), 0.9);
	LocalOut.ar(sig);
	Out.ar(0, (sig!2) * \amp.kr(0.3));
}).add;
)
