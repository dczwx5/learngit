//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/1/10.
 */
package kof.game.task {

import QFLib.Foundation;

import flash.utils.Dictionary;

import kof.framework.INetworking;
import kof.game.common.CRewardUtil;
import kof.game.common.system.CNetHandlerImp;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.task.data.CTaskData;
import kof.message.CAbstractPackMessage;
import kof.message.Task.DrawAllTaskRewardRequest;
import kof.message.Task.DrawAllTaskRewardResponse;
import kof.message.Task.DrawDailyTaskActiveRewardRequest;
import kof.message.Task.DrawDailyTaskActiveRewardResponse;
import kof.message.Task.DrawTaskRewardRequest;
import kof.message.Task.DrawTaskRewardResponse;
import kof.message.Task.NpcDialogueRequest;
import kof.message.Task.RewardMessageResponse;
import kof.message.Task.TaskChangeResponse;
import kof.message.Task.TaskListRequest;
import kof.message.Task.TaskListResponse;
import kof.message.Task.TaskResetResponse;

public class CTaskHandler extends CNetHandlerImp {

    private var _curRwardID : int;
    private var _curRward : int;
    private var _oldSendTaskID : int;

    public function CTaskHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(TaskListResponse, _onTaskListResponseHandler);
        this.bind(TaskChangeResponse, _onTaskChangeResponseHandler);
        this.bind(DrawTaskRewardResponse, _onDrawTaskRewardResponseHandler);
        this.bind(DrawDailyTaskActiveRewardResponse, _onDrawDailyTaskActiveRewardResponseHandler);
        this.bind(RewardMessageResponse, _onRewardMessageResponseHandler);
        this.bind(DrawAllTaskRewardResponse, _onDrawAllTaskRewardResponseHandler);
        this.bind(TaskResetResponse, _onTaskResetResponseResponseHandler);

        this.onTaskListRequest();
        return ret;
    }

    /**********************Request********************************/

    /*任务列表*/
    private var _isGM : Boolean = true;
    public function onTaskListRequest( ):void{
        _isGM = false;
        var request:TaskListRequest = new TaskListRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*领取任务奖励请求*/
    public function onDrawTaskRewardRequest( taskID : int , type : int ):void{
        if( taskID == _oldSendTaskID )
                return;
        _oldSendTaskID = taskID ;
        var request:DrawTaskRewardRequest = new DrawTaskRewardRequest();
        request.decode([taskID,type]);

        networking.post(request);
    }
    /*领取日常任务活跃值奖励请求*/
    public function onDrawDailyTaskActiveRewardRequest( rewardID : int ,reward :int):void{
        _curRwardID = rewardID;
        _curRward = reward;
        var request:DrawDailyTaskActiveRewardRequest = new DrawDailyTaskActiveRewardRequest();
        request.decode([rewardID]);

        networking.post(request);
    }
    /*npc对话结束请求*/
    public function onNpcDialogueRequest( npcID : int , talkID : int ):void{
        var request:NpcDialogueRequest = new NpcDialogueRequest();
        request.decode([npcID,talkID]);

        networking.post(request);
    }
    /*一键领取奖励请求*/
    public function onDrawAllTaskRewardRequest( type : int ):void{
        var request:DrawAllTaskRewardRequest = new DrawAllTaskRewardRequest();
        request.decode([type]);

        networking.post(request);
    }


    /**********************Response********************************/

    private final function _onTaskListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:TaskListResponse = message as TaskListResponse;
        (system.getBean(CTaskManager) as CTaskManager).initialTaskData(response);

        if( _isGM ){
            var taskDataDic : Dictionary = pCTaskManager.getUserTaskList();
            for each( var pTaskData:CTaskData in taskDataDic ){
                Foundation.Log.logMsg( "taskID:" + pTaskData.taskID + "," +
                                       "type:" + pTaskData.type + "," +
                                       "state:" + pTaskData.state + "," +
                                       "condition:" + pTaskData.condition + "," +
                                       "conditionParam:" + pTaskData.conditionParam
                );
            }
        }
        _isGM = true;

        system.dispatchEvent(new CTaskEvent(CTaskEvent.TASK_INIT));
    }
    private var _responseAry : Array;
    private final function _onTaskChangeResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:TaskChangeResponse = message as TaskChangeResponse;
        if( !_responseAry )
            _responseAry = [];
        _responseAry.push( response );
        if( _responseAry.length <= 1 ){
            _taskDataUpdateComp();
        }else{
            system.removeEventListener( CTaskEvent.TASK_DATA_UPDATE_COMP ,_taskDataUpdateComp );
            system.addEventListener( CTaskEvent.TASK_DATA_UPDATE_COMP ,_taskDataUpdateComp );
        }
        system.dispatchEvent(new CTaskEvent(CTaskEvent.TASK_UPDATE));
    }
    private function _taskDataUpdateComp( evt : CTaskEvent = null):void{
        (system.getBean(CTaskManager) as CTaskManager).updateTaskData(_responseAry[0]);
        _responseAry.shift();
    }
    private final function _onDrawTaskRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:DrawTaskRewardResponse = message as DrawTaskRewardResponse;
    }
    private final function _onDrawDailyTaskActiveRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:DrawDailyTaskActiveRewardResponse = message as DrawDailyTaskActiveRewardResponse;
        var rewardDataList:CRewardListData = CRewardUtil.createByDropPackageID( system.stage, _curRward );
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull( rewardDataList );
        pCPlayerData.taskData.dailyQuestActiveRewards.push( _curRwardID );

        system.dispatchEvent(new CTaskEvent(CTaskEvent.DRAW_DAILY_TASK_ACTIVE_REWARD ,_curRwardID));

    }
    private final function _onRewardMessageResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:RewardMessageResponse = message as RewardMessageResponse;
        response
    }
    private final function _onDrawAllTaskRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:DrawAllTaskRewardResponse = message as DrawAllTaskRewardResponse;
    }
    private final function _onTaskResetResponseResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:TaskResetResponse = message as TaskResetResponse;
        pCPlayerData.taskData.dailyQuestActiveRewards = [];
        pCPlayerData.taskData.dailyQuestActiveValue = 0;
        system.dispatchEvent(new CTaskEvent(CTaskEvent.TASK_RESET_RESPONSE));
    }

    private function get pCPlayerData():CPlayerData{
        var playerManager:CPlayerManager = system.stage.getSystem( CPlayerSystem ).getBean(CPlayerManager) as CPlayerManager;
        return  playerManager.playerData;
    }
    private function get pCTaskManager():CTaskManager{
        return system.getBean( CTaskManager ) as CTaskManager;
    }


}
}
