/**
 * Created by auto on 2016/5/19.
 */
package kof.game.level.imp {

import QFLib.Graphics.RenderCore.starling.events.EventDispatcher;
import flash.geom.Rectangle;

import kof.game.levelCommon.info.CLevelConfigInfo;
import kof.game.levelCommon.info.trunk.CTrunkConfigInfo;


public class CGameLevel extends EventDispatcher {
    internal var _levelConfig:CLevelConfigInfo;

    // =======================================================================================
    public function CGameLevel(cfgInfo:CLevelConfigInfo) {
        _levelConfig = cfgInfo;
    }
    public function dispose() : void {
        _levelConfig = null;
    }
    // ========================================================================================

    public function get levelCfgInfo() : CLevelConfigInfo {
        return _levelConfig;
    }

    public function findTrunkById(id:int) : CTrunkConfigInfo {
        return _levelConfig.getTrunkById(id);
    }

    public function destroy() : void  {
        _levelConfig = null;
    }
    public function getTrunkAreaData(trunkID:int) : Rectangle {
        var ret:Rectangle = findTrunkById(trunkID).getTrunkRect();
        return ret;
    }

}
}
