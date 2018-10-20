//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/28.
 */
package kof.game.strengthen {

import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.strengthen.control.CStrengthenMainControler;
import kof.game.strengthen.data.CStrengthenData;
import kof.game.strengthen.enum.EStrengthenDataEventType;
import kof.game.strengthen.enum.EStrengthenWndType;
import kof.game.strengthen.event.CStrengthenEvent;
import kof.game.strengthen.view.CStrengthenView;

public class CStrengthenUIHandler extends CViewManagerHandler {

    public function CStrengthenUIHandler() {
    }

    public override function dispose() : void {
        super.dispose();
    }

    override public virtual function onEvtEnable() : void {
        super.onEvtEnable();
        var pPlayerSystem:CPlayerSystem;
        if (evtEnable) {
            _system.listenEvent(_onStrengthenEvent);
            pPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            if (pPlayerSystem) {
                pPlayerSystem.addEventListener(CPlayerEvent.PLAYER_TEAM, _onTeamEvent);
            }
        } else {
            _system.unListenEvent(_onStrengthenEvent);
            pPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            if (pPlayerSystem) {
                pPlayerSystem.removeEventListener(CPlayerEvent.PLAYER_TEAM, _onTeamEvent);
            }
        }
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.addViewClassHandler(EStrengthenWndType.WND_MAIN, CStrengthenView, CStrengthenMainControler);

        this.addBundleData(EStrengthenWndType.WND_MAIN, _system.SYSTEM_TAG);

        return ret;
    }

    // ================================== event ==================================
    private function _onStrengthenEvent(e:CStrengthenEvent) : void {
        if (CStrengthenEvent.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;
        switch (subEvent) {
            case EStrengthenDataEventType.DATA :
                win = getWindow(EStrengthenWndType.WND_MAIN);
                if (win && win.isShowState) {
                    win.invalidate();
                }

                break;
        }
    }
    private function _onTeamEvent(e:CPlayerEvent) : void {
        var win:CViewBase;
        win = getWindow(EStrengthenWndType.WND_MAIN);
        if (win && win.isShowState) {
            win.invalidate();
        }
    }

    public function showStrengthen() : void {
        show(EStrengthenWndType.WND_MAIN, null, null, [_data, _playerData]);
    }
    public function hideStrengthen() : void {
        this.hide(EStrengthenWndType.WND_MAIN);
    }
    // ================================== common data ==================================
    [Inline]
    private function get _system() : CStrengthenSystem {
        return system as CStrengthenSystem;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _data() : CStrengthenData {
        return _system.data;
    }
}
}
