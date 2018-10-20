/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
public class CDynRandomValue extends CParticleValue {
    private var m_fMinValue:Number = 0;
    private var m_fMaxValue:Number = 0;
    public function CDynRandomValue(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    protected override function _calculateValue(life:Number = 0):Object
    {
        return m_fMinValue + Math.random() * (m_fMaxValue - m_fMinValue);
    }

    protected override function _isEqual(theTarget:CParticleValue):Boolean
    {
        var theMyTarget:CDynRandomValue = theTarget as CDynRandomValue;
        return super._isEqual(theTarget) &&
                m_fMinValue == theMyTarget.m_fMinValue &&
                        m_fMaxValue == theMyTarget.m_fMaxValue;
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        m_fMinValue = Number(theData["min"]);
        m_fMaxValue = Number(theData["max"]);
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        theResultData["min"] = m_fMinValue;
        theResultData["max"] = m_fMaxValue;

        return theResultData;
    }
}
}
