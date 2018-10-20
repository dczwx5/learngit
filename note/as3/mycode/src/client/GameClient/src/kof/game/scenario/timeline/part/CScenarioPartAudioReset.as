//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.audio.IAudio;
import kof.game.level.ILevelFacade;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartAudioReset extends CScenarioPartBase {
    public function CScenarioPartAudioReset(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
    }
    public override function start() : void {
        _scenarioManager.gameObjectManager.resetBgMusic();
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
