//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/23.
 */
package kof.game.streetFighter {

import QFLib.Foundation.CTime;


import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.event.CStreetFighterEvent;
import kof.message.CAbstractPackMessage;
import kof.message.StreetFighter.StreetFighterAgainChallengeRequest;
import kof.message.StreetFighter.StreetFighterDisconnectedResponse;
import kof.message.StreetFighter.StreetFighterEnterRequest;
import kof.message.StreetFighter.StreetFighterEnterResetResponse;
import kof.message.StreetFighter.StreetFighterFightReportRequest;
import kof.message.StreetFighter.StreetFighterFightReportResponse;
import kof.message.StreetFighter.StreetFighterGamePromptResponse;
import kof.message.StreetFighter.StreetFighterGetRewardRequest;
import kof.message.StreetFighter.StreetFighterGetRewardResponse;
import kof.message.StreetFighter.StreetFighterHeroSelectRequest;
import kof.message.StreetFighter.StreetFighterHeroSelectResponse;
import kof.message.StreetFighter.StreetFighterInfoRequest;
import kof.message.StreetFighter.StreetFighterInfoResponse;
import kof.message.StreetFighter.StreetFighterInfoUpdateResponse;
import kof.message.StreetFighter.StreetFighterLoadingResponse;
import kof.message.StreetFighter.StreetFighterMatchCancelRequest;
import kof.message.StreetFighter.StreetFighterMatchEnemyInfoResponse;
import kof.message.StreetFighter.StreetFighterMatchRequest;
import kof.message.StreetFighter.StreetFighterProgressSyncRequest;
import kof.message.StreetFighter.StreetFighterProgressSyncResponse;
import kof.message.StreetFighter.StreetFighterRankingRequest;
import kof.message.StreetFighter.StreetFighterRankingResponse;
import kof.message.StreetFighter.StreetFighterSelectHeroReadyRequest;
import kof.message.StreetFighter.StreetFighterSelectHeroReadyResponse;
import kof.message.StreetFighter.StreetFighterSettlementResponse;
import kof.message.StreetFighter.StreetFighterSyncHeroRequest;
import kof.message.StreetFighter.StreetFighterSyncHeroResponse;

public class CStreetFighterNetHandler extends CNetHandlerImp {
    public function CStreetFighterNetHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        bind(StreetFighterInfoResponse, _onData);// 街头争霸信息反馈
        bind(StreetFighterInfoUpdateResponse, _onDataUpdate);// 街头争霸信息改变反馈
        bind(StreetFighterMatchEnemyInfoResponse, _onMatchEnemyInfo);// 街头争霸匹配对手信息反馈
        bind(StreetFighterHeroSelectResponse, _onHeroSelect);// 街头争霸出站格斗家选定反馈
        bind(StreetFighterLoadingResponse, _onLoading);// 街头争霸加载界面反馈
        bind(StreetFighterProgressSyncResponse, _onProgressSync);// 街头争霸进度同步反馈
        bind(StreetFighterDisconnectedResponse, _onDisconnected);// 街头争霸匹配对手掉线反馈
        bind(StreetFighterSettlementResponse, _onSettlement);// 街头争霸结算反馈
        bind(StreetFighterGamePromptResponse, _onGamePrompt);// 街头争霸错误码反馈
        bind(StreetFighterRankingResponse, _onRanking);// 街头争霸排行榜反馈
        bind(StreetFighterFightReportResponse, _onReport);// 街头争霸战报反馈
        bind(StreetFighterEnterResetResponse, _onReset);// 街头争霸进场重置请求
        bind(StreetFighterGetRewardResponse, _onGetReward);//
        bind(StreetFighterSelectHeroReadyResponse, _onSelectHeroReady);//
        bind(StreetFighterSyncHeroResponse, _onEnemySelectHeroSync); // 街头争霸同步选择格斗家反馈



        return true;
   }
    // =================================== get/set =========================================
    [Inline]
    private function get _system() : CStreetFighterSystem {
        return system as CStreetFighterSystem;
    }
    [Inline]
    public function get data() : CStreetFighterData {
        return _system.data;
    }
    // =================================== S 2 C=========================================

    // 信息反馈, 客户端主动请求，服务器返回
    private final function _onData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterInfoResponse = message as StreetFighterInfoResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_DATA, null, response.streetFighterData));
        }
    }
    // 信息更新, 服务器主动返回
    private final function _onDataUpdate(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterInfoUpdateResponse = message as StreetFighterInfoUpdateResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_UPDATE_DATA, null, response.streetFighterDataUpdate));
        }
    }

    // 街头争霸匹配对手信息反馈
    private final function _onMatchEnemyInfo(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterMatchEnemyInfoResponse = message as StreetFighterMatchEnemyInfoResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_MATCH_DATA, null, response.matchData));
        }
    }

    // 街头争霸出站格斗家选定反馈
    private final function _onHeroSelect(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterHeroSelectResponse = message as StreetFighterHeroSelectResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_SELECTED_HERO, null, response.enemyHeroID));
        }
    }

    // 街头争霸加载界面反馈.客户端进loading - 拳皇大赛。这个是进度更新
    private final function _onLoading(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterLoadingResponse = message as StreetFighterLoadingResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_LOADING_DATA, null, response.loadingData));
        }
    }

    // 街头争霸进度同步反馈
    private final function _onProgressSync(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterProgressSyncResponse = message as StreetFighterProgressSyncResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_LOADING_PROGRESS_SYNC_DATA, null, response.enemyProgress));
        }
    }

    // 街头争霸匹配对手掉线反馈 , 需要停止流程
    private final function _onDisconnected(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterDisconnectedResponse = message as StreetFighterDisconnectedResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_ENTER_ERROR, null, response.flag));
        }
    }
    // 街头争霸结算反馈
    private final function _onSettlement(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterSettlementResponse = message as StreetFighterSettlementResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_SETTLEMENT_DATA, null, response.settlementData));
        }
    }
    // 街头争霸错误码反馈
    private final function _onGamePrompt(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterGamePromptResponse = message as StreetFighterGamePromptResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_GAME_PROMT, null, response.gamePromptID));
        }
    }
    // 街头争霸排行榜反馈
    private final function _onRanking(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterRankingResponse = message as StreetFighterRankingResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_RANK_DATA, null, response.rankDatas));
        }
    }

    // 街头争霸战报反馈
    private final function _onReport(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterFightReportResponse = message as StreetFighterFightReportResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_REPORT_DATA, null, response));
        }
    }

    // 街头争霸进场重置请求
    private final function _onReset(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterEnterResetResponse = message as StreetFighterEnterResetResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_NOTIFY_CLIENT_REFRESH, null, response.flag));
        }
    }
    //
    private final function _onGetReward(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        setProtocolBusy(GET_REWARD, false);
        if (!isError) {
            var response:StreetFighterGetRewardResponse = message as StreetFighterGetRewardResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_GET_REWARD, null, response.rewardList));
        }
    }
    private final function _onSelectHeroReady(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterSelectHeroReadyResponse = message as StreetFighterSelectHeroReadyResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_SELECT_HERO_READY, null));
        }
    }
    private final function _onEnemySelectHeroSync(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:StreetFighterSyncHeroResponse = message as StreetFighterSyncHeroResponse;
            _system.sendEvent(new CStreetFighterEvent(CStreetFighterEvent.NET_EVENT_SELECT_HERO_SYNC, null, response.enemyHeroID));
        }
    }

    // =================================== C 2 S=========================================


    // 街头争霸信息请求
    public function sendGetData() : void {
        var request:StreetFighterInfoRequest = new StreetFighterInfoRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 街头争霸匹配请求
    public function sendMatchRequest() : void {
        var request:StreetFighterMatchRequest = new StreetFighterMatchRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 街头争霸匹配取消请求
    public function sendCancelMatchRequest() : void {
        var request:StreetFighterMatchCancelRequest = new StreetFighterMatchCancelRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 街头争霸出站格斗家选定请求
    public function sendSelectHeroRequest(heroID:int) : void {
        var request:StreetFighterHeroSelectRequest = new StreetFighterHeroSelectRequest();
        request.heroID = heroID;
        networking.post(request);
    }
    // 街头争霸进度同步请求
    public function sendProgressSyncRequest(progress:int) : void {
        var request:StreetFighterProgressSyncRequest = new StreetFighterProgressSyncRequest();
        request.progress = progress;
        networking.post(request);
    }
    // 街头争霸手动领取奖励请求
    public function sendGetRewardRequest(reward:int) : void {
        if (isProtocolBusy(GET_REWARD)) {
            return ;
        }

        this.setProtocolBusy(GET_REWARD, true);
        var request:StreetFighterGetRewardRequest = new StreetFighterGetRewardRequest();
        request.streetFighterRewardID = reward;
        networking.post(request);
    }
    // 街头争霸排行榜请求
    public function sendGetRank() : void {
        var request:StreetFighterRankingRequest = new StreetFighterRankingRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 街头争霸战报请求
    public function sendGetReport() : void {
        var request:StreetFighterFightReportRequest = new StreetFighterFightReportRequest();
        request.flag = 1;
        networking.post(request);
    }
    public var lastSendEnterTime:Number = 0;
    // 街头争霸进场请求
    public function sendEnterRequest() : void {
        lastSendEnterTime = CTime.getCurrServerTimestamp();
        var request:StreetFighterEnterRequest = new StreetFighterEnterRequest();
        request.flag = 1;
        networking.post(request);
    }

    // 街头争霸 选择人物界面加载好
    public function sendSelectHeroReady() : void {
        var request:StreetFighterSelectHeroReadyRequest = new StreetFighterSelectHeroReadyRequest;
        request.flag = 1;
        networking.post(request);
    }
    // 街头争霸 选人同步
    public function sendSelectHeroSync(heroID:int) : void {
        var request:StreetFighterSyncHeroRequest = new StreetFighterSyncHeroRequest;
        request.heroID = heroID;
        networking.post(request);
    }
    // 重新挑战
    public function sendRefight() : void {
        var request:StreetFighterAgainChallengeRequest = new StreetFighterAgainChallengeRequest;
        request.flag = 1;
        networking.post(request);
    }

    public static const GET_REWARD:int = 0;
}
}