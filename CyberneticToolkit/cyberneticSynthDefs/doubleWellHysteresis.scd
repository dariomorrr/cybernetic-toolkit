/////////////////////////////////
/* Two bistable double-well attractors are driven and coupled by an ecosystem of stochastic, deterministic-chaotic and hash-based pseudo-random sources, all ultimately seeded by a smooth reading of the system’s envelope and a faster, unsmoothed reading of its raw signal and zero-crossing rate. A Hénon map is nested inside one attractor coupling parameter, itself detuned by the raw feedback signal, producing tiered multi-level chaos. The two attractor voices are given deliberately opposite spectral self- regulation before being cross-multiplied, folded and additively re-mixed with a further nonlinearly-shaped copy of the raw feedback signal. A slow, one-shot thirty second ramp additionally gates the strength of one self-coupling pathway, meaning the system’s regulatory intensity is not fixed but develops over the opening minutes of sound.
*/
/////////////////////////////////

(
SynthDef(\dwHyster, {
	var sigs, sig1, sig2, fbIn, fbAmp, zc, sub;
	fbIn = LocalIn.ar(1);
	fbAmp = Amplitude.ar(fbIn).lag(0.1);
	fbAmp = fbAmp.linlin(0, 1, 0.01, 0.9);
	zc = ZeroCrossing.ar(fbIn);
	sig1 = DoubleWell3.ar(Impulse.ar(PinkNoise.ar(fbAmp)), 0.01, SinOsc.ar(Hasher.ar(fbAmp) * \hasherFq.ar(34520)));
	sig2 = DoubleWell3.ar(Dust.ar(Hasher.ar(fbAmp)),0.05,HenonC.ar(\henonFq.ar(230)  - fbIn.linexp(0,1,1,40)) + zc.clip, Line.kr(0.0,0.3,30) * fbIn, zc.tanh);
	sig1 = BPeakEQ.ar(sig1, \peakFq.ar(250) * Lag.ar(fbIn, 1.0 + fbAmp), 10.0, -10 * fbAmp);
	sig2 = BHiShelf.ar(sig2, \shelfFq.ar(7200) - fbAmp.linexp(0,1,100,300), 1.4, 3.4 * fbAmp);
	sigs = (sig1 * sig2).fold2;
	sigs = (sigs * sig1).tanh;
	sigs = (sigs + (fbIn.fold2)).tanh;

	sigs = Limiter.ar(LeakDC.ar(sigs));

	LocalOut.ar(sigs);
	sigs = Pan2.ar(sigs);
	Out.ar(0, sigs * \amp.kr(0.4));
}).add;
)
