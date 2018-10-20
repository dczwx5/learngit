//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/23.
 */
package kof.game.peak1v1 {

import QFLib.Foundation.CTime;

import kof.framework.CAbstractHandler;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.peak1v1.data.CPeak1v1Data;
import kof.game.peak1v1.data.CPeak1v1RewardRecordData;
import kof.game.peak1v1.enum.EPeak1v1DataEventType;
import kof.game.peak1v1.event.CPeak1v1Event;

public class CPeak1v1RedPoint extends CAbstractHandler {
    public function CPeak1v1RedPoint() {

    }

    public override function dispose() : void {
        super.dispose();
        if (_system) {
            _system.removeEventListener(CPeak1v1Event.DATA_EVENT, _onDataUpdate);
        }
    }

    public function processNotify() : void {
        _system.addEventListener(CPeak1v1Event.DATA_EVENT, _onDataUpdate);
    }

    private function _isRewardDamageNotify(pData : CPeak1v1Data) : Boolean {
        return _isRewardNotifyB(pData, pData.rewardUtil.damageRewardList, pData.totalDamage, pData.isDamageRewardHasGet);
    }
    private function _isRewardFightCountNotify(pData : CPeak1v1Data) : Boolean {
        return _isRewardNotifyB(pData, pData.rewardUtil.joinRewardList, pData.fightCount, pData.isJoinRewardHasGet);
    }
    private function _isRewardWinCountNotify(pData : CPeak1v1Data) : Boolean {
        return _isRewardNotifyB(pData, pData.rewardUtil.winRewardList, pData.winCount, pData.isWinRewardHasGet);
    }
    private function _isRewardNotifyB(pData : CPeak1v1Data, pDataList:Array, curCount:int, rewardHasGetHandler:Function) : Boolean {
        var hasCanReward:Boolean = false;
        for (var i:int = 0; i < pDataList.length; i++) {
            var dataRecord:CPeak1v1RewardRecordData = pDataList[i];
            if (curCount >= dataRecord.startValue && rewardHasGetHandler(dataRecord.ID) == false) {
                hasCanReward = true;
                break;
            }
        }
        return hasCanReward;
    }
    private function _isCanFightNotify(pData : CPeak1v1Data) : Boolean {
        var curTime:Number = CTime.getCurrServerTimestamp();
        var startTime:Number = pData.startTime;
        var endTime:Number = pData.endTime;
        if (curTime >= startTime && curTime <= endTime) {
            return pData.fightCount < pData.fightCountMax;
        }
        return false;
    }

    private function _onDataUpdate(e:CPeak1v1Event) : void {
        var pData : CPeak1v1Data = e.data as CPeak1v1Data;
        if ( e.type == CPeak1v1Event.DATA_EVENT && e.subEvent == EPeak1v1DataEventType.DATA ) {
            var bundleTarget:ISystemBundle = _system;

            var pSystemBundleContext : ISystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
            if (pSystemBundleContext) {
                var bCurNotificationValue:Boolean = pSystemBundleContext.getUserData(bundleTarget, CBundleSystem.NOTIFICATION, false);
                var isCanFight:Boolean = _isCanFightNotify(pData);
                var isRewardDamageNotify:Boolean = _isRewardDamageNotify(pData);
                var isRewardFightCountNotify:Boolean = _isRewardFightCountNotify(pData);
                var isRewardWinCountNotify:Boolean = _isRewardWinCountNotify(pData);

                // 外部图标
                if (isCanFight || isRewardDamageNotify || isRewardFightCountNotify || isRewardWinCountNotify) {
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

    private function get _system() : CPeak1v1System {
        return system as CPeak1v1System;
    }
}
}
