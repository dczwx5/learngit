//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/13.
 */
package kof.game.common.system {


import kof.framework.CAbstractHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.message.Instance.InstanceOverResponse;

import morn.core.handlers.Handler;

public class CInstanceOverHandler extends CAbstractHandler {

    private var _instanceType:int;
    private var _allFinishProcessHandler:Handler;
    private var _assertHandler:Handler;
    private var _overHandler:Handler;
    public function CInstanceOverHandler(instanceType:int, allFinishProcessHandler:Handler, assertHandler:Handler = null, overHandler:Handler = null) {
        _instanceType = instanceType;
        _allFinishProcessHandler = allFinishProcessHandler;
        _assertHandler = assertHandler;
        _overHandler = overHandler;
    }

    public override function dispose() : void {
        super.dispose();

        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.NET_EVENT_INSTANCE_OVER, _onInstanceOverHandler);
        }
    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();

        return ret;
    }


    public function listenEvent() : void {
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.addEventListener(CInstanceEvent.NET_EVENT_INSTANCE_OVER, _onInstanceOverHandler);
        }
    }
    public function unlistenEvent() : void {
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.NET_EVENT_INSTANCE_OVER, _onInstanceOverHandler);
        }
    }
    private function _onInstanceOverHandler(e:CInstanceEvent)　:　void　{
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;

        var checkInstanceType:Boolean = _instanceType == pInstanceSystem.instanceType || _instanceType == EInstanceType.TYPE_ALL;
        if (!checkInstanceType) return ;

        if (e.type == CInstanceEvent.NET_EVENT_INSTANCE_OVER) {
            var response:InstanceOverResponse = e.data as InstanceOverResponse;
            pInstanceSystem.isEndByStop = response.fightResult == 2;
            if (pInstanceSystem.isEndByStop) {
                // 中断退出, 服务器不发结算, 直接走结算流程
                instanceOverEventProcess(null);
            } else {
                if (_overHandler) {
                    _overHandler.executeWith([e]);
                }
            }
        }
    }

    public function instanceOverEventProcess(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (!pInstanceSystem) {
            return ;
        }
        var checkInstanceType:Boolean = _instanceType == pInstanceSystem.instanceType || _instanceType == EInstanceType.TYPE_ALL;
        if (!checkInstanceType) return ;

        pInstanceSystem.startWaitAllGameObjectFinish();
        pInstanceSystem.addEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
    }

    private function _onInstanceAllGameObjectFinish(e:CInstanceEvent) : void {
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.INSTANCE_ALL_GAME_OBJECT_FINISH_OR_TIME_OUT, _onInstanceAllGameObjectFinish);
            if (pInstanceSystem.isEndByStop) {
                // 如果是中途结算的, 则不显示结算
                if (_assertHandler) {
                    _assertHandler.execute();
                }
                pInstanceSystem.exitInstance();
            } else {
                if (_allFinishProcessHandler) {
                    _allFinishProcessHandler.execute();
                }
            }
        }
    }
}
}
