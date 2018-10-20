//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame.control {

import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameDataEventType;
import kof.game.peakGame.enum.EPeakGameRankType;
import kof.game.peakGame.enum.EPeakGameViewEventType;
import kof.game.peakGame.enum.EPeakGameWndType;
import kof.game.peakGame.event.CPeakGameEvent;
import kof.game.player.data.CPlayerData;

public class CPeakGameRankControl extends CPeakGameControler {
    public function CPeakGameRankControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        switch (subType) {
            case EPeakGameViewEventType.FIRST_OPEN_GLORY_ALL :
                if (peakGameData.isFirstOpenGloryHallFlag == false) {
                    peakGameData.isFirstOpenGloryHallFlag = true;
                    netHandler.sendFirstOpenGloryHallRequest(system.playType, true);
                }
                break;
            case EPeakGameViewEventType.RANK_CHANGE_TAB :
                var tab:int = e.data as int;
                if (tab == 0) {
                    if (peakGameData.rankDataOne.needSync) {
                        peakGameData.rankDataOne.sync();
                        netHandler.sendGetRank(EPeakGameRankType.TYPE_SELF_SERVER, system.playType);
                    } else {
                        _wnd.invalidate();
                    }

                } else if (tab == 1){
                    if (peakGameData.rankDataMulti.needSync) {
                        peakGameData.rankDataMulti.sync();
                        netHandler.sendGetRank(EPeakGameRankType.TYPE_MULTI_SERVER, system.playType);
                    } else {
                        _wnd.invalidate();
                    }
                } else {
                    showHonourView();
                }
                break;
        }
    }

    public function showHonourView() : void {
        var isHonourDataRequested:Boolean = peakGameData.gloryData.isServerData; // todo 还能优化。这种处理。如果有更新。需要刷新页面
        if (isHonourDataRequested) {
            _wnd.invalidate();
        } else {
            var func:Function  = function (e:CPeakGameEvent) : void {
                if (e.type == CPeakGameEvent.DATA_EVENT && e.subEvent == EPeakGameDataEventType.HONOUR) {
                    _wnd.invalidate();
                    system.unListenEvent(func);
                }
            };
            // 没有初始化过数据, 请求数据回来之后, 才弹出界面
            system.listenEvent(func);
            system.netHandler.sendGetGloryHall(system.playType);
        }
    }

}
}
