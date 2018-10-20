//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/12/14.
//----------------------------------------------------------------------
package kof.game.character.fight.skilleffect {

import QFLib.Collision.CCharacterCollisionBound;
import QFLib.Framework.CObject;
import QFLib.Math.CMath;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.geom.Point;

import kof.game.character.CKOFTransform;

import kof.game.character.collision.CCollisionComponent;

import kof.game.character.fight.CTargetCriteriaComponet;

import kof.game.character.fight.event.CFightTriggleEvent;

import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fx.CFXMediator;
import kof.game.character.level.CLevelMediator;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.table.Summoner;

public class CSkillSummonEffect extends CAbstractSkillEffect {
    public function CSkillSummonEffect( id : int, startFrame : Number, hitEvent : String, etype : int, des : String = "" ) {
        super( id, startFrame, hitEvent, etype, des );
    }

    override public function dispose() : void {
        m_bSummoned = false;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );
        var targetPosition : CVector3;
        targetPosition = _findPosition();
        if ( null != targetPosition && !m_bSummoned ) {
            m_bSummoned = true;
            _summon( targetPosition );
        }
    }

    override public function initData( ... arg ) : void {
        super.initData( null );
        m_summonerData = CSkillCaster.skillDB.getSummoner( effectID );
    }

    private function _findPosition() : CVector3 {
        var position : CVector3;
        if ( m_summonerData.BornMode == 2 ) {
            position = _findTrunkIndexPosition( m_summonerData.TrunkPoint );
        } else if ( m_summonerData.BornMode == 1 ) {
            position = _findCriteriaPosition();
        }

        return position;
    }

    private function _findTrunkIndexPosition( index : int ) : CVector3 {
        var pCollisionComp : CCollisionComponent = collisionComp;
        var pLevelMediator : CLevelMediator = owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
        var levelInfo : Object;
        var collisionBound : CCharacterCollisionBound;
        var retPosition : CVector3;
        if ( null == pCollisionComp || pLevelMediator == null ) return null;

        collisionBound = pCollisionComp.getCollisionBoundByHitEvent( hitEventSignal );

        if ( collisionBound == null )
            return null;

        levelInfo = pLevelMediator.getSingPoints( index );

        if ( levelInfo != null )
            retPosition = new CVector3( levelInfo.x + m_summonerData.OffsetX, levelInfo.y + m_summonerData.OffsetZ, m_summonerData.OffsetY );
        else {
            CSkillDebugLog.logTraceMsg( "The trunk index posion for Summon do not exist , index = " + index + " SUMMON ID : " + effectID );
        }

        return retPosition;
    }

    private function _findCriteriaPosition() : CVector3 {
        var pCriteriaComp : CTargetCriteriaComponet = criteriaComp;
        var retPosition : CVector3;
        if ( null == pCriteriaComp ) return null;

        var targets : Array = pCriteriaComp.getTargetByCollision( hitEventSignal, m_summonerData.CriteriaID );
        if ( targets != null && targets.length > 0 ) {
            var target : CGameObject = targets[ 0 ] as CGameObject;
            var targetTransform : CKOFTransform = target.getComponentByClass( CKOFTransform, true ) as CKOFTransform;

            if ( targetTransform ) {
                var targetPosition : CVector3 = new CVector3( targetTransform.x + m_summonerData.OffsetX,
                        targetTransform.y + m_summonerData.OffsetZ, targetTransform.z + m_summonerData.OffsetY );

                var axis2d : CVector3 = CObject.get2DPositionFrom3D( targetPosition.x , targetPosition.z , targetPosition.y );
                retPosition = new CVector3( axis2d.x , axis2d.y , axis2d.z );
            }

            return retPosition;
        }

        return null;
    }

    final private function get criteriaComp() : CTargetCriteriaComponet {
        return owner.getComponentByClass( CTargetCriteriaComponet, true ) as CTargetCriteriaComponet;
    }

    final private function get collisionComp() : CCollisionComponent {
        return owner.getComponentByClass( CCollisionComponent, true ) as CCollisionComponent;
    }

    private function _summon( position : CVector3 ) : void {
        var pFightTrigger : CCharacterFightTriggle;
        var dir : int;
        pFightTrigger = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;

        var pFXMediator : CFXMediator = owner.getComponentByClass( CFXMediator , true ) as CFXMediator;
        var pStateBorad : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
        if( pFXMediator )
                pFXMediator.playComhitEffects( m_summonerData.BornSFXName );

        var dirPoint : Point;
        if( pStateBorad )
                dirPoint  = pStateBorad.getValue( CCharacterStateBoard.DIRECTION );
        if( dirPoint )
                dir = Math.ceil( dirPoint.x );

        var summonID : int = m_summonerData.ID;
        if ( pFightTrigger ) {
            pFightTrigger.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SUMMON, null, [ summonID, position ,dir ] ) );
        }
    }

    private var m_summonerData : Summoner;
    private var m_bSummoned : Boolean;
    /**
     * 1 为碰撞框筛选配置  ， 2 为指定关卡点配置
     */
}
}
