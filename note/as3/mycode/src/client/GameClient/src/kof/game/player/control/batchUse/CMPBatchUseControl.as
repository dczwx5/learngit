//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/7.
 * Time: 15:36
 */
package kof.game.player.control.batchUse {

import kof.game.common.view.event.CViewEvent;
import kof.game.player.CHeroNetHandler;
import kof.game.player.CPlayerHandler;
import kof.game.player.control.CPlayerControler;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.enum.EPlayerWndType;
import kof.game.player.view.equipmentTrain.CEquipmentTrainViewHandler;
import kof.game.player.view.event.EPlayerViewEventType;
import kof.game.player.view.player.CPlayerHeroView;
import kof.game.player.view.playerTrain.CPlayerHeroTrainViewHandler;

public class CMPBatchUseControl extends CPlayerControler {
    public function CMPBatchUseControl() {
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var uiEvent:String = e.subEvent;
        var value:Number=0;
        var heroID:int;
        switch (uiEvent) {
            case EPlayerViewEventType.EVENT_HERO_TRAIN_LEVELUP:
                heroID = e.data.id;
                var itemArr:Array = e.data.itemArr;
                _heroNetHandler.sendHeroLevelUp(heroID,itemArr);
                break;
            case EPlayerViewEventType.EVENT_BATCH_USE_OK:
//                var win1:CEquipmentTrainViewHandler = uiHandler.getWindow(EPlayerWndType.WND_EQUIP_TRAIN) as CEquipmentTrainViewHandler;
//                if(win1)
//                {
////                    win1.updateShow(e.data);
//                }
                break;
        }
    }
    [Inline]
    private function get _heroNetHandler() : CHeroNetHandler {
        return _system.getBean(CHeroNetHandler) as CHeroNetHandler;
    }
}
}
