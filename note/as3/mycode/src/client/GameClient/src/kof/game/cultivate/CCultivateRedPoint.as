//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/9/21.
 */
package kof.game.cultivate {

import kof.framework.CAbstractHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.cultivate.data.cultivate.CCultivateHeroData;
import kof.game.cultivate.enum.ECultivateDataEventType;
import kof.game.cultivate.event.CCultivateEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;

public class CCultivateRedPoint extends CAbstractHandler {
    public function CCultivateRedPoint() {

    }

    public override function dispose() : void {
        super.dispose();
        if (_system) {
            _system.removeEventListener(CCultivateEvent.DATA_EVENT, _onDataUpdate);
        }
    }

    public function processNotify() : void {
        _system.addEventListener(CCultivateEvent.DATA_EVENT, _onDataUpdate);
    }

    private function _isResetNotify() : Boolean {
        return _system.climpData.cultivateData.otherData.resetTimes > 0;
    }
    private function _isFightNotify() : Boolean {
        var isPass:Boolean = _system.climpData.cultivateData.levelList.curLevelData.passed != 0;
        if (isPass) {
            return false;
        }

        var hasHeroAlive:Boolean = false;
        var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var pPlayerData:CPlayerData = pPlayerSystem.playerData;
        var heroList:Array = pPlayerData.heroList.list;
        var cultivateHeroData:CCultivateHeroData;
        for each (var heroData:CPlayerHeroData in heroList) {

            // hp
            cultivateHeroData = _system.climpData.cultivateData.heroList.getHero(heroData.prototypeID);
            if (cultivateHeroData) {
                hasHeroAlive = cultivateHeroData.HP > 0;
            } else {
                hasHeroAlive = true;
            }
            if (hasHeroAlive) {
                break;
            }
        }

        return hasHeroAlive;
    }

    private function _onDataUpdate(e:CCultivateEvent) : void {
        if (e.type == CCultivateEvent.DATA_EVENT && e.subEvent == ECultivateDataEventType.DATA) {
            var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if (pSystemBundleContext) {
                var bCurNotificationValue:Boolean = pSystemBundleContext.getUserData(_system, CBundleSystem.NOTIFICATION, false);
                var isFightNotify:Boolean = _isFightNotify();
                var isResetNotify:Boolean = _isResetNotify();

                // 外部图标
                if (isFightNotify || isResetNotify) {
                    if (!bCurNotificationValue) {
                        pSystemBundleContext.setUserData(_system, CBundleSystem.NOTIFICATION, true);
                    }
                } else {
                    if (bCurNotificationValue) {
                        pSystemBundleContext.setUserData(_system, CBundleSystem.NOTIFICATION, false);
                    }
                }
            }

        }
    }

    private function get _system() : CCultivateSystem {
        return system as CCultivateSystem;
    }
}
}
