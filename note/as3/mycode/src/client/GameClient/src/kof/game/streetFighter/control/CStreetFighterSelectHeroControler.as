//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/25.
 */
package kof.game.streetFighter.control {

import kof.game.common.CLang;
import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.streetFighter.enum.EStreetFighterViewEventType;

public class CStreetFighterSelectHeroControler extends CStreetFighterControler {
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        var embattleSystem:CEmbattleSystem;
//        var pSystemBundleCtx : ISystemBundleContext;
//        var pSystemBundle : ISystemBundle;
        var heroID:int;
        switch (subType) {
            case EStreetFighterViewEventType.SELECT_HERO_CLICK_OK :
                if (streetFighterData.isAllSelectHeroOpened) {
                    heroID = e.data as int;
                    if (heroID > 0) {
                        netHandler.sendSelectHeroRequest(heroID);
                    }
                } else {
                    uiCanvas.showMsgAlert(CLang.Get("street_wait_enemy_open_select_hero_view"));
                }
                break;
            case EStreetFighterViewEventType.SELECT_HERO_READY :
                netHandler.sendSelectHeroReady();
                break;
            case EStreetFighterViewEventType.SELECT_HERO :
                heroID = e.data as int;
                netHandler.sendSelectHeroSync(heroID);
                break;

        }
    }

    private function _onHide(e:CViewEvent) : void {

    }

}
}
