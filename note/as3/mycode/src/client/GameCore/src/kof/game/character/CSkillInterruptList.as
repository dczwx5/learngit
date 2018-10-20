//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/2/27.
//----------------------------------------------------------------------
package kof.game.character {

import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.level.CLevelMediator;
import kof.game.core.CGameComponent;

public class CSkillInterruptList extends CGameComponent {
    private var m_interruptList : Vector.<int>;

    public function CSkillInterruptList( name : String = null, branchData : Boolean = false ) {
        super( name, branchData );
        m_interruptList = new Vector.<int>( 10 );
    }

    override protected function onEnter() : void {
        super.onEnter();
    }

    override protected function onExit() : void {
        super.onExit();
        m_interruptList = null;
    }

    public function setInterruptList( index : int, bIntterupt : int ) : void {
        if ( !m_interruptList || m_interruptList.length <= index )
            return;
        m_interruptList[ index ] = bIntterupt;
    }

    public function getInterruptByIndex( index : int ) : int {
        if ( index >= m_interruptList.length || !m_interruptList )
            return 0;
        return m_interruptList[ index ];
    }

    public function getInterruptBySkill( skillID : int ) : int {
        var pSkillList : CSkillList;
        var mainSkillID : int = CSkillUtil.getMainSkill( skillID );
        pSkillList = owner.getComponentByClass( CSkillList , true ) as CSkillList;
        if( pSkillList ){
            var skillIndex : int  = pSkillList.findIndexBySkill( mainSkillID );
            if( skillIndex > -1 && m_interruptList != null ){
                return m_interruptList[ skillIndex ];
            }
        }
        return 0;
    }

    public function getIsInterruptSkill(skillID : int ) : Boolean{
        var pLMediator : CLevelMediator = pLevelMediator;
        //播放剧情的时候无视这个字段
        if( pLMediator && pLMediator.isPlayingScenario() )
                return false;

        return getInterruptBySkill( skillID ) == 0;
    }

    private function get pLevelMediator() : CLevelMediator{
        return owner.getComponentByClass( CLevelMediator , true ) as CLevelMediator;
    }
}
}
