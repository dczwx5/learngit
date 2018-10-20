//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/1/23.
 */
package kof.game.level.teaching {

import QFLib.Interface.IDisposable;

import kof.framework.CAppSystem;

import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.handler.CPlayHandler;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.table.TeachingGoal;

public class CTeachingCourseBasics implements IDisposable {
    public function CTeachingCourseBasics(pTeachingData:TeachingGoal, _system:CAppSystem) {
        system = _system;
        teachingData = pTeachingData;
    }

    public function dispose() : void {
        teachingData = null;
        fnCallback = null;
    }

    public function execute( pfnCallback : Function = null ) : void {
        count = 0;
        fnCallback = pfnCallback;
    }

    protected function onCompleted() : void {
        if(fnCallback != null){
            count++;
            fnCallback(count);
        }
    }

    public function get pFightTriggerEvent() : CCharacterFightTriggle{
        if(hero){
            return hero.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
        }
        return null;
    }
    public var teachingData : TeachingGoal;
    public var fnCallback : Function;
    private var count:int;
    protected var system:CAppSystem;

    public function get hero() : CGameObject {
        var m_hero:CGameObject = (system.stage.getSystem(CECSLoop).getBean(CPlayHandler) as CPlayHandler).hero;
        return m_hero;
    }
}
}
