/////////////////////////////////
// Exploration of buffer players with cybernetic disruption and sample mod
/*
This explores a pre-recorded audio buffer in place of purely synthetic generators, testing how far the same closed sensing-and-actuation loop can be pushed once the ma- terial it acts on is no longer entirely self-produced. Across its three variants, playback rate (including direction reversal of it), retrigger density, buffer-read position and distortion depth remain governed entirely by an envelope-based and zero-crossing-based sensor pair computed from the system’s one-block de- layed output, exactly as in the purely synthetic patches. The second and third variants additionally graft the double-well attractor pair from the Cyber Wells patch onto this buffer playback front end, with small but present parameter evolution between them.
*/
/////////////////////////////////

// Note: insert a valid audio path in a buffer


// scrubber 2

(
SynthDef(\bufScrub02, {|buf=0|
    var sigs, sig1, sig2, fbIn, fbAmp, zc, pBuf, sigMul, sel;

    fbIn = LocalIn.ar(2);
    fbIn = Mix(fbIn);

    fbAmp = Amplitude.ar(fbIn).lag(0.1);
    fbAmp = fbAmp.linlin(0, 1, 0.01, 0.9);
    zc = ZeroCrossing.ar(fbIn);

    sig1 = DoubleWell3.ar(
        Impulse.ar(PlayBuf.ar(2, buf, 1.0, 1.0, 0, 0, 0)),
        0.01 + zc.tanh,
		SinOsc.ar(Hasher.ar(fbAmp) * \hashfreq1.ar(250))
    );

    sig2 = DoubleWell3.ar(
        Dust.ar(Hasher.ar(fbAmp * \hashfreq2.ar(1.0))),
        0.05 * fbIn.clip,
        HenonC.ar(\henonfreq.ar(300)) + zc.clip,
        Line.kr(0.0, 0.3, 30) * fbIn,
        zc.tanh
    );

    sigMul = (sig1 * sig2).fold2;
    sigs = (sigMul * sig1).tanh;
    sigs = (sigs + fbIn.fold2).tanh;

	pBuf = PlayBuf.ar(2, buf, 1.1 * zc.clip - fbAmp, Dust.ar(sigMul * 10), 0, 0, 0,);
	pBuf = CrossoverDistortion.ar(pBuf, \distamp.kr(0.01), \distsmooth.kr(0.9));

	sigs = (sigs + pBuf).tanh;

    LocalOut.ar(pBuf);
	Out.ar(0, Pan2.ar(Mix(pBuf + sigs)) * \amp.kr(0.4));
}).add;
)
