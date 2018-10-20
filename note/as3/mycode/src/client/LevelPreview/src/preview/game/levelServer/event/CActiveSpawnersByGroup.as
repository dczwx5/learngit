/**
 * Created by AUTO on 2016/6/2.
 * nmh 刷怪组
 */
package preview.game.levelServer.event {
import flash.utils.setTimeout;

import kof.framework.CAppSystem;
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.level.imp.CGameLevel;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.entity.CTrunkEntityMonster;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;

// 刷怪点/激活指定刷怪点
public class CActiveSpawnersByGroup  extends ATrunkEventHandler {

    private var _system:CAppSystem;

    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var ids:Array = sceneEvent.getParameterIntArray();
        _system = system;
        var findEntities:Vector.<CTrunkEntityBaseData> = new Vector.<CTrunkEntityBaseData>();
        var gameLevel:CGameLevel = this.getGameLevel(system);
        var entities:Array = gameLevel.levelCfgInfo.getTrunkById(trunkID).entities;
        for each (var entity:CTrunkEntityBaseData in entities) {
            if (entity.type == ETrunkEntityType.MONSTER && ids.indexOf(entity.ID) != -1) {
                var monster:CTrunkEntityMonster = entity as CTrunkEntityMonster;
                var delay:int = monster.delay;
                if(delay != 0){
                    setTimeout(_timeoutFun,delay*1000,entity);
                }
                else{
                    _timeoutFun(entity);
                }
//                findEntities.push(entity);
            }
        }
        /*if (findEntities.length > 0) {
            var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
            server.sender.spawnMonsters(findEntities);
        }*/
    }

    private function _timeoutFun( entity:CTrunkEntityBaseData ):void{
        var server:CLevelServer = _system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
        server.sender.spawnMonsters(entity);
    }
}
}
