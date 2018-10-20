//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/21.
 */
package kof.game.streetFighter {

import kof.framework.CAbstractHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.streetFighter.data.CStreetFighterData;
import kof.game.streetFighter.data.CStreetFighterRewardData;
import kof.game.streetFighter.enum.EStreetFighterDataEventType;
import kof.game.streetFighter.event.CStreetFighterEvent;
import kof.table.StreetFighterReward;

public class CStreetFighterRedPoint extends CAbstractHandler {
    public function CStreetFighterRedPoint() {

    }

    public override function dispose() : void {
        super.dispose();
        if (_system) {
            _system.removeEventListener(CStreetFighterEvent.DATA_EVENT, _onDataUpdate);
        }
    }

    public function processNotify() : void {
        _system.addEventListener(CStreetFighterEvent.DATA_EVENT, _onDataUpdate);
    }

    public static function hasFightRewardCanGet(streetData:CStreetFighterData) : Boolean {
        var ret:Boolean;
        var record:StreetFighterReward = getCanRewardB(streetData, [CStreetFighterRewardData.TYPE_FIGHT_COUNT,
                CStreetFighterRewardData.TYPE_WIN_COUNT,
                CStreetFighterRewardData.TYPE_ALWAYS_WIN_COUNT]);
        ret = record != null;
        return ret;
    }
    public static function hasScoreRewardCanGet(streetData:CStreetFighterData) : Boolean {
        var record:StreetFighterReward = getCanRewardB(streetData, [CStreetFighterRewardData.TYPE_SCORE]);
        var ret:Boolean = record != null;
        return ret;
    }
    public static function getCanRewardB(streetData:CStreetFighterData, typeList:Array) : StreetFighterReward {
        var dataList:Array = streetData.rewardData.getRewardRecordListByType(typeList);

        for each (var record:StreetFighterReward in dataList) {
            var target:int = record.param[0] as int;
            var curValue:int = streetData.getCurValueByType(record.type);
            var finish:Boolean = curValue >= target;
            if (finish) {
                var hasReward:Boolean = streetData.rewardData.hasRewarded(record.ID);
                if (!hasReward) {
                    return record;
                }
            }
        }
        return null;
    }
    // 获得可做任务
    public static function getCanProcessReward(streetData:CStreetFighterData, typeList:Array) : StreetFighterReward {
        var dataList:Array = streetData.rewardData.getRewardRecordListByType(typeList);

        for each (var record:StreetFighterReward in dataList) {
            var hasReward:Boolean = streetData.rewardData.hasRewarded(record.ID);
            if (!hasReward) {
                return record;
            }
        }
        return null;
    }

    private function _onDataUpdate(e:CStreetFighterEvent) : void {
        var pStreetData:CStreetFighterData = e.data as CStreetFighterData;
        if (e.type == CStreetFighterEvent.DATA_EVENT && e.subEvent == EStreetFighterDataEventType.DATA) {
            var bundleTarget:ISystemBundle = _system;

            var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if (pSystemBundleContext) {
                var bCurNotificationValue:Boolean = pSystemBundleContext.getUserData(bundleTarget, CBundleSystem.NOTIFICATION, false);
                var hasFightReward:Boolean = hasFightRewardCanGet(pStreetData);
                var hasScoreReward:Boolean = hasScoreRewardCanGet(pStreetData);

                // 外部图标
                if (hasFightReward || hasScoreReward) {
                    if (!bCurNotificationValue) {
                        pSystemBundleContext.setUserData(bundleTarget, CBundleSystem.NOTIFICATION, true);
                    }
                } else {
                    if (bCurNotificationValue) {
                        pSystemBundleContext.setUserData(bundleTarget, CBundleSystem.NOTIFICATION, false);
                    }
                }
            }
        }
    }

    private function get _system() : CStreetFighterSystem {
        return system as CStreetFighterSystem;
    }
}
}
