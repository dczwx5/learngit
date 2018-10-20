/**
 * Created by auto on 2016/5/25.
 */
package kof.game.level.event.triggerEvent {
import kof.game.levelCommon.Interface.*;
import kof.framework.CAppSystem;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.level.imp.CGameLevel;
import kof.game.levelCommon.info.event.CSceneEventInfo;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;

public class ATrunkEventHandler implements ITrunkEventHandler {
    public virtual function handler(system:CAppSystem, trunkID:int, sceneEvent:CSceneEventInfo):void {
        throw new Error("ATrunkEventHandler's handler function need to override");
    }

    // ====
    final protected function getLevelSystem(system:CAppSystem):CLevelSystem {
        var levelSystem:CLevelSystem = system.stage.getSystem(CLevelSystem) as CLevelSystem;
        return levelSystem;
    }

    final protected function getLevelManager(system:CAppSystem):CLevelManager {
        var levelManager:CLevelManager = getLevelSystem(system).getBean(CLevelManager) as CLevelManager;
        return levelManager;
    }


    final protected function getGameLevel(system:CAppSystem):CGameLevel {
        var gameLevel:CGameLevel = getLevelManager(system).gameLevel;
        return gameLevel;
    }

    final protected function getLevelTrunk(system:CAppSystem, trunkID:int):CTrunkConfigInfo {
        var levelTrunk:CTrunkConfigInfo = getGameLevel(system).findTrunkById(trunkID);
        return levelTrunk;
    }

    final protected function getTrunkInfo(system:CAppSystem, trunkID:int):CTrunkConfigInfo {
        var trunkInfo:CTrunkConfigInfo = getLevelTrunk(system, trunkID);
        return trunkInfo;
    }

    final protected function getTrunkEntityList(system:CAppSystem, trunkID:int):Array {
        var trunkInfo:CTrunkConfigInfo = getTrunkInfo(system, trunkID);
        return trunkInfo.entities;
    }


}
}