//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/09/03.
 */
package kof.game.gemenRecharge {


import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.platform.EPlatformType;
import kof.game.platform.data.CPlatformBaseData;
import kof.game.player.CPlayerSystem;

import morn.core.handlers.Handler;

/**
 * 七天登录
 * */
public class CGemenRechargeSystem extends CBundleSystem implements ISystemBundle {

    private var m_bInitialized : Boolean;

    private var m_pViewHandler : CGemenRechargeViewHandler;
    private var m_pNetHandler : CGemenRechargeNetHandler;
    private var m_pManager : CGemenRechargeManager;
    public function CGemenRechargeSystem() {
        super();
    }

    override public function dispose() : void
    {
        super.dispose();
    }

    override public function initialize() : Boolean
    {
        if( !super.initialize() )
            return false;

        if( !m_bInitialized )
        {
            m_bInitialized = true;
            m_pViewHandler = new CGemenRechargeViewHandler();
            this.addBean( m_pViewHandler );
            m_pManager = new CGemenRechargeManager();
            this.addBean( m_pManager );
            m_pNetHandler = new CGemenRechargeNetHandler();
            this.addBean( m_pNetHandler );

        }

        m_pViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.GEMEN_RECHARGE );
    }

    /**
     * 系统开启
     * **/
    override protected function onBundleStart( ctx : ISystemBundleContext ) : void
    {
        super.onBundleStart( ctx );
        var platformData:CPlatformBaseData = (stage.getSystem(CPlayerSystem) as CPlayerSystem).platform.data;
        if(!platformData || platformData.platform != EPlatformType.PLATFORM_GEMEN)
        {
            App.log.debug("wx_qrcode start load: " + platformData?platformData.platform:"");
            ctx.stopBundle(this);
            return;
        }
        m_pManager.plat = platformData.platform;
        m_pManager.serveID = platformData.platformServerID;
        m_pManager.account = platformData.account;
        m_pNetHandler.urlGetWXCode();
        //_updateSevenDaysRedPoint( null );
    }


//    private function _updateSevenDaysRedPoint( e : CSevenDaysEvent ) : void
//    {
//        // 主界面图标提示
//        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
//        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( SYSTEM_ID( "SEVEN_DAYS" ) );
//        if ( pSystemBundleContext && pSystemBundle)
//        {
//            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION,m_pSevenDaysManager.canGetReward());
//        }
//    }

    override protected function onActivated( value : Boolean ) :void
    {
        super.onActivated( value );

        var pView : CGemenRechargeViewHandler = this.getHandler( CGemenRechargeViewHandler ) as CGemenRechargeViewHandler;
        if ( !pView ) {
            LOG.logErrorMsg( "SystemBundle activated, but the CGemenRechargeViewHandler isn't instance." );
            return;
        }

        if ( value ) {
            pView.addDisplay();
        } else {
            pView.removeDisplay();
        }
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }
}
}
