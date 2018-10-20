//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/19.
 */
package kof.game.title {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.title.data.CTitleData;
import kof.game.title.event.CTitleEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Title.TitleDataRequest;
import kof.message.Title.TitleDataResponse;
import kof.message.Title.TitleInfoChangeResponse;
import kof.message.Title.TitleWearRequest;
import kof.message.Title.TitleWearResponse;

public class CTitleNetHandler extends CNetHandlerImp {
    public function CTitleNetHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        bind(TitleDataResponse, _onData);
        bind(TitleInfoChangeResponse, _onDataUpdate);
        bind(TitleWearResponse, _onWorn);

        return true;
   }
    // =================================== get/set =========================================
    [Inline]
    private function get _system() : CTitleSystem {
        return system as CTitleSystem;
    }
    [Inline]
    public function get data() : CTitleData {
        return _system.data;
    }
    // =================================== S 2 C=========================================

    // 信息反馈, 客户端主动请求，服务器返回
    private final function _onData(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:TitleDataResponse = message as TitleDataResponse;
            var eventDataObject:Object = new Object();
            eventDataObject[CTitleData._curTitle] = response.curTitle;
            eventDataObject[CTitleData._titleInfos] = response.titleInfos;
            var pPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            eventDataObject["isSelf"] = response.roleId == pPlayerData.ID;
            _system.sendEvent(new CTitleEvent(CTitleEvent.NET_EVENT_DATA, null, eventDataObject));
        }
    }
    // 信息更新, 服务器主动返回
    private final function _onDataUpdate(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:TitleInfoChangeResponse = message as TitleInfoChangeResponse;
            _system.sendEvent(new CTitleEvent(CTitleEvent.NET_EVENT_UPDATE_DATA, null, response.targetInfo));
        }
    }
    // 穿戴
    private final function _onWorn(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (!isError) {
            var response:TitleWearResponse = message as TitleWearResponse;
            _system.sendEvent(new CTitleEvent(CTitleEvent.NET_EVENT_WEAR, null, response.curTitle));
        }
    }
    // =================================== C 2 S=========================================


    // 信息请求
    public function sendGetData(playerUID:Number) : void {
        var request:TitleDataRequest = new TitleDataRequest();
        request.roleId = playerUID;
        networking.post(request);
    }
    // 信息请求
    public function sendGetOtherData(playerUID:Number) : void {
        var request:TitleDataRequest = new TitleDataRequest();
        request.roleId = playerUID;
        networking.post(request);
    }
    // 穿戴
    public function sendToWear(configId:int) : void {
        var request:TitleWearRequest = new TitleWearRequest();
        request.configId = configId;
        networking.post(request);
    }

}
}