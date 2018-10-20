//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Math.CVector2;

import flash.events.Event;
import flash.utils.Dictionary;

import kof.framework.events.CEventPriority;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.core.CGameObject;
import kof.game.core.CSubscribeBehaviour;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CTarget extends CSubscribeBehaviour {

    /** @private */
    private var m_pTargetRef : Dictionary;
    private var m_bTargetDirty : Boolean;

    /**
     * Creates a new CTarget.
     */
    public function CTarget() {
        super( "target" );
    }

    /** Returns the target object. */
    public final function get targetObject() : CGameObject {
        //noinspection LoopStatementThatDoesntLoopJS
        for ( var o : * in m_pTargetRef ) {
            return o as CGameObject;
        }
        return null;
    }

    /** Sets the targe object. */
    public final function set targetObject( value : CGameObject ) : void {
        var o : *;
        //noinspection LoopStatementThatDoesntLoopJS
        for ( o in m_pTargetRef ) {
            break;
        }

        if ( o == value )
            return;

        if ( o ) {
            this.detachTargetRemovedHandler( o );
            delete m_pTargetRef[ o ];
        }

        if ( value ) {
            m_pTargetRef[ value ] = true;
            this.attachTargetRemovedHandler( value );
        }

        m_bTargetDirty = true;
    }

    private function attachTargetRemovedHandler( obj : CGameObject ) : void {
        var pEventMediator : CEventMediator = obj.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator )
            pEventMediator.addEventListener( CCharacterEvent.REMOVED, _onTargetRemoved, false, CEventPriority.DEFAULT, true );
    }

    private function detachTargetRemovedHandler( obj : CGameObject ) : void {
        var pEventMediator : CEventMediator = obj.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( pEventMediator )
            pEventMediator.removeEventListener( CCharacterEvent.REMOVED, _onTargetRemoved );
    }

    private function _onTargetRemoved( event : Event ) : void {
        this.targetObject = null;
    }

    /** @inheritDoc */
    override protected virtual function onEnter() : void {
        if ( !m_pTargetRef ) {
            m_pTargetRef = new Dictionary( true ); // target object as WeakReference, must be.
        }
    }

    override protected virtual function onExit() : void {
        m_pTargetRef = null;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( m_bTargetDirty ) {
            m_bTargetDirty = false;

            var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
            if ( pEventMediator ) {
                pEventMediator.dispatchEvent( new Event( CCharacterEvent.TARGET_CHANGED ) );
            }
        }
    }

    public function setTargetObjects( targetList : Vector.<CGameObject> ) : void {
        // Comparing the target id instead of CGameObject reference.
        if ( !targetList || !targetList.length ) {
            this.targetObject = null;
            return;
        }

        var pCurrentTarget : CGameObject = this.targetObject;
        if ( !pCurrentTarget || targetList.indexOf( pCurrentTarget ) == -1 )
            pCurrentTarget = targetList[ 0 ];

        this.targetObject = pCurrentTarget;
    }

}
}
