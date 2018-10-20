/**
 * Created by auto on 2016/6/2.
 */
package preview.game.levelServer.event {
import kof.framework.CAppSystem;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.level.imp.CGameLevel;
import kof.game.levelCommon.info.event.CSceneEventInfo;

import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;

// 触发事件组里的事件们..
public class CTriggerSceneEventGroup extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var name:String  = sceneEvent.parameter; // name 与事件组里的name对应

        var gameLevel:CGameLevel = this.getGameLevel(system);
        var group:Object = null;
        var eventGroups:Array = gameLevel.levelCfgInfo.getTrunkById(trunkID).eventGroups;
        for each (var g:Object in eventGroups) {
            if (g["name"] == name) {
                group = g;
                break;
            }
        }
        if (group) {
            var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;

            server.serverEnventManager.handlerEvent(trunkID, group["events"]);
        }

    }
}
}
