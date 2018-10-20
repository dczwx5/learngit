//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peakpk {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.peakpk.data.CPeakpkData;
import kof.game.peakpk.event.CPeakpkEvent;
import kof.message.CAbstractPackMessage;
import kof.message.PeakPK.PeakPKBattleResultResponse;
import kof.message.PeakPK.PeakPKCancelInviteRequest;
import kof.message.PeakPK.PeakPKInviteBeConfirmedEvent;
import kof.message.PeakPK.PeakPKInviteCancelledEvent;
import kof.message.PeakPK.PeakPKInviteConfirmRequest;
import kof.message.PeakPK.PeakPKInviteReceivedEvent;
import kof.message.PeakPK.PeakPKMatchResponse;
import kof.message.PeakPK.PeakPKProgressSyncRequest;
import kof.message.PeakPK.PeakPKProgressSyncResponse;
import kof.message.PeakPK.PeakPKSendInviteRequest;
import kof.message.PeakPK.PeakPKSendInviteResponse;

public class CPeakpkNetHandler extends CNetHandlerImp {
    public function CPeakpkNetHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        bind(PeakPKSendInviteResponse, _onSendInviteSuccessResponse);
        bind(PeakPKInviteBeConfirmedEvent, _onReceiveAnswerResponse);
        bind(PeakPKInviteReceivedEvent, _onReceiveInviteResponse);
        bind(PeakPKMatchResponse, _onMatchData);
        bind(PeakPKProgressSyncResponse, _onLoadingData);
        bind(PeakPKBattleResultResponse, _onResultData);
        bind(PeakPKInviteCancelledEvent, _onInviteCancelP2);


        return true;
   }
    // =================================== get/set =========================================
    [Inline]
    private function get _system() : CPeakpkSystem {
        return system as CPeakpkSystem;
    }
    [Inline]
    public function get data() : CPeakpkData {
        return _system.data;
    }
    // =================================== S 2 C=========================================

    // 1p 收到请求切磋回复, 接受还是拒绝
    private final function _onReceiveAnswerResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakPKInviteBeConfirmedEvent = message as PeakPKInviteBeConfirmedEvent;
            if (response.isAccept > 0) {
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_RECEIVE_CONFIRM_DATA_P1));
            } else {
                _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_RECEIVE_REFUSE_DATA_P1));

            }
        }
    }
    // 1p收到请求切磋成功
    private final function _onSendInviteSuccessResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakPKSendInviteResponse = message as PeakPKSendInviteResponse;
            _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_PK_SUCCESS_DATA_1P));
        } else {
            _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_PK_FAIL_DATA_1P));
        }
    }
    // 2p 收到切磋邀请
    private final function _onReceiveInviteResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakPKInviteReceivedEvent = message as PeakPKInviteReceivedEvent;
            _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_RECEIVE_INVITE_DATA_2P, null, response.fromInfo));
        }
    }
    private final function _onMatchData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakPKMatchResponse = message as PeakPKMatchResponse;
            _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_MATCH_DATA, null, response.matchData));
        }
    }
    private final function _onLoadingData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakPKProgressSyncResponse = message as PeakPKProgressSyncResponse;
            _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_LOADING_DATA, null, response.enemyProgress));
        }
    }
    private final function _onResultData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakPKBattleResultResponse = message as PeakPKBattleResultResponse;
            _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_RESULT_DATA, null, response.params));
        }
    }
    private final function _onInviteCancelP2(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakPKInviteCancelledEvent = message as PeakPKInviteCancelledEvent;
            _system.sendEvent(new CPeakpkEvent(CPeakpkEvent.NET_RECEIVE_INVITE_CANCEL_DATA_P2));
        }
    }

    // =================================== C 2 S=========================================
    // 1p 发切磋
    public function sendInvite(playerUID:Number) : void {
        var request:PeakPKSendInviteRequest = new PeakPKSendInviteRequest();
        request.toId = playerUID;
        networking.post(request);
    }
    // 1p 取消邀请
    public function sendCancelInvite() : void {
        var request:PeakPKCancelInviteRequest = new PeakPKCancelInviteRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 2p 拒绝邀请
    public function sendRefuseInvite(p1UID:Number) : void {
        var request:PeakPKInviteConfirmRequest = new PeakPKInviteConfirmRequest();
        request.inviterId = p1UID;
        request.isAccept = false;
        networking.post(request);
    }
    // 2p 接受邀请
    public function sendAccessInvite(p1UID:Number) : void {
        var request:PeakPKInviteConfirmRequest = new PeakPKInviteConfirmRequest();
        request.inviterId = p1UID;
        request.isAccept = true;
        networking.post(request);
    }
    public function sendSyncLoading(progress:int) : void {
        var request:PeakPKProgressSyncRequest = new PeakPKProgressSyncRequest();
        request.progress = progress;
        networking.post(request);
    }
}
}