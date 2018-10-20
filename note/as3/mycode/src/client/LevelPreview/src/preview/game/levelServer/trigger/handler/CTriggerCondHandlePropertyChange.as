//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/23.
 */
package preview.game.levelServer.trigger.handler {
import flash.utils.getTimer;

import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import preview.game.levelServer.data.CLevelSceneMonsterData;
import preview.game.levelServer.data.CLevelSceneObjectData;
import preview.game.levelServer.trigger.AbsLevelTriggerBase;
import preview.game.levelServer.trigger.CTriggerGlobalMonster;

public class CTriggerCondHandlePropertyChange extends CTriggerCondHandleBase {
    public function CTriggerCondHandlePropertyChange(trigger:AbsLevelTriggerBase) {
        super(trigger);
    }
    public override function handler(cond:CTrunkConditionInfo,triggerFilter:Array) : Boolean {
        var monsterVec:Vector.<CLevelSceneObjectData> = (_trigger as CTriggerGlobalMonster).getMonsterByID(cond.targetID);
        var ret:Boolean = false;
        for (var i:int = 0; i < monsterVec.length; i++) {
            var monstrer:CLevelSceneMonsterData = (monsterVec[i] as CLevelSceneMonsterData);
            switch (cond.targetType){
                case CTrunkConditionInfo.TARGET_TYPE_HP:
                    ret = _processValue( monstrer.HP, monstrer, cond );
                    return ret;
                case CTrunkConditionInfo.TARGET_TYPE_ATTACKPOWER:
                    ret = _processValue( monstrer.attackPower, monstrer, cond );
                    return ret;
                case CTrunkConditionInfo.TARGET_TYPE_DEFENSEPOWER:
                    ret = _processValue( monstrer.defensePower, monstrer, cond );
                    return ret;
            }
        }
        return ret;
    }

    private var lastValue:int;

    protected function _processValue(value:int, monster:CLevelSceneMonsterData, cond:CTrunkConditionInfo) : Boolean {
        switch (cond.countType) {
            case CTrunkConditionInfo.COUNT_TYPE_ADD:
                if(lastValue == 0){
                    lastValue = value;
                }
                var addValue = value - lastValue;
                lastValue = value;
                return _checkValuePass(addValue, cond);
            case CTrunkConditionInfo.COUNT_TYPE_SUB:
                if(lastValue == 0){
                    lastValue = value;
                }
                if(lastValue == value){
                    return false;
                }
                var subValue = lastValue - value;
                lastValue = value;
                return _checkValuePass(subValue, cond);
            case CTrunkConditionInfo.COUNT_TYPE_TO_VALUE:
                return _checkValuePass(value, cond);
            case CTrunkConditionInfo.COUNT_TYPE_KEEP:
                if (_checkValuePass(value, cond)) {
                    if( monster.updateTime[cond.targetType]==null || monster.updateTime[cond.targetType] == 0 ){
                        monster.updateTime[cond.targetType] = getTimer();
                    }

                    var time:int = (getTimer() - monster.updateTime[cond.targetType]);
                    return time >= cond.keepTime*1000;
                }else{
                    monster.updateTime[cond.targetType] = 0;
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


}
}
