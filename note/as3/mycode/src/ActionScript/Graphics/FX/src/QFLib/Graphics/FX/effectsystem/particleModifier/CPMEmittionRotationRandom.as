/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/28.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.Particle;

    public class CPMEmittionRotationRandom extends CParticleModifier {
    public function CPMEmittionRotationRandom() {
    }

    protected override function _processAfterEmition(theParticle:Particle):void
    {
        super._processAfterEmition(theParticle);

        var fRandomAngle:Number = 2 * Math.PI * Math.random();
        theParticle.rotation.x = Math.cos(fRandomAngle);
        theParticle.rotation.y = Math.sin(fRandomAngle);
    }
}
}
