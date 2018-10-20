//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/5/9.
 */
package kof.game.level.teaching.courses {

import QFLib.Foundation.CMap;

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import kof.framework.CAppSystem;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.fightui.CFightViewHandler;
import kof.game.fightui.compoment.CSkillViewHandler;
import kof.game.level.teaching.CTeachingCourseBasics;
import kof.game.lobby.CLobbySystem;
import kof.table.TeachingGoal;

//技能CD
public class CTeachingSkillCD extends CTeachingCourseBasics {
    public function CTeachingSkillCD( pTeachingData : TeachingGoal, _system : CAppSystem ) {
        super( pTeachingData, _system );
    }

    override public function dispose() : void {
        if( pFightTriggerEvent ){
            pFightTriggerEvent.removeEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN , _onBegin);
        }
        system.stage.flashStage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
        var pLobbySystem:CLobbySystem = system.stage.getSystem(CLobbySystem) as CLobbySystem;
        (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).showAllSkillItems();
        super.dispose();
    }

    override public function execute( pfnCallback : Function = null ) : void {
        super.execute( pfnCallback );
        targetsID = int(teachingData.SkillID);
        hideSkill();
        if( pFightTriggerEvent ){
            pFightTriggerEvent.addEventListener( CFightTriggleEvent.SPELL_SKILL_BEGIN , _onBegin);
        }
    }

    private function _onBegin( e : CFightTriggleEvent ) : void{
        var paramsList : Array = e.parmList;
        var skillID : int = paramsList[0];
            if(targetsID == skillID){
                trace("释放技能!!!!");
                onCompleted();
                return;
            }
    }

    private function hideSkill():void{

        var pLobbySystem:CLobbySystem = system.stage.getSystem(CLobbySystem) as CLobbySystem;
        (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).hideSkillItemByKey("U");
        (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).hideSkillItemByKey("I");
        (pLobbySystem.getBean(CFightViewHandler).getBean(CSkillViewHandler) as CSkillViewHandler).hideSkillItemByKey("SPACE");
        system.stage.flashStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, false, 9999);

        _invalidKeyList = new CMap();
        _invalidKeyList.add(Keyboard.U, Keyboard.U);
        _invalidKeyList.add(Keyboard.I, Keyboard.I);
        _invalidKeyList.add(Keyboard.SPACE, Keyboard.SPACE);
    }

    private function _onKeyDown(e:KeyboardEvent):void {
        if (e.keyCode in _invalidKeyList) {
            e.stopImmediatePropagation();
        }
    }

    private var _invalidKeyList:CMap;
    private var targetsID : int;
}
}
