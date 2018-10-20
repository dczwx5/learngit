/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/13.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.Particle;

    public class CPMColor extends CParticleModifier {

    private var m_preColor:uint;

    public function CPMColor() {
        super();
    }

    protected override function _processAfterEmition(theParticle:Particle):void
    {
        super._processAfterEmition(theParticle);
        theParticle.color = (_getModifierData() as CPMColorData).getColor().rgba;
    }

    protected override function _processBeforeUpdate(theParticle:Particle, fDeltaTime:Number):void
    {
        super._processBeforeUpdate(theParticle, fDeltaTime);
        //now the particle color will be change by keyframe in particle system.
        //so save color so that always override keyframe color
        var data:CPMColorData = _getModifierData() as CPMColorData;
        if(data.getIsPersistent() == false)
        {
            m_preColor = theParticle.color;
        }
    }

    protected override function _processAfterUpdate(theParticle:Particle, fDeltaTime:Number):void
    {
        super._processAfterUpdate(theParticle, fDeltaTime);
        var data:CPMColorData = _getModifierData() as CPMColorData;
        if(data.getIsPersistent())
        {
            var life:Number = (theParticle.maxLife - theParticle.life) / theParticle.maxLife;
            theParticle.color = data.getColorInLife(life).rgba;
        }
        else
        {
            //now the particle color will be change by keyframe in particle system.
            //so save color so that always override keyframe color
            theParticle.color = m_preColor;
        }
    }
}
}
