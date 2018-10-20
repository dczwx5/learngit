/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.Particle;
    import QFLib.Math.CVector2;

    public class CPMGravity extends CParticleModifier {

    private static var m_vector2DHelper:CVector2 = CVector2.zero();

    public function CPMGravity() {
        super();
    }

    protected override function _processAfterUpdate(theParticle:Particle, fDeltaTime:Number):void
    {
        super._processAfterUpdate(theParticle, fDeltaTime);

        var origin:CVector2 = theParticle.origin;
        var position:CVector2 = theParticle.position;
        var orientation:CVector2 = m_vector2DHelper;
        orientation.set(origin);
        orientation.subOn(position);
        if(orientation.equals(CVector2.ZERO) == false)
        {
            var life:Number = (theParticle.maxLife - theParticle.life) / theParticle.maxLife;
            var size:Number = (_getModifierData() as CPMGravityData).getGravitySizeInLife(life);
            orientation.normalize();
            orientation.mulOnValue(size);
            orientation.mulOnValue(fDeltaTime);
            theParticle.velocity.addOn(orientation);
        }
    }
}
}
