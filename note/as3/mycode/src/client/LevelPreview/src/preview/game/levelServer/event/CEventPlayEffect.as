//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/11/8.
 */
package preview.game.levelServer.event {
import kof.framework.CAppSystem;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import preview.game.levelServer.CLevelServer;
import preview.game.levelServer.CLevelServerSystem;

public class CEventPlayEffect extends ATrunkEventHandler {
    private var _type:int;

    public function CEventPlayEffect(type:int):void{
        _type=type;
    }

    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var params:Array = sceneEvent.getParameterArray();


        var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
        server.sender.playEff(sceneEvent.parameter,_type);
    }
}
}
