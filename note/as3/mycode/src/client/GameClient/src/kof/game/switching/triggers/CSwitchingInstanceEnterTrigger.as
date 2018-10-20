//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.triggers {

import flash.events.Event;

import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;
import kof.game.switching.ISwitchingTrigger;
import kof.util.CAssertUtils;

/**
 * 功能开启 - 进入副本触发器
 *     NOTE: 装饰所有需要区分主城和副本（特定副本等）的触发器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingInstanceEnterTrigger extends CAbstractSwitchingTrigger {

    /** @private */
    private var m_pDelegate : ISwitchingTrigger;

    /** @private */
    private var m_bIsMainCity : Boolean;
    /** @private */
    private var m_bFirstEnter : Boolean;

    /** @private */
    private var m_nTriggerCnt : uint;

    /** @private */
    private var m_nMainCityEnteredCnt : uint;

    /** Creates a new CSwitchingInstanceEnterTrigger */
    public function CSwitchingInstanceEnterTrigger() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        m_pSystemRef = null;
    }

    public function initWith( delegate : ISwitchingTrigger, aSystem : CAppSystem ) : Boolean {
        if ( !delegate || !aSystem )
            return false;

        var pInstanceSys : IInstanceFacade = aSystem.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( !pInstanceSys || !pInstanceSys.eventDelegate )
            return false;

        m_pSystemRef = aSystem;

        pInstanceSys.eventDelegate.addEventListener( CInstanceEvent.ENTER_INSTANCE, _instanceSys_enterInstanceEventHandler,
                false, CEventPriority.DEFAULT, true );

        if ( m_pDelegate == delegate )
            return true;

        if ( m_pDelegate ) {
            // destructs the previous.
            m_pDelegate.removeEventListener( CSwitchingTriggerBridge.EVENT_TRIGGERED, _delegate_triggeredEventHandler );
        }

        m_pDelegate = delegate;

        m_pDelegate.addEventListener( CSwitchingTriggerBridge.EVENT_TRIGGERED, _delegate_triggeredEventHandler, false,
                CEventPriority.DEFAULT, true );

        return Boolean( m_pDelegate );
    }

    public function get isMainCity() : Boolean {
        return m_bIsMainCity;
    }

    /** @private */
    private function _instanceSys_enterInstanceEventHandler( event : Event ) : void {
        var pInstanceSys : IInstanceFacade = m_pSystemRef.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        CAssertUtils.assertNotNull( pInstanceSys );

        var bPreamble : Boolean = pInstanceSys.currentIsPrelude;

        if ( !bPreamble ) {
            m_bFirstEnter = m_bFirstEnter || true;
        }

        m_bIsMainCity = pInstanceSys.isMainCity;
        if ( m_bIsMainCity )
            m_nMainCityEnteredCnt++;

        m_pSystemRef.stage.callLater( _notifyTriggered, [ m_nMainCityEnteredCnt == 1 ] );
    }

    /** @private */
    private function _delegate_triggeredEventHandler( event : CSwitchingTriggerEvent ) : void {
        m_nTriggerCnt++;

        if ( !m_bFirstEnter )
            return;

        m_pSystemRef.stage.callLater( _notifyTriggered, [ event.isInitPhase ] );
    }

    private function _notifyTriggered( bIsInit : Boolean = false ) : void {
        m_nTriggerCnt = 0;

        var vEvent : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        vEvent.isInitPhase = bIsInit;
        dispatchEvent( vEvent );
    }

}
}

// vim:ft=as3 tw=120 sw=4 ts=4 expandtab
