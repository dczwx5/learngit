/**
 * Created by auto on 2016/7/30.
 */
package preview.game.levelServer {

import kof.game.levelCommon.Enum.ELevelEventType;
import kof.game.levelCommon.Enum.ETrunkEntityType;

import preview.game.levelServer.event.map.CTrunkMonsterDeadEvent;

import preview.game.levelServer.data.CLevelSceneObjectDeadData;

/**
 * 记录死亡列表, 切换trunk时清除
 */
public class CLevelServerEntityDeadHandler {
    public function CLevelServerEntityDeadHandler(server:CLevelServer) {
        _server = server;
        _server.addEventListener(ELevelEventType.MONSTER_DIE, _onObjectDie);

        _objectMap = new Vector.<Vector.<CLevelSceneObjectDeadData>>(ETrunkEntityType.COUNT);
        for (var i:int = 0; i < _objectMap.length; i++) {
            // ETrunkEntityType , 每种type都对应有一个组
            _objectMap[i] = new Vector.<CLevelSceneObjectDeadData>();
        }

    }
    public function dispose() : void {
        this.reset();
        _server.removeEventListener(ELevelEventType.MONSTER_DIE, _onObjectDie);
        _server = null;
    }
    public function reset() : void {
        for (var i:int = 0; i < _objectMap.length; i++) {
            _objectMap[i] = new Vector.<CLevelSceneObjectDeadData>();
        }
    }

    public function getCount(entityType:int, monsterID:int) : int {
        var list:Vector.<CLevelSceneObjectDeadData> = _objectMap[entityType];
        for each (var deadInfo:CLevelSceneObjectDeadData in list) {
            if (deadInfo.monsterID == monsterID) {
                return deadInfo.count;
            }
        }
        return 0;
    }

    private function _onObjectDie(e:CTrunkMonsterDeadEvent) : void {
        if (e.entityType >= _objectMap.length || e.entityType < 0) return ;

        var list:Vector.<CLevelSceneObjectDeadData> = _objectMap[e.entityType];

        var isExist:Boolean = false;
        for each (var info:CLevelSceneObjectDeadData in list) {
            if (info.monsterID == e.monsterID) {
                isExist = true;
                info.count++;
                break;
            }
        }

        if (!isExist) {
            var newDeadInfo:CLevelSceneObjectDeadData = new CLevelSceneObjectDeadData(e.monsterID, 1);
            list.push(newDeadInfo);
        }
    }

    private var _objectMap:Vector.<Vector.<CLevelSceneObjectDeadData>>;

    private var _server:CLevelServer;
}
}
