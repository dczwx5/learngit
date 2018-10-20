//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/3.
 */
package kof.game.Tutorial.tutorPlay {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CMath;

import flash.display.DisplayObject;
import flash.utils.getTimer;

import kof.framework.IDataTable;
import kof.game.Tutorial.CTutorHandler;
import kof.game.Tutorial.CTutorManager;
import kof.game.Tutorial.CTutorUIHandler;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.data.CTutorGroupInfo;
import kof.game.Tutorial.enum.ETutorWndType;
import kof.game.Tutorial.tutorPlay.action.CTutorActionBase;
import kof.game.Tutorial.tutorPlay.action.CTutorActionPlayScenario;
import kof.game.Tutorial.view.CTutorArrowView;
import kof.game.Tutorial.view.CTutorDialogView;
import kof.game.Tutorial.view.CTutorView;
import kof.game.common.CTest;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskStateType;
import kof.ui.CUIComponentTutorHandler;
import kof.ui.CUISystem;
import kof.util.CAssertUtils;

import morn.core.components.Box;

import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.managers.DialogLayer;

public class CTutorPlay implements IUpdatable, IDisposable {

    public function CTutorPlay( tutorManager : CTutorManager ) {
        _tutorManager = tutorManager;

        _rollbackCheck = new CTutorActionRollBackCheck(this);
        _finishCondCheck = new CTutorCondProcess(this);
        _scenarioPlayFinishActionList = new CMap();

    }

    public function dispose() : void {
        uiHandler.hideTutor();
        uiHandler.hideTutorArrow();

        _tutorManager = null;
        clear();
        _autoFindValidActionIDList = null;
        _playingActList = null;
        _delayList = null;
        _isGroupFinish = false;

        if (_rollbackCheck) {
            _rollbackCheck.dispose();
            _rollbackCheck = null;
        }
        if (_finishCondCheck) {
            _finishCondCheck.dispose();
            _finishCondCheck = null;
        }
        if (_scenarioPlayFinishActionList) {
            _scenarioPlayFinishActionList = null;
        }


    }

    public function clear() : void {
        _isFinish = false;
        _isStart = false;
        _isGroupFinish = false;
        _clearAction();

        hideView();
        _pTutorView = null;
        _pTutorArrow = null;
        _pDialog = null;
    }

    private function _clearAction() : void {
        if ( _playingActList ) {
            for each ( var action : CTutorActionBase in _playingActList ) {
                if ( action ) {
                    action.dispose();
                }
            }
            _playingActList.clear();
        }

        if (_autoFindValidActionIDList) {
            _autoFindValidActionIDList.clear();
        }
        if ( _delayList ) {
            _delayList.length = 0;
        }
    }

    public function start( groupID : int ) : void {
        clear();
        _isStarting = true;
        _isStart = false;

        if ( !_playingActList ) {
            _playingActList = new CMap();
        }

        if (!_autoFindValidActionIDList) {
            _autoFindValidActionIDList = new CMap();
        }
        if ( !_delayList ) {
            _delayList = new Vector.<DelayAction>();
        }

        // 显示UI
        _pTutorView = uiHandler.getWindow(ETutorWndType.WND_TUTOR) as CTutorView;
        _pTutorArrow = uiHandler.getWindow(ETutorWndType.WND_TUTOR_ARROW) as CTutorArrowView;
        _pDialog = uiHandler.getWindow(ETutorWndType.WND_DIALOG_TUTOR) as CTutorDialogView;
        _startGroup( groupID );
    }

    public function stop() : void {
        this.stopAction();
        clear();

        _isStart = _isStarting = false;
    }

    protected function stopAction() : void {

    }

    // ============================================================update===========================================================

    public function get isForceHide() : Boolean {
        return _isForceHide;
    }
    private var _isForceHide:Boolean;
    public function update( delta : Number ) : void {
        if ( !_isStart ) return;

        _isForceHide = _checkForcePause();
        if (!_isForceHide) { // 如果在需要强制隐藏新手界面的情况下, 执行强制新手引导会导致界面重叠, 和引导不正确
            _updateDelayAction( delta );
            // 播放动作
            _updateAction( delta );
            _checkGroup();

            if ( !_isFinish ) {
                _isFinish = (_tutorGroupInfo == null);
            }
        } else {

            // 还是要检测 rollback
            for each ( var action : CTutorActionBase in _playingActList ) {
                // action完成不是点击,而且condFinish, 而且如果condFinish是打开其他界面, 会导致一直isForceHide == true
                if (action.isCondFinish == false) {
                    action.isCondFinish = _finishCondCheck.isCondFinish(action.info.actionFinishCond, action.info.finishCondParam);
                }
//                action.update( delta );

                if (action.isActionFinish()) {
                    action.saveToServerIfAbsent(); // 引导完成, 但是有东西挡住, 将下一个引导放入可前进队列, action没有save,
                    // 避免点击之后, 因为另一个界面打开, 导致下一个界面的指引没有了, 因为新界面出来之后, fiForceHide为true了
                    var nextAction : CTutorActionInfo = _tutorGroupInfo.getNextActionByID( action.infoID );
                    _addToAutoValidList(nextAction);
                }
                // 会导致已完成的动作没有saveToServer
                _rollbackNForward(action);
            }
        }
        _checkForceHide(); // 只是简单的隐藏新手view
    }

    private var _lastForceHideTime:int;
    // 只隐藏view, 不暂停新手
    private function _checkForceHide() : Boolean {
        var bForceHide:Boolean = false;

//        // scenario
        if (!bForceHide) {
            var pInstanceSystem:CInstanceSystem = _tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if (pInstanceSystem && pInstanceSystem.isPlayingScenario()) {
                bForceHide = true;
            }
        }
        _forceHideViewB(bForceHide);

        return bForceHide;
    }

    // 某些界面打开时, 强制暂停引导界面
    private var _forceHideCompTagsList:Array = ["TUTOR_TASK_OK_BTN", "TUTOR_HERO_QUALITY_SUCC_OK_BTN", "ROLE_TEAM_UPGRADE_OK", "TUTOR_COMMING", "ONE_DIAMOD_OK", "NPC_DIALOG_OK"];
    private function _checkForcePause() : Boolean {
        var bForcePause:Boolean = false;

        if (!bForcePause) {
            var pReciprocalSystem:CReciprocalSystem = (uiHandler.system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
            if (pReciprocalSystem) {
                if (pReciprocalSystem.hasEventPopWindow()) {
                    bForcePause = true;
                }
            }
        }

//        if (!bForcePause) {
//            var pLobbySystem:CLobbySystem = _tutorManager.system.stage.getSystem(CLobbySystem) as CLobbySystem;
//            if (pLobbySystem) {
//                bForcePause = pLobbySystem.isSwitchTweening;
//            }
//        }

        if (!bForcePause) {
            var pUctHandler : CUIComponentTutorHandler = _tutorUIParser;
            for each (var sCompTags:String in _forceHideCompTagsList) {
                var com:Component = pUctHandler.getCompByTutorID( sCompTags );
                if (com && CTutorActionBase.isCompVisible(com)) {
                    bForcePause = true;
                }
            }
        }

        if (!bForcePause) {
            // 升级时, 隐藏
            var playerData:CPlayerData = (uiHandler.system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            if (playerData.isLevelUp) {
                bForcePause = true;
            }
        }
        if (!bForcePause) {
            // 出现报错之后, 蒙板会出现, 在副本做下保护
            if (_pTutorView.visible || _pTutorArrow.visible) {
                var pInstanceSystem:CInstanceSystem = uiHandler.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                if (!pInstanceSystem.isMainCity) {
                    bForcePause = true;
                }
            }
        }

        if (!bForcePause) {
            // 检测当前显示的界面, 是不是箭头所指的界面
            var holeTarget:Component = _pTutorArrow.holeTarget;
            if (holeTarget && holeTarget.stage) {
                var dialogLayer:DialogLayer = (uiHandler.uiCanvas as CUISystem).dialogLayer;
                if (dialogLayer) {
                    var topChildIndex:int = dialogLayer.numChildren - 1; // 考虑二级框的情况
                    var boxContainer:Box = dialogLayer.getChildAt(topChildIndex) as Box; // dialogLayer里的dialog都是放在这个box里的
                    if (boxContainer && boxContainer.numChildren > 0) {
                        // 当前有dialog, 拿最后一个dialog
                        var dialog:Dialog = boxContainer.getChildAt(boxContainer.numChildren-1) as Dialog;
                        if (dialog) {
                            var rootDialogIsHoleTargetsParent:Boolean = false;
                            var holeTargetParent:DisplayObject = holeTarget.parent;
                            while (holeTargetParent) {
                                if (holeTargetParent == dialog) {
                                    rootDialogIsHoleTargetsParent = true;
                                    break;
                                }
                                holeTargetParent = holeTargetParent.parent;
                            }
                            if (!rootDialogIsHoleTargetsParent) {
                                bForcePause = true;
                            }
                        }
                    }
                }
            }
        }

        _forceHideViewB(bForcePause);

        return bForcePause;
    }
    private function _forceHideViewB(bForceHideView:Boolean) : void {
        if (bForceHideView) {
            _lastForceHideTime = getTimer();

            if (_pTutorView) {
                _pTutorView.visible = false;
//                if (_playingActList) {
//                    var curActionInfo:CTutorActionBase = _playingActList.firstValue();
//                    if (curActionInfo && curActionInfo.info.isForceShowMask) {
//                        _pTutorView.visible = true;
//                    }
//                }
            }
            if (_pDialog && _pDialog.isShowState && _pDialog.visible) {
                _pDialog.visible = false;
            }
            if (_pTutorArrow) {
                _pTutorArrow.visible = false;
            }
        } else {
            // 可以显示了
            if (_lastForceHideTime != 0) {
                // 上一次强制隐藏到现在, 延迟500ms显示和处理逻辑
                var curTime:int = getTimer();
                if (curTime - _lastForceHideTime > 500) {
                    if (_pDialog) {
                        _pDialog.setForceHide(false);
                    }
                    _pTutorArrow.setForceHide(false);
                    _lastForceHideTime = 0;
                } else {
                    _pTutorArrow.setForceHide(true);
                    if (_pDialog) {
                        _pDialog.setForceHide(true);
                    }
                }
            }
        }
    }

    private function _updateDelayAction( delta : Number ) : void {
        for ( var i : int = 0; i < _delayList.length; i++ ) { // 不用for each , 保证顺序
            var delayAction : DelayAction = _delayList[ i ];
            delayAction.duringTime += delta * 1000;
            if ( delayAction.duringTime - delayAction.actionInfo.startDelay > CMath.EPSILON ) {
                _startAction( delayAction.actionInfo );
                _delayList.splice( i, 1 );
                i--;
            }
        }
    }

    private function _updateAction( delta : Number ) : void {
        if ( _checkPreConditionInScheduled ) {
            _checkPreConditionInScheduled = false;
            startByPreCondition();
        }

        var nextActionInfo : CTutorActionInfo;

        for each ( var action : CTutorActionBase in _playingActList ) {
            if (action.isCondFinish == false) {
                action.isCondFinish = _finishCondCheck.isCondFinish(action.info.actionFinishCond, action.info.finishCondParam);
            }

            action.lastForceHideTime = _lastForceHideTime;
            if (action.isAutoPass && action.isAutoPassTimeOut || action.isPassBySpaceTriggered) {
                action.autoPassProcess();
            }
            action.update( delta ); // 有些引导会在update判断是否已经完成
            var isActionFinish:Boolean = action.isActionFinish();

            if ( isActionFinish ) {
                // 剧情播放完列表
                if (action is CTutorActionPlayScenario) {
                    var isExistInScenarioFinishList:Boolean = _scenarioPlayFinishActionList.find(action.infoID) == true;
                    if (!isExistInScenarioFinishList) {
                        _scenarioPlayFinishActionList.add(action.infoID, true);
                    }
                }

                action.saveToServerIfAbsent();
                // 开启下个action
                if ( action.info.isBlock == 1 ) {
                    // isBlock == 0的在action开始时就开启下一个动作了
                    if ( action.info.hasNext ) {
                        nextActionInfo = _tutorGroupInfo.getNextActionByID( action.infoID );
                        if ( !nextActionInfo ) {
                            Foundation.Log.logErrorMsg( "系统新手指引：没有找到ID为" + action.infoID + "的下一个引导Action" );
                        }

                        var nextIsInScenarioFinishList:Boolean = _scenarioPlayFinishActionList.find(nextActionInfo.ID) == true;
                        if (nextIsInScenarioFinishList) {
                            if (nextActionInfo.hasNext) {
                                nextActionInfo = _tutorGroupInfo.getNextActionByID( nextActionInfo.ID );
                            } else {
                                nextActionInfo = null;
                            }
                        }
                    }
                }

                if ( action.info && action.info.isRemoveByFinish > 0 ) {
                    // ui关闭 todo :
                }
                _isGroupFinish = (_tutorGroupInfo.lastAction.ID == action.infoID);
                _playingActList.remove( action.infoID );

                action.stop();
                action.dispose();

                if ( nextActionInfo ) {
                    if ( nextActionInfo.startDelay > 0 ) {
                        var delayAction : DelayAction = new DelayAction( nextActionInfo );
                        _delayList[ _delayList.length ] = delayAction;
                    } else {
                        _startAction( nextActionInfo );
                    }
                }
            } else {
                var isRollbackOrForwark:Boolean = false;
                // 自动寻找可用的action
                isRollbackOrForwark = _rollbackNForward(action);

                if (!isRollbackOrForwark) {
                    // 检测是否要回滚到上一步
                    var isRollBack:Boolean = false;
                    var rollbackCondID:int = action.info.rollbackCondID;
                    var rollbackActionID:int = action.info.rollbackActionID;
                    if (rollbackCondID > 0 && rollbackActionID > 0) {
                        var pInstanceSystem:CInstanceSystem = _tutorManager.system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
                        if (pInstanceSystem.isMainCity) {
                            var bRollback:Boolean = _rollbackCheck.canRollBack(action.info);
                            if (bRollback) {
                                action.stop();
                                _playingActList.remove( action.infoID );
                                var rollbackActionInfo:CTutorActionInfo = _tutorGroupInfo.getActionByID(rollbackActionID);
                                _startAction( rollbackActionInfo );
                                isRollBack = true;
                            }
                        }
                    }
                }
            }
        }
    }

    private function _rollbackNForward(action:CTutorActionBase) : Boolean {
        var isRollbackOrForwark:Boolean = false;
        if (action.info.groupInfo.isAutoFindValidAction) {
            var bInAutoValidList:Boolean = _autoFindValidActionIDList.find(action.infoID);
            if (bInAutoValidList) {

                var toActionInfo:CTutorActionInfo;
                toActionInfo = _findForwarkAutoValidAction(action); // forwark : 可以激活后面的动作, 自己完成

                if (!toActionInfo) {
                    toActionInfo = _findRollbackAutoValidAction(action); // rollback : 当前动作不可激活, 且有可以激动的前面的动作, 回滚
                }
                if (toActionInfo) {
                    _playingActList.remove( action.infoID );
                    action.stop();
                    action.dispose();
                    _startAction(toActionInfo);
                    isRollbackOrForwark = true;
                    CTest.log("tutor rollback or forwar by auto : ID : " + toActionInfo.ID);
                }
            }
        }
        return isRollbackOrForwark;
    }

    private function _checkGroup() : void {
        if ( _tutorGroupInfo && _isGroupFinish ) {
            if ( _tutorGroupInfo.hasNext() ) {
                var actionTable:IDataTable = _tutorManager.tutorData.tutorActionTable;
                var findList:Array = actionTable.findByProperty("GroupID", _tutorGroupInfo.nextGroupID) as Array;
                if (findList && findList.length > 0) {
                    _startGroup( _tutorGroupInfo.nextGroupID );
                } else {
                    // 如果有组ID。但是组ID没有配对应的action列表, 则停止引导
                    _tutorGroupInfo = null;
                }
            } else {
                _tutorGroupInfo = null;
            }
            return;
        }
    }

    // ===============================start=================================
    private function _startGroup( groupID : int ) : void {
        _isStarting = false;
        _isStart = true;
        _isGroupFinish = false;

        // 停止所有
        _clearAction();

        _tutorGroupInfo = _tutorManager.tutorData.getTutorGroupByID( groupID );

        // 检测 _tutorGroupInfo,暂未使用
        if (!_isStartGroupIgnoreOtherCondition) {
            var isFinish : Boolean = false;
            if ( _tutorGroupInfo && _tutorGroupInfo.finishCond > 0 ) {
                isFinish = _finishCondCheck.isCondFinish( _tutorGroupInfo.finishCond, _tutorGroupInfo.finishCondParam );

            } // finishCond == 0, 则group的完成条件, 是action全完成

            // 判断任务是否完成
            if (!isFinish && _tutorGroupInfo.doingMainQuestCondID > 0) {
                var pTaskSystem:CTaskSystem = _tutorManager.system.stage.getSystem(CTaskSystem) as CTaskSystem;
                isFinish = pTaskSystem.getTaskStateByTaskID(_tutorGroupInfo.doingMainQuestCondID) >= CTaskStateType.FINISH;
            }

            if (isFinish) {
                saveGroupActionToServer(_tutorGroupInfo);
                start(_tutorGroupInfo.nextGroupID);
                return ;
            }
        }


        _pTutorView.setData( _tutorGroupInfo );
        _pTutorView.maskView.visible = _tutorGroupInfo.hasMask;
        _pTutorView.maskView.alpha = _tutorGroupInfo.maskAlpha;

        _pTutorArrow.setData(_tutorGroupInfo);

        configurePrimaryView( _tutorGroupInfo.primaryView );
        startByPreCondition();
    }

    protected function startByPreCondition() : void {
        // 如果有任务完成的前提条件
        var isMainCity:Boolean = false;
        var pInstanceSys : IInstanceFacade = _tutorManager.system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys ) {
            isMainCity = pInstanceSys.isMainCity;
        }

        if ( _isStartGroupIgnoreOtherCondition || isMainCity && isTaskFinished( _tutorGroupInfo.completeMainQuestCondID ) && isTaskDoing(_tutorGroupInfo.doingMainQuestCondID) ) {
            var firstActionInfo : CTutorActionInfo = _tutorGroupInfo.firstAction;
            _startAction( firstActionInfo );
            _checkPreConditionInScheduled = false;
        } else if (isTaskFinished(_tutorGroupInfo.doingMainQuestCondID)) {
            // 任务在一开始的时候未完成，但是过一会之后就完成了, 比如先打了副本。到该指引时，。任务马上完成。但是引导先接了。任务是否完成的判断也过了。
            saveGroupActionToServer(_tutorGroupInfo);
            _isGroupFinish = true;
            _checkGroup();
//            start(_tutorGroupInfo.nextGroupID);
//            trace("任务在一开始的时候未完成，但是过一会之后就完成了, 比如先打了副本。到该指引时，。任务马上完成。但是引导先接了。任务是否完成的判断也过了。");
        } else {
            _checkPreConditionInScheduled = true;
        }
    }

    protected function configurePrimaryView( type : int ) : void {
        var pInstanceSys : IInstanceFacade = _tutorManager.system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSys ) {
            pInstanceSys.isShowViewWhenReturnMainCity = type == 0;
        }
    }

    protected function isTaskFinished( iTaskID : int ) : Boolean {
        if ( iTaskID == 0 ) return true;
        if ( iTaskID < 0 ) return false;
        var pTaskSys : CTaskSystem = _tutorManager.system.stage.getSystem( CTaskSystem ) as CTaskSystem;
        if ( pTaskSys ) {
            if ( pTaskSys.getTaskStateByTaskID( iTaskID ) == CTaskStateType.COMPLETE ) {
                return true;
            }
        }
        return false;
    }
    protected function isTaskDoing( iTaskID : int ) : Boolean {
        if ( iTaskID == 0 ) return true;
        if ( iTaskID < 0 ) return false;
        var pTaskSys : CTaskSystem = _tutorManager.system.stage.getSystem( CTaskSystem ) as CTaskSystem;
        if ( pTaskSys ) {
            var iTaskState:int = pTaskSys.getTaskStateByTaskID( iTaskID );
            if ( iTaskState == CTaskStateType.CAN_DO) {
                return true;
            }
        }
        return false;
    }

    private function _startAction( actionInfo : CTutorActionInfo ) : void {
        CAssertUtils.assertNotNull( actionInfo );

        var action : CTutorActionBase = CTutorActionCreater.createAction( actionInfo, _tutorManager.system );
        if ( !action ) {
            Foundation.Log.logErrorMsg( "新手引导ID: " + actionInfo.ID + " 动作未定义" );
            this.stop();
            return;
        }

        _playingActList.add( action.infoID, action );
        _addToAutoValidList(action.info);
        action.start();

        // 检测是否为非阻塞action
        if ( action.info.isBlock == 0 ) {
            if ( action.info.hasNext ) {
                var nextAction : CTutorActionInfo = _tutorGroupInfo.getNextActionByID( action.infoID );
                _startAction( nextAction );
            }
        }
    }

    private function _addToAutoValidList(actionInfo:CTutorActionInfo) : void {
        if (!actionInfo || actionInfo.groupInfo.isAutoFindValidAction == false) return ;

        if (null == _autoFindValidActionIDList.find(actionInfo.ID)) {
            _autoFindValidActionIDList.add(actionInfo.ID, actionInfo);
        }
    }
    // 如果需要回滚, 寻找可回滚的动作
    private function _findRollbackAutoValidAction(action:CTutorActionBase) : CTutorActionInfo {
        if (!action || !action.info || action.info.groupInfo.isAutoFindValidAction == false) return null;
        if (action.info.isForceNotRollback) return null;

        var needRollback:Boolean = action.needRollback;
        if (needRollback) {
            // 需要目标, 但没有目标
            // action之前的肯定是_autoFindValidActionIDList里的了, 不用检查
            var curActionInfo:CTutorActionInfo = action.info;
            var pUctHandler : CUIComponentTutorHandler = _tutorUIParser;
            while (curActionInfo) {
                var preActionInfo:CTutorActionInfo = curActionInfo.groupInfo.getPreAction(curActionInfo.ID);
                if (preActionInfo) {
                    var isExistInScenarioFinishList:Boolean = _scenarioPlayFinishActionList.find(preActionInfo.ID) == true;
                    if (!isExistInScenarioFinishList) {
                        var com:Component = pUctHandler.getCompByTutorID( preActionInfo.maskHoleTargetID );
                        if (com && CTutorActionBase.isCompVisible(com)) {
                            return preActionInfo;
                        }
                    }
                }
                curActionInfo = preActionInfo;
            }
        }

        return null;
    }
    // 如果可以向前走, 寻找可往前的动作
    private function _findForwarkAutoValidAction(action:CTutorActionBase) : CTutorActionInfo {
        if (!action || !action.info || action.info.groupInfo.isAutoFindValidAction == false || action.info.isStopAutoForward) return null;

        var bForward:Boolean = false;
        for (var autoValidID:int in _autoFindValidActionIDList) {
            if (autoValidID > action.infoID) {
                bForward = true;
                break;
            }
        }
        bForward = bForward && action.info.hasMaskHoleTarget;

        if (bForward) {
            // 需要目标, 但没有目标
            var curActionInfo:CTutorActionInfo = action.info;
            var pUctHandler : CUIComponentTutorHandler = _tutorUIParser;
            while (curActionInfo) {
                var nextActionInfo:CTutorActionInfo = curActionInfo.groupInfo.getNextActionByID(curActionInfo.ID);
                if (nextActionInfo) {
                    var isExistInScenarioFinishList:Boolean = _scenarioPlayFinishActionList.find(nextActionInfo.ID) == true;
                    // 已播放过的剧情动作不再播放
                    if (!isExistInScenarioFinishList) {
                        var bInValidAction:Boolean = _autoFindValidActionIDList.find(nextActionInfo.ID) != null;
                        if (!bInValidAction) {
                            // 当前动作没在列表里, 后面的肯定也不会在列表里
                            break;
                        }

                        var com:Component = pUctHandler.getCompByTutorID( nextActionInfo.maskHoleTargetID );
                        if (com && CTutorActionBase.isCompVisible(com)) {
                            return nextActionInfo;
                        }
                    }
                }
                curActionInfo = nextActionInfo;
            }
        }

        return null;
    }

    private function get _tutorUIParser() : CUIComponentTutorHandler {
        if ( !_tutorManager.system )
            return null;
        var pUISys : CUISystem = _tutorManager.system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISys ) {
            return pUISys.getHandler( CUIComponentTutorHandler ) as CUIComponentTutorHandler;
        }
        return null;
    }
    public function saveGroupActionToServer(vGroupInfo:CTutorGroupInfo) : void {
        var pAction:CTutorActionInfo = vGroupInfo.firstAction;
        var pHandler:CTutorHandler = _tutorManager.system.getHandler(CTutorHandler) as CTutorHandler;
        if (pHandler) {
            while (pAction) {
                pHandler.sendTutorFinish(pAction.ID);
                var nextActionID:int = pAction.nextActionID;
                pAction = vGroupInfo.getActionByID(nextActionID);
            }
        }
    }
    [Inline]
    public function get tutorGroupInfo() : CTutorGroupInfo {
        return _tutorGroupInfo;
    }

    public function get uiHandler() : CTutorUIHandler {
        return _tutorManager.system.getBean( CTutorUIHandler ) as CTutorUIHandler;
    }

    public function get isPlaying() : Boolean {
        return (_isStart || _isStarting) && !_isFinish;
    }
    [Inline]
    public function get isFinish() : Boolean {
        return _isFinish;
    }

    [Inline]
    public function get isStart() : Boolean {
        return _isStart;
    }
    public function get tutorView() : CTutorView {
        return _pTutorView;
    }
    public function get tutorArrow() : CTutorArrowView {
        return _pTutorArrow;
    }
    public function get dialogView() : CTutorDialogView {
        return _pDialog;
    }
    public function get tutorManager():CTutorManager {
        return _tutorManager;
    }
    public function hideView() : void {
        if (_pTutorArrow && _pTutorArrow.visible) {
            _pTutorArrow.visible = false;
        }
        if (_pTutorView && _pTutorView.visible) {
            _pTutorView.visible = false;
        }
        if (_pDialog && _pDialog.visible) {
            _pDialog.visible = false;
        }
    }

    private var _checkPreConditionInScheduled : Boolean;

    private var _tutorManager : CTutorManager;
    private var _isFinish : Boolean;
    private var _isStart : Boolean;
    private var _isStarting : Boolean;
    private var _tutorGroupInfo : CTutorGroupInfo;

    private var _playingActList : CMap; // 同时正在播放的action列表
    private var _isGroupFinish:Boolean; //

    private var _autoFindValidActionIDList:CMap; // 自动寻找可用的action
    private var _delayList : Vector.<DelayAction>; // 延迟列表

    private var _rollbackCheck:CTutorActionRollBackCheck;
    private var _finishCondCheck:CTutorCondProcess;

    private var _pTutorView : CTutorView;
    private var _pTutorArrow:CTutorArrowView;
    private var _pDialog:CTutorDialogView;

    private var _scenarioPlayFinishActionList:CMap; // 剧情对话动作已播放列表, 剧情对话动作只播一次

    public var _isStartGroupIgnoreOtherCondition:Boolean = false; // 是否直接开始动作组, 并忽略其他条件
}
}

import kof.game.Tutorial.data.CTutorActionInfo;

class DelayAction {
    public function DelayAction( actionInfo : CTutorActionInfo ) {
        this.actionInfo = actionInfo;
        this.duringTime = 0;
    }

    public var actionInfo : CTutorActionInfo;
    public var duringTime : Number;
}