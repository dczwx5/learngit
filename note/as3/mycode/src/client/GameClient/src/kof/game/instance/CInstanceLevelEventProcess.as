//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/29.
 */
package kof.game.instance {

import flash.utils.setTimeout;

import kof.framework.CAbstractHandler;
import kof.game.dataLog.CDataLog;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelSystem;
import kof.game.level.event.CLevelEvent;
import kof.message.Level.StartLevelReadyGOResponse;

// 处理level 事件
public class CInstanceLevelEventProcess extends CAbstractHandler {
    public function CInstanceLevelEventProcess() {
    }

    public function listenEvent():void {
        _levelSystem.listenEvent(_onLevelEvent);
    }

    public function unListenEvent():void {
        _levelSystem.unListenEvent(_onLevelEvent);
    }

    private function _onLevelEvent(event:CLevelEvent):void {
        var e:CLevelEvent = event as CLevelEvent;

        if (e.type == CLevelEvent.ENTER) {
            _system.setAiEnable(false);
            _system.setPlayEnable(_system.isMainCity);
            _system.uiHandler.hideResultPvpWinView();
        } else if (e.type == CLevelEvent.ENTERED) {
            CDataLog.logMainCityLoadingEnd(_system, _system.instanceData, _system.instanceContent);
            _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.LEVEL_ENTERED, null, null));
        } else if (e.type == CLevelEvent.SCENARIO_START) {
            _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.SCENARIO_START, null, null));
        } else if (e.type == CLevelEvent.SCENARIO_END) {
            _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.SCENARIO_END, null, null));
            var returnLevel:Boolean = true;
            if (e.data && e.data.hasOwnProperty("returnLevel")) {
                returnLevel = e.data["returnLevel"];
            }
            if (returnLevel == false) {
                if (false == _system.isMainCity) { // 副本的剧情回到主城才播
                    // create mask
                    // 剧情结束不回关卡, 等待副本结束
                    _system.uiHandler.uiCanvas.showHoldingMaskView();
                    _system.setPlayEnable(false); // 黑幕过程中, 停止玩家操作
                }
            }
        } else if (e.type == CLevelEvent.READY_GO) {
            var response:StartLevelReadyGOResponse = e.data as StartLevelReadyGOResponse;
            if(false == EInstanceType.isClassicalMode(_system.instanceType) ) {
                if (_system.instanceManager.isFirstLevel && response.readyGO > 0) {
                    setTimeout( _system.uiHandler.showReadyGoView, 1000 );
                }
            } else {
                _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.LEVEL_PROCESS_READY_GO_BY_OTHER, response))
            }

        } else if (e.type == CLevelEvent.PLAYER_READY) {
            _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.LEVEL_PLAYER_READY, null));
        } else if (e.type == CLevelEvent.ROLE_DIE) {
            //
            _onCharacterDie(e);
            _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.CHARACTOR_DIE, e.data, null));
        } else if (e.type == CLevelEvent.EACHGAME_END) {
            _system.uiHandler.showResultPvpWinView(e.data);
        } else if (e.type == CLevelEvent.WINACTOR_END) {
            _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.WINACTOR_END, e.data, null));
        }  else if (e.type == CLevelEvent.WINACTOR_START) {
            _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.WINACTOR_STRAT, e.data, null));
        } else if (CLevelEvent.EXIT == e.type) {
            _system.dispatchEvent(new CInstanceEvent(CInstanceEvent.LEVEL_EXIT, null));
        }
    }

    private function _onCharacterDie(event:CLevelEvent):void {
        // var pCharacter : CGameObject = event.data as CGameObject;

    }

    // =============================get/set===============================
    private function get _system():CInstanceSystem {
        return system as CInstanceSystem;
    }

    private function get _levelSystem():CLevelSystem {
        return system.stage.getSystem(CLevelSystem) as CLevelSystem;
    }

}
}
