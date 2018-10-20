//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/9/21.
 */
package kof.game.instance.mainInstance {

import kof.game.instance.*;

import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;

import kof.framework.CAbstractHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.event.CInstanceEvent;

public class CInstanceRedPoint extends CAbstractHandler {
    public function CInstanceRedPoint() {

    }

    public override function dispose() : void {
        super.dispose();
        if (_system) {
            system.removeEventListener(CInstanceEvent.INSTANCE_MODIFY, _onDataUpdate);
            system.removeEventListener(CInstanceEvent.INSTANCE_DATA, _onDataUpdate);
            system.removeEventListener(CInstanceEvent.CHAPTER_REWARD, _onDataUpdate);

        }
    }

    public function processNotify() : void {
        system.addEventListener(CInstanceEvent.INSTANCE_MODIFY, _onDataUpdate);
        system.addEventListener(CInstanceEvent.INSTANCE_DATA, _onDataUpdate);
        system.addEventListener(CInstanceEvent.CHAPTER_REWARD, _onDataUpdate);

    }
    public function refresh() : void {
        var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if (pSystemBundleContext) {
            // 剧情
            _processScenario(pSystemBundleContext);
            // 精英
            _processElite(pSystemBundleContext);
        }
    }

    private function _isScenarioNotify() : Boolean {
        return _system.instanceData.chapterList.isScenarioHasReward();
    }
    private function _isEliteNotify() : Boolean {
        return _system.instanceData.chapterList.isEliteHasReward() || _system.instanceData.instanceList.isEliteHasExternsReward();
    }

    private function _onDataUpdate(e:CInstanceEvent) : void {
        if (e.type == CInstanceEvent.INSTANCE_DATA || e.type == CInstanceEvent.INSTANCE_MODIFY || e.type == CInstanceEvent.CHAPTER_REWARD) {

            var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if (pSystemBundleContext) {
                // 剧情
                _processScenario(pSystemBundleContext);
                // 精英
                _processElite(pSystemBundleContext);
            }
        }
    }

    private function _processScenario(pSystemBundleContext:ISystemBundleContext) : void {
        var pBundleScenario:ISystemBundle = _system;
        if (pSystemBundleContext.getSystemBundleState( pBundleScenario ) != CSystemBundleContext.STATE_STARTED) {
            return ;
        }

        var bScenarioNotificationValue:Boolean = pSystemBundleContext.getUserData(pBundleScenario, CBundleSystem.NOTIFICATION, false);
        var isScenarioFightNotify:Boolean = _isScenarioNotify();

        // 外部图标
        if (isScenarioFightNotify) {
            if (!bScenarioNotificationValue) {
                pSystemBundleContext.setUserData(pBundleScenario, CBundleSystem.NOTIFICATION, true);
            }
        } else {
            if (bScenarioNotificationValue) {
                pSystemBundleContext.setUserData(pBundleScenario, CBundleSystem.NOTIFICATION, false);
            }
        }
    }
    private function _processElite(pSystemBundleContext:ISystemBundleContext) : void {
        var pBundleElite:ISystemBundle = _system.eliteBundle;
        if (pSystemBundleContext.getSystemBundleState( pBundleElite ) != CSystemBundleContext.STATE_STARTED) {
            return ;
        }

        var bEliteNotificationValue:Boolean = pSystemBundleContext.getUserData(pBundleElite, CBundleSystem.NOTIFICATION, false);
        var isFightNotify:Boolean = _isEliteNotify();

        // 外部图标
        if (isFightNotify) {
            if (!bEliteNotificationValue) {
                pSystemBundleContext.setUserData(pBundleElite, CBundleSystem.NOTIFICATION, true);
            }
        } else {
            if (bEliteNotificationValue) {
                pSystemBundleContext.setUserData(pBundleElite, CBundleSystem.NOTIFICATION, false);
            }
        }
    }

    private function get _system() : CInstanceSystem {
        return system as CInstanceSystem;
    }
}
}
