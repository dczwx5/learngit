//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/3.
 */
package kof.game.recharge.firstRecharge
{

import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.instance.CInstanceSystem;

import morn.core.handlers.Handler;

public class CFirstRechargeSystem extends CBundleSystem
{
    public function CFirstRechargeSystem()
    {
        super();
    }

    private var m_bInitialized : Boolean;

    private var m_pViewHandler:CFirstRechargeViewHandler;
    private var m_pNetHandler:CFirstRechargeNetHandler;
    private var m_pManager:CFirstRechargeManager;
    private var m_pTipsHandler : CTipsViewHandler;

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pViewHandler = new CFirstRechargeViewHandler();
            this.addBean( m_pViewHandler );

            m_pNetHandler = new CFirstRechargeNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new CFirstRechargeManager();
            this.addBean( m_pManager );

            m_pTipsHandler = new CTipsViewHandler();
            this.addBean( m_pTipsHandler );
        }

        m_pViewHandler = m_pViewHandler || this.getHandler( CFirstRechargeViewHandler ) as CFirstRechargeViewHandler;
        m_pViewHandler.closeHandler = new Handler( _onViewClosed );

        m_pTipsHandler = m_pTipsHandler || this.getHandler( CTipsViewHandler ) as CTipsViewHandler;
        m_pTipsHandler.closeHandler = new Handler( _onViewClosed );

        var pSystemBundleContext : ISystemBundleContext = stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        var pSystemBundle : ISystemBundle = pSystemBundleContext.getSystemBundle( bundleID );
        if ( pSystemBundleContext && pSystemBundle)
        {
            pSystemBundleContext.setUserData(this,CBundleSystem.NOTIFICATION, true);


            var tips : CTipsViewHandler = this.getHandler( CTipsViewHandler ) as CTipsViewHandler;
            var handler : Handler = new Handler( tips.show );
            pSystemBundleContext.setUserData( this, "tip_handler", handler );
//            pSystemBundleContext.setUserData(this,CBundleSystem.TIME_COUNTDOWN, "123456");
        }

//        var tipView : CTipsViewHandler = this.getHandler( CTipsViewHandler ) as CTipsViewHandler;
//        if ( !tipView )
//        {
//            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
//            return false;
//        }
//
//        if ( tipView )
//        {
//            tipView.addDisplay();
//        }
//        else
//        {
//            tipView.removeDisplay();
//        }
        return m_bInitialized;
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    public function setActivity(isActivity : Boolean) : void
    {
        this.setActivated(isActivity);
    }


    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        super.onBundleStart( pCtx );
        var instanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if(instanceSystem.isMainCity)
        {
            loadAsset();
        }
        else
        {
            instanceSystem.callWhenInMainCity(loadAsset, null, null, null, 2);
        }

        pCtx.setUserData(this, CBundleSystem.GLOW_EFFECT, true);

        if(_activityManager)
            _activityManager.checkHavePreviewData();
    }
    private function loadAsset() : void
    {
        if ( m_pTipsHandler )
            m_pTipsHandler.loadAssetsByView( m_pTipsHandler.viewClass );
    }
    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : CFirstRechargeViewHandler = this.getHandler( CFirstRechargeViewHandler ) as CFirstRechargeViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }

        if ( value )
        {
            pView.addDisplay();
        }
        else
        {
            pView.removeDisplay();
        }
    }
    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.FIRST_RECHARGE );
    }

    override public function dispose() : void
    {
        super.dispose();

        m_pViewHandler.dispose();
        m_pViewHandler = null;

        m_pNetHandler.dispose();
        m_pNetHandler = null;

        m_pManager.dispose();
        m_pManager = null;

        m_pTipsHandler.dispose();
        m_pTipsHandler = null;
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
}
}
