/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.audio.IAudio;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartAudioStop extends CScenarioPartBase {
    public function CScenarioPartAudioStop(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        var type:int = _info.params["type"]; // 0 : 音乐, 1 : 音效
        if (type == 0) {
            (this.getActor() as IAudio).stopMusic();
        } else {
            // 音效
            (this.getActor() as IAudio).stopAudio();
        }
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
