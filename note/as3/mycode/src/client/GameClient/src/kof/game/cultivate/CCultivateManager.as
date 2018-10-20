//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/11.
 */
package kof.game.cultivate {

import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.enum.ECultivateDataEventType;
import kof.framework.CAbstractHandler;
import QFLib.Interface.IUpdatable;
import kof.framework.IDatabase;
import kof.game.cultivate.event.CCultivateEvent;
import kof.message.ClimbTower.ClimbTowerChallengeResultResponse;
import kof.message.ClimbTower.ClimbTowerOpenBoxResponse;

public class CCultivateManager extends CAbstractHandler implements IUpdatable {
    public function CCultivateManager() {
        clear();
    }

    public function update( delta : Number ) : void {
    }

    public override function dispose():void {
        super.dispose();
        _system.unListenEvent(_onCultivateNetEvent);

        clear();
    }

    public function clear() : void {

    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
        _climpData = new CClimpData(system.stage.getSystem(IDatabase) as IDatabase);

        _system.listenEvent(_onCultivateNetEvent);

        return ret;
    }

    private function _onCultivateNetEvent(e:CCultivateEvent) : void {
        switch (e.type) {
            case CCultivateEvent.NET_EVENT_DATA :
                _climpData.initialCultivateData(e.data);
                _system.sendEvent(new CCultivateEvent(CCultivateEvent.DATA_EVENT, ECultivateDataEventType.DATA, _climpData));
                break;
            case CCultivateEvent.NET_EVENT_UPDATE_DATA :
                var lastBuffActived:Boolean = _climpData.cultivateData.otherData.currBuffEffect > 0;
                 _climpData.updateCultivateData(e.data);
                var curBuffActived:Boolean = _climpData.cultivateData.otherData.currBuffEffect > 0;
                if (lastBuffActived == 0 && curBuffActived > 0) {
                    // 激活了buff, 这个事件要先发。才能处理一些东西
                    _system.sendEvent(new CCultivateEvent(CCultivateEvent.DATA_EVENT, ECultivateDataEventType.BUFF_DATA_ACTIVED, _climpData));
                }
                _system.sendEvent(new CCultivateEvent(CCultivateEvent.DATA_EVENT, ECultivateDataEventType.DATA, _climpData));
                break;
            case CCultivateEvent.NET_EVENT_REWARD_BOX_DATA :
                _climpData.updateRewardBoxData(e.data as ClimbTowerOpenBoxResponse);
                _system.sendEvent(new CCultivateEvent(CCultivateEvent.DATA_EVENT, ECultivateDataEventType.DATA, _climpData));
                _system.sendEvent(new CCultivateEvent(CCultivateEvent.DATA_EVENT, ECultivateDataEventType.REWARD_BOX_DATA, (e.data as ClimbTowerOpenBoxResponse).index));
                break;
            case CCultivateEvent.NET_EVENT_RESET_DATA :
                _system.sendEvent(new CCultivateEvent(CCultivateEvent.DATA_EVENT, ECultivateDataEventType.RESET_DATA));
                break;
        }
    }

    [Inline]
    public function get climpData() : CClimpData {
        return _climpData;
    }
    [Inline]
    private function get _system() : CCultivateSystem {
        return system as CCultivateSystem;
    }
    private var _climpData:CClimpData;
}
}
