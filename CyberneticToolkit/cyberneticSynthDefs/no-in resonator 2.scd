/////////////////////////////////
/* A closed, no-input feedback system in which resonant filtering and nonlinear wave-shaping sustain self-generated oscillation, while a parallel analysis path performs cybernetic re-parametrisation. Negative and positive-feedback elements continually reintroduce unpredictability, preventing convergence to a static state.
*/
/////////////////////////////////


//env multiplied by HenonC, step is 1
(
SynthDef(\noinReson02, {
	var snd, fb, env, trig, freqStep;
	fb = LocalIn.ar(1);
	env = Amplitude.ar(fb, 0.0001);
	trig = (HPZ1.ar(env) > 0.01) & (env > \threshold.kr(0.001));

	freqStep = Stepper.ar(HenonC.ar(10*env.linlin(-1,1,0.5,2.0)) + trig.linlin(0, 1, -1, 1), reset: 0, min: -12, max: 12, step: 1);
	freqStep = Lag.ar(freqStep, 0.5 + env);
	snd = Limiter.ar(LeakDC.ar(CombC.ar(fb, 1.1, 0.1, 1.0 - fb.linlin(-1,1,0.1, 0.5))));
	snd = (CrossoverDistortion.ar(snd, 10.5, 0.9, 1000)).tanh;
	snd = Ringz.ar(snd,
		(\freq.ar(40.0) * (freqStep/trig.linlin(0.0, 1.0, 1.0, 10.0))),
		2);
	snd = CrossoverDistortion.ar(snd, \dist.kr(0.5) + (fb * \distCoeff.kr(0.8)), \smooth.kr(0.5));
	snd = Limiter.ar(CombC.ar(snd, 0.1, 0.01 + fb.clip, mul: 12));
	snd = Resonz.ar(snd, 60 + trig.linexp(0, 1, 10, 60), 1.0, 10);
	snd = Splay.ar(snd);
	snd = Limiter.ar(LeakDC.ar(snd), 0.9);


	LocalOut.ar(snd);
	Out.ar(0, snd * \amp.kr(0.3));
}).add;
)
