//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/28.
 */
package kof.game.instance.line {

import QFLib.Utils.CFlashVersion;

import kof.framework.CAbstractHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.scene.CSceneSystem;
import kof.message.Instance.EnterInstanceResponse;
import kof.message.Instance.InstanceOverResponse;
import kof.message.Instance.InstanceUpdateTimeResponse;
import kof.message.Level.EnterLevelResponse;
import kof.message.Level.LevelStartResponse;
import kof.message.Level.LevelStateResponse;
import kof.message.Level.StartPortalResponse;

// 处理副本流程的网络事件
public class CInstanceLineNetEventProcess extends CAbstractHandler {
    public function CInstanceLineNetEventProcess() {

    }

    public override function dispose():void {
        super.dispose();
        _system.unListenEvent(_onInstanceEvent);
    }

    override protected function onSetup():Boolean {
        var ret:Boolean =  super.onSetup();
        _system.listenEvent(_onInstanceEvent);

        return ret;
    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        switch (e.type) {
            case CInstanceEvent.NET_EVENT_INSTANCE_ENTER :
                _onEnterInstance(e);
                break;
            case CInstanceEvent.NET_EVENT_LEVEL_ENTER :
                _onEnterLevel(e);
                break;
            case CInstanceEvent.NET_EVENT_LEVEL_ENTERED :
                _onLevelEntered(e);
                break;
            case CInstanceEvent.NET_EVENT_LEVEL_START :
                _onLevelStart(e);
                break;
            case CInstanceEvent.NET_EVENT_LEVEL_PORTAL_START :
                _onLevelPortalStart(e);
                break;
            case CInstanceEvent.NET_EVENT_UPDATE_TIME :
                _onUpdateTime(e);
                break;
            case CInstanceEvent.NET_EVENT_STOP_INSTANCE :
                _onStopInstance(e);
                break;
        }
    }

    private function _onEnterInstance(e:CInstanceEvent) : void {
        // 退出副本操作
        _system.onExitInstance();

        // 进入副本操作
        var response:EnterInstanceResponse = e.data as EnterInstanceResponse;
        _system.onEnterInstance(response.instanceID);
    }

    private function _onEnterLevel(e:CInstanceEvent) : void {
        var response:EnterLevelResponse = e.data as EnterLevelResponse;
        _system.onEnterLevel(response);
    }

    private function _onLevelEntered(e:CInstanceEvent) : void {
        var response : LevelStartResponse = e.data as LevelStartResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.LEVEL_ENTER, response.remainTime));
        var manager:CLevelManager = _levelSystem.getBean(CLevelManager);
        manager.onLevelEntered();
    }
    private function _onLevelStart(e:CInstanceEvent) : void {
        var response : LevelStateResponse = e.data as LevelStateResponse;
        if(response.state == 1){ // 1 : 关卡正式开始, 目前只有这个
            var manager:CLevelManager = _levelSystem.getBean(CLevelManager);
            manager.onStarted();
            _system.onLevelStart();
        }
    }
    private function _onLevelPortalStart(e:CInstanceEvent) : void {
        var response:StartPortalResponse = e.data as StartPortalResponse;
        _levelSystem.startPortal(response.portalWay);

    }
    private function _onUpdateTime(e:CInstanceEvent) : void {
        var response:InstanceUpdateTimeResponse = e.data as InstanceUpdateTimeResponse;
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.INSTANCE_UPDATE_TIME, response.remainTime));
    }


    private function _onStopInstance(e:CInstanceEvent) : void {
        var isSuccess:Boolean = e.data as Boolean;
        _system.isEndByStop = isSuccess; // 惹stop成功, 则...
        system.dispatchEvent(new CInstanceEvent(CInstanceEvent.STOP_INSTANCE, isSuccess));
    }

    [Inline]
    private function get _system() : CInstanceSystem {
        return system as CInstanceSystem;
    }
    private function get _levelSystem():CLevelSystem {
        return system.stage.getSystem(CLevelSystem) as CLevelSystem;
    }

}
}
