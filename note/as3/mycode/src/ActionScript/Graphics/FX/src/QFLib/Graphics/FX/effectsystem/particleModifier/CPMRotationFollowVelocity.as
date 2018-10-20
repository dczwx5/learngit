/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/28.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.Particle;
    import QFLib.Math.CVector2;

    public class CPMRotationFollowVelocity extends CParticleModifier {
    private static var m_vector2DHelper:CVector2 = CVector2.zero();

    public function CPMRotationFollowVelocity() {
    }

    protected override function _processAfterEmition(theParticle:Particle):void
    {
        super._processAfterEmition(theParticle);
        var velocity:CVector2 = theParticle.velocity;
        if(velocity.equals(CVector2.ZERO) == false)
        {
            var isOpposite:Boolean = (_getModifierData() as CPMRotationFollowVelocityData).getIsOpposite();
            m_vector2DHelper.set(velocity);
            velocity = m_vector2DHelper
            velocity.normalize();
            velocity.y = - velocity.y;
            if(isOpposite)velocity.mulOnValue(-1);
            theParticle.rotation.set(velocity);
        }
    }

    protected override function _processAfterUpdate(theParticle:Particle, fDeltaTime:Number):void
    {
        super._processAfterUpdate(theParticle, fDeltaTime);

        var velocity:CVector2 = theParticle.velocity;
        if(velocity.equals(CVector2.ZERO) == false)
        {
            var life:Number = (theParticle.maxLife - theParticle.life) / theParticle.maxLife;
            var isOpposite:Boolean = (_getModifierData() as CPMRotationFollowVelocityData).getIsOppositeInLife(life);
            m_vector2DHelper.set(velocity);
            velocity = m_vector2DHelper
            velocity.normalize();
            velocity.y = - velocity.y;
            if(isOpposite)velocity.mulOnValue(-1);
            theParticle.rotation.set(velocity)
;        }
    }
}
}
