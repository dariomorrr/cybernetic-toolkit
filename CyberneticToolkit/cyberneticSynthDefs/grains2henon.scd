/////////////////////////////////
// Feedback modulation of a chaotic Hénon map and granular impulses
/////////////////////////////////

(
SynthDef(\grains2henon, { arg freqA = 145, freqB = 123;
	var fbIn = LocalIn.ar(2);
	var sigs = Henon2DC.ar([freqA, freqB] + (fbIn.reverse));
	var fbAmp = Amplitude.ar(fbIn).lag(0.1);
	var pitch = sigs + PitchShift.ar(sigs, \pitchShift.kr(2.0) * fbAmp.linlin(0, 1, 0.01, 1.0), fbAmp.linlin(0, 1, 0.01, 1.0), 2.0);
	var sig = SinGrain.ar(Dust.ar(\dens.kr(15)), 1, [freqA, freqB] + (fbIn.reverse));
	fbAmp = fbAmp * (SinOsc.ar(\lfoFq.ar(0.1)) + pitch);
	sigs = sigs * fbAmp.linlin(0, 1, 0.001, 1.0); // NOTICE by mapping fbAmp with its true limits (0 / 1) the result changes
	sigs = ((sigs * sig) + pitch);
	sigs = ((sigs * sig) + sig).tanh; // comment-out for different timbre
	//sigs = ((sigs * sig) + sig).fold2; // comment-in for different timbre
	sigs = Limiter.ar(sigs, 0.9);
	sigs = LeakDC.ar(sigs);
	LocalOut.ar(sigs!2);
	sigs * \amp.kr(0.1);
	Out.ar(0, sigs!2 * \amp.kr(0.1));
}).add;
)
