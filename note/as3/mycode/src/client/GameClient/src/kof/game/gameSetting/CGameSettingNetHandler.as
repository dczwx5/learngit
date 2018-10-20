//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/16.
 */
package kof.game.gameSetting {

import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.gameSetting.event.CGameSettingEvent;
import kof.message.CAbstractPackMessage;
import kof.message.GameSetting.GetAllGameSettingRequest;
import kof.message.GameSetting.GetAllGameSettingResponse;
import kof.message.GameSetting.SetGameSettingRequest;
import kof.message.GameSetting.SetGameSettingResponse;

public class CGameSettingNetHandler extends CNetHandlerImp {
    public function CGameSettingNetHandler()
    {
        super();
    }

    override protected function onSetup() : Boolean {
        super.onSetup();

        bind( GetAllGameSettingResponse, _getAllGameSettingResponse );
        bind( SetGameSettingResponse, _setGameSettingResponse );

        return true;
    }

//======================================================================================================>>
    /**
     * 获得所有游戏设置
     */
    public function getAllGameSettingRequest():void
    {
        var request:GetAllGameSettingRequest = new GetAllGameSettingRequest();
        request.flag = 1;
        networking.post(request);
    }

    /**
     * 获得所有游戏设置响应
     * @param net
     * @param message
     */
    private function _getAllGameSettingResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if(isError)
        {
            return;
        }

        var response:GetAllGameSettingResponse = message as GetAllGameSettingResponse;
        if(response)
        {
            (system.getHandler(CGameSettingManager) as CGameSettingManager).updateGameSettingData(response.settings);
            system.dispatchEvent(new CGameSettingEvent(CGameSettingEvent.UpdateAllSettings, null));
        }
    }
//<<======================================================================================================



//======================================================================================================>>
    /**
     * 游戏选项设置
     */
    public function setGameSettingRequest(setting:Object):void
    {
        var request:SetGameSettingRequest = new SetGameSettingRequest();
        request.settings = setting;
        networking.post(request);
    }

    /**
     * 游戏选项响应
     * @param net
     * @param message
     */
    private function _setGameSettingResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if(isError)
        {
            return;
        }

        var response:SetGameSettingResponse = message as SetGameSettingResponse;
    }
//<<======================================================================================================

}
}
