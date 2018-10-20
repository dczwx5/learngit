//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2017/6/6.
 */
package kof.game.scenario.timeline.part {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.framework.IApplication;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.core.CGameObject;
import kof.game.scenario.CScenarioPlaySkillViewHandler;
import kof.game.scenario.info.CScenarioPartInfo;

/**
 * 播放技能（新手序章副本专用）
 */
public class CScenarioPartActorPlayNoviceSkill extends CScenarioPartActorBase {
    public function CScenarioPartActorPlayNoviceSkill( partInfo:CScenarioPartInfo, system:CAppSystem ) {
        super( partInfo, system );
    }

    public override function dispose() : void {

    }

    public override function start() : void {
        _actionValue = false;

        _isSpace = false;//是否是大招
        if(_info.params.hasOwnProperty("isSpace")){
            _isSpace =  Boolean(_info.params["isSpace"]);
        }

        if(_info.params.hasOwnProperty("playSpeed")){
            _playSpeed =  Number(_info.params["playSpeed"]);
        }

        _isShowShortDownView = true;//是否现在快捷键UI
        if(_info.params.hasOwnProperty("isShowView")){
            _isShowShortDownView = Boolean(_info.params["isShowView"]);
        }

        var skillId : int;
        if(_info.params.hasOwnProperty("skillId")) {
            skillId = int( _info.params[ "skillId" ] );
        }
        if( _isShowShortDownView ){
            _skillView = _scenarioSystem.getBean( CScenarioPlaySkillViewHandler ) as CScenarioPlaySkillViewHandler;
            if(_skillView){
                _skillView.show( playSkill, _isSpace, skillId );
                var pApp : Object = _system.stage.getBean( IApplication ) as IApplication;
                pApp._baseDeltaFactor = _playSpeed;
            }
        }else{
            playSkill();
        }
    }

    private function playSkill():void {

        if(_skillView){
            _skillView.hide();
        }

        var forceFinish:Boolean = false;

        var pApp : Object = _system.stage.getBean( IApplication ) as IApplication;
        pApp._baseDeltaFactor = 1;

        if(_info.params.hasOwnProperty("skillId")){
            var skillId:int = int(_info.params["skillId"]);
//            forceFinish = skillId == CScenarioPlaySkillViewHandler._KYO_O;
            var monster:CGameObject = this.getActor() as CGameObject;

            (monster.getComponentByClass(CCharacterFightTriggle, false) as CCharacterFightTriggle).addEventListener(CFightTriggleEvent.SPELL_SKILL_END, _onSkillTimeEnd, false, 0, true);
            (monster.getComponentByClass(CCharacterFightTriggle, false) as CCharacterFightTriggle).addEventListener(CFightTriggleEvent.HIT_TARGET, _onSkillHit, false, 0, true);
            (monster.getComponentByClass(CSimulateSkillCaster, false) as CSimulateSkillCaster).castSkillByID(skillId);
        }
        forceFinish = forceFinish || _isSpace;
        _actionValue = forceFinish;
    }

    private function _onSkillHit( event:Event ):void {
//        var pApp : Object = _system.stage.getBean( IApplication ) as IApplication;
//        pApp._baseDeltaFactor = _playSpeed;

        _actionValue = true;
    }

    private function _onSkillTimeEnd( event:Event ):void {
//        var pApp : Object = _system.stage.getBean( IApplication ) as IApplication;
//        pApp._baseDeltaFactor = 1;
    }

    public override function end() : void {
        _actionValue = false;
    }
    public override function stop() : void {
        super.stop();
        // force finish action
    }

    public override function update(delta:Number) : void {
        super.update(delta);
    }

    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

    private var _skillView:CScenarioPlaySkillViewHandler;

    private var _playSpeed:Number = 1.0;
    private var _isSpace:Boolean = false;//是否是大招
    private var _isShowShortDownView:Boolean = true;//是否显示快捷键UI表现
}
}
