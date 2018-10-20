//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/22.
 */
package preview.game.levelServer.event {
import kof.framework.CAppSystem;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.levelCommon.Enum.ETrunkEntityType;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;

public class CActiveDeactiveRandomTrigger extends ATrunkEventHandler {
    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var ids:Array = sceneEvent.getParameterArray();
        var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
        server.deactiveTrigger(ETrunkEntityType.RANDOM_TRIGGER, ids[0]);
    }
}
}
