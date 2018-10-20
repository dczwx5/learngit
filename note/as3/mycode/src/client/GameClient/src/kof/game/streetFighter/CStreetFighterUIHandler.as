//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter {


import QFLib.Foundation.CTime;

import kof.game.KOFSysTags;
import kof.game.common.CRewardUtil;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.CInstanceSystem;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.streetFighter.control.CStreetFighterEmbattleControler;
import kof.game.streetFighter.control.CStreetFighterLoadingControl;
import kof.game.streetFighter.control.CStreetFighterMainControler;
import kof.game.streetFighter.control.CStreetFighterMatchControl;
import kof.game.streetFighter.control.CStreetFighterRankControler;
import kof.game.streetFighter.control.CStreetFighterRefightControler;
import kof.game.streetFighter.control.CStreetFighterReportControler;
import kof.game.streetFighter.control.CStreetFighterRewardControler;
import kof.game.streetFighter.control.CStreetFighterSelectHeroControler;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.match.CStreetFighterLoadingData;
import kof.game.streetFighter.enum.EStreetFighterDataEventType;
import kof.game.streetFighter.enum.EStreetFighterWndType;
import kof.game.streetFighter.event.CStreetFighterEvent;
import kof.game.streetFighter.view.embattle.CStreetFighterEmbattleView;
import kof.game.streetFighter.view.loading.CStreetFighterLoadingView;
import kof.game.streetFighter.view.main.CStreetFighterMainRankView;
import kof.game.streetFighter.view.main.CStreetFighterRefightConfirmView;
import kof.game.streetFighter.view.main.CStreetFighterView;
import kof.game.streetFighter.view.match.CStreetFighterMatchView;
import kof.game.streetFighter.view.rank.CStreetFighterRankView;
import kof.game.streetFighter.view.report.CStreetFighterReportView;
import kof.game.streetFighter.view.reward.CStreetFighterRewardView;
import kof.game.streetFighter.view.select_hero.CStreetFighterSelectHeroView;

public class CStreetFighterUIHandler extends CViewManagerHandler {

    public function CStreetFighterUIHandler() {
    }

    public override function dispose() : void {
        super.dispose();
        _system.unListenEvent(_onStreetFighterEvent);
    }

    override public virtual function onEvtEnable() : void {
        super.onEvtEnable();

        var embattleSystem:CEmbattleSystem = system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem;
        if (embattleSystem) {
            if (evtEnable) {
                system.stage.getSystem(CEmbattleSystem).addEventListener(CEmbattleEvent.EMBATTLE_SUCC, _onEmbattleEvent);
            } else {
                system.stage.getSystem(CEmbattleSystem).removeEventListener(CEmbattleEvent.EMBATTLE_SUCC, _onEmbattleEvent);
            }
        }
    }

    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();

//        this.registTips(CStreetFighterPlayerTips);

        this.addViewClassHandler(EStreetFighterWndType.WND_STREET_FIGHTER, CStreetFighterView, CStreetFighterMainControler);
        this.addViewClassHandler(EStreetFighterWndType.WND_EMBATTLE, CStreetFighterEmbattleView, CStreetFighterEmbattleControler);
        this.addViewClassHandler(EStreetFighterWndType.WND_RANK, CStreetFighterRankView, CStreetFighterRankControler);
        this.addViewClassHandler(EStreetFighterWndType.WND_REPORT, CStreetFighterReportView, CStreetFighterReportControler);
        this.addViewClassHandler(EStreetFighterWndType.WND_REWARD, CStreetFighterRewardView, CStreetFighterRewardControler);
        this.addViewClassHandler(EStreetFighterWndType.WND_HERO_SELECT, CStreetFighterSelectHeroView, CStreetFighterSelectHeroControler);
        this.addViewClassHandler(EStreetFighterWndType.WND_MATCH, CStreetFighterMatchView, CStreetFighterMatchControl);
        this.addViewClassHandler(EStreetFighterWndType.WND_LOADING, CStreetFighterLoadingView, CStreetFighterLoadingControl);
        this.addViewClassHandler(EStreetFighterWndType.WND_REFIGHT_CONFIRM, CStreetFighterRefightConfirmView, CStreetFighterRefightControler);

        this.addBundleData(EStreetFighterWndType.WND_STREET_FIGHTER, KOFSysTags.STREET_FIGHTER);

        _system.listenEvent(_onStreetFighterEvent); // 由于在没有打开界面的时候。也需要处理事件，(levelUpView, 所以不能放到onEvtEnable处理)

        return ret;
    }

    // ================================== event ==================================
    private function _onStreetFighterEvent(e:CStreetFighterEvent) : void {
        if (CStreetFighterEvent.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;

        switch (subEvent) {
            case EStreetFighterDataEventType.DATA :
                win = getWindow(EStreetFighterWndType.WND_STREET_FIGHTER);
                if (win && win.isShowState) {
                    win.invalidate();
                }
                win = getWindow(EStreetFighterWndType.WND_HERO_SELECT);
                if (win && win.isShowState) {
                    win.invalidate();
                }
                win = getWindow(EStreetFighterWndType.WND_REWARD);
                if (win && win.isShowState) {
                    win.invalidate();
                }
                break;
            case EStreetFighterDataEventType.MATCHING :
//                if (peakGame.isMatching) {
//                    showMatchView();
//                } else {
//                    hideMatchView(); // 匹配成功和区配取消
//                }
                break;
            case EStreetFighterDataEventType.MATCH_DATA :
                // show loadingView
                hideMatch();
                // status不恢复。
                this.showHeroSelectView();

                break;
            case EStreetFighterDataEventType.RANK :
                win = getWindow(EStreetFighterWndType.WND_RANK);
                if (win) {
                    win.invalidate();
                }

                win = getWindow(EStreetFighterWndType.WND_STREET_FIGHTER);
                if (win && win.isShowState) {
                    var rnkView:CViewBase = win.getChildByType(CStreetFighterMainRankView) as CViewBase;
                    if (rnkView) {
                        rnkView.invalidate();
                    }
                }
                break;
            case EStreetFighterDataEventType.LOADING :
                    // EnterFrameEvent process.
                hide(EStreetFighterWndType.WND_HERO_SELECT);
                showLoading();
//                (_system.stage.getSystem(CInstanceSystem) as CInstanceSystem).enterInstance(_data.loadingData.instanceID);
                break;
            case EStreetFighterDataEventType.REPORT :
                win = getWindow(EStreetFighterWndType.WND_REPORT);
                if (win && win.isShowState) {
                    win.invalidate();
                }
                break;

            case EStreetFighterDataEventType.ENTER_ERROR :
                CGameStatus.unSetStatus(CGameStatus.Status_StreetFighterMatch);
                win = getWindow(EStreetFighterWndType.WND_MATCH);
                if (win && win.isShowState) {
                    hideMatch();
                }
                win = getWindow(EStreetFighterWndType.WND_HERO_SELECT);
                if (win && win.isShowState) {
                    hideSelectHeroView();
                }
                break;
            case EStreetFighterDataEventType.SETTLEMENT :
                win = getCreatedWindow(EStreetFighterWndType.WND_LOADING);
                if (win) {
//                    (win as CStreetFighterLoadingView).clearPreloadData();
                }
                break;

            case EStreetFighterDataEventType.GET_REWARD :
                var rewardList:Array = e.data as Array;
                var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, rewardList);
                (_system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);
                break;
            case EStreetFighterDataEventType.SELECT_HERO_READY :

                break;
            case EStreetFighterDataEventType.ENEMY_SELECT_HERO_SYNC :
                // 对方选择格斗家
                win = getWindow(EStreetFighterWndType.WND_HERO_SELECT);
                if (win) {
                    win.invalidate();
                }
                break;
            case EStreetFighterDataEventType.SELECT_HERO :
                // 对方选定格斗家, 点了确定
                win = getWindow(EStreetFighterWndType.WND_HERO_SELECT);
                if (win) {
                    win.invalidate();
                }
                break;
        }
    }

    private function _onEmbattleEvent(e:CEmbattleEvent) : void {
        var win:CViewBase = getWindow(EStreetFighterWndType.WND_STREET_FIGHTER);
        if (win && win.isShowState) {
            win.invalidate();
        }
        win = getWindow(EStreetFighterWndType.WND_EMBATTLE);
        if (win && win.isShowState) {
            win.invalidate();
        }
    }

    public function showStreetFighter() : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        if (streetData.rankData.needSync) {
            _system.netHandler.sendGetRank();
        }

        show(EStreetFighterWndType.WND_STREET_FIGHTER, null, null, [streetData, playerData]);
    }
    public function hideStreetFighterFair() : void {
        this.hide(EStreetFighterWndType.WND_STREET_FIGHTER);
    }

    public function openEmbattleView(callback:Function = null) : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        show(EStreetFighterWndType.WND_EMBATTLE, null, callback, [streetData, playerData]);
    }

    public function showReportView(callback:Function = null) : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        show(EStreetFighterWndType.WND_REPORT, null, callback, [streetData, playerData]);
    }

    public function showRewardView(callback:Function = null) : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        show(EStreetFighterWndType.WND_REWARD, null, callback, [streetData, playerData]);
    }

    public function showRankView(callback:Function = null) : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        if (streetData.rankData.needSync) {
            streetData.rankData.sync();
            _system.netHandler.sendGetRank();
        }
        show(EStreetFighterWndType.WND_RANK, null, callback, [streetData, playerData]);
    }
    public function showHeroSelectView(callback:Function = null) : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        show(EStreetFighterWndType.WND_HERO_SELECT, null, callback, [streetData, playerData]);
    }
    public function hideSelectHeroView() : void {
        hide(EStreetFighterWndType.WND_HERO_SELECT);
    }
    public function showMatch() : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        show(EStreetFighterWndType.WND_MATCH, null, null, [streetData, playerData]);
    }
    public function hideMatch() : void {
        hide(EStreetFighterWndType.WND_MATCH);
    }
    public function showLoading() : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        show(EStreetFighterWndType.WND_LOADING, null, null, [streetData, playerData]);
    }
    public function showRefightConfirm() : void {
        var playerData:CPlayerData = _playerData;
        var streetData:CStreetFighterData = _data;
        show(EStreetFighterWndType.WND_REFIGHT_CONFIRM, null, null, [streetData, playerData]);
    }

    // =================================================================
    public function showResult() : void {
        var pvpResultData:CPVPResultData = (system.getHandler(CStreetFighterResultDataProvider) as CStreetFighterResultDataProvider).getResultData();
        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem) {
            (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).data = pvpResultData;
            (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).addDisplay();
        }
    }

    // ================================== common data ==================================
    [Inline]
    private function get _system() : CStreetFighterSystem {
        return system as CStreetFighterSystem;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _data() : CStreetFighterData {
        return _system.data;
    }
}
}
