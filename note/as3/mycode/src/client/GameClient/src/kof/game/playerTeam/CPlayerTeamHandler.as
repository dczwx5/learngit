//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/23.
 */
package kof.game.playerTeam {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.event.CPlayerEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Player.ChangeHeadRequest;
import kof.message.Player.ChangePrototypeRequest;
import kof.message.Player.LookInfoRequest;
import kof.message.Player.LookInfoResponse;
import kof.message.Player.ModifyPlayerNameRequest;
import kof.message.Player.ModifySighRequest;
import kof.message.Player.RandomNameRequest;

// 关卡通信, 接收服务器发来的信息
public class CPlayerTeamHandler extends CNetHandlerImp {
    public function CPlayerTeamHandler() {
        super();
    }
    override protected function onSetup() : Boolean {
        super.onSetup();

        bind( LookInfoResponse, _onVisitPlayerDataResponse );
        return true;
    }
    public function _onVisitPlayerDataResponse(net : INetworking, message : CAbstractPackMessage, isError:Boolean) : void {
        if (isError) return ;
        var response : LookInfoResponse = message as LookInfoResponse;
        var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
        _system.playerData.updateVisitData(response.infos);
        _system.dispatchEvent(new CPlayerEvent(CPlayerEvent.VISIT_DATA, playerData.visitPlayerData));
    }

//    // ======================================C2S=============================================

    public function sendModifyPlayerName(name:String) : void {
        var request:ModifyPlayerNameRequest = new ModifyPlayerNameRequest();
        request.name = name;
        networking.post(request);
    }
    public function sendRandomName() : void {
        var request:RandomNameRequest = new RandomNameRequest();
        request.randomName = 1;
        networking.post(request);
    }
    public function sendChangeHead(headID:int) : void {
        var request:ChangeHeadRequest = new ChangeHeadRequest();
        request.headID = headID;
        networking.post(request);
    }
    // 修改签名
    public function sendModifySighRequest(sign:String) : void {
        if (sign == null || sign.length == 0) return ;
        var playerData:CPlayerData = _system.playerData;
        if (sign == playerData.teamData.sign) return ;

        var request:ModifySighRequest = new ModifySighRequest();
        request.sign = sign;
        networking.post(request);
    }

    // 请求访问数据
    public function sendGetVisitData(playerUID:Number) : void {
        var request:LookInfoRequest = new LookInfoRequest();
        request.id = playerUID;
        networking.post(request);
    }
    public function sendChangeTeamModel(prototypeID:int) : void {
        var request:ChangePrototypeRequest = new ChangePrototypeRequest();
        request.prototypeID = prototypeID;
        networking.post(request);
    }

    private function get _system() : CPlayerTeamSystem {
        return system as CPlayerTeamSystem;
    }
}
}