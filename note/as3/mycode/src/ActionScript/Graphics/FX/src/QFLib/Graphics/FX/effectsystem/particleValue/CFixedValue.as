/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
public class CFixedValue extends CParticleValue{
    private var m_fValue:Number = 0;
    public function CFixedValue(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    protected override function _calculateValue(life:Number = 0):Object
    {
        return m_fValue;
    }

    protected override function _isEqual(theTarget:CParticleValue):Boolean
    {
        var theMyTarget:CFixedValue = theTarget as CFixedValue;
        return super._isEqual(theTarget) && m_fValue == theMyTarget.m_fValue;
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        m_fValue = Number(theData["value"]);
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        theResultData["value"] = m_fValue;
        return theResultData;
    }


}
}
