/**
 * Created by auto on 2016/5/25.
 */
package preview.game.levelServer.event {
import flash.geom.Point;
import flash.geom.Rectangle;

import kof.framework.CAppSystem;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.level.imp.CGameLevel;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;


public class CLockTrunks extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var gameLevel:CGameLevel = this.getGameLevel(system);
        var lockRect:Rectangle = gameLevel.getTrunkAreaData(trunkID);
        var topPoint:Point = new Point(lockRect.x, lockRect.y);
        var bottomPoint:Point = new Point(lockRect.x + lockRect.width, lockRect.y + lockRect.height);

        var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
        server.sender.lockTrunks(topPoint, bottomPoint);
    }
}
}
