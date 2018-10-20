/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/13.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
    import QFLib.Graphics.FX.utils.ColorArgb;

    public class CColorFixedValue extends CParticleValue {
    private var m_color:ColorArgb = ColorArgb.fromRgba(0xffffffff);
    public function CColorFixedValue(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    protected override function _calculateValue(life:Number = 0):Object
    {
        return m_color;
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        if(theData["value"]){
            var value:Array = theData["value"];
            m_color.r = value[0] * 255;
            m_color.g = value[1] * 255;
            m_color.b = value[2] * 255;
            m_color.a = value[3] * 255;
        }
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        var value:Array = new Array();
        var color:ColorArgb = m_color;
        value[value.length] = Number((color.r / 255).toFixed(3));
        value[value.length] = Number((color.g / 255).toFixed(3));
        value[value.length] = Number((color.b / 255).toFixed(3));
        value[value.length] = Number((color.a / 255).toFixed(3));
        theResultData["value"] = value;
        return theResultData;
    }
}
}
