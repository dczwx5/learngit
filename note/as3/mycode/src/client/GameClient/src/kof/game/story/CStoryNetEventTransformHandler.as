//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story {

import kof.framework.CAbstractHandler;
import kof.game.story.data.CStoryData;
import kof.game.story.enum.EStoryDataEventType;
import kof.game.story.event.CStoryEvent;

// net 事件转换成其他事件
public class CStoryNetEventTransformHandler extends CAbstractHandler {
    public function CStoryNetEventTransformHandler() {
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

    private function _onNetEvent(e:CStoryEvent) : void {
        if (e.type == CStoryEvent.DATA_EVENT) {
            return ;
        }
        var dataObject:Object = e.data as Object;

        switch (e.type) {
            case CStoryEvent.NET_EVENT_DATA :
            case CStoryEvent.NET_EVENT_UPDATE_DATA :
                if (CStoryEvent.NET_EVENT_DATA == e.type) {
                    // 初始化数据
                    _data.initialData(dataObject);
                } else {
                    // 更新数据
                    _data.updateDataByData(dataObject);
                }
                _system.sendEvent(new CStoryEvent(CStoryEvent.DATA_EVENT, EStoryDataEventType.DATA, _data));
                break;
//            case CStoryEvent.NET_EVENT_SETTLEMENT_DATA :
//                _system.sendEvent(new CStoryEvent(CStoryEvent.DATA_EVENT, EStoryDataEventType.SETTLEMENT, _data));
//                break;
            case CStoryEvent.NET_EVENT_BUY_FIGHT_COUNT :
//                _data.updateMatchData(dataObject);
//                _system.sendEvent(new CStoryEvent(CStoryEvent.DATA_EVENT, EStoryDataEventType.MATCH_DATA, _data));
                break;
            case CStoryEvent.NET_EVENT_FIGHT :
//                _data.updateEnemySelectHero(dataObject);
//                _system.sendEvent(new CStoryEvent(CStoryEvent.DATA_EVENT, EStoryDataEventType.SELECT_HERO, _data));
                break;
        }

    }


    [Inline]
    private function get _system() : CStorySystem {
        return system as CStorySystem;
    }
    [Inline]
    private function get _data() : CStoryData {
        return _system.data;
    }
}
}
