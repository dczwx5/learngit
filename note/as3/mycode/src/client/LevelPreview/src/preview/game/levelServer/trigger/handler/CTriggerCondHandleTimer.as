/**
 * Created by auto on 2016/9/13.
 */
package preview.game.levelServer.trigger.handler {

import flash.utils.getTimer;

import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import kof.game.levelCommon.info.entity.CTrunkTriggerTimerData;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleBase;
import preview.game.levelServer.trigger.AbsLevelServerTrigger;

public class CTriggerCondHandleTimer extends CTriggerCondHandleBase {
    public function CTriggerCondHandleTimer(trigger:AbsLevelServerTrigger) {
        super (trigger);
    }

    public override function handler(cond:CTrunkConditionInfo,triggerFilter:Array) : Boolean {
        var curTime:int = getTimer();
        var duration:int = curTime - _trigger.startConditionTime;

        var monsterCount:int = -1;
        var timerData:CTrunkTriggerTimerData = _trigger.triggerData as CTrunkTriggerTimerData;
        if (curTime - _lastCheckTime > 500) {
            if (timerData.triggerNextImmediatelyWhenNoMonster) {
                // 1秒检查2次
                _lastCheckTime = curTime;

                monsterCount = (_trigger as AbsLevelServerTrigger).server.sceneObjectHandler.getAllMonster().length;
                if (0 == monsterCount) return true;
            }
        }


        if (duration >= cond.interval*1000) {
            if (timerData.maxEnemyCnt > 0) {
                if (monsterCount == -1) {
                    monsterCount = (_trigger as AbsLevelServerTrigger).server.sceneObjectHandler.getAllMonster().length;
                }
                return (timerData.maxEnemyCnt > monsterCount);
            } else {
                return true;
            }
        }

        return false;
    }

    private var _lastCheckTime:int;
}
}
