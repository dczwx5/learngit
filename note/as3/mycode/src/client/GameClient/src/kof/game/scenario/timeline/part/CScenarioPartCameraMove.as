/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import QFLib.Graphics.Scene.CCamera;
import QFLib.Math.CVector2;

import kof.framework.CAppSystem;
import kof.game.scenario.info.CScenarioPartInfo;
public class CScenarioPartCameraMove extends CScenarioPartBase {
    public function CScenarioPartCameraMove(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        var toX:int = -1; //_info.params["x"];
        var toY:int = -1; // _info.params["y"];
        var height:int = -1; // _info.params["height"];
        var hasPoint:Boolean = false;
        var hasHeight:Boolean = false;
        var pointVec:CVector2 = new CVector2();
        var extVec:CVector2 = new CVector2();
        var moveTime:Number = -1;
        if (_info.params.hasOwnProperty("x") && _info.params.hasOwnProperty("y")) {
            toX = _info.params["x"];
            toY = _info.params["y"];
            hasPoint = true;
            pointVec.addOnValueXY(toX,toY);
        }
        if (_info.params.hasOwnProperty("height")) {
            height = _info.params["height"];
            hasHeight = true;
        }
        if (_info.params.hasOwnProperty("moveTime")) {
            moveTime = _info.params["moveTime"];
        }
        if (hasPoint && !hasHeight) {
            (this.getActor() as CCamera).zoomCenterExtValue(false,toX,toY,-1,-1,-1,moveTime,-1);
        } else if (hasPoint && hasHeight) {
            var width:Number = 1500/900 * height;
            extVec.addOnValueXY(width*0.5,height*0.5);
            (this.getActor() as CCamera).zoomCenterExtValue(false,toX,toY,extVec.x,extVec.y,-1,moveTime,-1);
        }
        // _scenarioManager.gameObjectManager.moveCamera(toX, toY, height);
        _actionValue = true;
    }
    public override function end() : void {
        _actionValue = false;
    }
    public override function stop() : void {
        super.stop();
        // force move to targer
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

}
}
