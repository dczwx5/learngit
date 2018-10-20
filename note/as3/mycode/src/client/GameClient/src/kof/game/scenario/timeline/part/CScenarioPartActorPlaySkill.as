//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2016/12/22.
 */
package kof.game.scenario.timeline.part {
import flash.events.Event;

import kof.framework.CAppSystem;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.core.CGameObject;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartActorPlaySkill extends CScenarioPartActorBase {
    public function CScenarioPartActorPlaySkill(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super(partInfo, system);
    }

    public override function dispose() : void {
    }
    public override function start() : void {
        _actionValue = false;
        var monster:CGameObject = this.getActor() as CGameObject;
        var skillId:int = int(_info.params["skillId"]);
        (monster.getComponentByClass(CCharacterFightTriggle, false) as CCharacterFightTriggle).addEventListener(CFightTriggleEvent.SPELL_SKILL_END, _onSkillTimeEnd, false, 0, true);
        (monster.getComponentByClass(CSimulateSkillCaster, false) as CSimulateSkillCaster).castSkillByID(skillId);
    }

    private function _onSkillTimeEnd(event:Event):void {
        _actionValue = true;
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

}
}
