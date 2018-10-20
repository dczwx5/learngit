/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.Particle;
    import QFLib.Math.CVector2;

    public class CPMForwardMove extends CParticleModifier {

    private static var m_helperVec2:CVector2 = CVector2.zero();

    public function CPMForwardMove() {
        super();
    }

    protected override  function _processAfterEmition(theParticle:Particle):void
    {
        super._processAfterEmition(theParticle);
        var rotation:CVector2 = theParticle.rotation;
        var size:Number = (_getModifierData() as CPMForwardMoveData).getVelocitySize();
        var velocity:CVector2 = m_helperVec2;
        velocity.set(rotation);
        velocity.mulOnValue(size);
        theParticle.velocity.x = velocity.x;
        theParticle.velocity.y = velocity.y;
    }
}
}
