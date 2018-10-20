/**
 * Created by auto on 2016/8/8.
 */
package kof.game.scenario.timeline.part {
import flash.events.Event;

import kof.framework.CAppSystem;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.animation.IAnimation;
import kof.game.core.CGameObject;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartActorPlayAction extends CScenarioPartActorBase {
    public function CScenarioPartActorPlayAction(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
    }
    public override function start() : void {
        _actionValue = false;
        var monster:CGameObject = this.getActor() as CGameObject;
        var action:String = _info.params["action"];
        var speed:Number = _info.params["playSpeed"];
        var isLoop:Boolean = false;
        if(_info.params.hasOwnProperty("isLoop")){
            isLoop = _info.params["isLoop"];
        }
        (monster.getComponentByClass(CEventMediator, false) as CEventMediator).addEventListener(CCharacterEvent.ANIMATION_TIME_END, _onAnimationTimeEnd );

        var iAnimation:IAnimation = (monster.getComponentByClass(IAnimation, false) as IAnimation);
        iAnimation.addSkillAnimationState( action.toUpperCase() , action );
        iAnimation.speedUpAnimation(speed);
        iAnimation.noPhysicsAndAnimationOffset = false;
        iAnimation.animationOffsetEnabled = true;
        iAnimation.playAnimation(action.toUpperCase(), true, isLoop);//大写
        CLevelLog.addDebugLog("Scenario actor play action :" + action.toUpperCase());
    }

    private function _onAnimationTimeEnd(event:Event):void {
        //var monster:CGameObject = this.getActor() as CGameObject;
       // (monster.getComponentByClass(CEventMediator, false) as CEventMediator).removeEventListener(CCharacterEvent.ANIMATION_TIME_END, _onAnimationTimeEnd);
        _actionValue = true;
    }
    public override function end() : void {
        var monster:CGameObject = this.getActor() as CGameObject;
        (monster.getComponentByClass(IAnimation, false) as IAnimation).resumeAnimation();
//        (monster.getComponentByClass(IAnimation, false) as IAnimation).animationOffsetEnabled = false;
        (monster.getComponentByClass(CEventMediator, false) as CEventMediator).removeEventListener(CCharacterEvent.ANIMATION_TIME_END, _onAnimationTimeEnd);
        _actionValue = false;
    }
    public override function stop() : void {
        super.stop();
        // force finish action
        var monster:CGameObject = this.getActor() as CGameObject;
        if( monster ) {
            (monster.getComponentByClass(IAnimation, false) as IAnimation).resumeAnimation();
            (monster.getComponentByClass(IAnimation, false) as IAnimation).animationOffsetEnabled = false;
            (monster.getComponentByClass(CEventMediator, false) as CEventMediator).removeEventListener(CCharacterEvent.ANIMATION_TIME_END, _onAnimationTimeEnd);
        }
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

}
}
