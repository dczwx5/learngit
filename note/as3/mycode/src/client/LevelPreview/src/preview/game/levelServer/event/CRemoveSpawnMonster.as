/**
 * Created by user on 2016/11/4.
 */
package preview.game.levelServer.event {
import kof.framework.CAppSystem;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.levelCommon.Enum.ELevelEventType;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;
import preview.game.levelServer.data.CLevelSceneObjectData;
import preview.game.levelServer.event.map.CTrunkMonsterRemoveEvent;

//移除怪物事件
public class CRemoveSpawnMonster extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var array:Array = sceneEvent.getParameterArray();

        var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
        var monsterVec:Vector.<CLevelSceneObjectData> = server.sceneObjectHandler.getMonsterByEntityID(array[0]);
        var len:int = array[1] == -1 ? monsterVec.length : array[1];
        var removeArr:Array = [];
        if(monsterVec.length<len){
            return;
        }
        for(var i:int = 0; i<len; i++)
        {
            removeArr.push({id:monsterVec[i].uniID,type:monsterVec[i].gameObjectType,entityType:monsterVec[i].entityType})
        }
        server.dispatchEvent(new CTrunkMonsterRemoveEvent(ELevelEventType.MONSTER_REMOVE,removeArr));

        server.sender.sendRemoveSpawiedMonster(removeArr);
    }
}
}
