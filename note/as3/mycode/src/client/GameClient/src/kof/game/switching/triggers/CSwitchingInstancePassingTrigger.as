//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.triggers {

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;
import kof.game.switching.ISwitchingTrigger;
import kof.util.CAssertUtils;

/**
 * 副本通关触发器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingInstancePassingTrigger extends CAbstractSwitchingTrigger implements ISwitchingTrigger {

    /** Creates a new CSwitchingInstancePassingTrigger */
    public function CSwitchingInstancePassingTrigger() {
        super();
    }

    override public function dispose() : void {
        if ( m_pSystemRef ) {
            var pInstanceSys : IInstanceFacade = m_pSystemRef.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
            if ( pInstanceSys && pInstanceSys.eventDelegate )
                pInstanceSys.eventDelegate.removeEventListener( CInstanceEvent.INSTANCE_MODIFY,
                        _instanceSys_instanceFirstPassEventHandler );
            pInstanceSys.eventDelegate.removeEventListener( CInstanceEvent.INSTANCE_DATA,
                    _instanceSys_instanceFirstPassEventHandler );
        }

        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( super.initialize() ) {
            CAssertUtils.assertNotNull( m_pSystemRef, "CAppSystem required." );

            var pInstanceSys : IInstanceFacade = m_pSystemRef.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
            if ( !pInstanceSys || !pInstanceSys.eventDelegate ) {
                return false;
            }

            pInstanceSys.eventDelegate.addEventListener( CInstanceEvent.INSTANCE_FIRST_PASS,
                    _instanceSys_instanceFirstPassEventHandler, false, CEventPriority.DEFAULT, true );
            pInstanceSys.eventDelegate.addEventListener( CInstanceEvent.INSTANCE_DATA_INITIAL,
                    _instanceSys_instanceDataEventHandler, false, CEventPriority.DEFAULT, true );

            return true;
        }
        return false;
    }

    private function _instanceSys_instanceDataEventHandler( event : Event ) : void {
        event.currentTarget.removeEventListener( event.type, _instanceSys_instanceDataEventHandler );

        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        evt.isInitPhase = true;
        notifier.dispatchEvent( evt );
    }

    final private function _instanceSys_instanceFirstPassEventHandler( event : Event ) : void {
        var evt : CSwitchingTriggerEvent = new CSwitchingTriggerEvent( CSwitchingTriggerBridge.EVENT_TRIGGERED );
        notifier.dispatchEvent( evt );
    }

}
}

// vim:ft=as3 sw=4 ts=4 tw=120 expandtab
