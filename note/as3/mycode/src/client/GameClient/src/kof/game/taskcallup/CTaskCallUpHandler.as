//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/19.
 */
package kof.game.taskcallup {

import kof.framework.INetworking;
import kof.game.common.CRewardUtil;
import kof.game.common.system.CNetHandlerImp;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.game.taskcallup.data.CCallUpAcceptedData;
import kof.game.taskcallup.data.CTaskCallUpConst;
import kof.message.CAbstractPackMessage;
import kof.message.TaskCallUp.AcceptTaskCallUpRequest;
import kof.message.TaskCallUp.CallUpTaskTimeOutResponse;
import kof.message.TaskCallUp.CancelTaskCallUpRequest;
import kof.message.TaskCallUp.QuicklyFinishCallUpRequest;
import kof.message.TaskCallUp.QuicklyFinishCallUpResponse;
import kof.message.TaskCallUp.RefreshCallUpRequest;
import kof.message.TaskCallUp.RefreshCallUpResponse;
import kof.message.TaskCallUp.TaskCallUpListRequest;
import kof.message.TaskCallUp.TaskCallUpListResponse;
import kof.message.TaskCallUp.TaskCallUpRewardRequest;
import kof.message.TaskCallUp.TaskCallUpRewardResponse;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

import morn.core.handlers.Handler;

public class CTaskCallUpHandler extends CNetHandlerImp {
    public function CTaskCallUpHandler() {
        super();
    }
    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        this.bind(TaskCallUpListResponse, _onTaskCallUpListResponseHandler);
        this.bind(RefreshCallUpResponse, _onRefreshCallUpResponseHandler);
        this.bind(TaskCallUpRewardResponse, _onTaskCallUpRewardResponseHandler);
        this.bind(QuicklyFinishCallUpResponse, _onQuicklyFinishCallUpResponseHandler);
        this.bind(CallUpTaskTimeOutResponse , _onCallUpTaskTimeOutResponseHandler);

        this.onTaskCallUpListRequest();
        return ret;
    }
    /**********************Request********************************/

    /*召集令主界面请求*/
    public function onTaskCallUpListRequest( ):void{
        var request:TaskCallUpListRequest = new TaskCallUpListRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*刷新召集令请求*/
    public function onRefreshCallUpRequest():void{
        var request:RefreshCallUpRequest = new RefreshCallUpRequest();
        request.decode([1]);

        networking.post(request);
    }
    /*接取召集令请求*/
    public function onAcceptTaskCallUpRequest( taskId : int, heroList:Array ):void{
        var request:AcceptTaskCallUpRequest = new AcceptTaskCallUpRequest();
        request.decode([taskId,heroList]);
        networking.post(request);
    }
    /*取消召集令请求*/
    public function onCancelTaskCallUpRequest( taskId :int ):void{
        var request:CancelTaskCallUpRequest = new CancelTaskCallUpRequest();
        request.decode([taskId]);
        networking.post(request);
    }
    /*召集令领奖请求*/
    public function onTaskCallUpRewardRequest( taskId : int):void{
        var request:TaskCallUpRewardRequest = new TaskCallUpRewardRequest();
        request.decode([taskId]);
        _pTaskCallUpManager.taskCallUpRewardRequestTaskId = taskId;
        networking.post(request);
    }
    /*召集令任务快速完成请求*/
    public function onQuicklyFinishCallUpRequest( taskId : int):void{
        var request:QuicklyFinishCallUpRequest = new QuicklyFinishCallUpRequest();
        _pTaskCallUpManager.taskQuicklyFinishTaskId = taskId;
        request.decode([taskId]);

        networking.post(request);
    }
    /**********************Response********************************/

    /*召集令主界面响应*/
    private final function _onTaskCallUpListResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:TaskCallUpListResponse = message as TaskCallUpListResponse;
        _pTaskCallUpManager.updateCallUpInfo( response );
        system.dispatchEvent(new CTaskCallUpEvent(CTaskCallUpEvent.TASK_CALL_UP_UPDATE ));
        if( response.type == CTaskCallUpConst.ACCEPT_RESPONE_TYPE ){
            _pCUISystem.showMsgAlert('接取召集令成功',CMsgAlertHandler.NORMAL );
            system.dispatchEvent(new CTaskCallUpEvent(CTaskCallUpEvent.ACCEPT_TASK_CALLUP_RESPONSE ));
        }else if( response.type == CTaskCallUpConst.CANCEL_RESPONE_TYPE ){
            _pCUISystem.showMsgAlert('取消召集令成功',CMsgAlertHandler.NORMAL );
            system.dispatchEvent(new CTaskCallUpEvent(CTaskCallUpEvent.CANCEL_TASK_CALLUP_RESPONSE ));
        }
    }
    /*刷新召集令响应*/
    private final function _onRefreshCallUpResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:RefreshCallUpResponse = message as RefreshCallUpResponse;
        _pTaskCallUpManager.updateCallUpList( response.callUpList );
        _pTaskCallUpManager.refresh = response.refresh;
        system.dispatchEvent(new CTaskCallUpEvent(CTaskCallUpEvent.TASK_CALL_UP_REFRESH ));
        _pCUISystem.showMsgAlert('任务刷新成功',CMsgAlertHandler.NORMAL );
    }
    /*召集令领奖响应*/
    private final function _onTaskCallUpRewardResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:TaskCallUpRewardResponse = message as TaskCallUpRewardResponse;
        _pTaskCallUpManager.deleteAcceptedCallUpListItem( _pTaskCallUpManager.taskCallUpRewardRequestTaskId );
        system.dispatchEvent(new CTaskCallUpEvent(CTaskCallUpEvent.TASK_CALL_UP_UPDATE ));
        _pCUISystem.showMsgAlert('召集令领奖成功',CMsgAlertHandler.NORMAL );
        var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, response.rewards);
        (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull( rewardListData );

    }
    /*召集令任务快速完成响应*/
    private final function _onQuicklyFinishCallUpResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:QuicklyFinishCallUpResponse = message as QuicklyFinishCallUpResponse;
        var pCallUpAcceptedData : CCallUpAcceptedData =  _pTaskCallUpManager.getAcceptedCallUpListItemDataByTaskId( _pTaskCallUpManager.taskQuicklyFinishTaskId );
        if( pCallUpAcceptedData )
            pCallUpAcceptedData.endTime = 0;
        system.dispatchEvent(new CTaskCallUpEvent(CTaskCallUpEvent.TASK_CALL_UP_UPDATE ));
        _pCUISystem.showMsgAlert('召集令任务快速完成成功',CMsgAlertHandler.NORMAL );
    }

    /*召集令任务时间到，完成了*/
    private final function _onCallUpTaskTimeOutResponseHandler(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if ( isError ) return;
        system.dispatchEvent(new CTaskCallUpEvent(CTaskCallUpEvent.TASK_CALL_UP_CAN_REWARD ));
    }
    private function get _pTaskCallUpManager():CTaskCallUpManager{
        return system.getBean( CTaskCallUpManager ) as CTaskCallUpManager;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }

}
}
