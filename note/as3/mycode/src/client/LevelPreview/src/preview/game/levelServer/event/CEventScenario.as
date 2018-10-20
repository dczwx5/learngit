/**
 * Created by auto on 2016/5/25.
 */
package preview.game.levelServer.event {

import kof.framework.CAppSystem;
import preview.game.levelServer.CLevelServer;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.levelCommon.info.event.CSceneEventInfo;

import preview.game.levelServer.CLevelServerSystem;

public class CEventScenario extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var array:Array = sceneEvent.getParameterArray();
        var scenarioID:int = array[0];
        var isAllControl:int = array[1];
        if (scenarioID > 0) {
            var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
            server.sender.playScenario(scenarioID, isAllControl);
            server.onScenarioStart(isAllControl);
        }

    }
}
}
