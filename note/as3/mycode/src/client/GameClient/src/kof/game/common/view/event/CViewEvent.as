//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/30.
 */
package kof.game.common.view.event {

import flash.events.Event;

public class CViewEvent extends Event {
    public static const CREATE:String = "wndCreate";
    public static const LOAD_RESOURCE_FINISH:String = "wndLoadResourceFinish";
    public static const SHOW:String = "wndShow";
    public static const UPDATE_VIEW:String = "updateView";
    public static const FIRST_UPDATE_VIEW:String = "firstUpdateView";
    public static const HIDE:String = "wndHide";
    public static const DISPOSE:String = "wndDispose";
    public static const UNLOCK_RESOURCE_FINISH:String = "wndUnLockResourceFinish";
    public static const OK:String = "wndOK";
    public static const CANCEL:String = "wndCancel";

    // 是否启动uihandler的事件处理
    public static const EVENT_ENABLE:String = "eventEnable";

    // public static const TRY_TO_CLOSE:String = "tryToClose";


    public static const UI_EVENT:String = "uiEvent"; // 点击界面上某个按钮等, 具体哪个按钮由subEvent指定

    public function CViewEvent(type:String, subEvent:String = null, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        _data = data;
        _subEvent = subEvent;
    }

    public function get data() : Object {
        return _data;
    }
    public function get subEvent() : String {
        return _subEvent;
    }
    private var _data:Object;
    private var _subEvent:String;
}
}
