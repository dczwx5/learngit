/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.core.CGameObject;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartActorScale extends CScenarioPartActorBase {
    public function CScenarioPartActorScale(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        _actionValue = false;
    }
    public override function start() : void {
        var monster:CGameObject = this.getActor() as CGameObject;
//        var scaleX:Number = _info.params["scaleX"];
//        var scaleY:Number = _info.params["scaleY"];
//        var scaleZ:Number = _info.params["scaleZ"];
//        // NOTE: 判定Number是否NaN直接等于永远都不会成立，应该使用isNaN
//        if (scaleX != Number.NaN) monster.transform.scaleX = scaleX;
//        if (scaleY != Number.NaN) monster.transform.scaleY = scaleY;
//        if (scaleZ != Number.NaN) monster.transform.scaleZ = scaleZ;
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
