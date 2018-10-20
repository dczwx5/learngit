/**
 * Created by auto on 2016/7/30.
 */
package preview.game.levelServer {

import kof.game.levelCommon.Enum.ETrunkGoalType;
import kof.game.levelCommon.info.base.CTrunkEntityMapEntityBase;
import kof.game.levelCommon.info.goal.CTrunkGoalTargetInfo;
import kof.game.levelCommon.info.goal.CTrunkGoalTargetEntityInfo;
import kof.game.levelCommon.info.goal.CTrunkGoalsInfo;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;


import preview.game.levelServer.data.CLevelSceneObjectData;

/**
 * 杀死对象的目标, 目前只支持怪物, 物件
 */
public class CLevelServerTrunkPassHandler {
    public function CLevelServerTrunkPassHandler(server:CLevelServer) {

        _server = server;
    }


    // 检测trunk是否通过
    public function checkPass() : Boolean {
        switch (_curGoals.targetType) {
            case ETrunkGoalType.TARGET_TYPE_KILL_ALL:
                return _checkKillAll();
                break;
            case ETrunkGoalType.TARGET_TYPE_KILL_POINT_TO:
            case ETrunkGoalType.TARGET_TYPE_KILL_ANY_ONE:
                    return _checkKillAnyOne();
                break;
            case ETrunkGoalType.TARGET_TYPE_FINISH_TRIGGER:
                return _checkTriggerFinish();

        }
        return false;
    }

    public function isKillMonsterGoal() : Boolean {
        if (_curGoals.targetType == ETrunkGoalType.TARGET_TYPE_KILL_ALL || _curGoals.targetType == ETrunkGoalType.TARGET_TYPE_KILL_POINT_TO
                || _curGoals.targetType == ETrunkGoalType.TARGET_TYPE_KILL_ANY_ONE) {
            return true;
        }
        return false;
    }

    private function _checkKillAll() : Boolean {
        var ret:Boolean = false;
        if (!_server.triggerHandler.hasTriggerValid && !_server.serverEnventManager.hasDelayCall) {
            var allMonsters:Vector.<CLevelSceneObjectData> = _server.sceneObjectHandler.getAllMonster();
            for each (var obj:CLevelSceneObjectData in allMonsters){
                if(obj.campID != 1) {
                    ret = false;
                    return ret;
                }
            }
            ret = true;
        }
        return ret;
    }
    private function _checkKillAnyOne() : Boolean {
        var ret:Boolean = true;
        for (var i:int = 0; i < _curGoals.target.length; i++) {
            var count:int = 0;
            var targetInfo:CTrunkGoalTargetInfo = _curGoals.target[i];
            // 杀死object下面的任意一种怪物都算
            for each (var object:CTrunkGoalTargetEntityInfo in targetInfo.object) {
                var entity:CTrunkEntityMapEntityBase = _curTrunkInfo.getEntityById(object.entityType, object.entityID) as CTrunkEntityMapEntityBase;
                count += _server.deadData.getCount(object.entityType, entity.spawnID);
            }
            if (count < targetInfo.total) {
                ret = false;
                break;
            }
        }

        return ret;
    }
    private function _checkTriggerFinish() : Boolean {
        var ret:Boolean = true;
        for (var i:int = 0; i < _curGoals.target.length; i++) {
            var count:int = 0;
            var targetInfo:CTrunkGoalTargetInfo = _curGoals.target[i];
            for each (var object:CTrunkGoalTargetEntityInfo in targetInfo.object) {
                if (_server.triggerHandler.isTriggerFinish(object.entityType, object.entityID)) {
                    count++;
                }
            }
            if (count < targetInfo.total) {
                ret = false;
                break;
            }
        }
        return ret;
    }
    private function get _curGoals() : CTrunkGoalsInfo {
        return _server.curTrunkData.trunkInfo.goals;
    }
    private function get _curTrunkInfo() : CTrunkConfigInfo {
        return _server.curTrunkData.trunkInfo;
    }

    private var _server:CLevelServer;
}
}
