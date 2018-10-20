//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/4/5.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Foundation.CMap;
import QFLib.Math.CVector2;
import QFLib.Utils.Debug.Debug;

import flash.utils.getQualifiedSuperclassName;

import kof.game.character.CCharacterDataDescriptor;

import kof.game.character.CEventMediator;

import kof.game.character.CTarget;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skill.CSkillTeleport;
import kof.game.core.CGameObject;
import kof.game.core.CGameObject;
import kof.table.Teleport;
import kof.table.Teleport.ETeleportType;

public class CSkillTeleportEffect extends CAbstractSkillEffect {
    public function CSkillTeleportEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose() : void {
        doEnd();
        m_theTeleportedTarget.clear();
        m_theTeleportedTarget = null;
        m_theSkillTeleport = null;
//        m_theFirstDesTarget = null;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( m_theSkillTeleport != null )
            m_theSkillTeleport.update( delta );
    }

    override public function lastUpdate( delta : Number ) : void {
        if ( m_theSkillTeleport != null )
            m_theSkillTeleport.lastUpdate( delta );
        super.lastUpdate( delta );
    }

    override public function initData( ... arg ) : void {
        super.initData( arg );
        var skillDB : CSkillDataBase = CSkillCaster.skillDB;
        m_theTeleportData = skillDB.getTeleportEffectByID( effectID );
        m_theTeleportedTarget = new CMap( true );
    }

    public function doTeleportDirectlyToPosition2D( position : CVector2, onEndCallBack : Function = null ) : void {
        _subscribeTeleport( null, position, onEndCallBack );
    }

    public function doTeleportDirectlyToTarget( target : CGameObject, onEndCallBack : Function = null ) : void {
        _subscribeTeleport( target, null, onEndCallBack );
    }

    override public function doStart() : void {
        super.doStart();
    }

    override public function doRunning( delta : Number ) : void {
        super.doRunning( delta );
        var teleporters : Array = _findTeleTargets();
        if ( m_theFirstDesTarget == null )
            _findDesTarget();
        _castTeleportToTarget( teleporters );
    }

    //寻找被传送对象
    private function _findTeleTargets() : Array {
        if ( hitEventSignal != null && hitEventSignal.length != 0 ) {
            var teleporters : Array = pCriteriaComp.getTargetByCollision( hitEventSignal, m_theTeleportData.EffectCriteria );
            if ( teleporters ) {
                return teleporters;
            }
        }

        return null;
    }

    //寻找传送位置对象
    private function _findDesTarget() : CGameObject {
        if ( m_theTeleportData.TeleportType != ETeleportType.MODE_CRITERIA )
            return null;
        if ( m_theTeleportData.TeleportType == ETeleportType.MODE_CRITERIA &&
                m_theTeleportData.TeleportGoal != 0 && m_theTeleportData.HitEvent.length != 0 ) {
            var teleporters : Array = pCriteriaComp.getTargetByCollision( m_theTeleportData.HitEvent, m_theTeleportData.TeleportGoal );
            if ( teleporters && teleporters.length > 0 ) {
                if ( m_theFirstDesTarget == null ) {
                    m_theFirstDesTarget = teleporters[ 0 ];

                    CONFIG::debug {
                        CSkillDebugLog.logTraceMsg( "找到传送对象了， 目标为 " + CCharacterDataDescriptor.getSimpleDes( m_theFirstDesTarget.data ) );
                    }
                    return m_theFirstDesTarget;
                }

            }

        }
        return null;
    }

    private function _castTeleportToTarget( teleporters : Array ) : void {
        if ( m_theTeleportedTarget ) {
            for each( var teler : CGameObject in teleporters ) {
                if ( m_theTeleportedTarget.find( teler ) == null ) {
                    _decodeTeleport( teler );
                }
            }
        }
    }

    private function _decodeTeleport( target : CGameObject ) : void {
        var targetCaster : CSkillCaster = target.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        if ( targetCaster == null ) {
            CSkillDebugLog.logTraceMsg( "target has not caster Comp" );
            return;
        }

        if ( m_theTeleportData.TeleportType == ETeleportType.MODE_SELF )
            targetCaster.castTeleportToTarget( m_theTeleportData.ID, owner );
        else if ( m_theTeleportData.TeleportType == ETeleportType.MODE_CRITERIA ) {
            targetCaster.castTeleportToTarget( m_theTeleportData.ID, m_theFirstDesTarget );
        } else if ( m_theTeleportData.TeleportType == ETeleportType.MODE_GOAL ) {
            var curruntObj : CTarget = pTarget;// target.getComponentByClass( CTarget , true ) as CTarget;
            if ( curruntObj && curruntObj.targetObject ) {
                targetCaster.castTeleportToTarget( m_theTeleportData.ID, curruntObj.targetObject );
            }
        } else if ( m_theTeleportData.TeleportType == ETeleportType.MODE_POSITION ) {
            targetCaster.castTeleportToPosition( m_theTeleportData.ID, new CVector2( m_theTeleportData.TeleportX
                    , m_theTeleportData.TeleportY ) );
        }

        m_theTeleportedTarget.add( target, true );
    }

    final protected function get pTarget() : CTarget {
        return owner.getComponentByClass( CTarget, true ) as CTarget;
    }

    override public function doEnd() : void {
        super.doEnd();
        if ( m_theSkillTeleport )
            m_theSkillTeleport.unsubscribeTeleport();
        m_theSkillTeleport = null;
    }

    private function _subscribeTeleport( target : CGameObject, position : CVector2, onEndCallBack : Function = null ) : void {
        m_theSkillTeleport = new CSkillTeleport( m_pContainer.owner );
        m_theSkillTeleport.subscribeTeleport( m_theTeleportData, position, target, onEndCallBack );
    }

    private var m_theTeleportData : Teleport;
    private var m_theSkillTeleport : CSkillTeleport;
    private var m_theTeleportedTarget : CMap;
    private var m_theFirstDesTarget : CGameObject;
}
}
