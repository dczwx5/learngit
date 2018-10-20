//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.story.data.CStoryData;
import kof.game.story.event.CStoryEvent;
import kof.message.CAbstractPackMessage;
import kof.message.HeroStory.HeroStoryChallengeRequest;
import kof.message.HeroStory.HeroStoryChallengeResponse;
import kof.message.HeroStory.HeroStoryChallengeResultResponse;
import kof.message.HeroStory.HeroStoryInfoChangedResponse;
import kof.message.HeroStory.HeroStoryInfoRequest;
import kof.message.HeroStory.HeroStoryInfoResponse;
import kof.message.HeroStory.HeroStoryResetChallengeRequest;
import kof.message.HeroStory.HeroStoryResetChallengeResponse;

public class CStoryNetHandler extends CNetHandlerImp {
    public function CStoryNetHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        bind(HeroStoryInfoResponse, _onData);
        bind(HeroStoryInfoChangedResponse, _onDataUpdate);
        bind(HeroStoryChallengeResultResponse, _onSettlement);
        bind(HeroStoryResetChallengeResponse, _onBuyFightCount);
        bind(HeroStoryChallengeResponse, _onFight);



        return true;
   }
    // =================================== get/set =========================================
    [Inline]
    private function get _system() : CStorySystem {
        return system as CStorySystem;
    }
    [Inline]
    public function get data() : CStoryData {
        return _system.data;
    }
    // =================================== S 2 C=========================================

    // 信息反馈, 客户端主动请求，服务器返回
    private final function _onData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:HeroStoryInfoResponse = message as HeroStoryInfoResponse;
            _system.sendEvent(new CStoryEvent(CStoryEvent.NET_EVENT_DATA, null, response.gates));
        }
    }
    // 信息更新, 服务器主动返回
    private final function _onDataUpdate(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:HeroStoryInfoChangedResponse = message as HeroStoryInfoChangedResponse;
            _system.sendEvent(new CStoryEvent(CStoryEvent.NET_EVENT_UPDATE_DATA, null, response.changedGates));
        }
    }
    // 结算反馈
    private final function _onSettlement(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:HeroStoryChallengeResultResponse = message as HeroStoryChallengeResultResponse;
            _system.sendEvent(new CStoryEvent(CStoryEvent.NET_EVENT_SETTLEMENT_DATA, null, response));
        }
    }
    // 购买次数
    private final function _onBuyFightCount(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:HeroStoryResetChallengeResponse = message as HeroStoryResetChallengeResponse;
            _system.sendEvent(new CStoryEvent(CStoryEvent.NET_EVENT_BUY_FIGHT_COUNT, null, response));
        }
    }
    // 进入列传
    private final function _onFight(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:HeroStoryChallengeResponse = message as HeroStoryChallengeResponse;
            _system.sendEvent(new CStoryEvent(CStoryEvent.NET_EVENT_FIGHT, null, response));
        }
    }

    // =================================== C 2 S=========================================


    // 信息请求
    public function sendGetData() : void {
        var request:HeroStoryInfoRequest = new HeroStoryInfoRequest();
        request.flag = 1;
        networking.post(request);
    }
    // 挑战请求
    // gateIndex : start by 1
    public function sendToFight(heroID:int, gateIndex:int) : void {
        var request:HeroStoryChallengeRequest = new HeroStoryChallengeRequest();
        request.heroID = heroID;
        request.gateIndex = gateIndex;
        networking.post(request);
    }
    // 购买次数
    public function sendBuyFightCount(heroID:int, gateIndex:int) : void {
        var request:HeroStoryResetChallengeRequest = new HeroStoryResetChallengeRequest();
        request.heroID = heroID;
        request.gateIndex = gateIndex;
        networking.post(request);
    }

    public static const GET_REWARD:int = 0;
}
}