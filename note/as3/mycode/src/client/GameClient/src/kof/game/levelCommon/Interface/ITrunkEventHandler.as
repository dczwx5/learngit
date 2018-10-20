/**
 * Created by auto on 2016/5/25.
 */
package kof.game.levelCommon.Interface {
import kof.framework.CAppSystem;
import kof.game.levelCommon.info.event.CSceneEventInfo;

public interface ITrunkEventHandler {
    function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo) : void;
}
}
