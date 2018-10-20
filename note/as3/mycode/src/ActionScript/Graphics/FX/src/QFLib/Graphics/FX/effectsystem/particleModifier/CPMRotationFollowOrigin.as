/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/28.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.Particle;
    import QFLib.Math.CVector2;

    public class CPMRotationFollowOrigin extends CParticleModifier {

    private static var m_vector2DHelper:CVector2 = CVector2.zero();

    public function CPMRotationFollowOrigin() {
        super();
    }

    protected override function _processAfterEmition(theParticle:Particle):void
    {
        super._processAfterEmition(theParticle);
        var origin:CVector2 = theParticle.origin;
        var position:CVector2 = theParticle.position;
        var direction:CVector2 = m_vector2DHelper;
        direction.set(origin);
        direction.subOn(position);
        if(direction.equals(CVector2.ZERO) == false)
        {
            var isOpposite:Boolean = (_getModifierData() as CPMRotationFollowOriginData).getIsOpposite();
            direction.normalize();
            if(isOpposite)direction.mulOnValue(-1);
            direction.y = -direction.y;
            theParticle.rotation.set(direction);
        }
    }

    protected override function _processAfterUpdate(theParticle:Particle, fDeltaTime:Number):void
    {
        super._processAfterUpdate(theParticle, fDeltaTime);
        var origin:CVector2 = theParticle.origin;
        var position:CVector2 = theParticle.position;
        var direction:CVector2 = m_vector2DHelper;
        direction.set(origin);
        direction.subOn(position);
        if(direction.equals(CVector2.ZERO) == false)
        {
            var life:Number = (theParticle.maxLife - theParticle.life) / theParticle.maxLife;
            var isOpposite:Boolean = (_getModifierData() as CPMRotationFollowOriginData).getIsOppositeInLife(life);
            direction.normalize();
            if(isOpposite)direction.mulOnValue(-1);
            direction.y = -direction.y;
            theParticle.rotation.set(direction);
        }
    }

}
}
