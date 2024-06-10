FxDelayyyy : FxBase {

    *new { 
        var ret = super.newCopyArgs(nil, \none, (
            time: 0.5,
            hp: 50,
            lp: 10000,
            mod: 0,
            feedback: 0.6,
        ), nil, 0.5);
        ^ret;
    }

    *initClass {
        FxSetup.register(this.new);
    }

    subPath {
        ^"/fx_delayyyy";
    }  

    symbol {
        ^\fxDelayyyy;
    }

    addSynthdefs {
        SynthDef(\fxDelayyyy, {|inBus, outBus|
            var t = Lag.kr(\time.kr(0.2));
            var f = Lag.kr(\feedback.kr(0.5));
            var s = Lag.kr(\mod.kr(0) / 1000);

            var input = In.ar(inBus, 2);
            var fb = LocalIn.ar(2);
            var output = LeakDC.ar(fb * f + input);

            output = HPF.ar(output, \hp.kr(400));
            output = LPF.ar(output, \lp.kr(5000));
            output = output.tanh;

            output = DelayC.ar(output, 2.5, LFNoise2.ar(12).range([t, t + s], [t + s, t])).reverse;
            LocalOut.ar(output);

            Out.ar(outBus, output);
        }).add;
    }

}