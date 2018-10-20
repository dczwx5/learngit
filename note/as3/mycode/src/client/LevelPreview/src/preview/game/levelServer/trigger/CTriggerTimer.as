/**
 * Created by auto on 2016/5/24.
 */
package preview.game.levelServer.trigger {

import flash.utils.getTimer;

import kof.game.levelCommon.Enum.ELevelTriggerConditionType;
import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.entity.CTrunkTriggerTimerData;

import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleTimer;

// --- timer -> trunk事件组 -> 触发事件组里的事件...们
public class CTriggerTimer extends AbsLevelServerTrigger { // CTriggerAutoTrunk  {
    public function CTriggerTimer(server:CLevelServer, trunkInfo:CTrunkConfigInfo, trunkEntity:CTrunkEntityBaseData) {
        super(server, trunkInfo, trunkEntity, 1);
        this.addHandler(ELevelTriggerConditionType.TRIGGER_TIMER, CTriggerCondHandleTimer);
    }

    // 获得当前要显示的计时数
    public function getCounter() : int {
        var counter:int = 0;
        var timerData:CTrunkTriggerTimerData = triggerData as CTrunkTriggerTimerData;
        counter = (int(getTimer() - this.startConditionTime))/1000;

        if (timerData.countType != 0) {
            var interval:int = 0;
            // 定时触发器只能有一个timer条件
            if (triggerData.conditions && triggerData.conditions.length > 0) {
                interval = (triggerData.conditions[0] as CTrunkConditionInfo).interval;
            }
            counter = interval - counter;
            if (counter < 0) counter = 0;
        }
        return counter;
    }
}
}

