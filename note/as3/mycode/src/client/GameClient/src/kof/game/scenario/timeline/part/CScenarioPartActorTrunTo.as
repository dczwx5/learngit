/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.character.CFacadeMediator;
import kof.game.core.CGameObject;
import kof.game.scenario.info.CScenarioPartInfo;

/**
 * 转身
 */
public class CScenarioPartActorTrunTo extends CScenarioPartActorBase {
    public function CScenarioPartActorTrunTo(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        var monster:CGameObject = this.getActor() as CGameObject;
        var dir:int = _info.params["dir"];
        // 右1， 左-1
        if ((monster.getComponentByClass(CFacadeMediator, false) as CFacadeMediator))
            (monster.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).setDisplayDirection(dir);

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
