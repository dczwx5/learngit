//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/13.
 */
package kof.game.common.view.component {

import QFLib.Foundation.CMap;

import com.greensock.TweenLite;

import flash.utils.getQualifiedClassName;

import kof.game.common.view.CViewBase;
import kof.game.common.view.component.handler.IUIEffectHandler;

public class CUICompoentBase implements IUICompeontBase {
    public function CUICompoentBase(view:CViewBase) {
        _view = view;
        _effectHandler = new CMap();
    }

    public virtual function dispose() : void {
        _compoentMap = null;
        clear();
    }

    public virtual function refresh() : void {

    }

    public virtual function clear() : void {
        clearEffectHandler();
    }
    public function set compoentMap(v:IUICompeontBase) : void {
        _compoentMap = v as CUICompoentMap;
    }

    public function addEffectHandler(handler:IUIEffectHandler) : void {
        var className:String = getQualifiedClassName(handler);
        _effectHandler.add(className, handler);
    }
    public function removeEffectHandler(handler:IUIEffectHandler) : void {
        var className:String = getQualifiedClassName(handler);
        _effectHandler.remove(className);
    }
    public function handleEffect() : void {
        this._effectHandler.loop(function (key:*, value:*) : void {
            (value as IUIEffectHandler).handler();
        });
    }
    public function clearEffectHandler() : void {
        if(_effectHandler) {
            this._effectHandler.loop(function (key:*, value:*) : void {
                (value as IUIEffectHandler).clear();
            });
        }
    }

    public function delayCall(call:Function, delay:Number, ...args) : void {
        var func:Function = function() : void {
            call.apply(null, args);
        };
        _view.DelayCall(delay, func);
    }

    // delay : > 0, willDelayCall
    public function tweenToX(obj:Object, duringTime:Number, toX:int, delay:Number = -1, completedCallback:Function = null, args:Array = null) : void {
        var func:Function = function () : void {
            TweenLite.to(obj, duringTime, {x:toX, onComplete:function () : void {
                if (completedCallback) {
                    completedCallback.apply(null, args);
                }
            }});
        };
        if (delay > 0) {
            delayCall(func, delay);
        } else {
            func();
        }
    }

    public function get viewBase() : CViewBase {
        return _view;
    }

    protected var _compoentMap:CUICompoentMap;
    protected var _effectHandler:CMap;
    private var _view:CViewBase;
}
}
