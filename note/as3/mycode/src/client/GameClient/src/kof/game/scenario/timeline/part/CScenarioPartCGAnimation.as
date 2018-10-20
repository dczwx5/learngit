/**
 * Created by user on 2016/11/14.
 */
package kof.game.scenario.timeline.part {
import kof.framework.CAppSystem;
import kof.game.scenario.CScenarioViewHandler;
import kof.game.scenario.imp.CScenarioActorCG;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartCGAnimation extends CScenarioPartActorBase {

    private var _scenario:CScenarioViewHandler;
    public function CScenarioPartCGAnimation(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super(partInfo, system);
    }

    override public virtual function dispose() : void {
        _actionValue = false;
    }

    override public virtual function start() : void {
        _actionValue = false;
        _scenario = (_system.getBean(CScenarioViewHandler) as CScenarioViewHandler);
        var cg:CScenarioActorCG = this.getActor() as CScenarioActorCG;
        _scenario.showCGAnimation(_info, showOver, cg);
    }

    private function showOver(obj:Object = null):void{
        _actionValue = true;
        (getActor() as CScenarioActorCG).actorImg.visible = false;
    }

    override public virtual function update(delta:Number):void {
        super.update(delta);
    }

    public override function stop() : void {
        super.stop();
        if(_scenario){
            _scenario.hideCGAnimation(showOver);
        }
    }

    override public virtual function end() : void {
        _actionValue = false;
    }

    override public virtual function isActionFinish() : Boolean {
        return _actionValue;
    }
}
}
