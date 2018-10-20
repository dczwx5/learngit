//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/2/15.
 */
package kof.game.mail {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.systemnotice.CSystemNoticeConst;
import kof.game.systemnotice.CSystemNoticeSystem;

import morn.core.handlers.Handler;

public class CMailSystem extends CBundleSystem {

    private var m_bInitialized : Boolean;

    private var _pCMailManager : CMailManager;
    private var _pCMailHandler : CMailHandler;
    private var _pCMailViewHandler : CMailViewHandler;

    public function CMailSystem() {
        super();
    }
    override public function dispose() : void {
        super.dispose();

        _pCMailManager.dispose();
        _pCMailHandler.dispose();
        _pCMailViewHandler.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        if ( !m_bInitialized ) {
            m_bInitialized = true;

            this.addBean( _pCMailManager = new CMailManager() );
            this.addBean( _pCMailHandler = new CMailHandler() );
            this.addBean( _pCMailViewHandler = new CMailViewHandler() );

        }

        _pCMailViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.MAIL );
    }


    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CMailViewHandler = this.getHandler( CMailViewHandler ) as CMailViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value ) {

            pView.addDisplay();
            _pSystemNoticeSystem.hideIcon( CSystemNoticeConst.SYSTEM_MAIL );
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void {
        this.setActivated( false );
    }

    private function get _pSystemNoticeSystem():CSystemNoticeSystem{
        return stage.getSystem( CSystemNoticeSystem ) as CSystemNoticeSystem
    }

}
}
