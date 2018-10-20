//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.triggers {

import QFLib.Foundation;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import kof.framework.CAppSystem;
import kof.game.switching.ISwitchingTrigger;

/**
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAbstractSwitchingTrigger extends EventDispatcher implements ISwitchingTrigger {

    /** @private */
    public var m_pSystemRef : CAppSystem;
    private var m_pBridge : CSwitchingTriggerBridge;

    /** Creates a new CAbstractSwitchingTrigger. */
    public function CAbstractSwitchingTrigger() {
        super();
    }

    public function dispose() : void {
        m_pSystemRef = null;
        m_pBridge = null;
    }

    public function initialize() : Boolean {
        return true;
    }

    protected function get notifier() : IEventDispatcher {
        return m_pBridge || this;
    }

    public function bridgeAttached( pBridge : CSwitchingTriggerBridge ) : void {
        if ( m_pBridge == pBridge )
            return;
        this.m_pBridge = pBridge;
        this.initialize();
    }

    public function bridgeDetached( pBridge : CSwitchingTriggerBridge ) : void {
        if ( m_pBridge == pBridge ) {
            m_pBridge = null;
        } else {
            Foundation.Log.logWarningMsg( "Detached from a diff bridge!!!" );
        }
    }

}
}

// vim:ft=as3 tw=120 ts=4 sw=4 expandtab
