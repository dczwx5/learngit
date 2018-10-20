//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/26.
 */
package kof.game.instance {

import kof.game.KOFSysTags;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.dataLog.CDataLog;
import kof.game.embattle.CEmbattleEvent;
import kof.game.embattle.CEmbattleSystem;
import kof.game.instance.mainInstance.control.CInstanceChapterListControl;
import kof.game.instance.mainInstance.control.CInstanceEliteControl;
import kof.game.instance.mainInstance.control.CInstanceEliteDetailControl;
import kof.game.instance.mainInstance.control.CInstanceEliteDetailResetLevelControl;
import kof.game.instance.mainInstance.control.CInstanceLoseControl;
import kof.game.instance.mainInstance.control.CInstanceOneKeyRewardControl;
import kof.game.instance.control.CInstancePvpWinControl;
import kof.game.instance.control.CInstanceReadyGoControl;
import kof.game.instance.control.CInstanceRoundStartControl;
import kof.game.instance.mainInstance.control.CInstanceScenarioControl;
import kof.game.instance.mainInstance.control.CInstanceScenarioDetailControl;
import kof.game.instance.mainInstance.control.CInstanceScenarioExtraDetailControl;
import kof.game.instance.mainInstance.control.CInstanceScenarioSweepControl;
import kof.game.instance.control.CInstanceTimeOverControl;
import kof.game.instance.mainInstance.control.CInstanceWinControl;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.data.CInstanceDataManager;
import kof.game.instance.mainInstance.data.CInstanceSweepRewardListData;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.view.CInstanceIntroLockTips;
import kof.game.instance.mainInstance.view.CInstanceIntroTips;
import kof.game.instance.mainInstance.view.CInstanceOneKeyRewardView;
import kof.game.instance.mainInstance.view.chapterEffect.CInstanceChapterMovieView;
import kof.game.instance.mainInstance.view.chapterList.CInstanceChapterListView;
import kof.game.instance.mainInstance.view.extraDetail.CInstanceScenarioExtraDetailView;
import kof.game.instance.view.CInstanceReadyGoView;
import kof.game.instance.view.CInstanceRoundStartView;
import kof.game.instance.view.CInstanceTimeOverView;
import kof.game.instance.mainInstance.view.chapterEffect.CInstanceChapterEffectView;
import kof.game.instance.mainInstance.view.instanceEliteDetailView.CInstanceEliteDetailView;
import kof.game.instance.mainInstance.view.result.CInstanceLoseView;
import kof.game.instance.view.instanceResult.CInstancePvpWinView;
import kof.game.instance.mainInstance.view.result.CInstanceWinView;
import kof.game.instance.mainInstance.view.instanceScenario.CInstanceScenarioView;
import kof.game.instance.mainInstance.view.instanceScenarioDetail.CInstanceScenarioDetailResetLevelView;
import kof.game.instance.mainInstance.view.instanceScenarioDetail.CInstanceScenarioDetailView;
import kof.game.instance.mainInstance.view.instanceSweep.CInstanceSweepView;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerSystem;
import kof.game.player.event.CPlayerEvent;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;

public class CInstanceUIHandler extends CViewManagerHandler {

    public function CInstanceUIHandler() {
    }
    public override function dispose() : void {
        super.dispose();
        (system as IInstanceFacade).unListenEvent(_onDataUpdate);
        var pPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        if (pPlayerSystem) {
            pPlayerSystem.removeEventListener(CPlayerEvent.PLAYER_LEVEL_UP, _onPlayerDataUpdate);
            pPlayerSystem.removeEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _onPlayerDataUpdate);
            pPlayerSystem.removeEventListener(CPlayerEvent.PLAYER_VIT, _onPlayerDataUpdate);
        }
    }

    override public function onEvtEnable() : void {
        super.onEvtEnable();
        var embattleSystem:CEmbattleSystem = (system.stage.getSystem(CEmbattleSystem) as CEmbattleSystem);
        if (embattleSystem) {
            if (evtEnable) {
                embattleSystem.addEventListener(CEmbattleEvent.EMBATTLE_SUCC, _onEmbattleChange);
            } else {
                embattleSystem.removeEventListener(CEmbattleEvent.EMBATTLE_SUCC, _onEmbattleChange);
            }
        }
    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();

        this.registTips(CInstanceIntroTips);
        this.registTips(CInstanceIntroLockTips);

        // 精英 & 剧情 -> 主界面, 2级界面
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_SCENARIO, CInstanceScenarioView, CInstanceScenarioControl);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL, CInstanceScenarioDetailView, CInstanceScenarioDetailControl);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_ELITE, CInstanceScenarioView, CInstanceEliteControl);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_ELITE_DETAIL, CInstanceEliteDetailView, CInstanceEliteDetailControl);

        // 精英 & 剧情 -> 其他界面
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_READY_GO, CInstanceReadyGoView, CInstanceReadyGoControl);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_ROUND_START, CInstanceRoundStartView, CInstanceRoundStartControl);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_TIME_OVER, CInstanceTimeOverView, CInstanceTimeOverControl);
        this.addViewClassHandler(EInstanceWndType.WND_SWEEP, CInstanceSweepView, CInstanceScenarioSweepControl);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_ELITE_ResetLevel, CInstanceScenarioDetailResetLevelView, CInstanceEliteDetailResetLevelControl);

        // 结果表现
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_RESULT_WIN, CInstanceWinView, CInstanceWinControl); // pve
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_RESULT_LOSE, CInstanceLoseView, CInstanceLoseControl);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_RESULT_PVP_WIN, CInstancePvpWinView, CInstancePvpWinControl);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_ONE_KEY_REWARD, CInstanceOneKeyRewardView, CInstanceOneKeyRewardControl);// 一键领取界面

        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_CHAPTER_FINISH_EFFECT, CInstanceChapterEffectView);
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_FIRST_PASS_MOVIE, CInstanceChapterMovieView);

        //
        this.addViewClassHandler(EInstanceWndType.WND_INSTANCE_EXTRA_DETAIL, CInstanceScenarioExtraDetailView, CInstanceScenarioExtraDetailControl);

        this.addViewClassHandler(EInstanceWndType.WND_CHAPTER_LIST, CInstanceChapterListView, CInstanceChapterListControl);

        //
//        this.registerBundle(EInstanceWndType.WND_INSTANCE_SCENARIO, KOFSysTags.INSTANCE, showScenarioWindow, hideScenarioWindow);
//        this.registerBundle(EInstanceWndType.WND_INSTANCE_ELITE, KOFSysTags.ELITE, showEliteWindow, hideEliteWindow);
        this.addBundleData(EInstanceWndType.WND_INSTANCE_SCENARIO, KOFSysTags.INSTANCE);
        this.addBundleData(EInstanceWndType.WND_INSTANCE_ELITE, KOFSysTags.ELITE);

        (system as IInstanceFacade).listenEvent(_onDataUpdate);

        // lv currency 体力
        var pPlayerSystem:CPlayerSystem = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem);
        pPlayerSystem.addEventListener(CPlayerEvent.PLAYER_LEVEL_UP, _onPlayerDataUpdate);
        pPlayerSystem.addEventListener(CPlayerEvent.PLAYER_ORIGIN_CURRENCY, _onPlayerDataUpdate);
        pPlayerSystem.addEventListener(CPlayerEvent.PLAYER_VIT, _onPlayerDataUpdate);

        return ret;
    }


    // ====================show view========================================
    public function showOneKeyRewardView(data:CInstanceDataCollection) : void {
        show(EInstanceWndType.WND_INSTANCE_ONE_KEY_REWARD, null, null, data);
    }
    public function showEliteResetLevelView(instanceData:CChapterInstanceData) : void {
        show(EInstanceWndType.WND_INSTANCE_ELITE_ResetLevel, null, null, instanceData);
    }

    public function showReadyGoView() : void {
        show(EInstanceWndType.WND_INSTANCE_READY_GO, null, null, null);
    }

    public function showRoundStartView( data:Object ) : void {
        show(EInstanceWndType.WND_INSTANCE_ROUND_START,null,null,data);
    }

    public function showTimeOverView() : void {
        show(EInstanceWndType.WND_INSTANCE_TIME_OVER,null,null);
    }

    public function showScenarioWindow(chapterIndex:int = -1) : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        data.instanceDataManager = dataManager;
        data.instanceType = EInstanceType.TYPE_MAIN;
        show(EInstanceWndType.WND_INSTANCE_SCENARIO, [chapterIndex], null, data);
    }
    public function hideScenarioWindow() : void {
        _hideWindow(EInstanceWndType.WND_INSTANCE_SCENARIO);
    }
    private function _hideWindow(type:int) : void {
        hide(type);
    }


    public function showScenarioDetailWindow(instanceData:CChapterInstanceData) : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        data.instanceDataManager = dataManager;
        data.curInstanceData = instanceData;
        data.instanceType = EInstanceType.TYPE_MAIN;
        show(EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL, null, null, data);
    }

    public function showScenarioExtraDetailWindow(instanceData:CChapterInstanceData) : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        data.instanceDataManager = dataManager;
        data.curInstanceData = instanceData;
        data.instanceType = EInstanceType.TYPE_MAIN_EXTRA;
        show(EInstanceWndType.WND_INSTANCE_EXTRA_DETAIL, null, null, data);
    }
    public function hideScenarioExtraDetailWindow() : void {
        hide(EInstanceWndType.WND_INSTANCE_EXTRA_DETAIL);
    }
    public function hideScenarioDetailWindow() : void {
        hide(EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL);
    }

    public function showEliteWindow(chapterIndex:int = -1) : void {
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        data.instanceDataManager = dataManager;
        data.instanceType = EInstanceType.TYPE_ELITE;

        show(EInstanceWndType.WND_INSTANCE_ELITE, [chapterIndex], null, data);
    }
    public function hideEliteWindow() : void {
        hide(EInstanceWndType.WND_INSTANCE_ELITE);
    }
    public function showEliteDetailWindow(instanceData:CChapterInstanceData) : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        data.instanceDataManager = dataManager;
        data.curInstanceData = instanceData;
        data.instanceType = EInstanceType.TYPE_ELITE;
        show(EInstanceWndType.WND_INSTANCE_ELITE_DETAIL, null, null, data);
    }
    public function updateEliteDetailWindow(instanceData:CChapterInstanceData) : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        data.instanceDataManager = dataManager;
        data.curInstanceData = instanceData;
        data.instanceType = EInstanceType.TYPE_ELITE;
        getWindow(EInstanceWndType.WND_INSTANCE_ELITE_DETAIL).setData(data);
    }
    public function showSweepView(instanceData:CChapterInstanceData, count:int) : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var rewardList:CInstanceSweepRewardListData = dataManager.instanceData.lastSweepData;
        show(EInstanceWndType.WND_SWEEP, [instanceData, count], null, rewardList);
    }
    public function updateSweepView() : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var rewardList:CInstanceSweepRewardListData = dataManager.instanceData.lastSweepData;
        getWindow(EInstanceWndType.WND_SWEEP).setData(rewardList);
    }

    public function showResultWinView(callback:Function = null) : void {
        CDataLog.logInstanceResultLoadingBefore(system, (system as CInstanceSystem).instanceData, (system as CInstanceSystem).instanceContent);

        var instanceContentID:int = (system as CInstanceSystem).instanceContentID;

        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var data:CInstanceDataCollection = new CInstanceDataCollection();
        data.instanceDataManager = dataManager;
        var instanceData:CChapterInstanceData = dataManager.instanceData.instanceList.getByID(instanceContentID);
        data.curInstanceData = instanceData;
        // data.instanceType = EInstanceType.TYPE_MAIN;
        show(EInstanceWndType.WND_INSTANCE_RESULT_WIN, null, callback, data);
    }

    public function hideResultWinView() : void {
        hide(EInstanceWndType.WND_INSTANCE_RESULT_WIN);
    }
    public function showResultLoseView() : void {
        show(EInstanceWndType.WND_INSTANCE_RESULT_LOSE, null, null, null);
    }
    public function hideResultLoseView() : void {
        hide(EInstanceWndType.WND_INSTANCE_RESULT_LOSE);
    }
    public function showResultPvpWinView(data:Object) : void {
        show(EInstanceWndType.WND_INSTANCE_RESULT_PVP_WIN, null, null, data);
    }
    public function hideResultPvpWinView() : void {
        hide(EInstanceWndType.WND_INSTANCE_RESULT_PVP_WIN);
    }

    // isFinishNotOpen : true ：章节完成
    // isFinishNotOpen : false : 章节开启
    public function showChapterEffectView(isFinishNotOpen:Boolean) : void {
        show(EInstanceWndType.WND_INSTANCE_CHAPTER_FINISH_EFFECT, [isFinishNotOpen], null, null);
    }
    public function hideChapterEffectView() : void {
        hide(EInstanceWndType.WND_INSTANCE_CHAPTER_FINISH_EFFECT);
    }

    public function showChapterMovieView(pInstanceData:CChapterInstanceData) : void {
        show(EInstanceWndType.WND_INSTANCE_FIRST_PASS_MOVIE, null, null, [pInstanceData]);
    }
    public function hideChapterMovieView() : void {
        hide(EInstanceWndType.WND_INSTANCE_FIRST_PASS_MOVIE);
    }

    public function showChapterListView() : void {
        var rootView:CViewBase = getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO);
        if (!rootView) {
            rootView = getWindow(EInstanceWndType.WND_INSTANCE_ELITE);
        }

        var data:CInstanceDataCollection = rootView.getData() as  CInstanceDataCollection;
        show(EInstanceWndType.WND_CHAPTER_LIST, null, null, data);
    }
    public function hideChapterListView() : void {
        hide(EInstanceWndType.WND_CHAPTER_LIST);

    }

    // ===================================data update========================================================
    private function _onEmbattleChange(e:CEmbattleEvent) : void {
        switch (e.type) {
            case CEmbattleEvent.EMBATTLE_SUCC :
                _updateScenarioWnd();
                _updateEliteWnd();
                _onUpdateLevelItem();
                break;
        }
    }
    private function _onPlayerDataUpdate(e:CPlayerEvent) : void {
        _playerDataUpdate();
    }
    private function _onDataUpdate(e:CInstanceEvent) : void {
        switch (e.type) {
            case CInstanceEvent.INSTANCE_DATA:
                _instanceDataUpdate();
                break;
            case CInstanceEvent.INSTANCE_SWEEP_DATA:
                _sweepData(e);
                break;
            case CInstanceEvent.CHAPTER_REWARD:
                _chapterReward(e);
                break;
            case CInstanceEvent.INSTANCE_PASS_REWARD:
                _instancePassReward(e);
                break;
            case CInstanceEvent.INSTANCE_GET_ONE_KEY_REWARD :
                _getOneKeyReward(e);
                break;
            case CInstanceEvent.INSTANCE_MODIFY:
                _instanceModify(e);
                break;
            case CInstanceEvent.INSTANCE_BUY_COUNT:
                _instanceBuyCount(e);
                break;
            case CInstanceEvent.INSTANCE_GET_EXTENDS_REWARD:
                _instanceGetExtendsReward(e);
                break;
            case CInstanceEvent.WINACTOR_END :
//                var data:Object = e.data;
//                showResultPvpWinView(data);
                break;
            case CInstanceEvent.INSTANCE_FIRST_PASS :
                    // 副本首次通关
                    var pInstanceData:CChapterInstanceData = e.data as CChapterInstanceData;
                    if (pInstanceData && pInstanceData.firstPassMovieUrl && pInstanceData.firstPassMovieUrl.length > 0) {
                        (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).addEventPopWindow( EPopWindow.POP_WINDOW_15, function():void{
                            showChapterMovieView(pInstanceData);
                        });
                    }
                break;
            case CInstanceEvent.INSTANCE_CHAPTER_FINISH :
                (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).addEventPopWindow( EPopWindow.POP_WINDOW_4, function():void{
                    showChapterEffectView(true);
                });
                 break;
            case CInstanceEvent.INSTANCE_CHAPTER_OPEN :
                (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).addEventPopWindow( EPopWindow.POP_WINDOW_4, function():void{
                    showChapterEffectView(false);
                });
                break;
        }
    }

    private function _playerDataUpdate() : void {
        _updateScenarioWnd();
        _updateEliteWnd();
    }
    private function _instanceDataUpdate() : void {
        _invalidateEliteDetailWnd();
        _invalidateScenarioDetailWnd();
    }
    private function _sweepData(e:CInstanceEvent) : void {
        _showSweepViewData(e);
    }
    private function _chapterReward(e:CInstanceEvent) : void {
        _showChapterStarRewardViewData();
        _playerDataUpdate();
    }
    private function _instancePassReward(e:CInstanceEvent) : void {

    }
    private function _getOneKeyReward(e:CInstanceEvent) : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var rewardData:CRewardListData = dataManager.instanceData.lastOneKeyReward.getRewardListFull();
        if (!rewardData) return ;

        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardData);

    }
    private function _instanceModify(e:CInstanceEvent) : void {
        _invalidateEliteDetailWnd();
        _invalidateScenarioDetailWnd();
    }
    private function _instanceBuyCount(e:CInstanceEvent) : void {

    }
    private function _instanceGetExtendsReward(e:CInstanceEvent) : void {
//        _invalidateScenarioDetailWnd();
        _showExtendsRewardViewByData();
    }

    private function _invalidateEliteDetailWnd() : void {
        var view:CViewBase = getWindow(EInstanceWndType.WND_INSTANCE_ELITE_DETAIL);
        if (view) {
            view.invalidate();
        }
    }
    private function _invalidateScenarioDetailWnd() : void {
        var view:CViewBase = getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL);
        if (view) {
            view.invalidate();
        }
    }
    private function _updateScenarioWnd() : void {
        var view:CViewBase = getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO);
        if (view) {
            view.invalidate();
        }
        view = getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL);
        if (view) {
            view.invalidate();
        }
    }
    private function _updateEliteWnd() : void {
        var view:CViewBase = getWindow(EInstanceWndType.WND_INSTANCE_ELITE);
        if (view) {
            view.invalidate();
        }
        view = getWindow(EInstanceWndType.WND_INSTANCE_ELITE_DETAIL);
        if (view) {
            view.invalidate();
        }
    }
    private function _showSweepViewData(e:CInstanceEvent) : void {
        if (getWindow(EInstanceWndType.WND_SWEEP)) {
            updateSweepView();
        }
    }

    private function _showChapterStarRewardViewData() : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var rewardData:CRewardListData = dataManager.instanceData.lastChapterReward;
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardData);
    }
    private function _showExtendsRewardViewByData() : void {
        var dataManager:CInstanceDataManager = (system as CInstanceSystem).instanceManager.dataManager;
        var rewardData:CRewardListData = dataManager.instanceData.lastInstanceExtendsReward.rewardList;
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardData);
    }
    private function _onUpdateLevelItem() : void {
        var view:CInstanceScenarioView = getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO)as CInstanceScenarioView;
        if (view && view.isShowState && view._levelListView) {
            view._levelListView.invalidate();
        }
        view = getWindow(EInstanceWndType.WND_INSTANCE_ELITE)as CInstanceScenarioView;
        if (view && view.isShowState && view._levelListView) {
            view._levelListView.invalidate();
        }
    }
}
}
