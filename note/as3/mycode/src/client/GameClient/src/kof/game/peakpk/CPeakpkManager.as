//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/11/27.
 */
package kof.game.peakpk {

import kof.framework.CAbstractHandler;
import QFLib.Interface.IUpdatable;
import kof.framework.IDatabase;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.peakpk.enum.EPeakpkDataEventType;
import kof.game.peakpk.event.CPeakpkEvent;


public class CPeakpkManager extends CAbstractHandler implements IUpdatable {
    public function CPeakpkManager() {
        clear();
    }

    public function update( delta : Number ) : void {
    }

    public override function dispose():void {
        super.dispose();
        _system.unListenEvent(_onPeakpkNetEvent);

        clear();
    }

    public function clear() : void {

    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
         _data = new CPeakpkData(system.stage.getSystem(IDatabase) as IDatabase);

        _system.listenEvent(_onPeakpkNetEvent);

        return ret;
    }

    private function _onPeakpkNetEvent(e:CPeakpkEvent) : void {
        if (e.type == CPeakpkEvent.DATA_EVENT) {
            return ;
        }
        var netData:Object = e.data as Object;

        switch (e.type) {
            case CPeakpkEvent.NET_EVENT_DATA :
            case CPeakpkEvent.NET_EVENT_UPDATE_DATA :
                if (CPeakpkEvent.NET_EVENT_DATA == e.type) {
                    data.initialData(netData);
                } else {
                    data.updateDataByData(netData);
                }
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.DATA, data));

                break;
            case CPeakpkEvent.NET_PK_SUCCESS_DATA_1P :
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.PK_SUCCESS_DATA_P1, data));
                break;
            case CPeakpkEvent.NET_PK_FAIL_DATA_1P :
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.PK_FAIL_DATA_P1, data));
                break;

            case CPeakpkEvent.NET_RECEIVE_CONFIRM_DATA_P1 :
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.PK_CONFIRM_DATA_P1, data));
                break;
            case CPeakpkEvent.NET_RECEIVE_REFUSE_DATA_P1 :
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.PK_REFUSE_DATA_P1, data));
                break;
            case CPeakpkEvent.NET_RECEIVE_INVITE_DATA_2P :
                data.updateInviterData( e.data as Object);
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.PK_RECEIVE_INVITE_DATA_P2, data));
                break;
            case CPeakpkEvent.NET_RECEIVE_INVITE_CANCEL_DATA_P2 :
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.PK_RECEIVE_INVITE_CANCEL_DATA_P2, data));
                break;
            case CPeakpkEvent.NET_MATCH_DATA :
                data.updateMatchData(e.data as Object);
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.PK_MATCH_DATA, data));
                break;
            case CPeakpkEvent.NET_LOADING_DATA :
                var loadingData:int = e.data as int;
                data.updateLoadingData({enemyProgress:loadingData});
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.DATA_EVENT, EPeakpkDataEventType.PK_LOADING_DATA, data));
                break;
        }

    }

    [Inline]
    public function get data() : CPeakpkData {
        return _data;
    }
    [Inline]
    private function get _system() : CPeakpkSystem {
        return system as CPeakpkSystem;
    }
    private var _data:CPeakpkData;
}
}
