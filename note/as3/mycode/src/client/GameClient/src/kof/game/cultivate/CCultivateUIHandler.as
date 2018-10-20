//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/11.
 */
package kof.game.cultivate {

import QFLib.Foundation;

import kof.game.KOFSysTags;
import kof.game.common.CRewardUtil;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.cultivate.controller.CCultivateControl;
import kof.game.cultivate.controller.CCultivateEmbattleControl;
import kof.game.cultivate.controller.CCultivateStrategyControl;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.enum.ECultivateDataEventType;
import kof.game.cultivate.enum.ECultivateWndType;
import kof.game.cultivate.event.CCultivateEvent;
import kof.game.cultivate.imp.CCultivateResultDataProvider;
import kof.game.cultivate.view.cultivateNew.CCultivateViewNew;
import kof.game.cultivate.view.embattle.CCultivateEmbattleView;
import kof.game.cultivate.view.strategy.CCultivateStrategy;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;


public class CCultivateUIHandler extends CViewManagerHandler {

    public function CCultivateUIHandler() {
    }

    public override function dispose() : void {
        super.dispose();
    }

    override public virtual function onEvtEnable() : void {
        super.onEvtEnable();
        if (evtEnable) {
            _cultivateSystem.listenEvent(_onClimpEvent);
            _playerSystem.addEventListener(CPlayerEvent.HERO_ADD, _onHeroAddData);

        } else {
            _cultivateSystem.unListenEvent(_onClimpEvent);
            _playerSystem.removeEventListener(CPlayerEvent.HERO_ADD, _onHeroAddData);
        }

        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        if (embattleSystem) {
            if (evtEnable) {
                system.stage.getSystem(CEmbattleSystem).addEventListener(CEmbattleEvent.EMBATTLE_SUCC, _onEmbattleEvent);
            } else {
                system.stage.getSystem(CEmbattleSystem).removeEventListener(CEmbattleEvent.EMBATTLE_SUCC, _onEmbattleEvent);
            }
        }
    }
    private function _onEmbattleEvent(e:CEmbattleEvent) : void {
        // updateData -
        var win:CViewBase = getWindow(ECultivateWndType.Cultivate);
        if (win) {
            win.invalidate();
        }
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

        this.addViewClassHandler(ECultivateWndType.Cultivate, CCultivateViewNew, CCultivateControl);
        this.addViewClassHandler(ECultivateWndType.CULTIVATE_STRATEGY, CCultivateStrategy, CCultivateStrategyControl);
        this.addViewClassHandler(ECultivateWndType.CULTIVATE_EMBATTLE, CCultivateEmbattleView, CCultivateEmbattleControl);

        this.addBundleData(ECultivateWndType.Cultivate, KOFSysTags.CULTIVATE);
        return ret;
    }

    // ================================== event ==================================
    private function _onClimpEvent(e:CCultivateEvent) : void {
        if (CCultivateEvent.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;
        var climpData:CClimpData = _climpData;
        var playerData:CPlayerData = _playerData;

        switch (subEvent) {
            case ECultivateDataEventType.DATA :
                win = getWindow(ECultivateWndType.Cultivate);
                if (win) {
                    win.setData([climpData, playerData]);
                }

                win = getWindow(ECultivateWndType.CULTIVATE_STRATEGY);
                if (win) {
                    win.setData([climpData, playerData]);
                }

                win = getWindow(ECultivateWndType.CULTIVATE_EMBATTLE);
                if (win) {
                    win.setData([climpData, playerData]);
                }

                break;
            case ECultivateDataEventType.REWARD_BOX_DATA :
                var itemSystem:CItemSystem = system.stage.getSystem(CItemSystem) as CItemSystem;
                var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, _climpData.cultivateData.otherData.rewardBoxRewardList);
                itemSystem.showRewardFull(rewardListData);
                break;
            case ECultivateDataEventType.RESET_DATA :
                win = getWindow(ECultivateWndType.Cultivate);
                if (win) {
                    (win as CCultivateViewNew).showResetMovie();
                }
                break;
            case ECultivateDataEventType.BUFF_DATA_ACTIVED :
                win = getWindow(ECultivateWndType.CULTIVATE_EMBATTLE);
                if (win) {
                    (win as CCultivateEmbattleView).showBuffActivedMovie();
                }
                break;
        }
    }
    private function _onHeroAddData(e:CPlayerEvent) : void {
        var win:CViewBase;
        win = getWindow(ECultivateWndType.Cultivate);
        if (win) {
            win.sendEvent(new CViewEvent(CViewEvent.UPDATE_VIEW));
        }
    }

    // ===================================Main===================================
    public function showClimpView(hasEmbattleData:Boolean) : void {
        var playerData:CPlayerData = _playerData;
        var climpData:CClimpData = _climpData;
        if (climpData.cultivateData.isServerData) {
            _showClimpViewB(hasEmbattleData);
        } else {
            var func:Function  = function (e:CCultivateEvent) : void {
                if (e.type == CCultivateEvent.DATA_EVENT && e.subEvent == ECultivateDataEventType.DATA) {
                    climpData = _climpData;
                    if (climpData.cultivateData.levelList.list.length > 0) {
                        _showClimpViewB(hasEmbattleData);
                    } else {
                        _cultivateSystem.isActived = false;
                        climpData.cultivateData.isServerData = false;
                        climpData.cultivateData.clearData();
                        Foundation.Log.logErrorMsg("cultivate's towerDatas is empty");
                    }
                    _cultivateSystem.unListenEvent(func);

                }
            };
            // 没有初始化过数据, 请求数据回来之后, 才弹出界面
            _cultivateSystem.listenEvent(func);
            _cultivateSystem.netHandler.sendGetCultivateData(); // 现在系统开始就请求了。可以去掉这个send
        }
    }
    private function _showClimpViewB(hasEmbattleData:Boolean) : void {
        var playerData:CPlayerData = _playerData;
        var climpData:CClimpData = _climpData;
        show(ECultivateWndType.Cultivate, null, null, [climpData, playerData, hasEmbattleData]);
    }
    public function hideClimpView() : void {
        hide(ECultivateWndType.Cultivate);
    }
    // ===================================Strategy===================================
    public function showCultivateStrategyView(callback:Function) : void {
        var playerData:CPlayerData = _playerData;
        var climpData:CClimpData = _climpData;
        show(ECultivateWndType.CULTIVATE_STRATEGY, null, callback, [climpData, playerData]);
    }
    public function hideCultivateStrategyView() : void {
        hide(ECultivateWndType.CULTIVATE_STRATEGY);
    }
    public function hideCultivateRuleView() : void {
        hide(ECultivateWndType.CULTIVATE_RULE);
    }
    // ========================================布阵===============================
    public function showEmbattleView(callback:Function) : void {
        var playerData:CPlayerData = _playerData;
        var climpData:CClimpData = _climpData;

        var rootView:CCultivateViewNew = getWindow(ECultivateWndType.Cultivate) as CCultivateViewNew;
        show(ECultivateWndType.CULTIVATE_EMBATTLE, [rootView.getSelectLevelData()], callback, [climpData, playerData]);
    }
    public function hideEmbattleView() : void {
        hide(ECultivateWndType.CULTIVATE_EMBATTLE);
    }
    // ===================================Reward===================================
    public function showRewardFull(data:CRewardListData) : void {
        this.show(ECultivateWndType.REWARD_VIEW, null, null, data);
    }
    public function hideRewardFull() : void {
        this.hide(ECultivateWndType.REWARD_VIEW);
    }

    // ==================================结算=====================================
    public function showResult() : void {
        var pvpResultData:CPVPResultData = (system.getHandler(CCultivateResultDataProvider) as CCultivateResultDataProvider).getResultData();
        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            var resultView:CMultiplePVPResultViewHandler = instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler;
            resultView.data = pvpResultData;
            resultView.addDisplay();
        }
    }
    public function hideResult() : void {

    }

    // ================================== common data ==================================
    [Inline]
    private function get _cultivateSystem() : CCultivateSystem {
        return system as CCultivateSystem;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }
    [Inline]
    private function get _climpData() : CClimpData {
        return _cultivateSystem.climpData;
    }
}
}
