//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/5.
 */
package kof.game.Tutorial {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
import QFLib.Interface.IUpdatable;

import kof.framework.INetworking;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.Tutorial.data.CTutorData;
import kof.game.Tutorial.data.CTutorGroupInfo;
import kof.game.Tutorial.event.CTutorEvent;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.system.CNetHandlerImp;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.player.CPlayerSystem;
import kof.game.scenario.CScenarioSystem;
import kof.game.task.CTaskSystem;
import kof.game.task.data.CTaskStateType;
import kof.message.CAbstractPackMessage;
import kof.message.Level.BattleGuideEndRequest;
import kof.message.Level.BattleGuideResponse;
import kof.message.Player.SaveFightGuideRequest;
import kof.message.Player.SaveGuideRequest;

import morn.core.handlers.Handler;

public class CTutorHandler extends CNetHandlerImp implements IUpdatable {

    private var _messageQueue:Array; // 剧情正在播放时，有一些协议不能触发, 等待剧情结束才触发, 后面需要服务器改事件处理流程

    public function CTutorHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        _messageQueue = [];
        bind(BattleGuideResponse, getQueueHandler(_onStartBattleTutor)); // _onStartBattleTutor);

        return true;
    }

    // =================================== get/set =========================================
    [Inline]
    private function get _tutorSystem() : CTutorSystem {
        return system as CTutorSystem;
    }
    [Inline]
    public function get tutorData() : CTutorData {
        return _tutorSystem.tutorData;
    }

    // =================================== C 2 S=========================================
    private var _savedActionList:CMap;
    public function sendTutorFinish( actionID : int ) : void {
        if (!_savedActionList) {
            _savedActionList = new CMap();
        }
        if (_savedActionList.find(actionID) == true) {
            return ;
        }

        _savedActionList.add(actionID, true);
        var request : SaveGuideRequest = new SaveGuideRequest();
        request.guideIndex = actionID;
        networking.send( request );
    }

    public function onBundleStart( ctx : ISystemBundleContext ) : void {
        // 启动引导，事件attached
        var vInstanceSys : IInstanceFacade = system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( vInstanceSys ) {
            vInstanceSys.callWhenInMainCity(startByActionIndexID, null, null, null, 9999);
        } else {
            startByActionIndexID();
        }
    }

    public function startByActionIndexID( iGuideIndex : int = 0 ) : void {
        var pManager : CTutorManager = system.getHandler( CTutorManager ) as CTutorManager;
        if ( iGuideIndex == 0 ) {
            var vPlayerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
            if ( vPlayerSystem ) {
                iGuideIndex = vPlayerSystem.playerData.tutorData.guideIndex;
            }
        }

        if ( iGuideIndex == 0 ) { // first guide enable.
            if ( pManager ) {
                var pFirstGroupInfo : CTutorGroupInfo = pManager.tutorData.firstGroup();
                if ( pFirstGroupInfo ) {
                    iGuideIndex = pFirstGroupInfo.firstAction.ID;
                }
            }
        }

        if ( iGuideIndex == 0 ) {
            Foundation.Log.logWarningMsg( "没有找到有效的新手指引的开始数据！！！" );
        } else {
            if ( pManager ) {
                var vGroupInfo : CTutorGroupInfo = pManager.tutorData.getTutorGroupByActionID( iGuideIndex );
                var iStartGroupID : int = 0;
                if ( vGroupInfo ) {
                    var bSkip2Next : Boolean = false;
                    var lastAction:CTutorActionInfo = vGroupInfo.lastAction;
                    if (lastAction && lastAction.ID <= iGuideIndex) { // 一个组的最后一个ID已经完成了
                        bSkip2Next = true;
                    } else if ( vGroupInfo.groupRecord.GroupActionTargetID == 0 ) {
                        bSkip2Next = false;
                    } else if (vGroupInfo.groupRecord.GroupActionTargetID <= iGuideIndex ) {
                        bSkip2Next = true;
                    }

                    if (!bSkip2Next) {
                        // 判断任务是否完成
                        if (vGroupInfo.doingMainQuestCondID > 0) {
                            var pTaskSystem:CTaskSystem = pManager.system.stage.getSystem(CTaskSystem) as CTaskSystem;
                            var isFinish:Boolean = pTaskSystem.getTaskStateByTaskID(vGroupInfo.doingMainQuestCondID) >= CTaskStateType.FINISH;
                            bSkip2Next = isFinish;
                        }
                    }

                    if ( bSkip2Next ) {
                        if ( vGroupInfo.hasNext() )
                            // 跳过当前组
                            pManager.saveGroupActionToServer(vGroupInfo);
                            iStartGroupID = vGroupInfo.nextGroupID;
                    } else {
                        iStartGroupID = vGroupInfo.ID;
                    }
                }

                if ( iStartGroupID != 0 )
                    pManager.startTutor( iStartGroupID );
            }
        }
    }

    // ==============================================battleTutor=======================================

    private function getQueueHandler(process:Function) : Function {
        return function (net:INetworking, message:CAbstractPackMessage, isError:Boolean) : void {
            if (isError) return ;
            var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if (pInstanceSystem.isPlayingScenario()) {
                _messageQueue.push(new Handler(process, [net, message, isError]));
            } else {
                process(net, message, isError);
            }
        };
    }

    public override function update(delta:Number) : void {
        super.update(delta);

        if (_messageQueue && _messageQueue.length > 0) {
            var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if (false == pInstanceSystem.isPlayingScenario()) {
                while(_messageQueue.length > 0) {
                    var handler:Handler = _messageQueue.shift();
                    handler.execute();
                }
            }
        }
    }
    // =================================== S 2 C=========================================

    private final function _onStartBattleTutor(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:BattleGuideResponse = message as BattleGuideResponse;
        if (!response) {
            Foundation.Log.logErrorMsg("BattleGuideResponse is null");
        }

        var instanceSystem:IInstanceFacade = (system.stage.getSystem(IInstanceFacade) as IInstanceFacade);
        if (!instanceSystem) {
            Foundation.Log.logErrorMsg("instanceSystem is null");
        }
        if (!instanceSystem.instanceContent) {
            Foundation.Log.logErrorMsg("instanceSystem.instanceContent is null");
        }
        if (instanceSystem.isInstancePass(instanceSystem.instanceContent.ID)) {
            // 直接通过
            if (response.force > 0) {
                var request:BattleGuideEndRequest = new BattleGuideEndRequest();
                if (!request) {
                    Foundation.Log.logErrorMsg("BattleGuideEndRequest is null");
                }
                request.guideID = response.guideID;
                networking.post(request);
            }
            return ;
        }

        _tutorSystem.sendEvent(new CTutorEvent(CTutorEvent.NET_EVENT_START_BATTLE_TUTOR, null, {tutorID:response.guideID, force:response.force}));
    }
    // 假装收到要开始指引
    public function onStartBattleTutor(battleTutorID:int = 1001) : void {
        if (battleTutorID == 0) battleTutorID = 1001;
        _tutorSystem.sendEvent(new CTutorEvent(CTutorEvent.NET_EVENT_START_BATTLE_TUTOR, null, {tutorID:battleTutorID, force:1}));
    }
    // =================================== C 2 S=========================================

    public function sendBattleTutorFinish(tutorID:int) : void {
        var request:BattleGuideEndRequest = new BattleGuideEndRequest();
        request.guideID = tutorID;
        networking.post(request);
    }
    public function saveBattleTutorStep(step:int) : void {
        var request:SaveFightGuideRequest = new SaveFightGuideRequest();
        request.fightGuide = step;
        networking.post(request);
    }
}
}