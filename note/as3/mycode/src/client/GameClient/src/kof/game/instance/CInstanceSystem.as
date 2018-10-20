//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/6.
 */
package kof.game.instance {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;
import QFLib.Utils.CFlashVersion;

import flash.events.Event;
import flash.events.IEventDispatcher;

import kof.SYSTEM_ID;
import kof.data.CPreloadData;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CDelayCall;
import kof.game.common.CTest;
import kof.game.common.status.CGameStatus;
import kof.game.common.system.CAppSystemImp;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.common.view.CViewBase;
import kof.game.common.view.bundle.CViewBundleComponent;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.dataLog.CDataLog;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.line.CInstanceLineEnter;
import kof.game.instance.line.CInstanceLineNetEventProcess;
import kof.game.instance.mainInstance.CInstanceRedPoint;
import kof.game.instance.mainInstance.CMainInstanceHandler;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.level.CLevelSystem;
import kof.game.level.event.CLevelEvent;
import kof.game.lobby.CLobbySystem;
import kof.game.scenario.CScenarioSystem;
import kof.game.scene.CSceneSystem;
import kof.message.Instance.InstanceOverResponse;
import kof.message.Level.EnterLevelResponse;
import kof.table.Exit;
import kof.table.InstanceContent;
import kof.table.NumericTemplate;
import kof.ui.IUICanvas;

import morn.core.handlers.Handler;

public class CInstanceSystem extends CAppSystemImp implements IInstanceFacade, IUpdatable {
    public function CInstanceSystem() {
    }
    public override function dispose() : void {
        super.dispose();

        _eliteBundleComponent.dispose();
        _eliteBundleComponent = null;
    }

    // =============bundle==================
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.INSTANCE);
    }

    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);

        var pLobbySystem:CLobbySystem = stage.getSystem(CLobbySystem) as CLobbySystem;
        if (isActived) {
            if (CGameStatus.checkStatus(this) == false) {
                setActived(false);
            } else {
                pLobbySystem.forceHide = true;
                pLobbySystem.slideIn();
                _showInstanceB();
            }
        } else {

            var view:CViewBase = _uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO);
            if (view && view.isShowState) {
                _uiHandler.hideScenarioWindow();
                pLobbySystem.forceHide = false;
                pLobbySystem.slideOut();
                _hideInstaneB();
            }
        }
    }
    private function _showInstanceB() : void {
        var chapterIndex:int = this.tab;
        _uiHandler.showScenarioWindow(chapterIndex);
        this.tab = -1;
        closeAllSystemBundle([SYSTEM_ID(KOFSysTags.INSTANCE),SYSTEM_ID(KOFSysTags.SYSTEM_NOTICE)]);
    }
    private function _hideInstaneB() : void {

    }

    override protected function onBundleStart(ctx:ISystemBundleContext):void {
        super.onBundleStart(ctx);
        _redPoint.refresh();
    }

    // =============elite bundle==================
    public function setEliteTab(v:int) : void {
        if (_eliteBundleComponent) {
            _eliteBundleComponent.tab = v;
        }
    }
    protected function _onEliteActived(a_bActivated:Boolean) : void {
        var pLobbySystem:CLobbySystem = stage.getSystem(CLobbySystem) as CLobbySystem;
        if (a_bActivated) {
            if (CGameStatus.checkStatus(this) == false) {
                setActived(false);
            } else {
                pLobbySystem.forceHide = true;
                pLobbySystem.slideIn();
                _showEliteB();
            }
        } else {
            var view:CViewBase = _uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_ELITE);
            if (view && view.isShowState) {
                _uiHandler.hideEliteWindow();
                pLobbySystem.forceHide = false;
                pLobbySystem.slideOut();
                _hideEliteB();

            }
        }
    }
    private function _showEliteB() : void {
        var chapterIndex:int = _eliteBundleComponent.tab;
        _uiHandler.showEliteWindow(chapterIndex);
        _eliteBundleComponent.tab = -1;

        closeAllSystemBundle([SYSTEM_ID(KOFSysTags.ELITE),SYSTEM_ID(KOFSysTags.SYSTEM_NOTICE)]);
    }
    private function _hideEliteB() : void {

    }
    protected function _onEliteBundleStarted() : void {
        _redPoint.refresh();
    }

        public function get eliteBundle() : ISystemBundle {
        return _eliteBundleComponent;
    }
    public function setEliteActived(v:Boolean) : void {
        _eliteBundleComponent.isActived = v;
    }
    // =============elite bundle==================

    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();


        ret = ret && this.addBean(_redPoint = new CInstanceRedPoint());
        _redPoint.processNotify();

        ret = ret && this.addBean(_instanceManager = new CInstanceManager());

        ret = ret && this.addBean(_uiHandler = new CInstanceUIHandler());

        ret = ret && this.addBean(_handler = new CInstanceHandler());
        ret = ret && this.addBean(_mainNetHandler = new CMainInstanceHandler());

        ret = ret && this.addBean(_exitProcess = new CInstanceExitProcess());

        ret = ret && this.addBean(new CInstanceLineNetEventProcess());
        ret = ret && this.addBean(new CInstanceLineEnter());
        ret = ret && this.addBean(_otherUtil = new CInstanceOtherUtil(this));
        ret = ret && this.addBean(_levelEventProcess = new CInstanceLevelEventProcess());
        ret = ret && this.addBean(_autoFightHandler = new CInstanceAutoFightHandler());
        ret = ret && this.addBean(new CMultiplePVPResultViewHandler());

        ret = ret && this.addBean(new CInstanceLoadResInPreludeHandler());

        ret = ret && this.addBean(_allOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_ALL,
                        new Handler(_onFinishHandler), new Handler(_onAssertHandler), new Handler(_onOverHandler)));
        _allOverHandler.listenEvent();

        _eliteBundleComponent = new CViewBundleComponent();
        _eliteBundleComponent.bundleContext = ctx;
        _eliteBundleComponent.bundleID = SYSTEM_ID(KOFSysTags.ELITE);
        _eliteBundleComponent.activeHandler = _onEliteActived;
        _eliteBundleComponent.startHandler = _onEliteBundleStarted;

        _eliteBundleComponent.create();

        this.registerEventType(CInstanceEvent.ENTER_INSTANCE);
        this.registerEventType(CInstanceEvent.LEVEL_ENTERED);
        this.registerEventType(CInstanceEvent.SCENARIO_START);
		this.registerEventType(CInstanceEvent.SCENARIO_END);
        this.registerEventType(CInstanceEvent.LEVEL_STARTED);
        this.registerEventType(CInstanceEvent.EXIT_INSTANCE);
        this.registerEventType(CInstanceEvent.INSTANCE_DATA);
        this.registerEventType(CInstanceEvent.INSTANCE_SWEEP_DATA);
        this.registerEventType(CInstanceEvent.CHAPTER_REWARD);
        this.registerEventType(CInstanceEvent.INSTANCE_PASS_REWARD);
        this.registerEventType(CInstanceEvent.INSTANCE_GET_ONE_KEY_REWARD);
        this.registerEventType(CInstanceEvent.INSTANCE_MODIFY);
        this.registerEventType(CInstanceEvent.INSTANCE_BUY_COUNT);
        this.registerEventType(CInstanceEvent.INSTANCE_GET_EXTENDS_REWARD);
        this.registerEventType(CInstanceEvent.END_INSTANCE);
        this.registerEventType(CInstanceEvent.INSTANCE_UPDATE_TIME);
        this.registerEventType(CInstanceEvent.LEVEL_ENTER);
        this.registerEventType(CInstanceEvent.WINACTOR_END);
        this.registerEventType(CInstanceEvent.WINACTOR_STRAT);
        this.registerEventType(CInstanceEvent.INSTANCE_CHAPTER_FINISH);
        this.registerEventType(CInstanceEvent.INSTANCE_FIRST_PASS);
        this.registerEventType(CInstanceEvent.INSTANCE_CHAPTER_OPEN);


        // net event - line process
        this.registerEventType(CInstanceEvent.NET_EVENT_INSTANCE_ENTER);
        this.registerEventType(CInstanceEvent.NET_EVENT_LEVEL_ENTER);
        this.registerEventType(CInstanceEvent.NET_EVENT_LEVEL_ENTERED);
        this.registerEventType(CInstanceEvent.NET_EVENT_LEVEL_START);
        this.registerEventType(CInstanceEvent.NET_EVENT_LEVEL_PORTAL_START);
        this.registerEventType(CInstanceEvent.NET_EVENT_UPDATE_TIME);
        this.registerEventType(CInstanceEvent.NET_EVENT_INSTANCE_OVER);
        this.registerEventType(CInstanceEvent.NET_EVENT_STOP_INSTANCE);


        addEventListener(CInstanceEvent.INSTANCE_PASS_REWARD, _onResult);


        var pScenarioSystem:CScenarioSystem = stage.getSystem(CScenarioSystem) as CScenarioSystem;
        if (pScenarioSystem) {
            pScenarioSystem.aiEnableHandler = setAiEnable;
            pScenarioSystem.playEnableHandler = setPlayEnable;
            _pScenarioSystem = pScenarioSystem;
        } else {
            Foundation.Log.logErrorMsg("InstanceSystem initialize : pScenarioSystem is NULL");
        }

        var pLevelSystem:CLevelSystem = stage.getSystem(CLevelSystem) as CLevelSystem;
        if (pLevelSystem) {
            pLevelSystem.aiEnableHandler = setAiEnable;
            pLevelSystem.playEnableHandler = setPlayEnable;
            pLevelSystem.skillViewHandler = setSkillViewEnable;
            _pLevelSystem = pLevelSystem;
        } else {
            Foundation.Log.logErrorMsg("InstanceSystem initialize : pLevelSystem is NULL");
        }
        return ret;
    }

    public function update(delta:Number) : void {
        if (_instanceManager) {
            _instanceManager.update(delta);
        }
        if (_autoFightHandler && _autoFightHandler.enable && _isStart && !_isEnd) {
            if (isPlayingScenario() == false && isPlayingWinAnimation() == false) {
                _autoFightHandler.update(delta);
            }
        }
    }

    //======================== C->S ========================
    public function enterInstance(instanceID:int) : void {
        _instanceManager.onLeaveLevel(); // 没有可以退出关卡的地方, 在进入副本时, 清除数据
        _instanceManager.saveInstanceState(instanceID); // 保持副本的一些状态, 比如打之前是否已经通关
        _handler.sendEnterInstance(instanceID);
    }
    public function exitInstance() : void {
        // 剧情播放之前, 点退出, 卡黑幕
        // 退出副本的操作在进入副本做
        _handler.sendExitInstance(true);
    }

    // 中途退出副本
    public function stopInstance() : void {
        pauseInstance();
        addEventListener(CInstanceEvent.STOP_INSTANCE, _onStopInstanceResult);
        netHandler.stopInstance();
    }
    private function _onStopInstanceResult(e:CInstanceEvent) : void {
        var isSucess:Boolean = e.data as Boolean;
        if (!isSucess) {
            // 退出失败, 恢复暂停
            continueInstance();
        }
        removeEventListener(CInstanceEvent.STOP_INSTANCE, _onStopInstanceResult);
    }

    // =======================s -> c============================
    private var _unCloseSystemData:CInstanceUnCloseSystemData; // 不需要关闭的系统
    public function setUnCloseSystemData(sysTag:String, instanceType:int) : void {
        _unCloseSystemData = new CInstanceUnCloseSystemData(sysTag, instanceType);
    }
    public function onEnterInstance(instanceContentID:int) : void {
        trace("进入副本");
        isStart = false;
        isEnd = false;
        isEndByStop = false;

        instanceManager.onEnterInstance(instanceContentID);

        var exceptList:Array = [SYSTEM_ID(KOFSysTags.SYSTEM_NOTICE)];
        if (_unCloseSystemData && instanceType == _unCloseSystemData.instanceType && _unCloseSystemData.sysTag && _unCloseSystemData.sysTag.length > 0) {
            exceptList[exceptList.length] = SYSTEM_ID(_unCloseSystemData.sysTag);
        }
        closeAllSystemBundle(exceptList);

        _unCloseSystemData = null;


        _levelEventProcess.listenEvent();
        _recordAIState = otherUtil.aiState();

        CGameStatus.resetStatus();
        if (isMainCity || isPractice) {
            CGameStatus.unSetStatus(CGameStatus.Status_InInstance);
            enableFxPoolUpdate( true );
        } else {
            CGameStatus.setStatus(CGameStatus.Status_InInstance);
            enableFxPoolUpdate( false );
        }

        CDataLog.logInstanceLoadingBefore(this, instanceData, instanceContent);
        CDataLog.logMainCityLoadingBefore(this, instanceData, instanceContent);

        var event:CInstanceEvent = new CInstanceEvent(CInstanceEvent.ENTER_INSTANCE, instanceContentID);
        CTest.log("ENTER_INSTANCE instanceContentID : " + instanceContentID);
        dispatchEvent(event);


//        var sceneSystem:CSceneSystem = stage.getSystem(CSceneSystem) as CSceneSystem;
//        sceneSystem.initialHeroShowList();
    }
    public function onEnterLevel(response:EnterLevelResponse) : void {
        uiHandler.uiCanvas.hideHoldingMaskView(); // 关掉之前剧情结束时打开的黑幕, 没有退出关卡的接口, 所以在进入关卡时处理
        instanceManager.onEnterLevel(response);
    }
    // 关卡真正开始, 可以控制
    public function onLevelStart() : void {
        CTest.log("副本-关卡开始");
        isStart = true;

        dispatchEvent(new CInstanceEvent(CInstanceEvent.LEVEL_STARTED, null, null));
        var sceneSystem:CSceneSystem = stage.getSystem(CSceneSystem) as CSceneSystem;
        sceneSystem.initialHeroShowList();
        _levelSystem.onLevelStarted();
        _levelSystem.play();

        sceneSystem.pCamera.unZoom(true);

        setPlayEnable(true);

        if (!CFlashVersion.isPlayerVersionPriorTo(11, 8)) {
            if (isMainCity) {
                sceneSystem.scenegraph.persistCurrentScene(); // Submit to persist scene for MainCity.
            }
        }
    }
    public function onExitInstance() : void {
        trace("退出副本");

        var ui:IUICanvas = stage.getSystem(IUICanvas) as IUICanvas;
        if (ui) {
            ui.showSceneLoading();
        }

        _levelEventProcess.unListenEvent();
        if (_levelSystem) {
            _levelSystem.dispatchEvent(new CLevelEvent(CLevelEvent.INSTANCE_EXIT, null));
        }

        otherUtil.resetAIState(_recordAIState);
        setPlayEnable( true );

        dispatchEvent(new CInstanceEvent(CInstanceEvent.EXIT_INSTANCE, null));

        instanceManager.onInstanceFinal();
    }

    // ========================================结算-退出==============================================
    private function _onResult(e:Event) : void {
        instanceData.lastInstancePassReward.isServerData = true;

        if (EInstanceType.isPrelude(_instanceManager.instanceContentRecord.ID) || EInstanceType.isScenario(_instanceManager.instanceContentRecord.Type)) {
            _allOverHandler.instanceOverEventProcess(null);
        } else if (EInstanceType.isElite(_instanceManager.instanceContentRecord.Type)) {
            _allOverHandler.instanceOverEventProcess(null);
        }
    }
    private function _onFinishHandler() : void {
        var uiHandler : CInstanceUIHandler;

        if (EInstanceType.isPrelude(_instanceManager.instanceContentRecord.ID)) {
            // 序章要在剧情副本前面判断
            exitInstance();
//            uiHandler = getBean(CInstanceUIHandler) as CInstanceUIHandler;
//            uiHandler.uiCanvas.hideHoldingMaskView(); // 关掉之前剧情结束时打开的黑幕, 正常是在进入新关卡时关闭, 但是如果最后一个阶段剧情完了，不回关卡再弹结算, 结算会被黑幕挡住
        } else if ((_instanceManager.instanceContentRecord.Type == EInstanceType.TYPE_MAIN || _instanceManager.instanceContentRecord.Type == EInstanceType.TYPE_MAIN_EXTRA) || EInstanceType.isElite(_instanceManager.instanceContentRecord.Type)) {
            uiHandler = getBean(CInstanceUIHandler) as CInstanceUIHandler;
            if (null == uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_RESULT_WIN)){
                uiHandler.showResultWinView(function (view:CViewBase) : void {
                    uiHandler.uiCanvas.hideHoldingMaskView(); // 关掉之前剧情结束时打开的黑幕, 正常是在进入新关卡时关闭, 但是如果最后一个阶段剧情完了，不回关卡再弹结算, 结算会被黑幕挡住
                });
            } else {
                CTest.log("--------------------------------------找到导致黑幕一直存在, 可以按空格的原因了, 人物未停止之前, 结算界面先弹出来了"); // 目前测试, 使用通过副本时。会进入这里
                uiHandler.uiCanvas.hideHoldingMaskView(); // 关掉之前剧情结束时打开的黑幕, 正常是在进入新关卡时关闭, 但是如果最后一个阶段剧情完了，不回关卡再弹结算, 结算会被黑幕挡住

            }
        } else {
            uiHandler = getBean(CInstanceUIHandler) as CInstanceUIHandler;
            uiHandler.uiCanvas.hideHoldingMaskView();
        }
    }
    private function _onAssertHandler() : void {
        var uiHandler : CInstanceUIHandler;
        uiHandler = getBean(CInstanceUIHandler) as CInstanceUIHandler;
        uiHandler.uiCanvas.hideHoldingMaskView(); // 关掉之前剧情结束时打开的黑幕, 正常是在进入新关卡时关闭, 但是如果最后一个阶段剧情完了，不回关卡再弹结算, 结算会被黑幕挡住

    }
    /**
     * instanceOver处理
     */
    private function _onOverHandler(e:CInstanceEvent) : void {
        trace("副本结束");
        isEnd = true;
        _levelSystem.pause();
        var isWin:Boolean;
        var response:InstanceOverResponse = e.data as InstanceOverResponse;
        if (response.fightResult == 1) {
            isWin = true;
            dispatchEvent(new CInstanceEvent(CInstanceEvent.END_INSTANCE, isWin, null));
            dispatchEvent(new CInstanceEvent(CInstanceEvent.WIN, response.fightResult));
        } else if (response.fightResult == 0){
            isWin = false;
            dispatchEvent(new CInstanceEvent(CInstanceEvent.END_INSTANCE, isWin, null));

            if (EInstanceType.isScenario(_instanceManager.instanceContentRecord.Type) || EInstanceType.isElite(_instanceManager.instanceContentRecord.Type)) {
                new CDelayCall(function () : void {
                    var uiHandler : CInstanceUIHandler = getBean(CInstanceUIHandler) as CInstanceUIHandler;
                    uiHandler.showResultLoseView();
                }, 3);
            }
            dispatchEvent(new CInstanceEvent(CInstanceEvent.LOSE, response.fightResult));
        } else {
            isWin = false;
            dispatchEvent(new CInstanceEvent(CInstanceEvent.END_INSTANCE, isWin, null));
            dispatchEvent(new CInstanceEvent(CInstanceEvent.ASSERT, response.fightResult));
        }
    }
    // ========================================结算-退出==============================================

    // win show
    public function showLoseView() : void {
        _uiHandler.showResultLoseView();
    }

    public function startWaitAllGameObjectFinish() : void {
        if (instanceManager) {
            instanceManager.startWaitAllGameObjectFinish();
        }
    }

    // 只有再次进入主城才会调用
    public function addExitProcess(flagClz:Class, flagName:String, func:Function, param:Array, priority:int) : void {
        _exitProcess.addProcess(flagClz, flagName, func, param, priority);
    }
    public function removeExitProcess(flagClz:Class, flagName:String) : void {
        _exitProcess.removeProcess(flagClz, flagName);
    }

    protected function enableFxPoolUpdate( bEnabled : Boolean ) : void {
        var pSceneSystem : CSceneSystem = stage.getSystem( CSceneSystem ) as CSceneSystem;
        if ( pSceneSystem ) {
            pSceneSystem.scenegraph.graphicsFramework.fxPoolUpdateSwitchOn = bEnabled;
        }
    }

    // 只要是在主城就会调用
    // flag : CInstanceExitProcess.FLAG_XX
    // * @param priority 值越大, 优先级越小
    // callWhenInMainCity(func, null, null, null, 1);
    public function callWhenInMainCity(callback:Function, args:Array, flagClazz:Class, flagName:String, priority:int) : void {
        var processInInstance:Function = function () : void {
            if (isMainCity == false) {
                // 不在主城
                addExitProcess(flagClazz, flagName, callback, args, priority);
            } else {
                // 在主城
                callback.apply(null, args);
            }
        };
        var onInstanceEvent:Function = function (e:CInstanceEvent) : void {
            removeEventListener(CInstanceEvent.ENTER_INSTANCE, onInstanceEvent);
            processInInstance();
        };
        if (isInInstance) {
            processInInstance();
        } else {
            // 未进入副本
            addEventListener(CInstanceEvent.ENTER_INSTANCE, onInstanceEvent); // 不能用listereEvent, 这时个instance还没setup
        }
    }

    public function isScenarioDetailViewShow() : Boolean {
        var view:CViewBase = uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO_DETAIL);
        return view != null;
    }

    public function isScenarioSweepViewShow() : Boolean {
        var view:CViewBase = uiHandler.getWindow(EInstanceWndType.WND_SWEEP);
        return view != null;
    }

    public function levelTimeOut():void{
        if(EInstanceType.isPeakGame(instanceType) || EInstanceType.isPeakPK(instanceType)){
            uiHandler.showTimeOverView();
        }
    }

    // ===========================get/set=============================

    public function get isMainCity() : Boolean { return _instanceManager.isMainCity; }
    public function get isPractice() : Boolean{ return _instanceManager.isPractice;}
    public function get isTeaching() : Boolean{ return _instanceManager.isTeaching;}
    public function get isPVE() : Boolean{ return _instanceManager.isPVE; }
    public function get canQE() : Boolean{ return _instanceManager.canQE; }
    public function get  isArena() : Boolean{ return _instanceManager.isArena; }
    public function get isGuildWar() : Boolean{ return _instanceManager.isGuildWar; }
    public function get currentIsPrelude() : Boolean { return _instanceManager.isPrelude; }
    public function isPrelude(instanceID:int) : Boolean { return EInstanceType.isPrelude(instanceID); }

    public function get otherUtil() : CInstanceOtherUtil { return _otherUtil; }
    private function get _levelSystem() : CLevelSystem {
        if (!_pLevelSystem) {
            _pLevelSystem = stage.getSystem(CLevelSystem) as CLevelSystem;
        }
        return _pLevelSystem;
    }
    private function get _scenarioSystem() : CScenarioSystem {
        if (!_pScenarioSystem) {
            _pScenarioSystem = stage.getSystem(CScenarioSystem) as CScenarioSystem;
        }
        return _pScenarioSystem;
    }
    public function get instanceManager() : CInstanceManager { return _instanceManager; }
    public function get eventDelegate() : IEventDispatcher { return this;  }
    public function get instanceContentID() : int { return _instanceManager.instanceContentID; }
    public function get uiHandler() : CInstanceUIHandler { return _uiHandler; }
    public function get netHandler() : CInstanceHandler { return _handler; }
    public function get mainNetHandler() : CMainInstanceHandler { return _mainNetHandler; }

    public function get instanceType() : int {
        if (_instanceManager && _instanceManager.instanceContentRecord)
            return _instanceManager.instanceContentRecord.Type;
        return 0;
    }
    public function getNumericTemplate(monsterType:int, monsterProfession:int) : NumericTemplate {
        if (_instanceManager && _instanceManager.instanceContentRecord)
            return _instanceManager.getNumericTemplate(monsterType, monsterProfession);
        return null;
    }

    public function get rageRestoreComboInterval() : int {
        return _instanceManager.rageRestoreComboInterval;
    }

    public function get instanceContent() : InstanceContent {
        if (_instanceManager)
            return _instanceManager.instanceContentRecord;
        return null;
    }
    public function get isInInstance() : Boolean {
        return instanceContent != null;
    }
    public function get instanceData() : CInstanceData {
        if (_instanceManager) {
            return _instanceManager.dataManager.instanceData;
        }
        return null;
    }

    // 副本是否通关
    public function isInstancePass(instanceID:int) : Boolean {
        if (_instanceManager) {
            return _instanceManager.dataManager.instanceData.isInstancePass(instanceID)
        }
        return false;
    }

    public function getInstanceByID(instanceID:int) : CChapterInstanceData {
        if (_instanceManager) {
            return _instanceManager.dataManager.instanceData.getInstanceContentData(instanceID, -1);
        }
        return null;
    }

    public function addPreloadData(list:Vector.<CPreloadData>) : void {
        if (_instanceManager) {
            _instanceManager.addPreloadData(list);
        }
    }


    [Inline]
    public function get isShowViewWhenReturnMainCity() : Boolean {
        return _isShowViewWhenReturnMainCity;
    }

    [Inline]
    public function set isShowViewWhenReturnMainCity( value : Boolean ) : void {
        _isShowViewWhenReturnMainCity = value;
    }
    public function get isStart():Boolean {
        return _isStart;
    }
    public function set isStart(value:Boolean):void {
        _isStart = value;
    }
    public function get isEnd():Boolean {
        return _isEnd;
    }
    public function set isEnd(value:Boolean):void {
        _isEnd = value;
    }

    public function pauseInstance() : void {
        _levelSystem.pause();
    }
    public function continueInstance() : void {
        _levelSystem.play();
    }

    public function setPlayEnable(v:Boolean) : void {
        _otherUtil.setPlayEnable(v)
    }
    public function setAiEnable(v:Boolean) : void {
        _otherUtil.setAiEnable(v);
    }

    public function setSkillViewEnable( v : Boolean ) : void{
        _otherUtil.setSkillUIEnable( v );
    }
    public function isViewShow(type:int) : Boolean {
        var view:CViewBase = uiHandler.getWindow(type);
        return view && view.isShowState;
    }
    public function isPlayingScenario() : Boolean {
        return !(_pLevelSystem && _pLevelSystem.manager && _pLevelSystem.manager.isPlayingScenario == false &&
                _pLevelSystem.manager.isWaitingScenarioPlay == false && _pScenarioSystem && _pScenarioSystem.isEndB);
    }
    public function isPlayingWinAnimation() : Boolean {
        return (_pLevelSystem && _pLevelSystem.manager && _pLevelSystem.manager.getPlayWinAnimation());
    }
    public function get exitRecord() : Exit {
        if (!_instanceManager) return null;
        return _instanceManager.exitRecord;
    }

    private var _instanceManager:CInstanceManager;
    private var _handler:CInstanceHandler;
    private var _mainNetHandler:CMainInstanceHandler;
    private var _exitProcess:CInstanceExitProcess;
    private var _uiHandler:CInstanceUIHandler;
    private var _otherUtil:CInstanceOtherUtil;
    private var _levelEventProcess:CInstanceLevelEventProcess;
    private var _autoFightHandler:CInstanceAutoFightHandler;

    private var _recordAIState:Boolean = false;

    private var _eliteBundleComponent:CViewBundleComponent;
    private var _isShowViewWhenReturnMainCity:Boolean = false;

    private var _isStart:Boolean; // 副本开始, 可以操作
    private var _isEnd:Boolean; // 副本结束, 结束操作, 其他副本和剧情副本不一样, 可以通过外部设置isEnd标志

    private var _redPoint:CInstanceRedPoint;

    private var _pScenarioSystem:CScenarioSystem;
    private var _pLevelSystem:CLevelSystem;


    public var isEndByStop:Boolean; // 是否中断结束
    private var _allOverHandler:CInstanceOverHandler;
}
}
