/////////////////////////////////
// A system of complex agents
/////////////////////////////////

// alloc the buses for inter-agent feedback
(
~bus1 = Bus.audio(s, 1);
~bus2 = Bus.audio(s, 1);
~bus3 = Bus.audio(s, 1);
~bus4 = Bus.audio(s, 1);

~bus5 = Bus.audio(s, 1);
~bus6 = Bus.audio(s, 1);
~bus7 = Bus.audio(s, 1);
~bus8 = Bus.audio(s, 1);

// No-Input Resonator 1
SynthDef(\osc1, {
	var extIn = InFeedback.ar(~bus5, 1);
	var modIn = VarLag.ar(InFeedback.ar(8, 1), 0.2);
	var sig, fb, env, trig, freqStep;

	fb = LocalIn.ar(1);
	env = Amplitude.ar(fb, 0.0001);
	trig = (HPZ1.ar(env) > 0.01) & (env > \threshold.kr(0.001));

	freqStep = Stepper.ar(HenonC.ar(10*extIn.linlin(-1,1,0.5,2.0)) + trig.linlin(0, 1, -1, 1), reset: 0, min: -12, max: 12, step: -4);
	freqStep = Lag.ar(freqStep, 0.5 + env);
	sig = Limiter.ar(LeakDC.ar(CombC.ar(fb, 1.1, 0.1, 1.0 - fb.linlin(-1,1,0.1, 0.5))));
	sig = (CrossoverDistortion.ar(sig, 10.5, 0.9, 1000)).tanh;
	sig = Ringz.ar(sig,
		(\freq.ar(40.0) * (freqStep/trig.linlin(0.0, 1.0, 1.0, 10.0))),
		2);
	sig = CrossoverDistortion.ar(sig, \dist.kr(0.5) + (fb * \distCoeff.kr(0.8)), \smooth.kr(0.5));
	sig = Limiter.ar(CombC.ar(sig, 0.1, 0.01 + fb.clip, mul: 12));
	sig = Resonz.ar(sig, 60 + trig.linexp(0, 1, 10, 60), 1.0, 10);
	sig = Splay.ar(sig);

	LocalOut.ar(sig * ((-1 * modIn) * \attenFb.kr(0.9)));
	//LeakDC.ar(Limiter.ar(sig * (-1 * modIn)));
	Out.ar(~bus1, sig * \amp.kr(0.9));
}).add;

// No-Input Resonator 2
SynthDef(\osc2, {
	var extIn = VarLag.ar(InFeedback.ar(~bus6, 1), 0.5);
	var modIn = InFeedback.ar(8, 1);
	var fbIn, mod, sig1, sig2, sig, fbAmp;

	extIn = extIn.lag(0.4);
	modIn = Slew.ar(modIn, 0.3, 0.3);

	fbIn = LocalIn.ar(1);
	fbAmp = Amplitude.ar(fbIn);
	sig1 = Wrap.ar(InFeedback.ar(0, 1));
	sig2 = Wrap.ar(CombC.ar((fbAmp + extIn).tanh));
	sig = sig1.tanh + sig2.tanh;
	sig = CombC.ar(sig, 0.5, 0.1 * extIn.linlin(-1, 1, 0.1, 0.4), 1.0 - modIn.linlin(-1, 1, 0.1, 0.9));
	sig = Ringz.ar(sig, \rFreq2.ar(120) - (modIn * \modCoeff.kr(0.8)).linexp(-1, 1, 60, 80), 2);
	sig = CrossoverDistortion.ar(sig, \distamp.kr(0.12) - modIn.linlin(-1, 1, 0.1, 10), \smooth.kr(10.9) - extIn.linlin(-1, 1, 1, 10));
	LocalOut.ar(sig * ((-1 * modIn) * \attenFb.kr(0.9)));
	//LeakDC.ar(Limiter.ar(sig * (-1 * modIn)));
	Out.ar(~bus2, sig * \amp.kr(0.03));
}).add;


// Cyber crickets - modulation only, non-audible in the output
SynthDef(\mod, {
	var extIn = InFeedback.ar(~bus7, 1);
	var fb = LocalIn.ar(1);
	var fbAmp = Amplitude.ar(fb);
	var zc = ZeroCrossing.ar(fb);
	var sig, grn;
	//extIn = extIn.lag(0.7);
	fbAmp = fbAmp * SinOsc.ar(0.1 + Clip.ar(zc, 0.0, \noiseQ.ar(34)) + fb);
	sig = HenonC.ar(\freq.ar(13100) + (extIn * \extCoeff.kr(0.1).linexp(-1, 1, 20, 12000)) + fb * fbAmp.linlin(0, 1, 0.01, 0.8));
	grn = (GrainSin.ar(1,
		Dust.ar(\dens.ar(0.12) + fbAmp + Clip.ar(sig, 0.01, 0.9)),
		1 + Clip.ar((zc * sig), 0.01, 0.9),
		([1,2,3,4] + \baseFreq.ar(136.midicps)) + sig));
	grn = grn.sum;
	sig = (sig * grn).tanh;
	sig = sig.fold2;
	sig = Limiter.ar(LeakDC.ar(sig), 0.9);
	LocalOut.ar(sig);
	Out.ar(~bus3, sig * \amp.kr(0.9));
}).add;

// Mixing and cross-modulation stage
SynthDef(\mix, {
	var in1, in2, in3, env1, env2, env3, sig;
	var modOsc1, modOsc2, modMod, fbMod;
	in1 = InFeedback.ar(~bus1, 1);
	in2 = InFeedback.ar(~bus2, 1);
	in3 = InFeedback.ar(~bus3, 1);

	env1 = Amplitude.ar(in1, \atk1.kr(0.01), \rel1.kr(0.1));
	env2 = Amplitude.ar(in2, \atk2.kr(0.01), \rel2.kr(0.1));
	env3 = Amplitude.ar(in3, \atk3.kr(0.01), \rel3.kr(0.1));


	modOsc1 = (env2 + env3).clip * \coeffMod1.kr(0.7);
	modOsc2 = (env1 + env3).clip * \coeffMod1.kr(0.7);
	modMod = (env1 + env2).clip * \coeffMod1.kr(0.7);
	fbMod = in3.linexp(-1, 1, 10, 12000);

	sig = MoogFF.ar(Mix.ar([in1, in2]), \moogFq.ar(12900) - VarLag.ar(fbMod.expexp(10, 12000, 100, 200), 1.0));

	sig = Limiter.ar(LeakDC.ar(sig));


	Out.ar(~bus5, modOsc1);
	Out.ar(~bus6, modOsc2);
	Out.ar(~bus7, modMod);
	Out.ar(~bus8, fbMod);

	ReplaceOut.ar(\out.kr(0), Limiter.ar(sig!2) * \amp.kr(0.9));
}).add;
)
