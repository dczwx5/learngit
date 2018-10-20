//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title {

import kof.framework.CAbstractHandler;
import kof.game.title.data.CTitleData;
import kof.game.title.enum.ETitleDataEventType;
import kof.game.title.event.CTitleEvent;

// net 事件转换成其他事件
public class CTitleNetEventTransformHandler extends CAbstractHandler {
    public function CTitleNetEventTransformHandler() {
    }

    public override function dispose():void {
        super.dispose();
        _system.unListenEvent(_onNetEvent);
    }


    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();

        _system.listenEvent(_onNetEvent);
        return ret;
    }

    private function _onNetEvent(e:CTitleEvent) : void {
        if (e.type == CTitleEvent.DATA_EVENT) {
            return ;
        }
        var dataObject:Object = e.data as Object;

        switch (e.type) {
            case CTitleEvent.NET_EVENT_DATA :
                // 初始化数据
                var isSelf:Boolean = dataObject["isSelf"];
                if (isSelf) {
                    _data.initialData(dataObject);
                    _system.sendEvent(new CTitleEvent(CTitleEvent.DATA_EVENT, ETitleDataEventType.DATA, _data));
                } else {
                    var friendTitleData:CTitleData = CTitleManager.initialTitleDataByConfig(system);
                    friendTitleData.initialData(dataObject);
                    _system.sendEvent(new CTitleEvent(CTitleEvent.FRIEND_DATA_EVENT, null, friendTitleData));
                }

                break;
            case CTitleEvent.NET_EVENT_UPDATE_DATA :
                // 更新数据
                _data.updateItemData(dataObject);
                _system.sendEvent(new CTitleEvent(CTitleEvent.DATA_EVENT, ETitleDataEventType.DATA, _data));
                break;

            case CTitleEvent.NET_EVENT_WEAR :
                _data.updateByWear(dataObject);
                _system.sendEvent(new CTitleEvent(CTitleEvent.DATA_EVENT, ETitleDataEventType.DATA, _data));
                break;
        }

    }


    [Inline]
    private function get _system() : CTitleSystem {
        return system as CTitleSystem;
    }
    [Inline]
    private function get _data() : CTitleData {
        return _system.data;
    }
}
}
