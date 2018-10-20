/**
 * Created by user on 2016/10/10.
 */
package kof.game.scenario.timeline.part {

import kof.framework.CAppSystem;
import kof.game.core.CECSLoop;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.CScenarioViewHandler;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartScreenWhite extends CScenarioPartActorBase {
    public function CScenarioPartScreenWhite( partInfo : CScenarioPartInfo, system : CAppSystem ) {
        super( partInfo, system );
    }

    override public virtual function dispose() : void {
        _actionValue = false;
    }

    override public virtual function start() : void {
        if(_info.params == null){
            CLevelLog.addDebugLog("[CScenarioPartScreenWhite] info params is null");
            return;
        }
        if(_info.params.hasOwnProperty("showTime")){
            var duratiomTime:Number = _info.params["showTime"];
            (_system.getBean(CScenarioViewHandler) as CScenarioViewHandler).showMaskView(_endBlackFinish,null,null,duratiomTime,0xffffff);
        }
    }

    private function _endBlackFinish() : void {
        _actionValue = true;
    }

    override public virtual function update(delta:Number):void {
        super.update(delta);
    }

    override public virtual function end() : void {
        _actionValue = false;
    }

    override public virtual function isActionFinish() : Boolean {
        return _actionValue;
    }

}
}
