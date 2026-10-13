/////////////////////////////////
// External input drives playback and interruption of a buffer
/////////////////////////////////

// NOTE: insert a valid audio path in a buffer


(
SynthDef(\cyberListener, {
    arg amp = 0.1, threshold = 0.023, buf = 0,
        atk = 0.01, sus = 2.0, rel = 3.0,
        fadeTime = 0.001;

    var sig, env, input, trig, gateEnv;
    var posMod, rateMod;
    var retriggerFade, cleanTrig;
    var delayedTrig, fadeEnv;

    // environment listener
    input = Limiter.ar(LeakDC.ar(SoundIn.ar(0)));
    env = Amplitude.kr(input, attackTime: 0.01, releaseTime: 0.5);

    // environment-based modulation
    posMod = 1.0 * (1 - (env * 0.8));
    rateMod = 0.4 + (env * 0.6);

    // raw trigger
    trig = (HPZ1.kr(env) > 0.01) & (env > threshold);

    // detection of the rising edge of the trigger
    cleanTrig = trig > 0; // Convert to boolean

    // fade envelope
    retriggerFade = EnvGen.kr(
        Env.perc(
            attackTime: 0.05,
            releaseTime: fadeTime,
            curve: -4 // Exponential fade
        ),
        gate: cleanTrig,
        doneAction: 0
    );

    // inverse: 1 -> 0 on trigger
    retriggerFade = 1 - retriggerFade;

    // sustain envelope
    gateEnv = EnvGen.kr(
        Env.linen(atk, sus, rel, curve: -4),
        gate: cleanTrig,
        doneAction: 0
    );

    // delayed trigger
    delayedTrig = TDelay.kr(cleanTrig, fadeTime + 0.002);

    // delayed buffer player
    sig = PlayBuf.ar(
        2, buf, rateMod, delayedTrig,
        (posMod * 0.8) * BufFrames.kr(buf),
        0,          // no loop
        0
    );



    sig = sig * gateEnv * retriggerFade;

	Out.ar(0, (sig!2 + input!2) * amp);
}).add;
)
