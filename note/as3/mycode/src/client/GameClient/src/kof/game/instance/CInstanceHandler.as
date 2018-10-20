//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/1.
 */
package kof.game.instance {


import kof.framework.CAppSystem;
import kof.framework.INetworking;
import kof.game.common.system.CNetHandlerImp;
import kof.game.instance.event.CInstanceEvent;
import kof.message.CAbstractPackMessage;
import kof.message.Instance.EnterInstanceRequest;
import kof.message.Instance.EnterInstanceResponse;
import kof.message.Instance.ExitInstanceRequest;
import kof.message.Instance.ExitInstanceResponse;
import kof.message.Instance.InstanceOverResponse;
import kof.message.Instance.InstanceUpdateTimeResponse;
import kof.message.Instance.StopInstanceRequest;
import kof.message.Instance.StopInstanceResponse;
import kof.message.Level.EnterLevelResponse;
import kof.message.Level.LevelStartResponse;
import kof.message.Level.LevelStateResponse;
import kof.message.Level.StartPortalResponse;
import kof.message.Player.LoadingLogRequest;

// 关卡通信, 接收服务器发来的信息
public class CInstanceHandler extends CNetHandlerImp {
    public function CInstanceHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();
    }
    override protected function onSetup():Boolean {
        super.onSetup();
        // 流程
        bind(EnterInstanceResponse, _onEnterInstanceResponse);
        bind(EnterLevelResponse, _onEnterLevelResponse);
        bind(LevelStartResponse, _onLevelEnteredResponse);
        bind(LevelStateResponse,_onLevelStartResponse); // 关卡开始
        bind(StartPortalResponse,_onStartPortalResponse);

        bind(InstanceUpdateTimeResponse, _onUpdateTime);
        bind(InstanceOverResponse, _onOverInstance);
        bind(ExitInstanceResponse, _onExitInstanceResponse);
        bind(StopInstanceResponse, _onStopInstanceResponse);

        return true;
   }


// 进入, 请求配置
    override protected function enterSystem(system:CAppSystem):void {
        var mapType : int = 1;
        var roleData : Object = system.stage.configuration.getRaw( "role.data" );
        if ( roleData ) {
            mapType = int( roleData.mapType );
        }

        if (mapType == 2) {
            var fbID:int = int(roleData.mapID);
            _instanceSystem.enterInstance(fbID);
        }
    }
    // ======================================S2C=============================================

    // =================================流程=====================================

    // 进入副本反馈
    private final function _onEnterInstanceResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:EnterInstanceResponse = message as EnterInstanceResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_INSTANCE_ENTER, response));
    }
    /**
     * @准备进入关卡处理
     */
    private final function _onEnterLevelResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:EnterLevelResponse = message as EnterLevelResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_LEVEL_ENTER, response));
    }

    private function _onLevelEnteredResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response : LevelStartResponse = message as LevelStartResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_LEVEL_ENTERED, response));
    }
    // 关卡开始
    private function _onLevelStartResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:LevelStateResponse = message as LevelStateResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_LEVEL_START, response));
    }
    // 开始传送
    private function _onStartPortalResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void{
        if (isError) return ;

        var response:StartPortalResponse = message as StartPortalResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_LEVEL_PORTAL_START, response));
    }

    private function _onUpdateTime(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        if (isError) return ;

        var response:InstanceUpdateTimeResponse = message as InstanceUpdateTimeResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_UPDATE_TIME, response));
    }

    // 通关副本消息
    private function _onOverInstance(net:INetworking, message:CAbstractPackMessage, isError:Boolean) : void {
        if (isError) return ;

        var response:InstanceOverResponse = message as InstanceOverResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_INSTANCE_OVER, response));
    }
    // 退出副本反馈
    private final function _onExitInstanceResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        // 服务器退出副本和进入新副本的协议不是串行的, 会出现先进入副本，再收到退出副本的协议, 因此, 在进入副本时 ， 做退出副本的操作
    }
    // 中途退出副本反馈
    private final function _onStopInstanceResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void {
        var isSuccess:Boolean;
        if (!isError) {
            isSuccess = true;
            system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_STOP_INSTANCE, isSuccess));
        } else {
            isSuccess = false;
            system.dispatchEvent(new CInstanceEvent(CInstanceEvent.NET_EVENT_STOP_INSTANCE, isSuccess));
        }
    }


    // ======================================C2S=============================================

    /**
     * @请求进入副本
     */
    public function sendEnterInstance(instanceID:int) : void {
        var instanceRequest:EnterInstanceRequest = new EnterInstanceRequest();
        instanceRequest.instanceID = instanceID;
        networking.post(instanceRequest);
    }

    /**
     * @请求退出副本
     */
    public function sendExitInstance(flag:Boolean) : void {
        var exitInstanceRequest : ExitInstanceRequest = new ExitInstanceRequest();
        exitInstanceRequest.flag = flag;
        networking.post( exitInstanceRequest );
    }

    // 中断副本, 副本未通关前, 中断
    public function stopInstance() : void {
        var request : StopInstanceRequest = new StopInstanceRequest();
        request.flag = 1;
        networking.post( request );
    }

    public function logLoadingRequest(logID:int) : void {
        var request:LoadingLogRequest = new LoadingLogRequest();
        request.loadingId = logID;
        networking.post( request );
    }


    private function get _instanceSystem() : CInstanceSystem {
        return system as CInstanceSystem;
    }
}
}