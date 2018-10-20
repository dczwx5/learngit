//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.control {

import kof.game.KOFSysTags;
import kof.game.bag.data.CBagData;
import kof.game.common.CLang;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.event.CInstanceEvent;
import kof.game.player.data.CPlayerHeroData;
import kof.game.story.data.CStoryGateData;
import kof.game.story.enum.EStoryViewEventType;
import kof.game.story.view.main.CStoryView;

public class CStoryMainControler extends CStoryControler {
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
     }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var win:CViewBase;
        var dataObject:Array;
        var gateData:CStoryGateData;
        var heroData:CPlayerHeroData;
        var leftCount:int;
        switch (subType) {
            case EStoryViewEventType.MAIN_ADD_FIGHT_COUNT_CLICK :
                dataObject = e.data as Array;
                gateData = dataObject[0] as CStoryGateData;
                heroData = dataObject[1] as CPlayerHeroData;
                leftCount = gateData.leftCount;
                leftCount = Math.max(leftCount, 0);
                if (leftCount > 0) {
                    uiCanvas.showMsgAlert(CLang.Get("instance_need_not_buy_elite_count"));
                } else {
                    if (gateData.resetNum >= storyData.BUY_FIGHT_COUNT_DAILY) {
                        uiCanvas.showMsgAlert(CLang.Get("story_buy_count_limit"));
                    } else {
                        uiHandler.showAskBuyCount(gateData);
                    }
                }

                break;
            case EStoryViewEventType.MAIN_FIGHT_CLICK :
                dataObject = e.data as Array;
                gateData = dataObject[0] as CStoryGateData;
                heroData = dataObject[1] as CPlayerHeroData;
                var preGateData:CStoryGateData = dataObject[2] as CStoryGateData;
                    // 检查次数
                leftCount = gateData.leftCount;
                leftCount = Math.max(leftCount, 0);
                if (leftCount <= 0) {
                    uiCanvas.showMsgAlert(CLang.Get("story_no_fight_count"));
                } else {
                    // 检查门票
                    var fightConsume:int = storyData.getFightGateConsume(heroData.qualityBase, gateData.gateIndex);
                    var currencyCount:int = 0;
                    var itemData:CBagData = getItem(storyData.ITEM_ID);
                    if (itemData) {
                        currencyCount = itemData.num;
                    }
                    if (fightConsume > currencyCount) {
                        uiCanvas.showMsgAlert(CLang.Get("story_not_enough_currency"));
                    } else {
                        var needPassPreGate:Boolean = false;
                        if (preGateData && !preGateData.passed) {
                            uiCanvas.showMsgAlert(CLang.Get("story_pre_gate_not_passed"));
                            needPassPreGate = true;
                        }

                        if (!needPassPreGate) {
                            storyData.lastFightGateIsFirstPass = !gateData.passed;
                            pInstanceSystem.listenEvent(_onInstanceEvent);
                            netHandler.sendToFight(gateData.heroID, gateData.gateIndex);
                        }
                    }
                }
                break;
            case EStoryViewEventType.MAIN_SHOP_CLICK :
                CViewManagerHandler.OpenViewByBundle(system, KOFSysTags.MALL, "shop_type", [system.shopType]);
                break;
        }
    }



    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            pInstanceSystem.unListenEvent(_onInstanceEvent);
            pInstanceSystem.addExitProcess(CStoryView, CInstanceExitProcess.FLAG_STORY, system.setActived, [true], 9999);
        }
    }
}
}
