//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Burgess on 2017/8/14.
 */
package kof.game.OneDiamondReward {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.activityHall.CActivityHallDataManager;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;

import morn.core.handlers.Handler;

public class COneDiamondSystem extends CBundleSystem{
    public function COneDiamondSystem()
    {
        super();
    }
    private var m_bInitialized : Boolean;
    private var m_pViewHandler:COneDiamondViewHandler;
    private var m_pNetHandler:COneDiamondNetHandler;
    private var m_pManager:COneDiamondManager;

    override public function initialize() : Boolean
    {
        if ( !super.initialize() )
        {
            return false;
        }

        if ( !m_bInitialized )
        {
            m_bInitialized = true;

            m_pViewHandler = new COneDiamondViewHandler();
            this.addBean( m_pViewHandler );

            m_pNetHandler = new COneDiamondNetHandler();
            this.addBean( m_pNetHandler );

            m_pManager = new COneDiamondManager();
            this.addBean( m_pManager );
        }

        m_pViewHandler = m_pViewHandler || this.getHandler( COneDiamondViewHandler ) as COneDiamondViewHandler;
        m_pViewHandler.closeHandler = new Handler( _onViewClosed );

        return m_bInitialized;
    }

    private function _onViewClosed() : void
    {
        this.setActivated( false );
    }

    override protected function onBundleStart( pCtx : ISystemBundleContext ) : void {
        super.onBundleStart( pCtx );

        this.setActivated( true );
    }

    override protected function onActivated( value : Boolean ) : void
    {
        super.onActivated( value );

        var pView : COneDiamondViewHandler = this.getHandler( COneDiamondViewHandler ) as COneDiamondViewHandler;
        if ( !pView )
        {
            LOG.logErrorMsg( "SystemBundle activated, but the CRankingViewHandler isn't instance." );
            return;
        }
        var pReciprocalSystem:CReciprocalSystem = (stage.getSystem( CReciprocalSystem ) as CReciprocalSystem);
        if ( value )
        {

            if(pReciprocalSystem){
                pReciprocalSystem.addEventPopWindow( EPopWindow.POP_WINDOW_16, function():void{
                    pView.addDisplay();
                    _activityManager.checkHavePreviewData();
                });
            }
        }
        else
        {
            if(pReciprocalSystem){
                pReciprocalSystem.removeEventPopWindow( EPopWindow.POP_WINDOW_16 );
            }
            pView.removeDisplay();
            if (m_pManager.m_nState == 2)
            {
                m_pManager.closeOneDiamondSystem();
            }
        }
    }
    override public function get bundleID() : *
    {
        return SYSTEM_ID( KOFSysTags.ONE_DIAMOND_REWARD );
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
    }
    private function get _activityManager() : CActivityHallDataManager
    {
        var _activitySystem : CActivityHallSystem = stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
        if(!_activitySystem) return null;
        return _activitySystem.getBean(CActivityHallDataManager) as CActivityHallDataManager;
    }
}
}
