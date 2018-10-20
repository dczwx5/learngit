/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.audio.IAudio;
import kof.game.levelCommon.CLevelPath;
import kof.game.scenario.info.CScenarioPartInfo;

// 播放音乐, 剧情结束不恢复
public class CScenarioPartAudioPlay extends CScenarioPartBase {
    public function CScenarioPartAudioPlay(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        var type:int = _info.params["type"]; // 0 : 音乐, 1 : 音效
        if (_info.params.hasOwnProperty("music")) {
            var music:String = _info.params["music"];
            if (music != null && music.length > 0) {
                var isLoop:Boolean = _info.params.hasOwnProperty("loop") ? _info.params["loop"] : false;
                var playTime:int = isLoop ? int.MAX_VALUE : 1;
                if (type == 0) {
                    music = CLevelPath.getMusicPath(music);
                    (this.getActor() as IAudio).playMusicByPath(music, playTime);
                } else {
                    // 音效
                    music = CLevelPath.getAudioPath(music);
                    (this.getActor() as IAudio).playAudioByPath(music, playTime);
                }
            }

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
