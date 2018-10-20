//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1 {


import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.event.CPeak1v1Event;
import kof.message.CAbstractPackMessage;
import kof.message.Peak1v1.Peak1v1CancelRegRequest;
import kof.message.Peak1v1.Peak1v1DownSingleResponse;
import kof.message.Peak1v1.Peak1v1FightReportRequest;
import kof.message.Peak1v1.Peak1v1FightReportResponse;
import kof.message.Peak1v1.Peak1v1FightSettlementResponse;
import kof.message.Peak1v1.Peak1v1GetRewardRequest;
import kof.message.Peak1v1.Peak1v1InfoRequest;
import kof.message.Peak1v1.Peak1v1InfoResponse;
import kof.message.Peak1v1.Peak1v1InfoUpdateResponse;
import kof.message.Peak1v1.Peak1v1MatchResponse;
import kof.message.Peak1v1.Peak1v1ProgressSyncRequest;
import kof.message.Peak1v1.Peak1v1ProgressSyncResponse;
import kof.message.Peak1v1.Peak1v1RankingRequest;
import kof.message.Peak1v1.Peak1v1RankingResponse;
import kof.message.Peak1v1.Peak1v1RegRequest;
import kof.message.Peak1v1.Peak1v1ResetResponse;
import kof.message.Peak1v1.Peak1v1WindowRequest;

public class CPeak1v1NetHandler extends CNetHandlerImp {
    private static const _PROTOCOL_TYPE_REGISTER:int  = 1;
    private static const _PROTOCOL_TYPE_DATA:int  = 2;
    public function CPeak1v1NetHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        bind(Peak1v1InfoResponse, _onData);
        bind(Peak1v1InfoUpdateResponse, _onDataUpdate);
        bind(Peak1v1ProgressSyncResponse, _onSyncProgress);
        bind(Peak1v1FightReportResponse, _onReport);
        bind(Peak1v1RankingResponse, _onRanking);
        bind(Peak1v1DownSingleResponse, _onDownSingle);
        bind(Peak1v1FightSettlementResponse, _onResult);
        bind(Peak1v1MatchResponse, _onMatch);
        bind(Peak1v1ResetResponse, _onReset);

        return true;
   }
    // =================================== get/set =========================================
    [Inline]
    private function get _system() : CPeak1v1System {
        return system as CPeak1v1System;
    }
    [Inline]
    public function get data() : CPeak1v1Data {
        return _system.data;
    }
    // =================================== S 2 C=========================================
    private final function _onData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:Peak1v1InfoResponse = message as Peak1v1InfoResponse;
            _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.NET_EVENT_DATA, null, response.peak1v1Data));
            setProtocolBusy(_PROTOCOL_TYPE_DATA, false);
        }
    }
    private final function _onDataUpdate(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        setProtocolBusy(_PROTOCOL_TYPE_REGISTER, false);
        if (!isError) {
            var response:Peak1v1InfoUpdateResponse = message as Peak1v1InfoUpdateResponse;
            _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.NET_EVENT_UPDATE_DATA, null, response.peak1v1DataUpdate));
            setProtocolBusy(_PROTOCOL_TYPE_DATA, false);
        }
    }

    // 巅峰对决结算反馈
    private final function _onResult(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:Peak1v1FightSettlementResponse = message as Peak1v1FightSettlementResponse;
            _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.NET_RESULT_DATA, null, response.settlementData));
        }
    }
    // 对手loading进度
    private final function _onSyncProgress(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:Peak1v1ProgressSyncResponse = message as Peak1v1ProgressSyncResponse;
            _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.NET_ENEMY_PROGRESS_DATA, null, response.enemyProgress));
        }
    }

    // 巅峰对决战报反馈
    private final function _onReport(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:Peak1v1FightReportResponse = message as Peak1v1FightReportResponse;
            _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.NET_REPORT_DATA, null, response.fightReportDatas));
        }
    }
    // 巅峰对决排行榜反馈
    private final function _onRanking(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:Peak1v1RankingResponse = message as Peak1v1RankingResponse;
            _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.NET_RANKING_DATA, null, response.rankDatas));
        }
    }
    // 巅峰对决落单反馈
    private final function _onDownSingle(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:Peak1v1DownSingleResponse = message as Peak1v1DownSingleResponse;
            _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.NET_DOWN_SINGLE_DATA, null, null));
        }
    }
    // 匹配反馈
    private final function _onMatch(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:Peak1v1MatchResponse = message as Peak1v1MatchResponse;
            _system.sendEvent(new CPeak1v1Event(CPeak1v1Event.NET_MATCH_DATA, null, response.matchData));
        }
    }
    // 收到服务器重置请求
    private final function _onReset(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            sendGetData();
        }
    }
    // =================================== C 2 S=========================================

    // 巅峰赛信息请求
    public function sendGetData() : void {
        var request:Peak1v1InfoRequest = new Peak1v1InfoRequest();
        request.flag = 1;
        networking.post(request);
        setProtocolBusy(_PROTOCOL_TYPE_DATA, true);
    }
    public function sendOpenWindow() : void {
        var request:Peak1v1WindowRequest = new Peak1v1WindowRequest(); //活动界面状态 0关闭 1打开
        request.windowState = 1;
        networking.post(request);
    }
    public function sendCloseWindow() : void {
        var request:Peak1v1WindowRequest = new Peak1v1WindowRequest(); //活动界面状态 0关闭 1打开
        request.windowState = 0;
        networking.post(request);
    }
    // 巅峰对决报名请求
    public function sendRegister() : void {
        if (isProtocolBusy(_PROTOCOL_TYPE_REGISTER)) {
            return ;
        }
        setProtocolBusy(_PROTOCOL_TYPE_REGISTER, true);

        var request:Peak1v1RegRequest = new Peak1v1RegRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 巅峰对决取消报名请求
    public function sendCancelRegister() : void {
        if (isProtocolBusy(_PROTOCOL_TYPE_REGISTER)) {
            return ;
        }
        setProtocolBusy(_PROTOCOL_TYPE_REGISTER, true);

        var request:Peak1v1CancelRegRequest = new Peak1v1CancelRegRequest();
        request.flag = 0;
        networking.post(request);
    }

    // 巅峰对决进度同步请求
    public function sendSyncProcess(progress:int) : void {
        var request:Peak1v1ProgressSyncRequest = new Peak1v1ProgressSyncRequest();
        request.progress = progress;
        networking.post(request);
    }

    // 巅峰对决战报请求
    public function sendGetReport() : void {
        var request:Peak1v1FightReportRequest = new Peak1v1FightReportRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 排行
    public function sendGetRanking() : void {
        var request:Peak1v1RankingRequest = new Peak1v1RankingRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 领奖
    public function sendGetReward(peak1v1RewardID:int) : void {
        var request:Peak1v1GetRewardRequest = new Peak1v1GetRewardRequest();
        request.peak1v1RewardID = peak1v1RewardID;
        networking.post(request);
    }
}
}