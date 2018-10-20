//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/8.
 */
package kof.game.collectionGame {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;

import morn.core.handlers.Handler;

public class CCollectionGameSystem extends CBundleSystem {
    private var m_bInitialized : Boolean;
    public function CCollectionGameSystem() {
    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.COLLECTION );
    }

    public override function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CCollectionGameViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            pView = new CCollectionGameViewHandler();
            this.addBean( pView );
            this.addBean( new CCollectionGameHandler() );
            this.addBean( new CCollectionGameManager() );
        }

        pView = pView || this.getHandler( CCollectionGameViewHandler ) as CCollectionGameViewHandler;
        pView.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override protected function onBundleStart(pCtx:ISystemBundleContext):void
    {
        super.onBundleStart(pCtx);

        pCtx.setUserData(this, CBundleSystem.GLOW_EFFECT, true);
        pCtx.setUserData(this, CBundleSystem.NOTIFICATION, true);
    }

    private function _onViewClosed() : void {
        var pSystemBundleCtx : ISystemBundleContext = stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            pSystemBundleCtx.setUserData( this, "activated", false );
        }
    }

    override protected function onActivated( value : Boolean ) : void {
        super.onActivated( value );

        var pView : CCollectionGameViewHandler = this.getHandler( CCollectionGameViewHandler ) as CCollectionGameViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CCollectionGameViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    public function closeCollectionGameSystem() : void
    {
        if( ctx )
        {
            ctx.unregisterSystemBundle(this);
        }
    }
}
}
