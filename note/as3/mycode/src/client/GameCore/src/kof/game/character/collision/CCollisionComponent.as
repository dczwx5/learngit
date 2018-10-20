//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/3/16.
//----------------------------------------------------------------------
package kof.game.character.collision {

import QFLib.Collision.CCharacterCollisionBound;
import QFLib.Collision.CCollisionBound;
import QFLib.Collision.CCollisionPairInfo;
import QFLib.Collision.common.ICollision;
import QFLib.Foundation.CMap;
import QFLib.Foundation.free;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CObject;
import QFLib.Framework.CharacterExtData.CCharacterCollisionKey;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CAABBox3;
import QFLib.Math.CMath;
import QFLib.Math.CVector3;

import flash.events.Event;
import flash.geom.Point;

import kof.game.character.CCharacterEvent;

import kof.game.character.CEventMediator;

import kof.game.character.animation.IAnimation;
import kof.game.character.collision.ICollisable;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSkillDebugLog;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateBoard;

import kof.game.core.CGameComponent;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;

public class CCollisionComponent extends CGameComponent implements IUpdatable {
    public function CCollisionComponent() {

    }

    public function update( delta : Number ) : void {

    }

    public function collisionsFadeOut( delta : Number ) : void {
        pCollisable.collision.updateRemoval( delta );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function set enabled( value : Boolean ) : void {
        super.enabled = value;
        pCollisable.collision.enable = value;
    }

    override protected function onEnter() : void {
        super.onEnter();
        var pEventMediator : CEventMediator = getComponent( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onReady );
            pEventMediator.addEventListener( CCharacterEvent.COLLISION_READY, _onReady );

        }
        var pAnimation : IAnimation = getComponent( IAnimation, true ) as IAnimation;
        pAnimation.setEnableCollision( true );
        pCollisable.collisionOwnerData = owner;

    }

    override protected function onExit() : void {
        super.onExit();

        var pEventMediator : CEventMediator = getComponent( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.DISPLAY_READY, _onReady );
            pEventMediator.removeEventListener( CCharacterEvent.COLLISION_READY, _onReady );

        }
    }

    public function getCollisionBoundByHitEvent( hitEvent : String ) : CCharacterCollisionBound {
        for each ( var bound : CCharacterCollisionBound in collisionBounds ) {
            if ( bound.hitEvent == hitEvent )
                return bound;
        }
        return null;
    }

    /**
     * 获取碰撞框
     * @param hitEvent
     * @param owner
     * @return
     */
    public function getHurtBoundByTarget( hitEvent : String, owner : CGameObject ) : CAABBox3 {
        var pairInfo : CCollisionPairInfo;
        for each( var bound : CCharacterCollisionBound in collisionBounds ) {
            if ( bound.hitEvent == hitEvent ) {
                pairInfo = bound.characterCollision.getPairsInfo( owner );
                break;
            }
        }

        if ( pairInfo )
            return pairInfo.collisionBox;

        return null;
    }

    /**
     * the target
     * @param hitEvent
     * @return
     */
    public function getTargetByHitEvent( hitEvent : String ) : Array {
        var targets : Array = [] ;
        var targetBounds : Array = [];
        for each( var bound : CCharacterCollisionBound in collisionBounds ) {
            if ( bound.hitEvent == hitEvent )
                targetBounds.push( bound );
        }

        if ( targetBounds.length == 0 )
            return null;

        for each( var targetBound : CCharacterCollisionBound in targetBounds ) {
            var touchTarget : Array = targetBound.characterCollision.getCollidedData();
            for each( var key : * in touchTarget ) {
                var idx : int = targets.indexOf( key );
                if ( idx < 0 )
                    targets.push( key );
            }
        }

        if( targets.length ==  0 )
                return null;
        return targets;
    }

    public function clearAtkBounds() : void {
        if ( collisionBounds == null )
            return;

        var bound : CCharacterCollisionBound;
        var boundList : Array = collisionBounds.slice();
        for ( var boundIndex : int = 0; boundIndex < boundList.length; boundIndex++ ) {
            var idx : int = collisionBounds.indexOf( boundList[ boundIndex ] );
            if ( idx < 0 )
                return;
            bound = collisionBounds[ idx ];
            if ( bound.characterCollision.Type == CCollisionBound.TYPE_ATTACK )
                pCollisable.collision.destroyCollisionBound( bound );
        }
    }

    /**
     * collided area
     * @param hitEvent
     * @param owner
     * @return
     */
    public function getCollisedArea( hitEvent : String, owner : CGameObject ) : CAABBox3 {
        var pairInfo : CCollisionPairInfo;
        for each( var bound : CCharacterCollisionBound in collisionBounds ) {
            if ( bound.hitEvent == hitEvent ) {
                pairInfo = bound.characterCollision.getPairsInfo( owner );
                if( pairInfo != null )
                    break;
            }
        }

        if ( pairInfo )
            return pairInfo.collidedArea;

        return null;

    }

    public function getAttackArea( hitEvent : String, target : CGameObject ) : CAABBox3 {
        var pairInfo : CCollisionPairInfo;
        for each( var bound : CCharacterCollisionBound in collisionBounds ) {
            if ( bound.hitEvent == hitEvent ) {
                pairInfo = bound.characterCollision.getPairsInfo( target );
                if ( pairInfo != null )
                    break;
            }
        }

        if ( pairInfo )
            return pairInfo.attackerBox;

        return null;
    }

    /**
     * 获取默认的阻挡碰撞框 , 以IDLE动作的碰撞框为准
     * @param pCollidedArear
     * @return
     */
    public function getBlockAABB() : CAABBox3 {
        return pCollisable.collision.getRealTimeBlockAABB();
    }

    public function getHitPosition( pCollidedArear : CAABBox3 ) : CVector3 {
        var fZ : Number = NaN;
        var pCollidedCenter : CVector3 = pCollidedArear.center;
        var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( pDisplay ) {
            fZ = pDisplay.modelDisplay.position.z;
        }
        var fX : Number = pCollidedCenter.x;
        var fY : Number = pCollidedCenter.z;
        //var fY : Number = pCollidedCenter.z + pCollidedCenter.z * CObject.TAN_THETA_OF_CAMERA;
        return new CVector3( fX, fY, fZ );
    }

    /**
     * 计算目标碰撞框位移衰减值
     */

    public function getDecreseRadio( hitEvent : String, target : CGameObject ) : Number {
        var fDecreaseRadio : Number;
        var fDir : Point;
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( !hitEvent || hitEvent.length == 0 )
            return 0.0;

        fDir = pStateBoard.getValue( CCharacterStateBoard.DIRECTION ) as Point;

        var tTransform : ITransform = target.getComponentByClass( ITransform, true ) as ITransform;
        var targetCAABB3 : CAABBox3 = getAttackArea( hitEvent, target );//getCollisionBoundByHitEvent( hitEvent ).characterCollision.testAABBBox;
        if ( targetCAABB3 ) {
            var coliseArea : CAABBox3 = getCollisedArea( hitEvent, target );
            var collisionX : Number = tTransform.position.x;
            if ( coliseArea != null )
                collisionX = coliseArea.center.x;

            var fXLenCAABB3 : Number = targetCAABB3.extX * 2;
            var fXDistanceToLeft : Number = collisionX - ( targetCAABB3.center.x - targetCAABB3.extX * fDir.x );
            fDecreaseRadio = CMath.abs( fXDistanceToLeft / fXLenCAABB3 );
        }

        return fDecreaseRadio;
    }

    public function set collisionSpeed( speed : Number ) : void {
        this.pCollisable.collision.collisionSpeed = speed;
    }

    public function resumeCollisionSpeed() : void {
        this.pCollisable.collision.collisionSpeed = 1.0;
    }

    final private function get pCollisable() : ICollisable {
        return owner.getComponentByClass( ICollisable, true ) as ICollisable
    }

    final private function get collisionBounds() : Array {
        return pCollisable.collision.collisionBounds;
    }

    private function _onReady( e : Event ) : void {
        if ( e.type == CCharacterEvent.DISPLAY_READY )
            m_bDisplsyReady = true;
        if ( e.type == CCharacterEvent.COLLISION_READY )
            m_bColReady = true;
    }

    public function get isReady() : Boolean {
        return m_bDisplsyReady && m_bColReady;
    }

    protected var m_bColReady : Boolean;
    protected var m_bDisplsyReady : Boolean;
    public static const UNITY_TO_FLASH : CVector3 = new CVector3( 1.0, 1.0, 1.0 );
}
}
