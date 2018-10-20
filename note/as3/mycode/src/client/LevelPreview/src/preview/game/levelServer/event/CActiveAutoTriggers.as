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

public class CActiveAutoTriggers extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var entityList:Array = this.getTrunkEntityList(system, trunkID);
        var findEntities:Vector.<CTrunkEntityBaseData> = new Vector.<CTrunkEntityBaseData>();
        var findIDs:Array = sceneEvent.getParameterIntArray();

        for each (var trunkEntityInfo:CTrunkEntityBaseData in entityList) {
            var idIndex:int = findIDs.indexOf(trunkEntityInfo.ID);
            if (trunkEntityInfo.type == ETrunkEntityType.TIMER_TRIGGER && idIndex != -1) {
                if (trunkEntityInfo.limit != 0) {
                    findEntities.push(trunkEntityInfo);
                }
                findIDs.removeAt(idIndex);
            }
        }
        if (findEntities.length > 0) {
            var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
            for each (var trigger:CTrunkEntityBaseData in findEntities) {
                server.createTrigger(trunkID, trigger);
            }
        }
    }
}
}
