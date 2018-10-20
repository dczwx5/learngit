//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1 {

import flash.events.Event;

import kof.game.KOFSysTags;
import kof.game.common.loading.CLoadingEvent;
import kof.game.common.status.CGameStatus;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.event.CViewEvent;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.common.view.resultWin.CPVPResultData;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;
import kof.game.peak1v1.control.CPeak1v1LoadingControl;
import kof.game.peak1v1.control.CPeak1v1MainControl;
import kof.game.peak1v1.control.CPeak1v1NotifyControl;
import kof.game.peak1v1.control.CPeak1v1RankingControl;
import kof.game.peak1v1.control.CPeak1v1ReportControl;
import kof.game.peak1v1.control.CPeak1v1RewardControl;
import kof.game.peak1v1.control.CPeak1v1RewardDescControl;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.enum.EPeak1v1DataEventType;
import kof.game.peak1v1.enum.EPeak1v1WndType;
import kof.game.peak1v1.event.CPeak1v1Event;
import kof.game.peak1v1.view.CPeak1v1View;
import kof.game.peak1v1.view.imp.CPeak1v1ResultDataProvider;
import kof.game.peak1v1.view.loading.CPeak1v1LoadingView;
import kof.game.peak1v1.view.notify.CPeak1v1NotifyView;
import kof.game.peak1v1.view.ranking.CPeak1v1RankingView;
import kof.game.peak1v1.view.report.CPeak1v1ReportView;
import kof.game.peak1v1.view.reward.CPeak1v1RewardView;
import kof.game.peak1v1.view.rewardDesc.CPeak1v1RewardDescView;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;

public class CPeak1v1UIHandler extends CViewManagerHandler {

    public function CPeak1v1UIHandler() {
    }

    public override function dispose() : void {
        super.dispose();

        _system.removeEventListener(CPeak1v1Event.DATA_EVENT, _onPeak1v1DataEvent);

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

//        this.registTips(CPeakGamePlayerTips);

        this.addViewClassHandler(EPeak1v1WndType.WND_PEAK_1V1_MAIN, CPeak1v1View, CPeak1v1MainControl);
        this.addViewClassHandler(EPeak1v1WndType.WND_RANKING, CPeak1v1RankingView, CPeak1v1RankingControl);
        this.addViewClassHandler(EPeak1v1WndType.WND_REPORT, CPeak1v1ReportView, CPeak1v1ReportControl);
        this.addViewClassHandler(EPeak1v1WndType.WND_REWARD, CPeak1v1RewardView, CPeak1v1RewardControl);
        this.addViewClassHandler(EPeak1v1WndType.WND_REWARD_DESC, CPeak1v1RewardDescView, CPeak1v1RewardDescControl);
        this.addViewClassHandler(EPeak1v1WndType.WND_NOTIFY, CPeak1v1NotifyView, CPeak1v1NotifyControl);
        this.addViewClassHandler(EPeak1v1WndType.WND_LOADING, CPeak1v1LoadingView, CPeak1v1LoadingControl);


        this.addBundleData(EPeak1v1WndType.WND_PEAK_1V1_MAIN, KOFSysTags.PEAK_1V1);

        _system.addEventListener(CPeak1v1Event.DATA_EVENT, _onPeak1v1DataEvent);
        return ret;
    }

    // ================================== event ==================================
    private function _onPeak1v1DataEvent(e:CPeak1v1Event) : void {
        if (CPeak1v1Event.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;

        switch (subEvent) {
            case EPeak1v1DataEventType.DATA :
                win = getWindow(EPeak1v1WndType.WND_PEAK_1V1_MAIN);
                if (win && win.isShowState) {
                    win.invalidate();
                }
                win = getWindow(EPeak1v1WndType.WND_REWARD);
                if (win && win.isShowState) {
                    win.invalidate();
                }
                break;
            case EPeak1v1DataEventType.REGISTER_DATA :
                win = getWindow(EPeak1v1WndType.WND_PEAK_1V1_MAIN);
                if (win && win.isShowState) {
                    var isRegister:Boolean = e.data as Boolean;
                    if (isRegister) {
                        CGameStatus.setStatus(CGameStatus.Status_Peak1v1Match);
                    } else {
                        CGameStatus.unSetStatus(CGameStatus.Status_Peak1v1Match);
                    }
                }

                break;
            case EPeak1v1DataEventType.MATCH_DATA :
                CGameStatus.setStatus(CGameStatus.Status_Peak1v1Loading);
                showLoadingView();
                break;
            case EPeak1v1DataEventType.ENEMY_PROGRESS_DATA :
                // todo : 需要改成loading界面结束, 才发起进入副本
                break;
        }
    }

    private function _onEmbattleEvent(e:CEmbattleEvent) : void {
        var win:CViewBase = getWindow(EPeak1v1WndType.WND_PEAK_1V1_MAIN);
        if (win && win.isShowState) {
            win.invalidate();
        }
    }

    public function showPeak1v1View() : void {
        var playerData:CPlayerData = _playerData;
        var peak1v1Data:CPeak1v1Data = _data;
        show(EPeak1v1WndType.WND_PEAK_1V1_MAIN, null, function (view:CViewBase) : void {
            _system.netHandler.sendOpenWindow();
        }, [peak1v1Data, playerData]);
    }
    public function hidePeak1v1View() : void {
        _system.netHandler.sendCloseWindow();
        hide(EPeak1v1WndType.WND_PEAK_1V1_MAIN);
    }
    public function showResult() : void {
        var pvpResultData:CPVPResultData = (system.getHandler(CPeak1v1ResultDataProvider) as CPeak1v1ResultDataProvider).getResultData();
        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).data = pvpResultData;
            (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).addDisplay();
        }
    }
    public function showRankView() : void {
        var playerData:CPlayerData = _playerData;
        var peak1v1Data:CPeak1v1Data = _data;

        if (peak1v1Data.rankingListData.isServerData && peak1v1Data.rankingListData.needSync == false) {
            showRankViewB(playerData, peak1v1Data);
        } else {
            var func:Function = function (e:CPeak1v1Event):void {
                if (e.type == CPeak1v1Event.DATA_EVENT && e.subEvent == EPeak1v1DataEventType.RANKING_DATA) {
                    showRankViewB(playerData, peak1v1Data);
                    _system.removeEventListener(CPeak1v1Event.DATA_EVENT, func);
                }
            };
            // 没有初始化过数据, 请求数据回来之后, 才弹出界面
            _system.removeEventListener(CPeak1v1Event.DATA_EVENT, func);
            _system.addEventListener(CPeak1v1Event.DATA_EVENT, func);
            peak1v1Data.rankingListData.sync();
            _system.netHandler.sendGetRanking();
        }
    }
    public function showRankViewB(playerData:CPlayerData, peak1v1Data:CPeak1v1Data) : void {
        show(EPeak1v1WndType.WND_RANKING, null, null, [peak1v1Data, playerData]);
    }
    public function showReportView() : void {
        var playerData:CPlayerData = _playerData;
        var peak1v1Data:CPeak1v1Data = _data;

        if (peak1v1Data.reportData.isServerData && peak1v1Data.reportData.needSync == false) {
            _showReportViewB(playerData, peak1v1Data);
        } else {
            var func:Function = function (e:CPeak1v1Event):void {
                if (e.type == CPeak1v1Event.DATA_EVENT && e.subEvent == EPeak1v1DataEventType.REPORT_DATA) {
                    _showReportViewB(playerData, peak1v1Data);
                    _system.removeEventListener(CPeak1v1Event.DATA_EVENT, func);
                }
            };
            // 没有初始化过数据, 请求数据回来之后, 才弹出界面
            _system.removeEventListener(CPeak1v1Event.DATA_EVENT, func);
            _system.addEventListener(CPeak1v1Event.DATA_EVENT, func);
            peak1v1Data.reportData.sync();
            _system.netHandler.sendGetReport();
        }
    }
    private function _showReportViewB(playerData:CPlayerData, peak1v1Data:CPeak1v1Data) : void {
        show(EPeak1v1WndType.WND_REPORT, null, null, [peak1v1Data, playerData]);
    }
    public function showRewardView() : void {
        var playerData:CPlayerData = _playerData;
        var peak1v1Data:CPeak1v1Data = _data;
        show(EPeak1v1WndType.WND_REWARD, null, null, [peak1v1Data, playerData]);
    }
    public function showRewardDescView() : void {
        var playerData:CPlayerData = _playerData;
        var peak1v1Data:CPeak1v1Data = _data;
        show(EPeak1v1WndType.WND_REWARD_DESC, null, null, [peak1v1Data, playerData]);
    }

    public function showNotifyView() : void {
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem.isMainCity) {
            _showNotifyViewB();
        }

    }
    private function _showNotifyViewB() : void {
        var playerData:CPlayerData = _playerData;
        var peak1v1Data:CPeak1v1Data = _data;
        show(EPeak1v1WndType.WND_NOTIFY, null, null, [peak1v1Data, playerData]);
    }
    public function showLoadingView() : void {
        var playerData:CPlayerData = _playerData;
        var peak1v1Data:CPeak1v1Data = _data;
        show(EPeak1v1WndType.WND_LOADING, null, null, [peak1v1Data, playerData]);
    }

    // ================================== common data ==================================
    [Inline]
    private function get _system() : CPeak1v1System {
        return system as CPeak1v1System;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _data() : CPeak1v1Data {
        return _system.data;
    }
}
}
