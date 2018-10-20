//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/4/6.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Framework.CCharacter;
import QFLib.Graphics.FX.utils.MathUtils;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox2;
import QFLib.Math.CMath;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.events.Event;

import flash.geom.Point;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.CKOFTransform;

import kof.game.character.animation.IAnimation;

import kof.game.character.fx.CFXMediator;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameObject;
import kof.table.Teleport;
import kof.table.Teleport.ETeleportType;

import org.msgpack.NullWorker;

public class CSkillTeleport implements IUpdatable, IDisposable {
    public function CSkillTeleport( owner : CGameObject ) {
        m_pOwner = owner;
    }

    public function subscribeTeleport( teleData : Teleport, position : CVector2 = null, target : CGameObject = null,
                                       onEndCallBack : Function = null ) : void {
        m_pTeleportData = teleData;
        m_fTickTime = 0.0;
        m_pDestination = position;
        m_pTarget = target;
        m_pTeleportEndCallBack = onEndCallBack;
    }

    public function unsubscribeTeleport() : void {
        m_fTickTime = NaN;
        m_pTeleportData = null;
    }

    public function dispose() : void {
        m_pTeleportData = null;
        m_pOwner = null;
        m_fTickTime = NaN;
        m_pTeleportEndCallBack = null;
        m_pTarget = null;
        m_pDestination = null;
    }

    public function update( delta : Number ) : void {
        if ( isNaN( m_fTickTime ) )
            return;

        m_fTickTime += delta;
        if ( !m_boStarted ) {
            beginTeleport();
        }

        if ( !m_boTeleported && m_boStarted
                && m_fTickTime >= startDurationTime ) {
            doTeleport();
        }

//        if ( m_boTeleported && !isNaN( m_fStopTime ) ) {
//            m_fStopTime -= delta;
//            if ( m_fStopTime <= 0 ) {
//                m_fStopTime = NaN;
//                endTeleport();
//            }
//        }

    }


    public function lastUpdate( delta : Number ) : void {
        if ( m_boTeleported && !isNaN( m_fStopTime ) ) {
            m_fStopTime -= delta;
            if ( m_fStopTime <= 0 ) {
                m_fStopTime = NaN;
                endTeleport();
            }
        }
        if ( m_boStarted && !m_boEnd )
            endTeleport();
    }

    private function beginTeleport() : void {
        m_boStarted = true;
        if ( fxMediator ) {
            fxMediator.playComhitEffects( m_pTeleportData.BeginFX );
        }
        //fixme doSomething
    }

    final private function get startDurationTime() : Number {
        return m_pTeleportData.BeforeStopTime * CSkillDataBase.TIME_IN_ONEFRAME;
    }

    final private function get stopDurationTime() : Number {
        return m_pTeleportData.BeforeStopTime * CSkillDataBase.TIME_IN_ONEFRAME;
    }

    private function doTeleport() : void {
        m_boTeleported = true;
        _teleportToPosition();
        _begineEndTeleport();
    }

    private function _teleportToPosition() : void {
        if ( m_pTeleportData.TeleportType == ETeleportType.MODE_SELF ||
                m_pTeleportData.TeleportType == ETeleportType.MODE_CRITERIA ||
                m_pTeleportData.TeleportType == ETeleportType.MODE_GOAL ) {

            if ( m_pTarget ) {
                var targetTransform : CKOFTransform = m_pTarget.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
                var dir : Point;
                var pStateBoard : CCharacterStateBoard = m_pTarget.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
                if ( pStateBoard ) {
                    dir = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
                }
                _relocate3D( targetTransform.position, dir );
            } else {
                CSkillDebugLog.logTraceMsg( "Can not find teleport Target " );
            }
        } else if ( m_pTeleportData.TeleportType == ETeleportType.MODE_POSITION ) {
            if ( m_pDestination )
                _relocate2D( m_pDestination );
        } else {
            CSkillDebugLog.logTraceMsg( " undefine teleport type :" + m_pTeleportData.TeleportType )
        }
    }

    private function _relocate2D( targetPos : CVector2, dir : Point = null ) : void {
        if ( pModelDisplay ) {
            if ( dir )
                targetPos.addOnValueXY( m_pTeleportData.TeleportX * dir.x, m_pTeleportData.TeleportY );
            else
                targetPos.addOnValueXY( m_pTeleportData.TeleportX, m_pTeleportData.TeleportY );
            pModelDisplay.setPositionToFrom2D( targetPos.x, targetPos.y < 0 ? 0 : targetPos.y ,0.0,0.0, true,true,true );
        }
    }

    private function _relocate3D( targetPos : CVector3, dir : Point = null ) : Boolean {
        var pTransform : CKOFTransform = m_pOwner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
        var randomPos : CVector3 = _getRandomPosition();
        var bMoveSucceed : Boolean;
        if ( pTransform ) {
            bMoveSucceed = _moveToPerDir( targetPos, dir, randomPos );
            if ( !bMoveSucceed ) {
                //如果到版边则取相反方向位移
                if ( dir )
                    bMoveSucceed = _moveToPerDir( targetPos, new Point( -dir.x, dir.y ), randomPos );
            }
        }

        return bMoveSucceed;
    }

    private function _moveToPerDir( targetPos : CVector3, dir : Point = null, randomPos : CVector3 = null ) : Boolean {
        var pTransform : CKOFTransform = m_pOwner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
        var fDir : Number;
        fDir = dir == null ? 1.0 : dir.x;
        var yAxis : Number = targetPos.z + m_pTeleportData.TeleportY + randomPos.y;
        yAxis = yAxis<0?0:yAxis;
        return pTransform.moveTo( (m_pTeleportData.TeleportX + randomPos.x) * fDir + targetPos.x,
                yAxis
                , targetPos.y + m_pTeleportData.TeleportZ + randomPos.z, true, false );
    }

    private function _getRandomPosition() : CVector3 {
        var pos : CVector3 = new CVector3( m_pTeleportData.RandomX * Math.random(),
                m_pTeleportData.RandomY * Math.random(),
                m_pTeleportData.RandomZ * Math.random() );

        return pos;
    }

    private function _begineEndTeleport() : void {
        m_boEnd = true;
        if ( fxMediator ) {
            fxMediator.playComhitEffects( m_pTeleportData.EndFX );
        }

        m_fStopTime = stopDurationTime;
    }

    private function endTeleport() : void {
        //fixme do something
        m_fTickTime = NaN;
        var pEventMediator : CEventMediator = m_pOwner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new Event( CCharacterEvent.STOP_MOVE, false, false ) );
        }

        if ( m_pTeleportEndCallBack )
            m_pTeleportEndCallBack.apply();
    }

    final private function get pTransform() : CKOFTransform {
        return m_pOwner.getComponentByClass( CKOFTransform, true ) as CKOFTransform;
    }

    final private function get pModelDisplay() : CCharacter {
        var pAnimation : IAnimation;
        pAnimation = m_pOwner.getComponentByClass( IAnimation, true ) as IAnimation;
        if ( pAnimation ) {
            return pAnimation.modelDisplay;
        }
        return null;
    }

    final private function get fxMediator() : CFXMediator {
        return m_pOwner.getComponentByClass( CFXMediator, true ) as CFXMediator;
    }

    private var m_pOwner : CGameObject;
    private var m_fTickTime : Number;
    private var m_fStopTime : Number;
    private var m_boStarted : Boolean;
    private var m_boTeleported : Boolean;
    private var m_boEnd : Boolean;
    private var m_pTeleportData : Teleport;
    private var m_pDestination : CVector2;
    private var m_pTarget : CGameObject;
    private var m_pTeleportEndCallBack : Function;
}
}
