//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.peakGame {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.event.CPeakGameEvent;
import kof.message.CAbstractPackMessage;
import kof.message.PeakGame.EnterPeakBattleErrorResponse;
import kof.message.PeakGame.FightReportAddResponse;
import kof.message.PeakGame.FightReportRequest;
import kof.message.PeakGame.FightReportResponse;
import kof.message.PeakGame.FirstAutoEmbattleRequest;
import kof.message.PeakGame.FirstOpenGloryHallRequest;
import kof.message.PeakGame.GloryHallRequest;
import kof.message.PeakGame.GloryHallResponse;
import kof.message.PeakGame.NotityClientUpdatePeakResponse;
import kof.message.PeakGame.PeakFightSettlementResponse;
import kof.message.PeakGame.PeakGameInfoRequest;
import kof.message.PeakGame.PeakGameInfoResponse;
import kof.message.PeakGame.PeakGameInfoUpdateResponse;
import kof.message.PeakGame.PeakGameMatchCancelRequest;
import kof.message.PeakGame.PeakGameMatchRequest;
import kof.message.PeakGame.PeakGameMatchResponse;
import kof.message.PeakGame.PeakGetRewardRequest;
import kof.message.PeakGame.ProgressSyncRequest;
import kof.message.PeakGame.ProgressSyncResponse;
import kof.message.PeakGame.RankingRequest;
import kof.message.PeakGame.RankingResponse;

public class CPeakGameHandler extends CNetHandlerImp {
    public function CPeakGameHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        bind(PeakGameInfoResponse, _onData);
        bind(PeakGameInfoUpdateResponse, _onDataUpdate);
        bind(PeakGameMatchResponse, _onMatch);
        bind(GloryHallResponse, _onGloryHall);
        bind(FightReportResponse, _onFightReport);
        bind(FightReportAddResponse, _onFightReportUpdate);
        bind(RankingResponse, _onRank);
        bind(ProgressSyncResponse, _onSyncLoading);
        bind(PeakFightSettlementResponse, _onSettlement); // 整场结算
        bind(EnterPeakBattleErrorResponse, _onPeakErrorWhenEnter); // 整场结算
        bind(NotityClientUpdatePeakResponse, _onNotifyClientToRefresh); // 通知客户端重新请求数据

        return true;
   }
    // =================================== get/set =========================================
    [Inline]
    private function get _peakGameSystem() : CPeakGameSystem {
        return system as CPeakGameSystem;
    }
    [Inline]
    public function get peakGameData() : CPeakGameData {
        return (system as CPeakGameSystem).peakGameData;
    }
    // =================================== S 2 C=========================================

    // 巅峰赛信息反馈, 客户端主动请求，服务器返回
    private final function _onData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakGameInfoResponse = message as PeakGameInfoResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_DATA, null, [response.peakGameInfo, response.playType]));
            isRequiringDate = false;
        }
    }
    // 巅峰赛信息更新, 服务器主动返回
    private final function _onDataUpdate(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakGameInfoUpdateResponse = message as PeakGameInfoUpdateResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_UPDATE_DATA, null, [response.peakGameInfoUpdate, response.playType]));
        }

    }
    // 匹配反馈. 成功或失败
    private final function _onMatch(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakGameMatchResponse = message as PeakGameMatchResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_MATCH_DATA, null, [response.matchData, response.playType]));
        }
    }
    // 荣耀殿堂反馈
    private final function _onGloryHall(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:GloryHallResponse = message as GloryHallResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_HONOUR_DATA, null, [response.gloryHallDatas, response.playType]));
        }
    }
    // 战报反馈, c 2 s, s 2 c
    private final function _onFightReport(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:FightReportResponse = message as FightReportResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_REPORT_DATA, null, [response.fightReportDatas, response.playType]));
        }
    }
    // 战报反馈 s 2 c
    private final function _onFightReportUpdate(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:FightReportAddResponse = message as FightReportAddResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_REPORT_DATA, null, [response.fightReportDatas, response.playType]));
        }
    }
    // 排行榜反馈
    private final function _onRank(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:RankingResponse = message as RankingResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_RANK_DATA, null, [response, response.playType]));
        }
    }
    // 进度同步反馈
    private final function _onSyncLoading(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:ProgressSyncResponse = message as ProgressSyncResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_LOADING_DATA, null, [response.enemyProgress, response.playType]));
        }
    }
    // 整场结算
    private final function _onSettlement(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:PeakFightSettlementResponse = message as PeakFightSettlementResponse;
            _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_SETTLEMENT_DATA, null, [response.settlementData, response.playType]));
        }
    }
    // 从匹配到进入之间报错
    private final function _onPeakErrorWhenEnter(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        var response:EnterPeakBattleErrorResponse = message as EnterPeakBattleErrorResponse;
        _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_ENTER_ERROR, null, [response, response.playType]));
    }

    private final function _onNotifyClientToRefresh(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;
        var response:NotityClientUpdatePeakResponse = message as NotityClientUpdatePeakResponse;
        _peakGameSystem.sendEvent(new CPeakGameEvent(CPeakGameEvent.NET_EVENT_NOTIFY_CLIENT_REFRESH, null, [response, response.playType]));
    }

    // =================================== C 2 S=========================================

    // 巅峰赛信息请求
    public var isRequiringDate:Boolean = false;
    public function sendGetData(playType:int) : void {
        var request:PeakGameInfoRequest = new PeakGameInfoRequest();
        request.peakGameInfo = 1;
        request.playType = playType;
        networking.post(request);
        isRequiringDate = true;
    }
    // 匹配请求
    public function sendMatch(playType:int) : void {
        var request:PeakGameMatchRequest = new PeakGameMatchRequest();
        request.match = 1;
        request.playType = playType;
        networking.post(request);
    }
    // 取消匹配请求
    public function sendCancelMatch(playType:int) : void {
        var request:PeakGameMatchCancelRequest = new PeakGameMatchCancelRequest();
        request.matchCancel = 1;
        request.playType = playType;
        networking.post(request);
    }

    // 荣耀殿堂请求
    public function sendGetGloryHall(playType:int) : void {
        var request:GloryHallRequest = new GloryHallRequest();
        request.gloryHall = 1;
        request.playType = playType;
        networking.post(request);
    }
    // 战报请求
    public function sendGetReport(playType:int) : void {
        var request:FightReportRequest = new FightReportRequest();
        request.fightReport = 1;
        request.playType = playType;
        networking.post(request);
    }
    // 排行榜请求
    public function sendGetRank(type:int, playType:int) : void {
        var request:RankingRequest = new RankingRequest();
        request.type = type;
        request.playType = playType;
        networking.post(request);
    }
    // 进度同步请求
    public function sendSyncLoading(value:int, playType:int) : void {
        var request:ProgressSyncRequest = new ProgressSyncRequest();
        request.progress = value;
        request.playType = playType;
        networking.post(request);
    }
    // 领取奖励请求
    public function sendGetReward(value:int, playType:int) : void {
        var request:PeakGetRewardRequest = new PeakGetRewardRequest();
        request.playType = playType;
        request.peakRewardID = value;
        networking.post(request);
    }
    // 首次自动布阵请求
    public function sendFirstAutoEMbattleRequest(playType:int) : void {
        var request:FirstAutoEmbattleRequest = new FirstAutoEmbattleRequest();
        request.playType = playType;
        request.firstAutoEmbattle = true;
        networking.post(request);
    }

    // 修改是否已经打开荣耀标志
    public function sendFirstOpenGloryHallRequest(playType:int, value:Boolean) : void {
        var request:FirstOpenGloryHallRequest = new FirstOpenGloryHallRequest();
        request.playType = playType;
        request.flag = value;
        networking.post(request);
    }

}
}