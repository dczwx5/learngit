/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/13.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
    import QFLib.Graphics.FX.utils.ColorArgb;

    public class CColorLinearValue extends CParticleValue {
    private static const msc_IndexTIME:int = 0;
    private static const msc_IndexRED:int = 1;
    private static const msc_IndexGREEN:int = 2;
    private static const msc_IndexBLUE:int = 3;
    private static const msc_IndexALPHA:int = 4;

    private static const msc_ColorHelper:ColorArgb = ColorArgb.fromRgba(0xffffffff);
    private static var ms_colorHelper2:ColorArgb = new ColorArgb();

    private var m_colors:Vector.<ColorArgb> = new Vector.<ColorArgb>();
    private var m_times:Vector.<Number> = new Vector.<Number>();
    public function CColorLinearValue(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    public override function dispose():void
    {
        if(m_colors != null)m_colors.length = 0;
        m_colors = null;
        if(m_times != null)m_times.length = 0;
        m_times = null;
        super.dispose();
    }

    protected override function _calculateValue(life:Number = 0):Object
    {
        var colors:Vector.<ColorArgb> = m_colors;
        var times:Vector.<Number> = m_times;
        var count:int = times.length;
        if (count == 0)
            return msc_ColorHelper
        var i:int;
        for(i = 0; i < count; ++i)
        {
            if (times[i] > life) break;
        }
        if(i == 0)
        {
            return colors[0];
        }
        else if(i == count)
        {
            return colors[count - 1];
        }
        else
        {
            var percent:Number = (life - times[i - 1]) / (times[i] - times[i - 1]);
            ms_colorHelper2.fromRgba(ColorArgb.lerp(colors[i - 1], colors[i], percent))
            return ms_colorHelper2;
        }
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        var colors:Vector.<ColorArgb> = m_colors;
        var times:Vector.<Number> = m_times;
        colors.length = 0;
        times.length = 0;
        var  keys:Array = theData["keys"];
        if( ! keys)return;
        for(var i:int = 0, l:int = keys.length; i < l; ++i)
        {
            var time:Number = keys[i][msc_IndexTIME];
            var red:Number = keys[i][msc_IndexRED];
            var green:Number = keys[i][msc_IndexGREEN];
            var blue:Number = keys[i][msc_IndexBLUE];
            var alpha:Number  = keys[i][msc_IndexALPHA];
            var color:ColorArgb = new ColorArgb(red * 255, green * 255, blue * 255, alpha * 255);
            colors[colors.length] = color;
            times[times.length] = time;
        }
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        var keys:Array = new Array();
        var colors:Vector.<ColorArgb> = m_colors;
        var times:Vector.<Number> = m_times;
        for(var i:int = 0, l:int = times.length; i < l; ++i)
        {
            var key:Array = new Array();
            key[key.length] = Number(times[i].toFixed(3));
            key[key.length] = Number((colors[i].r / 255).toFixed(3));
            key[key.length] = Number((colors[i].g / 255).toFixed(3));
            key[key.length] = Number((colors[i].b / 255).toFixed(3));
            key[key.length] = Number((colors[i].a / 255).toFixed(3));
            keys[keys.length] = key;
        }
        theResultData["keys"] = keys;
        return theResultData;
    }


}
}
