/**
 * Created by auto on 2016/5/24.
 */
package preview.game.levelServer {

import QFLib.Interface.IUpdatable;

import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;

import preview.game.levelServer.trigger.AbsLevelServerTrigger;
import preview.game.levelServer.trigger.CTriggerGlobalMonster;
import preview.game.levelServer.trigger.CTriggerRandom;
import preview.game.levelServer.trigger.CTriggerTimer;
import preview.game.levelServer.trigger.CTriggerZone;

public class CLevelServerTriggerHandler implements IUpdatable {
    private var _server:CLevelServer;
    public function CLevelServerTriggerHandler(rServer:CLevelServer) {
        _server = rServer;
        _activeTriggers = new Vector.<AbsLevelServerTrigger>();
        _finishTriggers = new Vector.<AbsLevelServerTrigger>();
        _unuseRandomTriggers = new Vector.<AbsLevelServerTrigger>();
    }

    // 切换trunk, trigger需要被移除
    public function clearAll() : void {
        var iTrigger:AbsLevelServerTrigger;
        for each (iTrigger in _activeTriggers) {
            iTrigger.dispose();
        }
        for each (iTrigger in _finishTriggers) {
            iTrigger.dispose();
        }

        _activeTriggers = new Vector.<AbsLevelServerTrigger>();
        _unuseRandomTriggers = new Vector.<AbsLevelServerTrigger>();
        _finishTriggers = new Vector.<AbsLevelServerTrigger>();
    }


    public function update(delta:Number) : void {
        for (var i:int = 0; i < _activeTriggers.length; i++) {
            var trigger:AbsLevelServerTrigger = _activeTriggers[i];
            trigger.update(delta);
            if (trigger.isEnd()) {
                if (trigger is CTriggerRandom) {
                    _unuseRandomTriggers.push(trigger);
                } else {
                    // trigger.dispose();
                    _finishTriggers.push(trigger);
                }
                _activeTriggers.splice(i, 1);
                i--;
            }
        }
    }

    public function get hasTriggerValid() : Boolean {
        return _activeTriggers.length > 0;
    }
    public function getZoneTrigger() : CTriggerZone {
        for (var i:int = 0; i < _activeTriggers.length; i++) {
            if (_activeTriggers[i] is CTriggerZone) {
                return _activeTriggers[i] as CTriggerZone;
            }
        }
        return null;
    }

    public function getRandomTriggerByID(ID:int) : CTriggerRandom {
        var randomTrigger:CTriggerRandom;
        for (var i:int = 0; i < _activeTriggers.length; i++) {
            randomTrigger = (_activeTriggers[i] as CTriggerRandom);

            if (randomTrigger && (randomTrigger.triggerData.ID == ID)) {
                return _activeTriggers[i] as CTriggerRandom;
            }
        }
        for (i = 0; i < _unuseRandomTriggers.length; i++) {
            randomTrigger = (_unuseRandomTriggers[i] as CTriggerRandom);

            if (randomTrigger && (randomTrigger.triggerData.ID == ID)) {
                return _unuseRandomTriggers[i] as CTriggerRandom;
            }
        }
        return null;
    }
    public function getRandomTriggerCount() : int {
        var count:int = 0;
        for (var i:int = 0; i < _activeTriggers.length; i++) {
            if (_activeTriggers[i] is CTriggerRandom) {
                count++;
            }
        }
        return count;
    }
    public function getTriggerTimer() : CTriggerTimer {
        for (var i:int = 0; i < _activeTriggers.length; i++) {
            if (_activeTriggers[i] is CTriggerTimer) {
                return _activeTriggers[i] as CTriggerTimer;
            }
        }
        return null;
    }
    public function getTriggerGlobalMonster() : CTriggerGlobalMonster {
        for (var i:int = 0; i < _activeTriggers.length; i++) {
            if (_activeTriggers[i] is CTriggerGlobalMonster) {
                return _activeTriggers[i] as CTriggerGlobalMonster;
            }
        }
        return null;
    }
    public function createTrigger(trunkInfo:CTrunkConfigInfo, trunkEntityInfo:CTrunkEntityBaseData) : void {
        var trigger:AbsLevelServerTrigger;
        switch (trunkEntityInfo.type) {
            case ETrunkEntityType.TRIGGER:
                CLevelLog.addDebugLog("add Trigger Zone");
                trigger = new CTriggerZone(_server, trunkInfo, trunkEntityInfo);
                break;
            case ETrunkEntityType.TIMER_TRIGGER:
                CLevelLog.addDebugLog("add Trigger Timer");
                trigger = new CTriggerTimer(_server, trunkInfo, trunkEntityInfo);
                break;
            case ETrunkEntityType.GLOBAL_MONSTER:
                CLevelLog.addDebugLog("add Trigger Monster");
                trigger = new CTriggerGlobalMonster(_server, trunkInfo, trunkEntityInfo);
                break;
            case ETrunkEntityType.RANDOM_TRIGGER:
                CLevelLog.addDebugLog("add Trigger Random");
                trigger = this.getRandomTriggerByID(trunkEntityInfo.ID);
                if (null == trigger) {
                    trigger = new CTriggerRandom(_server, trunkInfo, trunkEntityInfo);
                } else {
                    (trigger as CTriggerRandom).reset();
                }
                break;
        }
        if (trigger && (_activeTriggers.indexOf(trigger) == -1)) {
            _activeTriggers.push(trigger);
        }
    }

    public function deactiveTrigger(type:int, triggerID:int):void{
        for (var i:int = 0; i < _activeTriggers.length; i++) {
            var trigger:AbsLevelServerTrigger = _activeTriggers[i];
            if (trigger.triggerData.ID == triggerID && trigger.triggerData.type == type) {
                if (trigger is CTriggerRandom) {
                    _unuseRandomTriggers.push(trigger);
                } else {
                    // trigger.dispose();
                    _finishTriggers.push(trigger);
                }
                _activeTriggers.splice(i, 1);
                i--;
            }
        }
    }

    public function get finishTriggers() : Vector.<AbsLevelServerTrigger> {
        return _finishTriggers;
    }
    public function isTriggerFinish(entityType:int, entityID:int) : Boolean {
         for each (var trigger:AbsLevelServerTrigger in _finishTriggers) {
             if (trigger.entityInfo.ID == entityID && trigger.entityInfo.type == entityType) {
                 return true;
             }
         }
        return false;
    }

    private var _activeTriggers:Vector.<AbsLevelServerTrigger>;
    private var _unuseRandomTriggers:Vector.<AbsLevelServerTrigger>; // 运行过的randomTrigger暂存起来, 因为randomTrigger需要一直存在
    private var _finishTriggers:Vector.<AbsLevelServerTrigger>; // 已完成的触发器, 不包含randomTrigger
}
}
