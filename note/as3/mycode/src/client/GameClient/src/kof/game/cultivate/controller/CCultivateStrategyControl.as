//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.cultivate.controller {

import flash.geom.Point;

import kof.game.common.CFlyItemUtil;
import kof.game.common.CLang;
import kof.game.cultivate.enum.ECultivateViewEventType;
import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.cultivate.enum.ECultivateWndType;
import kof.game.cultivate.view.embattle.CCultivateEmbattleView;
import kof.game.cultivate.view.strategy.CCultivateStrategy;
import kof.table.TowerRandBuffCost;
import kof.ui.master.cultivate.CultivateSListNewUI;

import morn.core.components.Component;

public class CCultivateStrategyControl extends CCultivateControlerBase {
    public function CCultivateStrategyControl() {
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        //_wnd.removeEventListener(CViewEvent.HIDE, _onHide);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        //_wnd.addEventListener(CViewEvent.HIDE, _onHide);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;

        switch (subType) {
            case ECultivateViewEventType.STRATEGY_CLICK_RESELECT :
                var randomBuffCountMax:int = playerData.vipHelper.climpRandomBuffCount;
                var leftCount:int = randomBuffCountMax - climpData.cultivateData.otherData.rerandBuffNum;
                if (leftCount < 0) {
                    leftCount = 0;
                }

                if (leftCount > 0) {
                    netHandler.sendRandomBuff(0);
                } else {
                    var randBuffCost:int = climpData.cultivateData.otherData.randBuffCostNum;
                    var towerRandBuffCostRecord:TowerRandBuffCost = climpData.cultivateData.getRandBuffCosttRecord(randBuffCost);
                    var cost:int = 0;
                    if (towerRandBuffCostRecord) {
                        cost = towerRandBuffCostRecord.randBuffCost;
                    } else {
                        cost = climpData.cultivateData.getMaxRandBuffCost();
                    }
                    if (cost > 0) {
                        var str:String = CLang.Get("cultivate_random_buff_cost", {v1:cost});
                        if (playerData.currency.blueDiamond + playerData.currency.purpleDiamond >= cost) {
                            uiSystem.showMsgBox(str, function () : void {
                                netHandler.sendRandomBuff(1);
                            });
                        } else {
                            uiSystem.showMsgAlert(CLang.Get("bangzuan_lanzuan_notEnough"));
                        }
                    } else {
                        uiSystem.showMsgAlert(CLang.Get("cultivate_random_buff_use_gold_no_time"));
                    }
                }
                break;
            case ECultivateViewEventType.STRATEGY_CLICK_BUFF :
                var selectIndex:int = (e.data as int);
                selectIndex++;
                // 显示buff界面
                if (selectIndex < 0) selectIndex = 0; // 没选直接关闭
                if (selectIndex > 3) selectIndex = 3;
                if (selectIndex > 0) {
                    climpData.cultivateData.buffSelectIndex = selectIndex;
                    netHandler.sendSelectBuff(selectIndex); // 修改buff
                    var component:Component = (_wnd as CCultivateStrategy)._ui.list.getCell(selectIndex-1);
                    var embattleView:CCultivateEmbattleView = uiHandler.getWindow(ECultivateWndType.CULTIVATE_EMBATTLE) as CCultivateEmbattleView;
                    if (embattleView) {
                        CFlyItemUtil.flyItemToTarget((component as CultivateSListNewUI).buff_box, null, embattleView._ui.buff_clip, system, null, 0, 0, -10, -20, 0.6);
                    }

                }
                break;
        }
    }

}
}
