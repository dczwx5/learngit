/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import QFLib.Math.CVector2;

import kof.framework.CAppSystem;
import kof.game.character.CFacadeMediator;
import kof.game.character.movement.CMovement;
import kof.game.core.CGameObject;
import kof.game.scenario.enum.EScenarioPartType;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartActorMove extends CScenarioPartActorBase {
    public function CScenarioPartActorMove(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
    }
    public override function start() : void {
        _actionValue = false;
        if (_info.type == EScenarioPartType.ACTOR_MOVE) {
            var monster:CGameObject = this.getActor() as CGameObject;
            if (!monster || monster.isRunning == false) {
                _actionValue = true;
                return ;
            }
            var toX:Number = _info.params["x"];
            var toY:Number = _info.params["y"];
            var movementComponent:CMovement = monster.getComponentByClass(CMovement, false) as CMovement;
            if (movementComponent){
                movementComponent.collisionEnabled = false;
            }
            (monster.getComponentByClass(CFacadeMediator, false) as CFacadeMediator).moveToPixel(Vector.<CVector2>([new CVector2(toX, toY)]), _onMoveEnd,true)
        } else {
            _actionValue = true;
        }

    }
    public override function end() : void {
        _actionValue = false;
    }
    public override function stop() : void {
        super.stop();
    }
    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

    private function _onMoveEnd() : void {
        if (this.isStop()) return ;
        _actionValue = true;
    }

}
}
