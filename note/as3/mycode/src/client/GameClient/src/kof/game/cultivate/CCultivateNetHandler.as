//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/11.
 */
package kof.game.cultivate {

import kof.framework.INetworking;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.event.CCultivateEvent;
import kof.game.common.system.CNetHandlerImp;
import kof.message.CAbstractPackMessage;
import kof.message.ClimbTower.ClimbTowerChallengeRequest;
import kof.message.ClimbTower.ClimbTowerChallengeResultResponse;
import kof.message.ClimbTower.ClimbTowerInfoChangeResponse;
import kof.message.ClimbTower.ClimbTowerInfoRequest;
import kof.message.ClimbTower.ClimbTowerInfoResponse;
import kof.message.ClimbTower.ClimbTowerOpenBoxRequest;
import kof.message.ClimbTower.ClimbTowerOpenBoxResponse;
import kof.message.ClimbTower.ClimbTowerRandomBuffRequest;
import kof.message.ClimbTower.ClimbTowerResetRequest;
import kof.message.ClimbTower.ClimbTowerSelectBuffRequest;
import kof.message.ClimbTower.ClimbTowerSetFlagRequest;
import kof.message.ClimbTower.ClimbTowerSetFlagResponse;

public class CCultivateNetHandler extends CNetHandlerImp {
    public function CCultivateNetHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        bind(ClimbTowerInfoResponse, _onCultivateData);
        bind(ClimbTowerInfoChangeResponse, _onCultivateUpdateData);
        bind(ClimbTowerChallengeResultResponse, _onCultivateResult);
        bind(ClimbTowerOpenBoxResponse, _onRewardBox);
        bind(ClimbTowerSetFlagResponse, _onSetOpenFlagResponse);

        return true;
   }
    // =================================== get/set =========================================
    [Inline]
    private function get _climpSystem() : CCultivateSystem {
        return system as CCultivateSystem;
    }
    [Inline]
    private function get _climpData() : CClimpData {
        return _climpSystem.climpData;
    }
    // =================================== S 2 C=========================================

    private final function _onCultivateData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            if (isReset) {
                _climpSystem.sendEvent(new CCultivateEvent(CCultivateEvent.NET_EVENT_RESET_DATA, null, response));
                isReset = false;
            }

            var response:ClimbTowerInfoResponse = message as ClimbTowerInfoResponse;
            _climpSystem.sendEvent(new CCultivateEvent(CCultivateEvent.NET_EVENT_DATA, null, response));
        }
    }
    private final function _onCultivateUpdateData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            if (isReset) {
                _climpSystem.sendEvent(new CCultivateEvent(CCultivateEvent.NET_EVENT_RESET_DATA, null, response));
                isReset = false;
            }
            var response:ClimbTowerInfoChangeResponse = message as ClimbTowerInfoChangeResponse;
            _climpSystem.sendEvent(new CCultivateEvent(CCultivateEvent.NET_EVENT_UPDATE_DATA, null, response));
        }
    }

    private final function _onCultivateResult(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:ClimbTowerChallengeResultResponse = message as ClimbTowerChallengeResultResponse;
            _climpSystem.sendEvent(new CCultivateEvent(CCultivateEvent.NET_EVENT_RESULT_DATA, null, response));
        }
    }
    // 领宝箱
    private final function _onRewardBox(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:ClimbTowerOpenBoxResponse = message as ClimbTowerOpenBoxResponse;
            _climpSystem.sendEvent(new CCultivateEvent(CCultivateEvent.NET_EVENT_REWARD_BOX_DATA, null, response));
        }
    }
    private final function _onSetOpenFlagResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {

    }
    // =================================== C 2 S=========================================

    // 请求
    public function sendGetCultivateData() : void {
        var request:ClimbTowerInfoRequest = new ClimbTowerInfoRequest();
        request.flag = 1;
        networking.post(request);
    }
    // fight
    // selectBuffIndex : 从1开始, 数组的坐标, 只有选择了buff才要传, 没有已经有buff, 没有选择的操作的话。传0
    public function sendCultivateFight(levelIndex:int, selectBuffIndex:int) : void {
//        trace("fight cultivate level index : " + levelIndex);
//        return ;
        var request:ClimbTowerChallengeRequest = new ClimbTowerChallengeRequest();
        request.index = levelIndex;
        request.selectBuffIndex = 0; /// 选择buff从另一个协议走;
        networking.post(request);
    }

    // 重置
    public var isReset:Boolean;
    public function sendReset() : void {
        isReset = true;
        var request:ClimbTowerResetRequest = new ClimbTowerResetRequest();
        request.flag = 1;
        networking.post(request);
    }

    // spend : 0 免费, 1花钱
    public function sendRandomBuff(spend:int) : void {
        var request:ClimbTowerRandomBuffRequest = new ClimbTowerRandomBuffRequest();
        request.spend = spend;
        networking.post(request);
    }
    //
    public function sendSelectBuff(buffIndex:int) : void {
        var request:ClimbTowerSelectBuffRequest = new ClimbTowerSelectBuffRequest();
        request.selectBuffIndex = buffIndex;
        networking.post(request);
    }
    public function sendGetRewardBox(index:int) : void {
        var request:ClimbTowerOpenBoxRequest = new ClimbTowerOpenBoxRequest();
        request.index = index;
        networking.post(request);
    }

    public function sendOpenFlag() : void {
        var request:ClimbTowerSetFlagRequest = new ClimbTowerSetFlagRequest();
        request.flags = {openFlag:true};
        networking.post(request);
    }

}
}