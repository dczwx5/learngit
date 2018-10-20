//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame {


import flash.events.Event;

import kof.game.KOFSysTags;
import kof.game.bootstrap.CBootstrapEvent;
import kof.game.bootstrap.CBootstrapSystem;
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
import kof.game.peakGame.control.CPeakGameLevelControl;
import kof.game.peakGame.control.CPeakGameLevelUpControl;
import kof.game.common.loading.CMatchLoadingControl;
import kof.game.peakGame.control.CPeakGameMainControl;
import kof.game.peakGame.control.CPeakGameMatchControl;
import kof.game.peakGame.control.CPeakGameNewSeasonControl;
import kof.game.peakGame.control.CPeakGameNewSeasonRankControl;
import kof.game.peakGame.control.CPeakGameRankControl;
import kof.game.peakGame.control.CPeakGameRankInfoControl;
import kof.game.peakGame.control.CPeakGameReportControl;
import kof.game.peakGame.control.CPeakGameResultControl;
import kof.game.peakGame.control.CPeakGameRewardControl;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameDataEventType;
import kof.game.peakGame.enum.EPeakGameRankType;
import kof.game.peakGame.enum.EPeakGameWndType;
import kof.game.peakGame.event.CPeakGameEvent;
import kof.game.peakGame.imp.CPeakResultDataProvider;
import kof.game.peakGame.view.CPeakGamePlayerTips;
import kof.game.peakGame.view.level.CPeakGameLevelView;
import kof.game.peakGame.view.levelUp.CPeakGameLevelUpView;
import kof.game.common.loading.CMatchLoadingView;
import kof.game.peakGame.view.main.CPeakGameView;
import kof.game.peakGame.view.match.CPeakGameMatchView;
import kof.game.peakGame.view.new_season.CPeakGameNewSeasonRankView;
import kof.game.peakGame.view.new_season.CPeakGameNewSeasonView;
import kof.game.peakGame.view.rank.CPeakGameRankView;
import kof.game.peakGame.view.rankIntro.CPeakGameRankInfoView;
import kof.game.peakGame.view.report.CPeakGameReportIntroView;
import kof.game.peakGame.view.report.CPeakGameReportView;
import kof.game.peakGame.view.result.CPeakGameResultView;
import kof.game.peakGame.view.reward.CPeakGameRewardView;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.message.Common.NetDelayResponse;
import kof.table.PeakScoreLevel;

import morn.core.handlers.Handler;

public class CPeakGameUIHandler extends CViewManagerHandler {

    public function CPeakGameUIHandler() {
    }

    public override function dispose() : void {
        super.dispose();
        _peakGameSystem.unListenEvent(_onPeakGameEvent);
        var pBootstrapSystem:CBootstrapSystem =  system.stage.getSystem( CBootstrapSystem ) as CBootstrapSystem;
        if (pBootstrapSystem) {
            pBootstrapSystem.removeEventListener(CBootstrapEvent.NET_DELAY_RESPONSE, _onNetDelayEvent);
        }
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

        this.registTips(CPeakGamePlayerTips);

        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_FAIR_MAIN, CPeakGameView, CPeakGameMainControl);
        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_REPORT, CPeakGameReportView, CPeakGameReportControl);
        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_RANK, CPeakGameRankView, CPeakGameRankControl);
        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_RANK_INFO, CPeakGameRankInfoView, CPeakGameRankInfoControl);
        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_LEVEL, CPeakGameLevelView, CPeakGameLevelControl);
        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_LEVEL_UP, CPeakGameLevelUpView, CPeakGameLevelUpControl);

        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_RESULT, CPeakGameResultView, CPeakGameResultControl); // pvp
        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_MATCH, CPeakGameMatchView, CPeakGameMatchControl);
        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_NEW_SEASON, CPeakGameNewSeasonView, CPeakGameNewSeasonControl); // 新赛季段位奖励
        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_NEW_SEASON_RANK, CPeakGameNewSeasonRankView, CPeakGameNewSeasonRankControl); // 新赛季排名奖励

        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_REPORT_INTRO, CPeakGameReportIntroView);

        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_REWARD, CPeakGameRewardView, CPeakGameRewardControl);


        this.addViewClassHandler(EPeakGameWndType.WND_PEAK_LOADING, CMatchLoadingView, CMatchLoadingControl);
        this.addBundleData(EPeakGameWndType.WND_PEAK_FAIR_MAIN, KOFSysTags.PEAK_GAME_FAIR);

        _peakGameSystem.listenEvent(_onPeakGameEvent); // 由于在没有打开界面的时候。也需要处理事件，(levelUpView, 所以不能放到onEvtEnable处理)

        var pBootstrapSystem:CBootstrapSystem =  system.stage.getSystem( CBootstrapSystem ) as CBootstrapSystem;
        if (pBootstrapSystem) {
            pBootstrapSystem.addEventListener(CBootstrapEvent.NET_DELAY_RESPONSE, _onNetDelayEvent);
        }

        return ret;
    }

    // ================================== event ==================================
    private function _onPeakGameEvent(e:CPeakGameEvent) : void {
        if (CPeakGameEvent.DATA_EVENT != e.type) return ;

        var win:CViewBase;
        var subEvent:String = e.subEvent;
        var peakGame:CPeakGameData = _peakGameSystem.peakGameData;
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;

        switch (subEvent) {
            case EPeakGameDataEventType.DATA :
                win = getWindow(EPeakGameWndType.WND_PEAK_FAIR_MAIN);
                if (win && win.isShowState) {
                    win.setData([peakGame, playerData]);
                }

                win = getWindow(EPeakGameWndType.WND_PEAK_REWARD);
                if (win) { win.setData([peakGame, playerData]); }
                break;
            case EPeakGameDataEventType.DATA_LEVEL_CHANGE :
                _isLevelChange = true;
                _levelChangeData = e.data as Array;
                var view:CViewBase = getWindow(EPeakGameWndType.WND_PEAK_FAIR_MAIN);
                if (view && view.isShowState) {
                    (view as CPeakGameView).playLevelChangeEffect(_levelChangeData);
                }
                break;
            case EPeakGameDataEventType.MATCHING :
                if (peakGame.isMatching) {
                    showMatchView();
                } else {
                    hideMatchView(); // 匹配成功和区配取消
                }
                break;
            case EPeakGameDataEventType.MATCH_DATA :
                    // show loadingView
                    showLoadingView();

                break;
            case EPeakGameDataEventType.RANK :
                win = getWindow(EPeakGameWndType.WND_PEAK_RANK);
                if (win) {
                    win.setData([peakGame, playerData]);
                }

                // 拳皇大赛主界面需要更新排名
                win = getWindow(EPeakGameWndType.WND_PEAK_FAIR_MAIN);
                if (win && win.isShowState) {
                    win.setData([peakGame, playerData]);
                }
                break;
            case EPeakGameDataEventType.LOADING :
                    // EnterFrameEvent process.
//                win = getWindow(EPeakGameWndType.WND_PEAK_LOADING);
//                if (win) {
//                    win.setData([peakGame.matchData, playerData, peakGame.loadingData]);
//                }

                break;
            case EPeakGameDataEventType.REPORT :
                win = getWindow(EPeakGameWndType.WND_PEAK_REPORT);
                if (win) {
                    win.setData([peakGame, playerData]);
                }
                break;
            case EPeakGameDataEventType.HONOUR :
                win = getWindow(EPeakGameWndType.WND_PEAK_HONOUR);
                if (win) {
                    win.setData([peakGame, playerData]);
                }
                break;
            case EPeakGameDataEventType.ENTER_ERROR :
                CGameStatus.unSetStatus(CGameStatus.Status_PeakGameMatch);
                win = getWindow(EPeakGameWndType.WND_PEAK_MATCH);
                if (win && win.isShowState) {
                    hideMatchView();
                }
                win = getWindow(EPeakGameWndType.WND_PEAK_LOADING);
                if (win) {
                    (win as CMatchLoadingView).forceStop();
                }
                break;
            case EPeakGameDataEventType.SETTLEMENT :
                win = getCreatedWindow(EPeakGameWndType.WND_PEAK_LOADING);
                if (win) {
                    (win as CMatchLoadingView).clearPreloadData();
                }
                break;
        }
    }

    private function _onEmbattleEvent(e:CEmbattleEvent) : void {
        // updateData -
        var playerData:CPlayerData;
        var peakGame:CPeakGameData;
        var win:CViewBase = getWindow(EPeakGameWndType.WND_PEAK_FAIR_MAIN);
        if (win && win.isShowState) {
            playerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            peakGame = _peakGameSystem.peakGameData;
            win.setData([peakGame, playerData]);
        }
    }

    private function _onNetDelayEvent(e:CBootstrapEvent) : void {
        var response:NetDelayResponse = e.data as NetDelayResponse;
        var peakGame:CPeakGameData = _peakGameSystem.peakGameData;
        if (peakGame) {
            peakGame.lastNetDelay = response.delayTime;
            if (evtEnable) {
                // peakGameUI是有打开的
                var view:CPeakGameView = getWindow(EPeakGameWndType.WND_PEAK_FAIR_MAIN) as CPeakGameView;
                if (view) {
                    view.updateNetDelay();
                }
            }
        }
    }

    // ===================================Main===================================
    public function showPeakGame(playType:int) : void {
        var peakGameData:CPeakGameData = _peakGameData;
        if (peakGameData.isServerData) {
            _showPeakGameB(playType);
            if (peakGameData.rankDataMulti.needSync) {
                peakGameData.rankDataMulti.sync();
                _peakGameSystem.netHandler.sendGetRank(EPeakGameRankType.TYPE_MULTI_SERVER, playType);
            }
        } else {
            var func:Function  = function (e:CPeakGameEvent) : void {
                if (e.type == CPeakGameEvent.DATA_EVENT && e.subEvent == EPeakGameDataEventType.DATA) {
                    if (peakGameData.rankDataMulti.needSync) {
                        peakGameData.rankDataMulti.sync();
                        _peakGameSystem.netHandler.sendGetRank(EPeakGameRankType.TYPE_MULTI_SERVER, playType);
                    }
                    _showPeakGameB(playType);
                    _peakGameSystem.unListenEvent(func);
                }
            };
            // 没有初始化过数据, 请求数据回来之后, 才弹出界面
            _peakGameSystem.listenEvent(func);
            _peakGameSystem.netHandler.sendGetData((system as CPeakGameSystem).playType);
        }
     }
    private var _isLevelChange:Boolean;
    private var _levelChangeData:Array;
    private function _showPeakGameB(playType:int) : void {
        var wndType:int = EPeakGameWndType.WND_PEAK_FAIR_MAIN;
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(wndType, [playType], function (view:CViewBase) : void {
            if (peakGameData.seasonComingFlag) showNewSeasonView();
            if (_isLevelChange) {
                _isLevelChange = false;
                (view as CPeakGameView).playLevelChangeEffect(_levelChangeData);
            } else {
                (view as CPeakGameView).showLevelItem();
            }
        }, [peakGameData, playerData]);

    }
    public function hidePeakGameFair() : void {
        hide(EPeakGameWndType.WND_PEAK_FAIR_MAIN);
    }
    // ===================================Honour===================================

    public function hideHonourView() : void {
        hide(EPeakGameWndType.WND_PEAK_HONOUR);
    }
    // ===================================Level===================================
    public function showLevelView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_LEVEL, null, null, [peakGameData, playerData]);
    }
    public function showLevelUpView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_LEVEL_UP, null, null, [peakGameData, playerData]);
    }
    public function hideLevelUpView() : void {
        hide(EPeakGameWndType.WND_PEAK_LEVEL_UP);
    }
    // ===================================Loading===================================
    public function showLoadingView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_LOADING, null, function (view:CViewBase) : void {
            view.addEventListener(CLoadingEvent.LOADING_REQUIRE_TO_END, _onLoadingFinish); // loading结束
            view.addEventListener(CViewEvent.HIDE, _onLoadingHide); // 防止loading异常结束
        }, [peakGameData.matchData, playerData, peakGameData.loadingData]);
    }
    private function _onLoadingFinish(e:Event) : void {
        var view:CViewBase = e.currentTarget as CViewBase;
        view.removeEventListener(CLoadingEvent.LOADING_REQUIRE_TO_END, _onLoadingFinish);
        view.removeEventListener(CViewEvent.HIDE, _onLoadingHide);

        (_peakGameSystem.stage.getSystem(IInstanceFacade) as IInstanceFacade).addExitProcess(CPeakGameView, CInstanceExitProcess.FLAG_PEAK, _peakGameSystem.setActived, [true], 9999);
    }
    private function _onLoadingHide(e:CViewEvent) : void {
        var view:CViewBase = e.currentTarget as CViewBase;
        view.removeEventListener(CLoadingEvent.LOADING_REQUIRE_TO_END, _onLoadingFinish);
        view.removeEventListener(CViewEvent.HIDE, _onLoadingHide);
    }
    public function hideLoadingView() : void {
        hide(EPeakGameWndType.WND_PEAK_LOADING);

    }
    // ===================================Rank===================================
    public function showRankView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        if (peakGameData.rankDataOne.isServerData && false == peakGameData.rankDataOne.needSync) {
            if (peakGameData.rankDataOne.hasData()) {
                _showRankViewB([peakGameData, playerData]);
            } else {
                showRankIntroView();
            }
        } else {
            var func:Function = function (e:CPeakGameEvent) : void {
                if (e.type == CPeakGameEvent.DATA_EVENT && e.subEvent == EPeakGameDataEventType.RANK) {
                    if (peakGameData.rankDataOne.hasData()) {
                        _showRankViewB([peakGameData, playerData]);
                    } else {
                        showRankIntroView();
                    }
                    _peakGameSystem.unListenEvent(func);
                }
            };
            // 没有初始化过数据, 请求数据回来之后, 才弹出界面
            _peakGameSystem.listenEvent(func);
            peakGameData.rankDataOne.sync();
            _peakGameSystem.netHandler.sendGetRank(EPeakGameRankType.TYPE_SELF_SERVER, (system as CPeakGameSystem).playType);
        }
    }
    private function _showRankViewB(data:Array) : void {
        show(EPeakGameWndType.WND_PEAK_RANK, null, null, data);
    }
    public function hideRankView() : void {
        hide(EPeakGameWndType.WND_PEAK_RANK);
    }
    // ===================================new Season=================================
    public function showNewSeasonView() : void { // 段位
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_NEW_SEASON, null, null, [peakGameData, playerData]);
    }
    public function showNewSeasonRankView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_NEW_SEASON_RANK, null, null, [peakGameData, playerData]);
    }
    // ===================================RankIntro===================================
    public function showRankIntroView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_RANK_INFO, null, null, [peakGameData, playerData]);
    }
    // ===================================Report===================================
    public function showReportView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;

        if (peakGameData.reportData.isServerData && peakGameData.reportData.needSync == false) {
            if (peakGameData.reportData.hasData()) {
                _showReportViewB([peakGameData, playerData]);
            } else {
                showReportIntroView();
            }
        } else {
            var func:Function  = function (e:CPeakGameEvent) : void {
                if (e.type == CPeakGameEvent.DATA_EVENT && e.subEvent == EPeakGameDataEventType.REPORT) {
                    if (peakGameData.reportData.hasData()) {
                        _showReportViewB([peakGameData, playerData]);
                    } else {
                        showReportIntroView();
                    }

                    _peakGameSystem.unListenEvent(func);
                }
            };
            // 没有初始化过数据, 请求数据回来之后, 才弹出界面
            _peakGameSystem.listenEvent(func);
            peakGameData.reportData.sync();
            _peakGameSystem.netHandler.sendGetReport((system as CPeakGameSystem).playType);
        }
    }
    private function _showReportViewB(data:Array) : void {
        show(EPeakGameWndType.WND_PEAK_REPORT, null, null, data);
    }
    public function hideReportView() : void {
        hide(EPeakGameWndType.WND_PEAK_REPORT);
    }
    // intro
    public function showReportIntroView() : void {
        show(EPeakGameWndType.WND_PEAK_REPORT_INTRO);
    }
    // ===================================Result===================================
    public function showResult() : void {
        var pvpResultData:CPVPResultData = (system.getHandler(CPeakResultDataProvider) as CPeakResultDataProvider).getResultData();
        var instanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem)
        {
            (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).data = pvpResultData;
            (instanceSystem.getHandler(CMultiplePVPResultViewHandler) as CMultiplePVPResultViewHandler).addDisplay();
        }
    }

    public function showSettlementView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_RESULT, null, null, [peakGameData, playerData]);
    }
    // ===================================Reward===================================
    public function showRewardView(tag:int) : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_REWARD, [tag], null, [peakGameData, playerData]);
    }
    // ===================================Reward===================================
    public function showMatchView() : void {
        var playerData:CPlayerData = _playerData;
        var peakGameData:CPeakGameData = _peakGameData;
        show(EPeakGameWndType.WND_PEAK_MATCH, null, null, [peakGameData, playerData]);
    }

    public function hideMatchView() : void {
        hide(EPeakGameWndType.WND_PEAK_MATCH);
    }
    // ================================== common data ==================================
    [Inline]
    private function get _peakGameSystem() : CPeakGameSystem {
        return system as CPeakGameSystem;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }
    [Inline]
    private function get _peakGameData() : CPeakGameData {
        return _peakGameSystem.peakGameData;
    }
}
}
