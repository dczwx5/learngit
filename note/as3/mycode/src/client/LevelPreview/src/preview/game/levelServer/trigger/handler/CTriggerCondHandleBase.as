/**
 * Created by auto on 2016/9/13.
 */
package preview.game.levelServer.trigger.handler {
import QFLib.Interface.IDisposable;

import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import preview.game.levelServer.trigger.AbsLevelTriggerBase;

public class CTriggerCondHandleBase implements IDisposable {
    public function CTriggerCondHandleBase(trigger:AbsLevelTriggerBase) {
        _trigger = trigger;
    }
    public function dispose() : void {
        _trigger = null;
    }
    public virtual function handler(cond:CTrunkConditionInfo, triggerFilter:Array) : Boolean {
        throw new Error("CTriggerCondHandleBase need override handler");
        return false;
    }



    protected var _trigger:AbsLevelTriggerBase;
}
}
