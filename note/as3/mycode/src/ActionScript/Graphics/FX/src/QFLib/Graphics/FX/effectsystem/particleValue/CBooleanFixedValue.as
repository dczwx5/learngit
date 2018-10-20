/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/28.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
public class CBooleanFixedValue extends CParticleValue {

    private var m_isTrue:Boolean = false;

    public function CBooleanFixedValue(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    protected override function _calculateValue(life:Number = 0):Object
    {
        return m_isTrue;
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        m_isTrue = Boolean(theData["value"]);
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        theResultData["value"] = m_isTrue;
        return theResultData;
    }

}
}
