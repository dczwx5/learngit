/**
 * Created by auto on 2016/6/3.
 */
package preview.game.levelServer.event {
import kof.framework.CAppSystem;
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.levelCommon.info.base.CTrunkEntityBaseData;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;

public class CActiveGlobalMonsterTrigger extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var entityList:Array = this.getTrunkEntityList(system, trunkID);
        var findEntities:Vector.<CTrunkEntityBaseData> = new Vector.<CTrunkEntityBaseData>();
        var findIDs:Array = sceneEvent.getParameterIntArray();

        for each (var trunkEntityInfo:CTrunkEntityBaseData in entityList) {
            var idIndex:int = findIDs.indexOf(trunkEntityInfo.ID);
            if (trunkEntityInfo.type == ETrunkEntityType.GLOBAL_MONSTER && idIndex != -1) {
                findEntities.push(trunkEntityInfo);
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
