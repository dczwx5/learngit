/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/28.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
    import QFLib.Graphics.FX.effectsystem.particleValue.CParticleValue;
    import QFLib.Graphics.FX.effectsystem.particleValue.CParticleValueFactory;

    public class CPMRotationOffsetData extends CParticleModifierData{

    private var m_isOpposite:CParticleValue;

    public function CPMRotationOffsetData(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    public override function dispose():void
    {
        if(m_isOpposite != null)
                CParticleValueFactory.deallocate(m_isOpposite);
        m_isOpposite = null;
        super.dispose();
    }

    public function getIsOpposite():Boolean { return m_isOpposite.getValue() as Boolean; }
    public function getIsOppositeInLife(life:Number):Boolean { return m_isOpposite.getValueInLife(life) as Boolean; }

    protected override function _isEqual(theTarget:CParticleModifierData):Boolean
    {
        var theMyTarget:CPMRotationOffsetData = theTarget as CPMRotationOffsetData;
        return super._isEqual(theTarget) && m_isOpposite.isEqual(theMyTarget.m_isOpposite);
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        if(m_isOpposite != null)CParticleValueFactory.deallocate(m_isOpposite);
        var theOppositeData:Object = theData["opposite"];
        m_isOpposite = CParticleValueFactory.allocate(theOppositeData);
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        theResultData["opposite"] = m_isOpposite.saveToJson();
        return theResultData;
    }
}
}
