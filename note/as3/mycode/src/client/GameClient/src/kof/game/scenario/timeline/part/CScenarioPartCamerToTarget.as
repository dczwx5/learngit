//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import QFLib.Graphics.Scene.CCamera;

import kof.framework.CAppSystem;
import kof.game.character.display.IDisplay;
import kof.game.core.CGameObject;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scene.CSceneHandler;
import kof.game.scene.CSceneSystem;

// 摄像机绑定到人物身上
public class CScenarioPartCamerToTarget extends CScenarioPartBase {
    public function CScenarioPartCamerToTarget(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        if(_target){
            _target.dispose();
            _target = null;
        }
        _actionValue = false;
    }
    public override function start() : void {
        if (_info.params.hasOwnProperty("toActorID")) {
            var targetActorID:int = _info.params["toActorID"];
            _target = _scenarioManager.actorManager.getActor(targetActorID) as CGameObject;
            if (_target) {
//                var characterDisplay : IDisplay = _target.getComponentByClass( IDisplay, true ) as IDisplay;
//                (this.getActor() as CCamera).followingTarget = characterDisplay.modelDisplay.theObject;
                (_system.stage.getSystem(CSceneSystem).handler as CSceneHandler).followObject(_target);
            }
        }
        _actionValue = true;

    }
    public override function end() : void {
//        if(_target){
//            var characterDisplay : IDisplay = _target.getComponentByClass( IDisplay, true ) as IDisplay;
//            (this.getActor() as CCamera).followingTarget = null;
//        }
        _actionValue = false;
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

    private var _target:CGameObject;

}
}
