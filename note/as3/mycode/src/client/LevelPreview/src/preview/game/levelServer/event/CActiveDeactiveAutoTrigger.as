/**
 * Created by user on 2016/11/21.
 */
package preview.game.levelServer.event {
import kof.framework.CAppSystem;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.levelCommon.Enum.ETrunkEventType;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;

public class CActiveDeactiveAutoTrigger extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var ids:Array = sceneEvent.getParameterArray();
        var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
        server.deactiveTrigger(ETrunkEntityType.TIMER_TRIGGER, ids[0]);
    }
}
}
