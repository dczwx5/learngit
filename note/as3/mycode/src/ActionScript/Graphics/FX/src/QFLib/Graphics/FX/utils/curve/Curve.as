/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/29.
 */
package QFLib.Graphics.FX.utils.curve {
public class Curve {
    private var m_keys:Vector.<KeyFrame> = new <KeyFrame>[];
    public function Curve() {
    }

    public function dispose():void
    {
        if(m_keys != null)m_keys.length = 0;
        m_keys = null;
    }

    public final function addKey(key:KeyFrame):void
    {
        var keys:Vector.<KeyFrame> = m_keys;
        for(var i:int = 0, l:int = keys.length; i < l; ++i)
        {
            if(keys[i].time > key.time){
                keys.splice(i, 0, key);
                break ;
            }
        }
        if(i == l)
        {
            keys[i] = key;
        }
    }

    public final function getKeyCount():int { return m_keys.length; }
    public final function getKeyByIndex(index:int):KeyFrame {
        if(index >= 0 && index < m_keys.length){
            return m_keys[index];
        }
        return null;
    }

    public final function evaluate(time:Number):Number {
        var keys:Vector.<KeyFrame> = m_keys;
        for(var i:int=0,len:int=keys.length;i<len;++i) {
            var current:KeyFrame = keys[i];
            if (current.time == time) return current.value;

            if (current.time > time) {
                if (i < 1) return current.value;
                var prev:KeyFrame = keys[i - 1];
                var isLinear:Boolean = false;
                var isStepped:Boolean = false;
                if (prev.outTangent == Number.POSITIVE_INFINITY || current.inTangent == Number.POSITIVE_INFINITY) {
                    isStepped = true;
                }
                else {
                    var isBroken_prev:Boolean = _getKeyIsBroken(prev);
                    var isBroken_next:Boolean = _getKeyIsBroken(current);
                    if (isBroken_prev && isBroken_next) {
                        var mode_pre:int = _getKeyTangentMode(prev, true);
                        var mode_next:int = _getKeyTangentMode(current, false);
                        if (mode_pre == TangentMode.LINEAR && mode_next == TangentMode.LINEAR) {
                            isLinear = true;
                        }
                        else if (mode_pre == TangentMode.STEPPED || mode_next == TangentMode.STEPPED) {
                            isStepped = true;
                        }
                    }
                }

                var interval:Number;
                var t:Number;
                if(isLinear)
                {
                    interval = current.time - prev.time;
                    t = (time - prev.time) / interval;
                    return prev.value * ( 1 - t ) + current.value * t;
                }
                else if(isStepped)
                {
                      return prev.value;
                }
                else {
                    interval = current.time - prev.time;
                    t = (time - prev.time) / interval;
                    var t2:Number = t * t;
                    var t3:Number = t2 * t;
                    var h00:Number = 2 * t3 - 3 * t2 + 1;
                    var h10:Number = t3 - 2 * t2 + t;
                    var h01:Number = -2 * t3 + 3 * t2;
                    var h11:Number = t3 - t2;
                    var value:Number = h00 * prev.value + h10 * interval * prev.outTangent + h01 * current.value + h11 * interval * current.inTangent;

                    return value;
                }
            }
        }

        //if suitable slot not found
        return keys[keys.length-1].value;
    }

    [Inline]
    private final function _getKeyTangentMode(key:KeyFrame, isRight:Boolean):int
    {
        var move:Number = 0;
        var mask:Number = 3;
        if(isRight) {
            move = 3;
        }
        else {
            move = 1;
        }
        return key.tangentMode >> move & mask;
    }

    [Inline]
    private final function _getKeyIsBroken(key:KeyFrame):Boolean
    {
        return Boolean(key.tangentMode & 1);
    }
}
}
