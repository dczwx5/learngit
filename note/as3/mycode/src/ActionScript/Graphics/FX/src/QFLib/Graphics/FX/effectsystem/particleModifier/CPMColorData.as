/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/13.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.particleValue.CParticleValue;
    import QFLib.Graphics.FX.effectsystem.particleValue.CParticleValueFactory;
    import QFLib.Graphics.FX.utils.ColorArgb;

    public class CPMColorData extends CParticleModifierData {
    private var m_color:CParticleValue;
    private var m_isPersistent:Boolean = false;
    public function CPMColorData(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    public override function dispose():void
    {
        if(m_color != null)
                CParticleValueFactory.deallocate(m_color);
        m_color = null;
        super.dispose();
    }

    public function getColor():ColorArgb { return m_color.getValue() as ColorArgb; }
    public function getColorInLife(life:Number):ColorArgb {
        return m_color.getValueInLife(life) as ColorArgb;
    }

    public function getIsPersistent():Boolean { return m_isPersistent; }

    protected override function _isEqual(theTarget:CParticleModifierData):Boolean
    {
        var theMyTarget:CPMColorData = theTarget as CPMColorData;
        return super._isEqual(theTarget) && m_color.isEqual(theMyTarget.m_color) &&
                m_isPersistent == theMyTarget.m_isPersistent;
    }

    protected override function _loadFromJson(theData:Object):void {
        super._loadFromJson(theData);
        if (m_color != null)CParticleValueFactory.deallocate(m_color);
        var theColorData:Object = theData["color"];
        m_color = CParticleValueFactory.allocate(theColorData);
        m_isPersistent = theData["isPersistent"] || m_isPersistent;
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        theResultData["color"] = m_color.saveToJson();
        theResultData["isPersistent"] = m_isPersistent;
        return theResultData;
    }
}
}
