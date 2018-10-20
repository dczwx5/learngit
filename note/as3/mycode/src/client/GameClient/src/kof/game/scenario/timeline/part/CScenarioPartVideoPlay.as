/**
 * Created by auto on 2016/8/11.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.levelCommon.CLevelPath;
import kof.game.level.lib.CVideoPlay;
import kof.game.scenario.enum.EScenarioActorType;
import kof.game.scenario.enum.EScenarioPartType;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.ui.CUISystem;

public class CScenarioPartVideoPlay extends CScenarioPartBase {
    public function CScenarioPartVideoPlay(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        if (_video) {
            _video.dispose();
            _video = null;
        }
    }
    public override function start() : void {
        if (_info.type == EScenarioPartType.VIDEO_PLAY && _info.actorType == EScenarioActorType.VIDEO) {
            _actionValue = false;
            var videoName:String = _info.params["mvName"];
            var url:String = CLevelPath.getVideoPath(videoName);
            _video = new CVideoPlay(url, (_system.stage.getSystem(CUISystem) as CUISystem).plotLayer, null, _onPlayFinish);

        } else {
            _actionValue = true;
        }

    }
    public override function end() : void {
        _actionValue = false;
        if (_video) {
            _video.dispose();
            _video = null;
        }
    }

    public override function update(delta:Number) : void {
        // super.update(delta);
    }

    public override function stop() : void {
        super.stop();
        if (_video) {
            _video.stop();
            _onPlayFinish();
        }
    }

    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

    private function _onPlayFinish() : void {
        _actionValue = true;
    }
    private var _video:CVideoPlay;
}
}
