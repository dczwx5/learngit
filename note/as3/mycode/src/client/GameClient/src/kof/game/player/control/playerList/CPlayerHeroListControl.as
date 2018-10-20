//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/27.
 */
package kof.game.player.control.playerList {

import kof.game.player.enum.EPlayerWndTabType;

import QFLib.Utils.ArrayUtil;
import kof.game.player.control.CPlayerControler;
import kof.game.common.view.event.CViewEvent;
import kof.game.player.view.event.EPlayerViewEventType;

public class CPlayerHeroListControl extends CPlayerControler {
    public function CPlayerHeroListControl() {
        super();
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    private function _onUIEvent(e:CViewEvent) : void {
        var uiEvent:String = e.subEvent;
        var heroID:int;
        switch (uiEvent) {
            case EPlayerViewEventType.EVENT_HERO_ICON_CLICK:
                heroID = e.data as int;
                var heroDatas:Array = playerData.heroList.list;
                var v1Index:int = ArrayUtil.findItemByProp(heroDatas, "prototypeID", heroID);
                if (-1 != v1Index) {
                    uiHandler.heroMainChangeTab(EPlayerWndTabType.STACK_ID_HERO_WND_DETAIL, heroID);
                }
                break;
            case EPlayerViewEventType.EVENT_HERO_HIRE_CLICK:
                heroID = e.data as int;
                heroNetHandler.sendHireHero(heroID);
                break;
            case EPlayerViewEventType.EVENT_HERO_HIRE_CLICK:
                    // 寻路
                break;
        }
    }

}
}
