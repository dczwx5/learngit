//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/11.
 */
package kof.game.weiClient {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;

import morn.core.handlers.Handler;

public class CWeiClientSystem extends CBundleSystem {
    private var m_bInitialized : Boolean;
    public function CWeiClientSystem( ) {
        super(  );
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.WEI_CLIENT );
    }

    public override function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CWeiClientViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            pView = new CWeiClientViewHandler();
            this.addBean( pView );
            this.addBean( new CWeiClientManager() );
            this.addBean( new CWeiClientHandler() );
        }

        pView = pView || this.getHandler( CWeiClientViewHandler ) as CWeiClientViewHandler;
        pView.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    private function _onViewClosed() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.setUserData( this, "activated", false );
        }
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CWeiClientViewHandler = this.getHandler( CWeiClientViewHandler ) as CWeiClientViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CWeiClientViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    public function closeWeiClientSystem() : void
    {
        if( ctx )
        {
            ctx.unregisterSystemBundle(this);
        }
    }
}
}
