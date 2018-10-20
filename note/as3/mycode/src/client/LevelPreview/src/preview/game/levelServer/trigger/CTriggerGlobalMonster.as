/**
 * Created by auto on 2016/5/24.
 * update by auto on 2016/9/12.
 * 用于服务器 刷怪区域
 */
package preview.game.levelServer.trigger {
import flash.utils.getTimer;
import kof.game.levelCommon.Enum.ELevelTriggerConditionType;
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.levelCommon.info.base.CTrunkConditionInfo;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.levelScenario.CLevelScenarioScenarioInfo;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.data.CLevelSceneObjectAllCountStartData;
import preview.game.levelServer.data.CLevelSceneObjectCountData;
import preview.game.levelServer.data.CLevelSceneObjectData;
import preview.game.levelServer.trigger.handler.CTriggerCondHandleGlobalMonster;
import preview.game.levelServer.trigger.handler.CTriggerCondHandlePropertyChange;

public class CTriggerGlobalMonster extends AbsLevelServerTrigger {
    public function CTriggerGlobalMonster(levelServer:CLevelServer, trunkInfo:CTrunkConfigInfo, trunkEntityInfo:CTrunkEntityBaseData) {
        super(levelServer, trunkInfo, trunkEntityInfo, 1);
        this.addHandler(ELevelTriggerConditionType.TRIGGER_MONSTER_COUNT_CHANGE, CTriggerCondHandleGlobalMonster);
        this.addHandler(ELevelTriggerConditionType.TRIGGER_MONSTER_PROPERTY_CHANGE, CTriggerCondHandlePropertyChange);
    }
    public override function dispose() : void {
        super.dispose();
        _startCountData = null;
    }
    // 每次触发器条件开始调用
    protected override function _onStartTrigger() : void {
        _startCountData = _server.sceneObjectHandler.getStartCountData();
    }
    //=============================================monster property Change========================================================
    final public function getMonsterByID(targetID:int):Vector.<CLevelSceneObjectData>{
        var monsterArr:Vector.<CLevelSceneObjectData> = new <CLevelSceneObjectData>[];

        if(targetID){
            monsterArr = _server.sceneObjectHandler.getMonsterByObjectID( targetID );
        }
        else{
            monsterArr = _server.sceneObjectHandler.getAllMonster();
        }

        return monsterArr;
    }


    // ============================================monster count==================================================================
    final public function getMonsterCountCurrent(cond:CTrunkConditionInfo) : int {
        var data:CLevelSceneObjectCountData = _server.sceneObjectHandler.getMonsterCountData(cond.targetID);
        if (data) return data.currentCount;
        else return 0;
    }
    // final public function getMonsterCountChange() : int { return getMonsterCountCurrent() - getMonsterCountByStart()}; 无意义
    final public function getMonsterAddCountByStart(cond:CTrunkConditionInfo) : int {
        if (cond.targetID > 0) {
            var monsterCountData:CLevelSceneObjectCountData = _startCountData.getMonsterCountData(cond.targetID);
            if (monsterCountData) return monsterCountData.addCount;
            else return 0;
        } else {
            return _startCountData.allMonsterCountData.addCount;
        }
    }
    final public function getMonsterAddCountCurrent(cond:CTrunkConditionInfo) : int {
        var data:CLevelSceneObjectCountData = _server.sceneObjectHandler.getMonsterCountData(cond.targetID);
        if (data) return data.addCount;
        else return 0;
    }
    final public function getMonsterAddCountChange(cond:CTrunkConditionInfo) : int {
        return getMonsterAddCountCurrent(cond) -  getMonsterAddCountByStart(cond);
    }

    final public function getMonsterRemoveCountByStart(cond:CTrunkConditionInfo) : int {
        if (cond.targetID > 0) {
            var monsterCountData:CLevelSceneObjectCountData = _startCountData.getMonsterCountData(cond.targetID);
            if (monsterCountData) return monsterCountData.removeCount;
            else return 0;
        } else {
            return _startCountData.allMonsterCountData.removeCount;
        }
    }
    final public function getMonsterRemoveCountCurrent(cond:CTrunkConditionInfo) : int {
        var data:CLevelSceneObjectCountData = _server.sceneObjectHandler.getMonsterCountData(cond.targetID);
        if (data) return data.removeCount;
        else return 0;
    }
    final public function getMonsterRemoveCountChange(cond:CTrunkConditionInfo) : int {
        return getMonsterRemoveCountCurrent(cond) - getMonsterRemoveCountByStart(cond);
    }

    final public function getMonsterCountChangeTime(cond:CTrunkConditionInfo) : int {
        var data:CLevelSceneObjectCountData = _server.sceneObjectHandler.getMonsterCountData(cond.targetID);
        if (data) return data.countChangeTime;
        else return 0;
    }
    // 数量改变时间
    final public function getMonsterCountChangeTimeKeep(cond:CTrunkConditionInfo) : int {
        // 数量改变持续时间, ms
        var lastTime:int = getMonsterCountChangeTime(cond);
        if (lastTime == -1) {
            return 0;
        }

        var curTime:int = getTimer();
        var subTime:int = curTime - lastTime;
        // 是否要从trigger开始计时, 确定是要的
        var triggerSubTime:int = curTime - this.startConditionTime;
        if (subTime > triggerSubTime) subTime = triggerSubTime;
        return subTime;
    }

    private var _startCountData:CLevelSceneObjectAllCountStartData; // 初始数据
}
}
