//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1 {

import kof.framework.CAbstractHandler;
import QFLib.Interface.IUpdatable;
import kof.framework.IDatabase;
import kof.game.common.status.CGameStatus;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.enum.EPeak1v1DataEventType;
import kof.game.peak1v1.event.CPeak1v1Event;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;


public class CPeak1v1Manager extends CAbstractHandler implements IUpdatable {
    public function CPeak1v1Manager() {
        clear();
    }

    public function update( delta : Number ) : void {
    }

    public override function dispose():void {
        super.dispose();
        _system.unListenEvent(_onPeak1v1NetEvent);

        clear();
    }

    public function clear() : void {

    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
        var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var pPlayerData:CPlayerData = playerSystem.playerData;
        _data = new CPeak1v1Data(system.stage.getSystem(IDatabase) as IDatabase);
        _data._playerUID = pPlayerData.ID;

        _system.listenEvent(_onPeak1v1NetEvent);

        return ret;
    }

    private function _onPeak1v1NetEvent(e:CPeak1v1Event) : void {
        if (e.type == CPeak1v1Event.DATA_EVENT) {
            return ;
        }
        var netData:Object = e.data as Object;

        switch (e.type) {
            case CPeak1v1Event.NET_EVENT_DATA :
            case CPeak1v1Event.NET_EVENT_UPDATE_DATA :
                var lastStartTime:Number = data.startTime;
                var lastRegisterState:int = data.regState;
                if (CPeak1v1Event.NET_EVENT_DATA == e.type) {
                    data.initialData(netData);
                } else {
                    data.updateDataByData(netData);
                }
                var newRegisterState:int = data.regState;
                if (newRegisterState != lastRegisterState) {
                    _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.REGISTER_DATA, newRegisterState > 0));
                }
                if (data.startTime - lastStartTime > 10) {
                    _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.START_TIME_CHANGE_DATA, data));
                }
                _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.DATA, data));

                break;
            case CPeak1v1Event.NET_ENEMY_PROGRESS_DATA :
                data.updateEnemyProgressData(netData);
                _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.ENEMY_PROGRESS_DATA, data));

                break;
            case CPeak1v1Event.NET_RESULT_DATA :
                data.updateResultData(netData);
                _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.RESULT_DATA, data));

                break;

            case CPeak1v1Event.NET_REPORT_DATA :
                data.updateReportData(netData);
                _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.REPORT_DATA, data));

                break;
            case CPeak1v1Event.NET_RANKING_DATA :
                data.updateRankingData(netData);
                _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.RANKING_DATA, data));

                break;
            case CPeak1v1Event.NET_DOWN_SINGLE_DATA :
                _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.DOWN_SINGLE_DATA, data));
                break;
            case CPeak1v1Event.NET_MATCH_DATA :
                data.reportData.resetSync();
                data.updateMatchData(netData);
                _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.DATA_EVENT, EPeak1v1DataEventType.MATCH_DATA, data));
                break;
        }

    }

    [Inline]
    public function get data() : CPeak1v1Data {
        return _data;
    }
    [Inline]
    private function get _system() : CPeak1v1System {
        return system as CPeak1v1System;
    }
    private var _data:CPeak1v1Data;
}
}
