//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/28.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation.CMap;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.collision.CCollisionComponent;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.fight.buff.CBuffContainer;
import kof.game.character.fight.buff.buffentity.IBuff;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.core.CGameObject;
import kof.table.BuffEmitter;

/**
 * buff发射器的效果
 */
public class CSkillBuffEffect extends CAbstractSkillEffect {
    public function CSkillBuffEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
        m_pTargetList = new CMap();
    }

    override public function dispose() : void
    {
        if( m_pTargetList )
                m_pTargetList.clear();
        m_pTargetList = null;

        m_buffEmitter = null;
        m_pOwner = null;
        super.dispose();
    }
    override public function update( delta : Number ) : void
    {
        if( m_buffEmitter == null )
                return;
        super.update( delta );
        var targets : Array = findTarget();
        if( targets && targets.length != 0 )
        {
             _castBuffs( targets );
        }
    }

    override public function initData( ...arg ) : void
    {
        if( arg == null || arg.length == 0 )
                return;
        m_pOwner = arg[ 0 ] as CGameObject;
        m_buffEmitter = CSkillCaster.skillDB.getBuffEmitterByInfo( effectID );
    }

    public function findTarget() : Array
    {
        var canHitTargets : Array;
        var criteriaComp : CTargetCriteriaComponet = m_pOwner.getComponentByClass( CTargetCriteriaComponet , true ) as CTargetCriteriaComponet;
        canHitTargets = criteriaComp.getTargetByCollision( hitEventSignal , m_buffEmitter.TargetFilter );
        if(canHitTargets && canHitTargets.length != 0 )
        {
            var resTarget : Array = [];
            for each( var target : CGameObject in  canHitTargets ) {
                if ( m_pTargetList.find( target ) != null ) break;
                resTarget.push(target);
                m_pTargetList.add(target,  target) ;
            }

            return resTarget ;
        }

        return null;
    }

    private function _castBuffs( targets : Array ) : void
    {
        if( !targets )return;

        var buffers : Array = [];
        for each ( var target : CGameObject in targets )
        {
            var targetInfo : Object = {};
            targetInfo.targetId = CCharacterDataDescriptor.getID( target.data );
            targetInfo.type =  CCharacterDataDescriptor.getType( target.data );
            buffers.push( targetInfo );
        }
        var pFightTrigger : CCharacterFightTriggle = m_pOwner.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
        pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_ADDBUFF , null , [ effectID , buffers ] ));

    }

    private var m_pOwner : CGameObject;
    private var m_buffEmitter : BuffEmitter;
    private var m_pTargetList : CMap;
}
}

