/**
 * Created by auto on 2016/5/25.
 */
package preview.game.levelServer.event {
import kof.framework.CAppSystem;
import preview.game.levelServer.CLevelServer;
import kof.game.level.event.triggerEvent.ATrunkEventHandler;
import kof.game.levelCommon.info.event.CSceneEventInfo;

import preview.game.levelServer.CLevelServerSystem;

public class CEventPlaySceneAnimation extends ATrunkEventHandler {
    private var _type:int;

    public function CEventPlaySceneAnimation(type:int):void{
        _type=type;
    }

    public override function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void {
        var params:Array = sceneEvent.getParameterArray();


        var server:CLevelServer = system.stage.getSystem(CLevelServerSystem).getBean(CLevelServer) as CLevelServer;
        server.sender.playSceneAnimation(sceneEvent.parameter,_type);
    }
}
}
