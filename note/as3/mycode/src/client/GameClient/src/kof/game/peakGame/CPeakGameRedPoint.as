//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/9/20.
 */
package kof.game.peakGame {

import kof.framework.CAbstractHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.peakGame.data.CPeakGameData;
import kof.game.peakGame.enum.EPeakGameDataEventType;
import kof.game.peakGame.event.CPeakGameEvent;

public class CPeakGameRedPoint extends CAbstractHandler {
    public function CPeakGameRedPoint() {

    }

    public override function dispose() : void {
        super.dispose();
        if (_system) {
            _system.removeEventListener(CPeakGameEvent.DATA_EVENT, _onDataUpdate);
        }
    }

    public function processNotify() : void {
        _system.addEventListener(CPeakGameEvent.DATA_EVENT, _onDataUpdate);
    }

    public function _isFightNotify(pPeakData:CPeakGameData) : Boolean {
        return pPeakData.dayFightCount < 2;
    }
    public function _isDailyRewardNotify(pPeakData:CPeakGameData) : Boolean {
        return pPeakData.rewardData.isDailyCanReward;
    }
    public function _isWeekRewardNotify(pPeakData:CPeakGameData) : Boolean {
        return pPeakData.rewardData.isWeekCanReward;
    }

    private function _onDataUpdate(e:CPeakGameEvent) : void {
        var pPeakData:CPeakGameData = e.data as CPeakGameData; // data 包括了normal和fair 两种
        if (e.type == CPeakGameEvent.DATA_EVENT && e.subEvent == EPeakGameDataEventType.DATA) {
            var bundleTarget:ISystemBundle = _system;

            var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if (pSystemBundleContext) {
                var bCurNotificationValue:Boolean = pSystemBundleContext.getUserData(bundleTarget, CBundleSystem.NOTIFICATION, false);
                var isFightNotify:Boolean = _isFightNotify(pPeakData);
                var isDailyRewardNotify:Boolean = _isDailyRewardNotify(pPeakData);
                var isWeekRewardNotify:Boolean = _isWeekRewardNotify(pPeakData);

                // 外部图标
                if (isFightNotify || isDailyRewardNotify || isWeekRewardNotify) {
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

    private function get _system() : CPeakGameSystem {
        return system as CPeakGameSystem;
    }
}
}
