/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/13.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
    import QFLib.Graphics.FX.utils.ColorArgb;

    public class CColorDynRandomValue extends CParticleValue {
    private var m_minColor:ColorArgb = ColorArgb.fromRgba(0xffffffff);
    private var m_maxColor:ColorArgb = ColorArgb.fromRgba(0xffffffff);
    private var m_isRandomAllD:Boolean = true;
    public function CColorDynRandomValue(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    protected override function _calculateValue(life:Number = 0):Object
    {
        var minColor:ColorArgb = m_minColor;
        var maxColor:ColorArgb = m_maxColor;
        if(m_isRandomAllD)
        {
            return new ColorArgb(
                    minColor.r + Math.random() * (maxColor.r - minColor.r),
                    minColor.g + Math.random() * (maxColor.g - minColor.g),
                    minColor.b + Math.random() * (maxColor.b - minColor.b),
                    minColor.a + Math.random() * (maxColor.a - minColor.a)
            );
        }
        else
        {
            var r:Number = Math.random();
            return new ColorArgb(
                    minColor.r + r * (maxColor.r - minColor.r),
                    minColor.g + r * (maxColor.g - minColor.g),
                    minColor.b + r * (maxColor.b - minColor.b),
                    minColor.a + r * (maxColor.a - minColor.a)
            );
        }
    }

//    protected override function _isEqual(theTarget:CParticleValue):Boolean
//    {
//        var theMyTarget:CColorDynRandomValue = theTarget as CColorDynRandomValue;
//        return super._isEqual(theTarget) &&
//    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        var min:Array = theData["min"];
        var max:Array = theData["max"];
        m_minColor = _readColor(min);
        m_maxColor = _readColor(max);
        m_isRandomAllD = theData["isRandomAllD"] || m_isRandomAllD;
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        theResultData["min"] = _writeColor(m_minColor);
        theResultData["max"] = _writeColor(m_maxColor);
        if(m_isRandomAllD == false)
                theResultData["isRandomAllD"] = m_isRandomAllD;
        return theResultData;
    }


    private function _readColor(value:Array):ColorArgb
    {
        var color:ColorArgb = ColorArgb.fromRgba(0xffffffff);
        if(value)
        {
            color.r = value[0] * 255;
            color.g = value[1] * 255;
            color.b = value[2] * 255;
            color.a = value[3] * 255;
        }
        return color;
    }

    private function _writeColor(color:ColorArgb):Object
    {
        var value:Array = new Array();
        value[value.length] = Number((color.r / 255).toFixed(3));
        value[value.length] = Number((color.g / 255).toFixed(3));
        value[value.length] = Number((color.b / 255).toFixed(3));
        value[value.length] = Number((color.a / 255).toFixed(3));
        return value;
    }
}
}
