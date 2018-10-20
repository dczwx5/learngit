//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.triggers {

import kof.framework.CAbstractHandler;
import kof.game.switching.ISwitchingTrigger;

[Event(name="event_triggered", type="flash.events.Event")]
/**
 * 系统功能开启触发器控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingTriggerBridge extends CAbstractHandler implements ISwitchingTrigger {

    public static const EVENT_TRIGGERED : String = "event_triggered";

    /** @private */
    private var m_pTriggers : Vector.<ISwitchingTrigger>;

    /**
     * Creates a new CSwitchingTriggerBridge.
     */
    public function CSwitchingTriggerBridge() {
        super();
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();

        if ( m_pTriggers && m_pTriggers.length ) {
            for each ( var vTrigger : ISwitchingTrigger in m_pTriggers ) {
                removeTrigger( vTrigger );
            }

            m_pTriggers.splice( 0, m_pTriggers.length );
        }

        m_pTriggers = null;
    }

    /** @inheritDoc */
    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.initialize();
        return ret;
    }

    protected function initialize() : Boolean {
        if ( !m_pTriggers ) {
            m_pTriggers = new <ISwitchingTrigger>[];
        }
        return Boolean( m_pTriggers );
    }

    /** @inheritDoc */
    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();

        return ret;
    }

    public function addTrigger( pTrigger : ISwitchingTrigger ) : void {
        if ( !pTrigger )
            return;

        if ( m_pTriggers.indexOf( pTrigger ) == -1 ) {
            m_pTriggers.push( pTrigger );

            if ( pTrigger is CAbstractSwitchingTrigger ) {
                CAbstractSwitchingTrigger( pTrigger ).m_pSystemRef = system;
            }

            pTrigger.bridgeAttached( this );
        }
    }

    public function removeTrigger( pTrigger : ISwitchingTrigger ) : void {
        if ( !pTrigger )
            return;

        var idx : int = m_pTriggers.indexOf( pTrigger );
        if ( idx != -1 )
            m_pTriggers.splice( idx, 1 );

        pTrigger.bridgeDetached( this );
    }

    public function bridgeAttached( cSwitchingTriggerBridge : CSwitchingTriggerBridge ) : void {
        // NOOP.
    }

    public function bridgeDetached( cSwitchingTriggerBridge : CSwitchingTriggerBridge ) : void {
        // NOOP.
    }

}
}

// vim:ft=as3 ts=4 sw=4 tw=120 expandtab
