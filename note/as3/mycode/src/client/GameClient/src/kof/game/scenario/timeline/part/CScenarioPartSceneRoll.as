//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/4.
 */
package kof.game.scenario.timeline.part {
import QFLib.Framework.CObject;
import QFLib.Framework.CScene;

import kof.framework.CAppSystem;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;

public class CScenarioPartSceneRoll extends CScenarioPartBase {
    public function CScenarioPartSceneRoll( partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }

    public override function dispose() : void {
        var playObject:CObject = this.getActor() as CObject;
        if (playObject) {
            playObject = null;
        }
    }
    public override function start() : void {
        _actionValue = false;
        var layer:int = _info.params["layer"];
        var throttle:int = _info.params["throttle"];

        var scene:CScene = ((_system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
        scene.setLayerRollingThrottle(throttle, 0.5, layer);

        _actionValue = true;
    }

    public override function end() : void {
        _actionValue = false;
    }

    public override function update(delta:Number) : void {
        super.update(delta);

    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

}
}
