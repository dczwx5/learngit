//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/12/15.
 */


package kof.util
{
import com.greensock.TweenLite;
import com.greensock.TweenMax;

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Dictionary;

import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
import QFLib.Graphics.RenderCore.starling.events.Event;

/**
 * greensock tween 工具
 * @author Jave.Lin
 * @date 2013-10-28
 **/
public class TweenUtil
{
    /*
     var vars:Object={
     yoyo:true,
     repeat:-1,
     glowFilter:{color:0xFFFF00, alpha:0.6, blurX:20, blurY:20, quality:3}
     };
     */
    private static var loopGrowDic:Dictionary = new Dictionary(true);

    public static function startLoopGrow(dis:flash.display.DisplayObject,duration:Number,vars:Object,loopTimes:int = 1,onCom:Function = null):void
    {
        if (!dis) return;
        if(loopGrowDic[dis] != null){
            var tl:TweenLite = loopGrowDic[dis];
            tl.kill();
        }

        dis.filters = null;
        loopGrowDic[dis] = tween(dis, duration, vars);
    }

    public static function stopLoopGrow(dis:flash.display.DisplayObject, complete:Boolean=false):void
    {
        if (!dis) return;
        if(loopGrowDic[dis] != null){
            var tl:TweenLite = loopGrowDic[dis];
            tl.kill();
            loopGrowDic[dis] = null;
            delete loopGrowDic[dis];
        }

        dis.filters = null;
    }

    public static function startLoopBrightness(dsp:flash.display.DisplayObject, duration:Number = .5, brightness:Number = 2.5, loopTimes:int = 1, onCom:Function = null, delay:Number = NaN, oneLoopRepeat:int = 1):void
    {
        if (!dsp) return;
        kill(dsp);
        dsp.filters = null;

        var count:int = 0;
        var vars:Object =
        {
            yoyo:true,
            repeat:oneLoopRepeat,
            colorMatrixFilter:{brightness:brightness},
            onComplete:function():void{
                count += 1;
                if(count >= loopTimes){
                    dsp.filters = null;
                    if(onCom != null) onCom();
                }
            }
        };
        if (!isNaN(delay))
        {
            vars["delay"] = delay;
        }

        tween(dsp, duration, vars);
    }

    public static function stopLoopBrightness(dsp:flash.display.DisplayObject):void
    {
        if (!dsp) return;
        tween(dsp, 0, {removeTint:true});
        kill(dsp, false);
        dsp.filters = null;
    }

    public static function kill(obj:Object, complete:Boolean = false, vars:Object = null):void
    {
        TweenMax.killTweensOf(obj, complete, vars);
    }

    public static function isTweening(obj:Object):Boolean
    {
        return TweenMax.isTweening(obj);
    }

    public static function killAll(arr:Array, complete:Boolean = false):void
    {
        for each (var obj:Object in arr) {
            kill(obj, complete);
        }
    }

    public static function tweenArr(arr:Array, duration, vars:Object, stagger:Number = 0, autoKill:Boolean = true, onCom:Function = null, onComArgs:Array = null):Array
    {
        var tweenArr:Array = TweenMax.allTo(arr, duration, vars, stagger, function():void{
            if (autoKill) {
                for each (var t:TweenLite in tweenArr) {
                    if (t) {
                        t.kill();
                    }
                }
            }
            if (onCom != null) {
                onCom.apply(null, onComArgs);
            }
        });
        return tweenArr;
    }

    /** 执行完Tween动画后，autoKill决定会否自动释放掉TweenLite */
    public static function tween(obj:Object, duration:Number, vars:Object, autoKill:Boolean = true):TweenLite
    {
        if (!obj) return null;

        var t:TweenLite;

        if (duration <= 0)
        {
            t = TweenMax.to(obj, 0, vars);
            if (t)
            {
                t.kill();
            }
            return t;
        }

        if (autoKill)
        {
            if (vars.onComplete != onAutoKill)
            {
                vars.onCompleteParams = [t, vars.onComplete, vars.onCompleteParams];
                vars.onComplete = onAutoKill;
            }
        }

        t = TweenMax.to(obj, duration, vars);

        if (autoKill)
        {
            vars.onCompleteParams[0] = t;
        }
        return t;
    }

    public static function from(obj:Object, duration:Number, vars:Object, autoKill:Boolean = true):TweenLite
    {
        if (!obj) return null;

        var t:TweenLite;

        if (duration <= 0)
        {
            t = TweenMax.to(obj, 0, vars);
            if (t)
            {
                t.kill();
            }
            return t;
        }

        if (autoKill)
        {
            if (vars.onComplete != onAutoKill)
            {
                vars.onCompleteParams = [t, vars.onComplete, vars.onCompleteParams];
                vars.onComplete = onAutoKill;
            }
        }

        t = TweenMax.from(obj, duration, vars);

        if (autoKill)
        {
            vars.onCompleteParams[0] = t;
        }
        return t;
    }

    private static function onAutoKill(t:TweenLite, onComplete:Function, onCompleteArgs):void
    {
        if (onComplete != null)
        {
            onComplete.apply(null, onCompleteArgs);
        }
        t.kill();
    }

    public static function isLoopGrowDsp( dsp:flash.display.DisplayObject , isFlash:Boolean  , color:uint = 0xFF0000 ):void
    {
        if(isFlash) {
            var vars:Object={
                yoyo:true,
                repeat:-1,
                glowFilter:{color:color, alpha:1, blurX:15, blurY:15, quality:3 , strength:2.1}
            };
            TweenUtil.startLoopGrow(dsp,0.7,vars);
        } else {
            TweenUtil.stopLoopGrow(dsp, true);
        }
    }

    private static var twinkleDic:Dictionary = new Dictionary(true);
    /**
     * 闪烁
     **/
    public static function twinkle(dsp:*, duration:Number = 1, count:int = 10, onRemoveAutoStopAndResetAlpha:Boolean = true, ignoreNotInStage:Boolean = true, onComplete:Function = null):void{
        if (duration == 0 || count == 0 || (ignoreNotInStage && !dsp.stage))
        {
            if (onComplete != null)
            {
                onComplete.apply();
            }
            return;
        }
        else{
            if (onRemoveAutoStopAndResetAlpha)
            {
                onRemoveHandler(dsp, function():void
                {
                    if(twinkleDic[dsp]){
                        (twinkleDic[dsp] as TweenMax).kill();
                        twinkleDic[dsp] = null;
                        delete twinkleDic[dsp];
                    }
                    dsp.alpha = 1;
                });
            }

            if(twinkleDic[dsp]){
                (twinkleDic[dsp] as TweenMax).kill();
            }
            dsp.alpha = 1;
            twinkleDic[dsp] = TweenMax.from(dsp, duration / count, {alpha:0, yoyo:true, repeat:count, onComplete:function (onCom:Function):void{
                twinkleDic[dsp] = null;
                delete twinkleDic[dsp];
                dsp.alpha = 1;
                if (onCom != null)
                {
                    onCom.apply();
                }
            }, onCompleteParams:[onComplete]});
        }
    }

    public static function cancelTwinkle(dsp:*):void{
        if(dsp && twinkleDic[dsp]){
            (twinkleDic[dsp] as TweenMax).kill();
            twinkleDic[dsp] = null;
            delete twinkleDic[dsp];
            dsp.alpha = 1;
        }
    }

    private static function onRemoveHandler(dsp:*, onComplete:Function = null):void
    {
        if(dsp is QFLib.Graphics.RenderCore.starling.display.DisplayObject)
        {
            function onRemove(e:QFLib.Graphics.RenderCore.starling.events.Event):void
            {
                dsp.removeEventListener(QFLib.Graphics.RenderCore.starling.events.Event.REMOVED_FROM_STAGE, onRemove);

                if (onComplete != null)
                {
                    onComplete.apply();
                }
            }
            dsp.addEventListener(QFLib.Graphics.RenderCore.starling.events.Event.REMOVED_FROM_STAGE, onRemove);
        }
        else if(dsp is flash.display.DisplayObject)
        {
            function onFlashRemove(e:flash.events.Event):void
            {
                dsp.removeEventListener(flash.events.Event.REMOVED_FROM_STAGE, onFlashRemove);

                if (onComplete != null)
                {
                    onComplete.apply();
                }
            }
            dsp.addEventListener(flash.events.Event.REMOVED_FROM_STAGE, onFlashRemove);
        }
    }

    /**
     * 闪烁效果
     * @param target
     * @param duration
     * @param color
     * @param repeat
     * @param onComplete
     * @param params
     * @return
     *
     * @author sprite
     */
    public static function lighting( target:flash.display.DisplayObject, duration:Number=0.4, repeat:int = 1,
                                     delay:Number = 0, onComplete:Function=null, params:Array=null, color:uint=0xFFCC00):TweenMax
    {
        if (TweenMax.isTweening(target)){
            return (null);
        };
        var vars:Object = {};
        vars["colorMatrixFilter"] = {
            colorize:color,
            amount:1,
            contrast:1,
            saturation:1,
            brightness:3,
            hue:0
        };

        vars["yoyo"] = true;
        vars["repeat"] = repeat;
        vars["delay"] = delay;
        vars["onComplete"] = onComplete;
        vars["onCompleteParams"] = params;
        return (TweenMax.to(target, duration, vars));
    }
}
}