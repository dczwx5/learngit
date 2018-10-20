//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2018/1/9.
 */
package kof.game.scenario.timeline.part {

import kof.framework.CAppSystem;
import kof.game.level.CLevelSystem;
import kof.game.level.CLevelUIHandler;
import kof.game.scenario.info.CScenarioPartInfo;

/**
 * 显示场景名称
 */
public class CScenarioPartSceneNameShow extends CScenarioPartBase {
    public function CScenarioPartSceneNameShow( partInfo : CScenarioPartInfo, system : CAppSystem ) {
        super( partInfo, system );
    }

    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        _actionValue = false;

        var sceneNameId:int = int(_info.params["sceneName"]);
        var stayTime:Number = int(_info.params["stayTime"]);

        var levelSys:CLevelSystem =  _system.stage.getSystem(CLevelSystem) as CLevelSystem;
        (levelSys.getBean(CLevelUIHandler) as CLevelUIHandler).showSceneName([sceneNameId,stayTime],close);
    }
    public override function end() : void {
        _actionValue = false;
    }

    private function close():void {
        _actionValue = true;
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }
}
}
