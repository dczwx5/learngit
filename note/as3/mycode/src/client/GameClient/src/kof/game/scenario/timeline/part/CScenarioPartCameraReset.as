//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/8/29.
 */
package kof.game.scenario.timeline.part {
import QFLib.Graphics.Scene.CCamera;

import kof.framework.CAppSystem;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CGameObject;
import kof.game.core.CECSLoop;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scene.CSceneHandler;
import kof.game.scene.CSceneSystem;

// 还原摄像机
public class CScenarioPartCameraReset extends CScenarioPartBase {
    public function CScenarioPartCameraReset(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        // this._scenarioManager.gameObjectManager.resetCamera();
        (this.getActor() as CCamera).unZoom(true);
        var hero:CGameObject = (_system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        (_system.stage.getSystem(CSceneSystem).getBean(CSceneHandler) as CSceneHandler).followObject(hero);

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
