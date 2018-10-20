//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/17.
 */
package kof.game.story.control {

import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.currency.enum.ECurrencyType;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.story.data.CStoryGateData;
import kof.game.story.enum.EStoryViewEventType;

public class CStoryAskBuyCountControler extends CStoryControler {
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
        var win:CViewBase;
        switch (subType) {
            case EStoryViewEventType.ASK_BUY_COUNT_CLICK_BUY :
                var gateData:CStoryGateData = e.data as CStoryGateData;
                var consume:int = storyData.getBuyCountConsume(gateData.resetNum);
                var pReciprocalSystem:CReciprocalSystem = (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
                if (false == pReciprocalSystem.isEnoughToPay(consume)) {
                    pReciprocalSystem.showCanNotBuyTips();
                    return ;
                }

                if(storyData.CURRENCY_TYPE == ECurrencyType.BIND_DIAMOND) {
                    pReciprocalSystem.showCostBdDiamondMsgBox( consume, function () : void {
                        netHandler.sendBuyFightCount( gateData.heroID, gateData.gateIndex );
                    } );
                } else {
                    netHandler.sendBuyFightCount( gateData.heroID, gateData.gateIndex );
                }

                _wnd.close();
                break;
        }
    }

    private function _onHide(e:CViewEvent) : void {

    }
}
}
