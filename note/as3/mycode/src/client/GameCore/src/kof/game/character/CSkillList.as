//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import kof.game.core.CGameComponent;

/**
 * 技能列表组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSkillList extends CGameComponent {

    /** @private */
    private var m_listSkillIDs : Vector.<uint>;
    private var m_listSkillDamageRevisions : Vector.<Number>;

    public function CSkillList() {
        super( "skills" );

        m_listSkillIDs = new Vector.<uint>(10);
        m_listSkillDamageRevisions = new Vector.<Number>( 10 )
    }

    override public function dispose() : void {
        super.dispose();
        m_listSkillIDs = null;
        m_listSkillDamageRevisions = null;
    }

    public function get size() : uint {
        return m_listSkillIDs.length;
    }

    public function getSkillIDByIndex( index : int ) : uint {
        if ( !m_listSkillIDs || m_listSkillIDs.length <= index )
            return 0;
        return m_listSkillIDs[ index ];
    }

    public function setSkillIDByIndex( index : int, skillID : uint ) : void {
        if ( index < 0 )
            return;
        m_listSkillIDs[ index ] = skillID;
    }

    public function setSkillDamageRevisionByIndex( index : int, damageRevision : Number ) : void {
        if ( index < 0 )
            return;

        m_listSkillDamageRevisions[ index ] = damageRevision;
    }

    public function getSkillDamageRevisionByIndex( index : int ) : Number {
        if ( !m_listSkillDamageRevisions || m_listSkillDamageRevisions.length <= index )
            return 1.0;
        return m_listSkillDamageRevisions[ index ];

    }

    public function findIndexBySkill( skillID : int ) : uint
    {
        if( m_listSkillIDs && m_listSkillIDs.length > 0 )
        {
            return m_listSkillIDs.indexOf( skillID );
        }

        return 0;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

}
}
