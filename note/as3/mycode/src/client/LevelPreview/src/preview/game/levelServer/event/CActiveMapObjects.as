/**
 * Created by auto on 2016/5/25.
 */
package preview.game.levelServer.event {
import kof.framework.CAppSystem;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;

import preview.game.levelServer.CLevelServer;
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.levelCommon.info.event.CSceneEventInfo;

import preview.game.levelServer.CLevelServerSystem;

public class CActiveMapObjects extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var entityList:Array = this.getTrunkEntityList(system, trunkID);
        var findEntities:Vector.<CTrunkEntityBaseData> = new Vector.<CTrunkEntityBaseData>();

        var iIds:Array = sceneEvent.getParameterIntArray();

        for each (var trunkEntityInfo:CTrunkEntityBaseData in entityList) {
            if (trunkEntityInfo.type == ETrunkEntityType.MAP_OBJ && iIds.indexOf(trunkEntityInfo.ID) != -1) {
                findEntities.push(trunkEntityInfo);
            }
        }
        if (findEntities.length > 0) {
            // spawner object
            // 服务器发信息给客户端
            var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
            server.sender.spawnMapObjects(findEntities);
        }
    }
}
}
