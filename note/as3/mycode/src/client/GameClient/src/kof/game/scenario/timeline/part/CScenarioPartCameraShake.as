/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import QFLib.Graphics.Scene.CCamera;

import kof.framework.CAppSystem;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartCameraShake extends CScenarioPartBase {
    public function CScenarioPartCameraShake(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
    }
    public override function start() : void {
        var camera:CCamera = this.getActor() as CCamera;
        if (camera) {
            var fIntensity:Number;
            if (_info.params.hasOwnProperty("shake")) {
                fIntensity = _info.params["shake"];
            } else {
                fIntensity = 4.0;
            }
            camera.shake(fIntensity, _info.duration);
        }
    }
    public override function end() : void {
    }

    public override function stop() : void {
        super.stop();
        var camera:CCamera = this.getActor() as CCamera;
        if (camera) {
            camera.stopShake();
        }
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return false;
    }

}
}
