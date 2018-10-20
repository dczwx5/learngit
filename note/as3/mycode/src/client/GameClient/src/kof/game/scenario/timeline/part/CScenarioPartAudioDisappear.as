/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartAudioDisappear extends CScenarioPartBase {
    public function CScenarioPartAudioDisappear(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
    }
    public override function start() : void {
    }
    public override function end() : void {

    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return false;
    }

}
}
