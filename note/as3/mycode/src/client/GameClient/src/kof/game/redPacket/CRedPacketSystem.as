//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Demi.Liu on 2018-06-01.
 */
package kof.game.redPacket {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;

import morn.core.handlers.Handler;

/**
 *@author Demi.Liu
 *@data 2018-06-01
 */
public class CRedPacketSystem extends CBundleSystem {
    private var m_bInitialized : Boolean;

    private var _pRedPacketManager : CRedPacketManager;

    private var _pRedPacketHandler : CRedPacketHandler;

    private var _pRedPacketViewHandler : CRedPacketViewHandler;

    public function CRedPacketSystem( A_objBundleID : * = null ) {
        super( A_objBundleID );
    }

    override public function dispose() : void {
        super.dispose();
        _pRedPacketManager = null;
        _pRedPacketHandler = null;
        _pRedPacketViewHandler = null;
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pRedPacketManager = new CRedPacketManager() );
            this.addBean( _pRedPacketHandler = new CRedPacketHandler() );
            this.addBean( _pRedPacketViewHandler = new CRedPacketViewHandler() );
        }

        _pRedPacketViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CRedPacketViewHandler = this.getHandler( CRedPacketViewHandler ) as CRedPacketViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRedPacketViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.RED_PACKET );
    }
}
}
