/**
 * Created by auto on 2016/9/13.
 */
package preview.game.levelServer.trigger.handler {
import preview.game.levelServer.trigger.AbsLevelTriggerBase;
import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import kof.game.levelCommon.CLevelLog;
import preview.game.levelServer.trigger.CTriggerGlobalMonster;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleBase;

public class CTriggerCondHandleGlobalMonster extends CTriggerCondHandleBase {
    public function CTriggerCondHandleGlobalMonster(trigger:AbsLevelTriggerBase) {
        super (trigger);

        _valueHandleMap = new Array(3);

        _valueHandleMap[CTrunkConditionInfo.TARGET_TYPE_MONSTER] = new Array(4);
//        _valueHandleMap[CTrunkConditionInfo.TARGET_TYPE_MAPOBJECT] = new Array(4);
        _valueHandleMap[CTrunkConditionInfo.TARGET_TYPE_HP] = new Array(4);

        _valueHandleMap[CTrunkConditionInfo.TARGET_TYPE_MONSTER][CTrunkConditionInfo.COUNT_TYPE_ADD] = [_monsterTrigger.getMonsterAddCountChange];
        _valueHandleMap[CTrunkConditionInfo.TARGET_TYPE_MONSTER][CTrunkConditionInfo.COUNT_TYPE_KEEP] = [_monsterTrigger.getMonsterCountCurrent, _monsterTrigger.getMonsterCountChangeTimeKeep];
        _valueHandleMap[CTrunkConditionInfo.TARGET_TYPE_MONSTER][CTrunkConditionInfo.COUNT_TYPE_SUB] = [_monsterTrigger.getMonsterRemoveCountChange];
        _valueHandleMap[CTrunkConditionInfo.TARGET_TYPE_MONSTER][CTrunkConditionInfo.COUNT_TYPE_TO_VALUE] = [_monsterTrigger.getMonsterCountCurrent];
    }

    public override function handler(cond:CTrunkConditionInfo,triggerFilter:Array) : Boolean {
        var handlerList:Array = _getValueHandler(cond.targetType, cond.countType);
        if (null == handlerList || handlerList.length == 0) return false;

        var params:Array = new Array();
        var result:int = 0;
        for (var i:int = 0; i < handlerList.length; i++) {

            result = (handlerList[i] as Function).apply(null, [cond]);
            params.push(result);
        }
        var ret:Boolean = false;
        if (params.length == 1) {
            ret = _processValue(params[0], -1, cond);
        } else {
            ret = _processValue(params[0], params[1], cond); // 只有keep 是2个参数
        }
        return ret;
    }

    protected function _processValue(value:int, keepTime:int, cond:CTrunkConditionInfo) : Boolean {
        switch (cond.countType) {
            case CTrunkConditionInfo.COUNT_TYPE_ADD:
            case CTrunkConditionInfo.COUNT_TYPE_SUB:
            case CTrunkConditionInfo.COUNT_TYPE_TO_VALUE:
                return _checkValuePass(value, cond);
            case CTrunkConditionInfo.COUNT_TYPE_KEEP:
                if (_checkValuePass(value, cond)) {
                    return keepTime >= cond.keepTime*1000;
                }
                return false;
        }
        CLevelLog.addDebugLog("CTriggerCondHandleBase : counter type error : " + cond.countType, true);
        return false;
    }

    private function _checkValuePass(value:int, cond:CTrunkConditionInfo) : Boolean {
        switch (cond.compare) {
            case CTrunkConditionInfo.COMPARTE_LESS:
                return value < cond.targetValue;
            case CTrunkConditionInfo.COMPARTE_LESS_EQUOT:
                return value <= cond.targetValue;
            case CTrunkConditionInfo.COMPARTE_EQUOT:
                return value == cond.targetValue;
            case CTrunkConditionInfo.COMPARTE_GREATER_EQUOT:
                return value > cond.targetValue;
            case CTrunkConditionInfo.COMPARTE_GREATER:
                return value>= cond.targetValue;
        }
        CLevelLog.addDebugLog("CTriggerCondHandleBase : compare type error : " + cond.compare, true);
        return false;
    }

    final private function get _monsterTrigger() : CTriggerGlobalMonster {
        return _trigger as CTriggerGlobalMonster;
    }

    private function _getValueHandler(target:int, countType:int) : Array {
        if (target >= _valueHandleMap.length) {
            CLevelLog.addDebugLog("CTriggerGlobalMonster getHandler : target type error : " + target, true);
            return null;
        }
        if (countType >= _valueHandleMap[target].length) {
            CLevelLog.addDebugLog("CTriggerGlobalMonster getHandler : count type error : " + countType, true);
            return null;
        }
        return _valueHandleMap[target][countType];
    }

    private var _valueHandleMap:Array;

}
}
