//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/12/13.
 */
package kof.game.common.system {

import QFLib.Foundation.CMap;

import kof.framework.CAbstractHandler;

public class CSystemListenerHandler extends CAbstractHandler {

    public function CSystemListenerHandler() {
        // 不放onSetup初始化, 不然registerEventType要在setStarted函数中处理
        _funcList = new CMap();
        _eventTypeList = new Vector.<String>();
    }

    public override function dispose() : void {
        super.dispose();

        if (_funcList) {
            _funcList.loop(function (key:Function, value:Function) : void {
                unListenEvent(value);
            });
            _funcList = null;
        }


        _eventTypeList = null;
    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();

        return ret;
    }

    public function listenEvent(func:Function) : void {
        if (null == func) return ;
        unListenEvent(func);

        _funcList.add(func, func);

        for each (var eventType:String in _eventTypeList) {
            system.addEventListener(eventType, func);
        }
    }

    public function unListenEvent(func:Function) : void {
        if (null == func) return ;

        if (_funcList) {
            _funcList.remove(func);
        }

        for each (var eventType:String in _eventTypeList) {
            system.removeEventListener(eventType, func);
        }
    }

    public function registerEventType(eventType:String) : void {
        _eventTypeList.push(eventType);
    }

    private var _funcList:CMap;
    private var _eventTypeList:Vector.<String>;
}
}
