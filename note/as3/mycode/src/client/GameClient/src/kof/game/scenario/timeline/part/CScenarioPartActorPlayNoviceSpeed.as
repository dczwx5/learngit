/**
 * Created by Administrator on 2017/6/20.
 */
package kof.game.scenario.timeline.part {

import kof.framework.CAppSystem;
import kof.framework.IApplication;
import kof.game.scenario.info.CScenarioPartInfo;

/**
 * 播放速度（新手序章副本专用）
 */
public class CScenarioPartActorPlayNoviceSpeed extends CScenarioPartActorBase {
    public function CScenarioPartActorPlayNoviceSpeed( partInfo : CScenarioPartInfo, system : CAppSystem ) {
        super( partInfo, system );
    }

    public override function dispose() : void {

    }

    public override function start() : void {
        _actionValue = true;

        if(_info.params.hasOwnProperty("speed")){
            _playSpeed = Number(_info.params["speed"]);
        }

        var pApp : Object = _system.stage.getBean( IApplication ) as IApplication;
        pApp._baseDeltaFactor = _playSpeed;

    }

    public override function end() : void {
        _actionValue = false;
    }
    public override function stop() : void {
        super.stop();
        // force finish action
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }

    public override function isActionFinish() : Boolean {
        return _actionValue;
    }


    private var _playSpeed:Number = 1.0;


}
}
