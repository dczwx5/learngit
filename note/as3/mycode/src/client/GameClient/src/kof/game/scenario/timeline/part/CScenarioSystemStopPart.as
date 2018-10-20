//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/8/11.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.scenario.enum.EScenarioActorType;
import kof.game.scenario.enum.EScenarioPartType;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioSystemStopPart extends CScenarioPartBase {
    public function CScenarioSystemStopPart(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        if (_info.type == EScenarioPartType.SYSTEM_STOP_PART && _info.actorType == EScenarioActorType.SYSTEM) {
            var partID:int = _info.params["part"];
            _scenarioManager.stopPart(partID);
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
