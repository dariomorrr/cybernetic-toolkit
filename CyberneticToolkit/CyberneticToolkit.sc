CyberneticToolkit {
	classvar <defs;

	*dir {
		^this.filenameSymbol.asString.dirname +/+ "cyberneticSynthDefs"
	}

	*load { |server|
		server = server ? Server.default;
		defs = (this.dir +/+ "*.scd").pathMatch.collect { |path| path.load };
		server.waitForBoot {
			defs.do(_.add);
			server.sync;
			"CyberneticToolkit: % SynthDefs loaded".format(defs.size).postln; //attenzione, questo ha senso solo se ogni .scd file contiente solo UN synth
		};
	}
}