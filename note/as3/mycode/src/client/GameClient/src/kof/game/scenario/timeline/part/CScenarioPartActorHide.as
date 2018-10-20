/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {

import kof.framework.CAppSystem;
import kof.game.character.display.IDisplay;
import kof.game.core.CGameObject;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartActorHide extends CScenarioPartActorBase {
    public function CScenarioPartActorHide(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        var monster:CGameObject = this.getActor() as CGameObject;
        (monster.getComponentByClass( IDisplay, false ) as IDisplay).modelDisplay.visible = false;
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
