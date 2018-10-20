//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/11/22.
 * Time: 11:46
 */
package kof.game.player.control.playerTrain {

import kof.game.common.view.event.CViewEvent;
import kof.game.currency.tipview.CTipsViewHandler;
import kof.game.player.control.CPlayerControler;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.event.EPlayerViewEventType;

public class CPlayerHeroTrainControl extends CPlayerControler {
    public function CPlayerHeroTrainControl() {
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
            case EPlayerViewEventType.EVENT_HERO_TRAIN_LEVELUP:
                heroID = e.data.id;
                var itemArr:Array = e.data.itemArr;
                heroNetHandler.sendHeroLevelUp(heroID,itemArr);
                break;
            case EPlayerViewEventType.EVENT_HERO_TARIN_QUALITY:
                heroID = e.data as int;
                heroNetHandler.sendHeroQuality(heroID);
                break;
            case EPlayerViewEventType.EVENT_HERO_TRAIN_STAR:
                heroID = e.data as int;
                heroNetHandler.sendHeroStar(heroID);
                break;
            case EPlayerViewEventType.EVENT_HERO_TRAIN_SHOWTIP:
                var str:String = e.data as String;
                uiSystem.getBean(CTipsViewHandler).show(0,str);
                break;
            case EPlayerViewEventType.EVENT_LIST_SELECT_HERO:
                heroID = (e.data as CPlayerHeroData).prototypeID;
                uiHandler.refreshPlayerMainView(EPlayerWndTabType.STACK_ID_HERO_WND_TRAIN);
                break;
            case EPlayerViewEventType.EVENT_BATCH_USE_ITEM:
                uiHandler.showMPBatchUse(e.data);
                break;
        }
    }
}
}
