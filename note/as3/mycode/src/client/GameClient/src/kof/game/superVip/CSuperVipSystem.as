//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/12/1.
 */
package kof.game.superVip {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.subData.CSubPlatformData;
import kof.table.SuperVipConfig;

import morn.core.handlers.Handler;

public class CSuperVipSystem extends CBundleSystem implements ISystemBundle {
    private var m_bInitialized : Boolean;
    private var _manager : CSuperVipManager;
    public function CSuperVipSystem(  ) {
        super(  );
    }
    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.SUPER_VIP );
    }

    public override function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {
        if ( !super.initialize() )
            return false;

        var pView : CSuperVipViewHandler;
        if ( !m_bInitialized ) {
            m_bInitialized = true;

            pView = new CSuperVipViewHandler();
            this.addBean( pView );
        }
        m_bInitialized = m_bInitialized && addBean( _manager = new CSuperVipManager() );
        pView = pView || this.getHandler( CSuperVipViewHandler ) as CSuperVipViewHandler;
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

        var pView : CSuperVipViewHandler = this.getHandler( CSuperVipViewHandler ) as CSuperVipViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CPracticeViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        var platformData:CPlatformBaseData = (stage.getSystem(CPlayerSystem) as CPlayerSystem).platform.data;
        if(platformData)
        {
            _manager.plat = platformData.platform;
            _manager.serveID = platformData.platformServerID;
            var config : SuperVipConfig = _manager.getConfigByPlatform();
            if(!config)
            {
                ctx.stopBundle(this);
                return;
            }
        }
        super.onBundleStart( pCtx );
//        if(platformData && platformData.platform != EPlatformType.PLATFORM_YAO_DOU){
//            ctx.stopBundle(this);
//            return;
//        }
    }
}
}
