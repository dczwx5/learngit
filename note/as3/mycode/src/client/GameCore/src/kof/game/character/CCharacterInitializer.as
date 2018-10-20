//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import flash.events.Event;

import kof.framework.events.CEventPriority;

import kof.game.character.display.IDisplay;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.level.CLevelMediator;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.scripts.appear.CFallAppearAction;
import kof.game.core.CSubscribeBehaviour;
import kof.game.scene.CSceneEvent;
import kof.util.CAssertUtils;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterInitializer extends CSubscribeBehaviour {

    public var m_bInitialized : Boolean;
    private var m_bMoveToAvailablePosition : Boolean;

    public function CCharacterInitializer() {
        super();
        m_bMoveToAvailablePosition = true;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        // Set the position by spawn.

        var x : Number = Number( owner.data.x );
        var y : Number = Number( owner.data.y );
        var fHeight : Number = Number( owner.data.z );

        CAssertUtils.assertFalse( isNaN( x ) || isNaN( y ) );

        var pTransform : CKOFTransform = this.transform as CKOFTransform;
        CAssertUtils.assertNotNull( pTransform, "CKOFTransform required." );

        pTransform.from2DAxis( x, y, isNaN( fHeight ) ? 0 : fHeight, moveToAvailablePosition );

        this.alignAnimationTimeline();
        this.configureNetworking();

        if ( !this.m_bInitialized ) {
            this.m_bInitialized = true;

            var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
            if ( pEventMediator ) {
                pEventMediator.dispatchEvent( new Event( CCharacterEvent.INIT, false, false ) );
            }
        }
    }

    override protected virtual function onExit() : void {
        super.onExit();

        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.dispatchEvent( new Event( CCharacterEvent.READY, false, false ) );
        }

        _onCharacterReady();
    }

    private function _onCharacterReady() : void {
        var pSceneFacade : CSceneMediator = getComponent( CSceneMediator ) as CSceneMediator;
        if ( pSceneFacade ) {
            pSceneFacade.sendEvent( new CSceneEvent( CSceneEvent.CHARACTER_READY, owner ) );
        }
    }

    public function get moveToAvailablePosition() : Boolean {
        return m_bMoveToAvailablePosition;
    }

    public function set moveToAvailablePosition( value : Boolean ) : void {
        m_bMoveToAvailablePosition = value;
    }

    private function alignAnimationTimeline() : void {
        var display : IDisplay = getComponent( IDisplay ) as IDisplay;
        if ( display ) {
//            display.modelDisplay.alignToFramePerSec = 30.0;
//            display.modelDisplay.alignToFramePerSec = 24.0;
//            display.modelDisplay.alignToFramePerSec = 12.0;
        }
    }

    protected virtual function get isDone() : Boolean {
        return m_bInitialized;
    }

    override public virtual function update( delta : Number ) : void {
        super.update( delta );

        if ( isDone ) {
            owner.removeComponent( this, true );
        }
    }

    protected function get asHost() : Boolean {
        return false;
    }

    private function configureNetworking() : void {
        var bAsHost : Boolean = this.asHost;
        var pNetworkMediator : CNetworkMessageMediator = getComponent( CNetworkMessageMediator ) as CNetworkMessageMediator;
        if ( pNetworkMediator ) {
            pNetworkMediator.asHost = bAsHost;
        }

        var pNetworkInput : CCharacterNetworkInput = getComponent( CCharacterNetworkInput ) as CCharacterNetworkInput;
        if ( pNetworkInput ) {
            pNetworkInput.isAsHost = bAsHost;
        }
    }

}
}
