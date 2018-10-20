/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/12/14.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
    import QFLib.Graphics.FX.utils.curve.Curve;
    import QFLib.Graphics.FX.utils.curve.KeyFrame;

    public class CCurveValue extends CParticleValue {
    private var m_theCurve:Curve = new Curve();
    public function CCurveValue(iTypeId:int, sTypeName:String) {
        super(iTypeId, sTypeName);
    }

    protected override function _calculateValue(life:Number = 0):Object
    {
        return m_theCurve.evaluate(life);
    }

    protected override function _loadFromJson(theData:Object):void
    {
        super._loadFromJson(theData);
        var keys:Array = theData["keys"];
        if(keys)
        {
            var theCurve:Curve = m_theCurve;
            for(var i:int = 0, l:int = keys.length; i < l; ++i)
            {
                theCurve.addKey(_readKeyframeFromJson(keys[i]));
            }
        }
    }

    protected override function _saveToJson(theResultData:Object):Object
    {
        theResultData = super._saveToJson(theResultData);
        var theCurve:Curve = m_theCurve;
        var count:int = theCurve.getKeyCount();
        if(count > 0)
        {
            var jsonKeys:Array = new Array();
            for(var i:int = 0; i < count; ++i)
            {
                jsonKeys[i] = _writeKeyframeToJson(theCurve.getKeyByIndex(i));
            }
            theResultData["keys"] = jsonKeys;
        }
        return theResultData;
    }

    private function _readKeyframeFromJson(theData:Object):KeyFrame
    {
        var theResultKeyFrame:KeyFrame = new KeyFrame();
        if(theData["inTangent"] == null)
        {
           theResultKeyFrame.inTangent = Number.POSITIVE_INFINITY;
        }
        else
        {
            theResultKeyFrame.inTangent = theData["inTangent"];
        }
        if(theData["outTangent"] == null)
        {
            theResultKeyFrame.outTangent = Number.POSITIVE_INFINITY;
        }
        else
        {
            theResultKeyFrame.outTangent = theData["outTangent"];
        }
        theResultKeyFrame.time = theData["time"];
        theResultKeyFrame.value = theData["value"];
        theResultKeyFrame.tangentMode = theData["tangentMode"];
        return theResultKeyFrame;
    }

    private function _writeKeyframeToJson(theKeyFrame:KeyFrame):Object
    {
        var theJsonData:Object = new Object();
        if(theKeyFrame.inTangent == Number.POSITIVE_INFINITY){
            theJsonData["inTangent"] = null;
        }
        else {
            theJsonData["inTangent"] = theKeyFrame.inTangent;
        }
        if(theKeyFrame.outTangent == Number.POSITIVE_INFINITY){
            theJsonData["outTangent"] = null;
        }
        else {
            theJsonData["outTangent"] = theKeyFrame.outTangent;
        }
        theJsonData["time"] = theKeyFrame.time;
        theJsonData["value"] = theKeyFrame.value;
        theJsonData["tangentMode"] = theKeyFrame.tangentMode;
        return theJsonData;
    }
}
}
